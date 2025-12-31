import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overkeys/models/keyboard_layouts.dart';
import 'package:overkeys/providers/keyboard_provider.dart';
import 'package:overkeys/providers/app_state_provider.dart';
import 'package:overkeys/providers/preferences_provider.dart';
import 'package:overkeys/utils/key_code.dart';
import 'package:overkeys/utils/hooks.dart';

/// Service for handling keyboard events and user layer switching
class KeyEventService {
  /// Active trigger keys for held layer switching
  final Set<String> _activeTriggers = {};

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
      if (kDebugMode) {
        print('Error spawning Isolate: $error');
      }
      throw error;
    });
  }

  /// Disposes of resources and closes the receive port
  void dispose() {
    _receivePort?.close();
    _receivePort = null;
    _activeTriggers.clear();
  }

  /// Handles keyboard events from the receive port
  void handleKeyEvent(
    dynamic message,
    WidgetRef ref,
    void Function() fadeIn,
    void Function() resetAutoHideTimer,
    void Function() cancelAutoHideTimer,
    void Function(bool) updateAutoHideBasedOnLayer,
  ) {
    try {
      if (message is! List) return;

      final keyboardNotifier = ref.read(keyboardNotifierProvider.notifier);
      final appNotifier = ref.read(appStateNotifierProvider.notifier);
      final keyboardState = ref.read(keyboardNotifierProvider);
      final appState = ref.read(appStateNotifierProvider);
      final prefsState = ref.read(preferencesNotifierProvider);

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

      if (kDebugMode) {
        print(
            'Key: ${key.padRight(10)}\tKeyCode: ${keyCode.toString().padRight(5)}\tPressed: ${isPressed.toString().padRight(5)}\tShift: $isShiftDown');
      }

      keyboardNotifier.updateKeyPressState(key, isPressed);

      // Handle auto-hide and visibility
      if (appState.forceHide) return;

      if (prefsState.autoHideEnabled &&
          !appState.isWindowVisible &&
          isPressed) {
        fadeIn();
      } else {
        resetAutoHideTimer();
      }

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
          cancelAutoHideTimer,
          updateAutoHideBasedOnLayer,
        );
      }
    } catch (error, stackTrace) {
      // Log the error but keep the listener alive
      if (kDebugMode) {
        print('Error in handleKeyEvent: $error');
        print('Stack trace: $stackTrace');
      }
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
    void Function(bool) updateAutoHideBasedOnLayer,
  ) {
    final userLayers = prefsState.userLayers;
    final activeLayer = userLayers.where((l) => l.trigger == key);

    for (final layout in activeLayer) {
      if (layout.type == 'toggle' && isPressed) {
        _handleToggleLayer(
          layout,
          ref,
          keyboardState,
          keyboardNotifier,
          appState,
          appNotifier,
          prefsState,
          fadeIn,
          cancelAutoHideTimer,
        );
      } else if (layout.type == 'held') {
        _handleHeldLayer(
          layout,
          key,
          isPressed,
          keyboardState,
          keyboardNotifier,
          appState,
          appNotifier,
          prefsState,
          fadeIn,
          cancelAutoHideTimer,
        );
      }

      updateAutoHideBasedOnLayer(
          ref.read(keyboardNotifierProvider).layout.name ==
              prefsState.defaultUserLayout?.name);
    }
  }

  void _handleToggleLayer(
    KeyboardLayout layout,
    WidgetRef ref,
    KeyboardState keyboardState,
    KeyboardNotifier keyboardNotifier,
    AppState appState,
    AppStateNotifier appNotifier,
    PreferencesState prefsState,
    void Function() fadeIn,
    void Function() cancelAutoHideTimer,
  ) {
    if (keyboardState.layout.name != layout.name) {
      keyboardNotifier.updateLayout(layout);
    } else if (prefsState.defaultUserLayout != null) {
      keyboardNotifier.updateLayout(prefsState.defaultUserLayout!);
    }

    if (prefsState.hideOnDefaultLayer) {
      final currentLayout = ref.read(keyboardNotifierProvider).layout;
      final isNowOnDefault = prefsState.defaultUserLayout != null &&
          currentLayout.name == prefsState.defaultUserLayout!.name;

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
    bool isPressed,
    KeyboardState keyboardState,
    KeyboardNotifier keyboardNotifier,
    AppState appState,
    AppStateNotifier appNotifier,
    PreferencesState prefsState,
    void Function() fadeIn,
    void Function() cancelAutoHideTimer,
  ) {
    if (isPressed && !_activeTriggers.contains(key)) {
      keyboardNotifier.updateLayout(layout);
      _activeTriggers.add(key);

      if (prefsState.hideOnDefaultLayer) {
        fadeIn();
      }
    } else if (!isPressed && _activeTriggers.contains(key)) {
      if (prefsState.defaultUserLayout != null) {
        keyboardNotifier.updateLayout(prefsState.defaultUserLayout!);
      }
      _activeTriggers.remove(key);

      if (prefsState.hideOnDefaultLayer &&
          prefsState.defaultUserLayout != null &&
          appState.isWindowVisible) {
        appNotifier.updateIsWindowVisible(false);
        cancelAutoHideTimer();
      }
    }
  }

  /// Clears all active triggers
  void clearActiveTriggers() {
    _activeTriggers.clear();
  }
}
