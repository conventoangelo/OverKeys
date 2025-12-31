import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overkeys/providers/keyboard_provider.dart';
import 'package:overkeys/providers/app_state_provider.dart';
import 'package:overkeys/providers/preferences_provider.dart';
import 'package:overkeys/utils/key_code.dart';
import 'package:overkeys/utils/hooks.dart';

/// Service for handling keyboard events and user layer switching
class KeyEventService {
  /// Active trigger keys for held layer switching
  final Set<String> _activeTriggers = {};

  /// Sets up the keyboard event listener
  void setupKeyListener(ReceivePort Function() createReceivePort,
      Function(dynamic) handleKeyEvent) {
    final receivePort = createReceivePort();
    Isolate.spawn(setHook, receivePort.sendPort)
        .then((_) {})
        .catchError((error) {
      if (kDebugMode) {
        print('Error spawning Isolate: $error');
      }
    });

    receivePort.listen(handleKeyEvent);
  }

  /// Handles keyboard events from the receive port
  void handleKeyEvent(
    dynamic message,
    WidgetRef ref,
    Function fadeIn,
    Function resetAutoHideTimer,
    Function cancelAutoHideTimer,
    Function updateAutoHideBasedOnLayer,
  ) {
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

    if (prefsState.autoHideEnabled && !appState.isWindowVisible && isPressed) {
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
  }

  void _handleUserLayerSwitching(
    String key,
    bool isPressed,
    WidgetRef ref,
    dynamic keyboardState,
    dynamic keyboardNotifier,
    dynamic appState,
    dynamic appNotifier,
    dynamic prefsState,
    Function fadeIn,
    Function cancelAutoHideTimer,
    Function updateAutoHideBasedOnLayer,
  ) {
    final userLayers = prefsState.userLayers;
    final activeLayer = userLayers.where((l) => l.trigger == key);

    for (final layout in activeLayer) {
      if (layout.type == 'toggle' && isPressed) {
        _handleToggleLayer(
          layout,
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
          keyboardState.layout.name == prefsState.defaultUserLayout?.name);
    }
  }

  void _handleToggleLayer(
    dynamic layout,
    dynamic keyboardState,
    dynamic keyboardNotifier,
    dynamic appState,
    dynamic appNotifier,
    dynamic prefsState,
    Function fadeIn,
    Function cancelAutoHideTimer,
  ) {
    if (keyboardState.layout.name != layout.name) {
      keyboardNotifier.updateLayout(layout);
    } else if (prefsState.defaultUserLayout != null) {
      keyboardNotifier.updateLayout(prefsState.defaultUserLayout!);
    }

    if (prefsState.hideOnDefaultLayer) {
      final isNowOnDefault = prefsState.defaultUserLayout != null &&
          keyboardState.layout.name == prefsState.defaultUserLayout!.name;

      if (isNowOnDefault && appState.isWindowVisible) {
        appNotifier.updateIsWindowVisible(false);
        cancelAutoHideTimer();
      } else if (!isNowOnDefault) {
        fadeIn();
      }
    }
  }

  void _handleHeldLayer(
    dynamic layout,
    String key,
    bool isPressed,
    dynamic keyboardState,
    dynamic keyboardNotifier,
    dynamic appState,
    dynamic appNotifier,
    dynamic prefsState,
    Function fadeIn,
    Function cancelAutoHideTimer,
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
          keyboardState.layout.name == prefsState.defaultUserLayout!.name &&
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
