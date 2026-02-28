import 'dart:isolate';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overkeys/models/keyboard_layouts.dart';
import 'package:overkeys/providers/keyboard_provider.dart';
import 'package:overkeys/providers/app_state_provider.dart';
import 'package:overkeys/providers/preferences_provider.dart';
import 'package:overkeys/utils/key_code.dart';
import 'package:overkeys/utils/hooks.dart';
import 'package:overkeys/utils/logger.dart';

/// Service for handling keyboard events and user layer switching
class KeyEventService {
  /// Logger instance for this service
  final _log = SimplePrintLogger('KeyEventService');

  /// Active trigger keys for held layer switching
  final Set<String> _activeTriggers = {};

  /// Stores the stack of layers that were active before held layers were activated
  final List<KeyboardLayout> _previousLayerStack = [];

  /// ReceivePort for keyboard events
  ReceivePort? _receivePort;

  /// Sets up the keyboard event listener
  void setupKeyListener(ReceivePort Function() createReceivePort,
      Function(dynamic) handleKeyEvent) {
    _receivePort = createReceivePort();
    Isolate.spawn(setHook, _receivePort!.sendPort).then((_) {
      // Only attach listener after isolate spawn succeeds
      _receivePort!.listen(handleKeyEvent);
    }).catchError((error) {
      // Close the unused port before handling error
      _receivePort?.close();
      _receivePort = null;
      _log.error('Error spawning Isolate', error: error);
      throw error;
    });
  }

  /// Disposes of resources and closes the receive port
  void dispose() {
    _receivePort?.close();
    _receivePort = null;
    _activeTriggers.clear();
    _previousLayerStack.clear();
  }

  /// Handles keyboard events from the receive port
  void handleKeyEvent(
    dynamic message,
    WidgetRef ref,
    void Function() fadeIn,
    void Function() resetAutoHideTimer,
    void Function() cancelAutoHideTimer,
  ) {
    try {
      if (message is! List) return;

      final keyboardNotifier = ref.read(keyboardProvider.notifier);
      final appNotifier = ref.read(appStateProvider.notifier);
      final keyboardState = ref.read(keyboardProvider);
      final appState = ref.read(appStateProvider);
      final prefsState = ref.read(preferencesProvider);

      // Handle session unlock
      if (message[0] is String) {
        if (message[0] == 'session_unlock') {
          keyboardNotifier.clearKeyPressStates();
        }
        return;
      }

      if (message[0] is! int) return;

      final keyCode = message[0] as int;
      final isPressed = message[1] as bool;
      final isShiftDown = message[2] as bool;
      final key = getKeyFromKeyCodeShift(keyCode, isShiftDown);

      // Display "Space" in logs for better readability instead of blank
      final displayKey = key == ' ' ? 'Space' : key;
      _log.debug(
          'Key: ${displayKey.padRight(10)}\tKeyCode: ${keyCode.toString().padRight(5)}\tPressed: ${isPressed.toString().padRight(7)}\tShift: $isShiftDown');

      keyboardNotifier.updateKeyPressState(key, isPressed);

      // Check if key should be ignored - stop all processing if it is
      final ignoredKeys = prefsState.userConfig?.ignoredKeys;
      if (ignoredKeys != null && ignoredKeys.contains(key)) {
        _log.debug('Key "$key" is in ignored list, stopping key event flow');
        return;
      }

      // Handle custom aliases
      final updatedKeyboardState = ref.read(keyboardProvider);
      final customAliases = updatedKeyboardState.customAliases;

      if (customAliases != null) {
        customAliases.forEach((alias, keys) {
          bool allPressed = true;
          for (final k in keys) {
            bool keyIsPressed = false;
            if (k == 'Control') {
              keyIsPressed =
                  (updatedKeyboardState.keyPressStates['LControl'] == true) ||
                      (updatedKeyboardState.keyPressStates['RControl'] == true);
            } else if (k == 'Shift') {
              keyIsPressed =
                  (updatedKeyboardState.keyPressStates['LShift'] == true) ||
                      (updatedKeyboardState.keyPressStates['RShift'] == true);
            } else if (k == 'Alt') {
              keyIsPressed =
                  (updatedKeyboardState.keyPressStates['LAlt'] == true) ||
                      (updatedKeyboardState.keyPressStates['RAlt'] == true);
            } else if (k == 'Win') {
              keyIsPressed =
                  (updatedKeyboardState.keyPressStates['Win'] == true) ||
                      (updatedKeyboardState.keyPressStates['RWin'] == true);
            } else {
              keyIsPressed = updatedKeyboardState.keyPressStates[k] == true;
            }

            if (!keyIsPressed) {
              allPressed = false;
              break;
            }
          }
          keyboardNotifier.updateKeyPressState(alias, allPressed);
        });
      }

      // Handle auto-hide and visibility
      if (appState.forceHide) return;

      // Handle user layer switching
      if (prefsState.useUserLayout && prefsState.advancedSettingsEnabled) {
        _handleUserLayerSwitching(
            key,
            isPressed,
            ref,
            keyboardState,
            keyboardNotifier,
            appState,
            appNotifier,
            prefsState,
            fadeIn,
            cancelAutoHideTimer);
      }

      // Re-read keyboard state as it might have changed during layer switching
      final currentKeyboardState = ref.read(keyboardProvider);
      // Re-read app state as it might have changed during layer switching (e.g. visibility)
      final currentAppState = ref.read(appStateProvider);

      // Check if we're on the default layer
      final isOnDefaultLayer = _isOnDefaultLayer(
        currentKeyboardState,
        prefsState,
      );

      if (prefsState.autoHideEnabled) {
        if (!currentAppState.isWindowVisible && isPressed) {
          fadeIn();
          // If we just faded in, but we are NOT on the default layer, we should cancel the timer
          // because fadeIn() starts it by default.
          if (!isOnDefaultLayer) {
            cancelAutoHideTimer();
          }
        } else if (isOnDefaultLayer) {
          resetAutoHideTimer();
        } else if (isPressed) {
          cancelAutoHideTimer();
        }
      }
    } catch (error, stackTrace) {
      // Log the error but keep the listener alive
      _log.error('Error in handleKeyEvent',
          error: error, stackTrace: stackTrace);
      return;
    }
  }

  void _handleUserLayerSwitching(
    String key,
    bool isPressed,
    WidgetRef ref,
    KeyboardState keyboardState,
    KeyboardNotifier keyboardNotifier,
    AppState appState,
    AppStateNotifier appNotifier,
    PreferencesState prefsState,
    void Function() fadeIn,
    void Function() cancelAutoHideTimer,
  ) {
    final userLayers = prefsState.userLayers;
    final activeLayer = userLayers.where((l) => l.trigger == key);

    for (final layout in activeLayer) {
      if (layout.type == 'toggle' && isPressed) {
        _handleToggleLayer(
          layout,
          ref,
          keyboardNotifier,
          appNotifier,
          prefsState,
          fadeIn,
          cancelAutoHideTimer,
        );
      } else if (layout.type == 'held') {
        _handleHeldLayer(
          layout,
          key,
          ref,
          isPressed,
          keyboardNotifier,
          appNotifier,
          prefsState,
          fadeIn,
          cancelAutoHideTimer,
        );
      }
    }
  }

  void _handleToggleLayer(
    KeyboardLayout layout,
    WidgetRef ref,
    KeyboardNotifier keyboardNotifier,
    AppStateNotifier appNotifier,
    PreferencesState prefsState,
    void Function() fadeIn,
    void Function() cancelAutoHideTimer,
  ) {
    // Read the current keyboard state fresh to avoid stale data
    final currentLayout = ref.read(keyboardProvider).layout;

    // Check if we're currently NOT on this toggle layer
    if (currentLayout.name != layout.name) {
      // Switch to the toggle layer
      _previousLayerStack.add(currentLayout);
      _log.debug('Switching to toggle layer: ${layout.name}');
      keyboardNotifier.updateLayout(layout);
    } else {
      // Already on toggle layer, revert to previous layer
      if (_previousLayerStack.isNotEmpty) {
        final previousLayer = _previousLayerStack.removeLast();
        _log.debug('Reverting toggle layer to: ${previousLayer.name}');
        keyboardNotifier.updateLayout(previousLayer);
      } else if (prefsState.defaultUserLayout != null) {
        _log.debug(
            'Reverting to default layer: ${prefsState.defaultUserLayout!.name}');
        keyboardNotifier.updateLayout(prefsState.defaultUserLayout!);
      }
    }

    if (prefsState.hideOnDefaultLayer) {
      final currentLayout = ref.read(keyboardProvider).layout;
      final isNowOnDefault = prefsState.defaultUserLayout != null &&
          currentLayout.name == prefsState.defaultUserLayout!.name;
      final appState = ref.read(appStateProvider);

      if (isNowOnDefault && appState.isWindowVisible) {
        appNotifier.updateIsWindowVisible(false);
        cancelAutoHideTimer();
      } else if (!isNowOnDefault) {
        fadeIn();
      }
    }
  }

  void _handleHeldLayer(
    KeyboardLayout layout,
    String key,
    WidgetRef ref,
    bool isPressed,
    KeyboardNotifier keyboardNotifier,
    AppStateNotifier appNotifier,
    PreferencesState prefsState,
    void Function() fadeIn,
    void Function() cancelAutoHideTimer,
  ) {
    if (isPressed && !_activeTriggers.contains(key)) {
      // Store the current layer before switching to the held layer
      final currentLayout = ref.read(keyboardProvider).layout;
      _previousLayerStack.add(currentLayout);

      _log.debug('Switching to held layer: ${layout.name}');
      keyboardNotifier.updateLayout(layout);
      _activeTriggers.add(key);

      if (prefsState.hideOnDefaultLayer) {
        fadeIn();
      }
    } else if (!isPressed && _activeTriggers.contains(key)) {
      final currentLayout = ref.read(keyboardProvider).layout;

      // If we are still on the held layer, revert normally
      if (currentLayout.name == layout.name) {
        if (_previousLayerStack.isNotEmpty) {
          final previousLayer = _previousLayerStack.removeLast();
          _log.debug('Reverting to previous layer: ${previousLayer.name}');
          keyboardNotifier.updateLayout(previousLayer);
        } else if (prefsState.defaultUserLayout != null) {
          _log.debug(
              'Reverting to default layer: ${prefsState.defaultUserLayout!.name}');
          keyboardNotifier.updateLayout(prefsState.defaultUserLayout!);
        }
      } else {
        // We moved away from the held layer (e.g., toggled another layer on top).
        // Remove the held layer from the stack so that when the current layer is
        // toggled off, it reverts to the correct previous layer.
        // Example: If on T1 (toggled from H1), stack is [Default, H1].
        // Removing H1 ensures T1 falls back to Default, not H1.

        final index =
            _previousLayerStack.lastIndexWhere((l) => l.name == layout.name);
        if (index != -1) {
          _previousLayerStack.removeAt(index);
          _log.debug(
              'Removed held layer from stack (out-of-order release): ${layout.name}');
        }
      }
      _activeTriggers.remove(key);

      if (prefsState.hideOnDefaultLayer &&
          prefsState.defaultUserLayout != null) {
        final appState = ref.read(appStateProvider);
        if (appState.isWindowVisible) {
          final currentLayout = ref.read(keyboardProvider).layout;
          final isNowOnDefault =
              currentLayout.name == prefsState.defaultUserLayout!.name;

          if (isNowOnDefault) {
            appNotifier.updateIsWindowVisible(false);
            cancelAutoHideTimer();
          }
        }
      }
    }
  }

  /// Checks if the current layer is the default layer
  bool _isOnDefaultLayer(
    KeyboardState keyboardState,
    PreferencesState prefsState,
  ) {
    return prefsState.isOnDefaultLayer(keyboardState.layout);
  }

  /// Clears all active triggers
  void clearActiveTriggers() {
    _activeTriggers.clear();
    _previousLayerStack.clear();
  }
}
