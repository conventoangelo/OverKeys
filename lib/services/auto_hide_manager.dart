import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overkeys/providers/app_state_provider.dart';
import 'package:overkeys/providers/keyboard_provider.dart';
import 'package:overkeys/providers/preferences_provider.dart';

/// Service for managing auto-hide functionality and overlay status messages
class AutoHideManager {
  // Timers for various auto-hide operations
  Timer? _autoHideTimer;
  Timer? _opacityDebounceTimer;
  Timer? _overlayTimer;
  Timer? _mouseCheckTimer;

  // Constants
  static const Duration _overlayDuration = Duration(milliseconds: 1000);
  static const Duration _mouseCheckInterval = Duration(milliseconds: 500);

  /// Resets the auto-hide timer based on user preferences
  void resetAutoHideTimer(WidgetRef ref) {
    final prefsState = ref.read(preferencesProvider);
    if (!prefsState.autoHideEnabled) return;

    // Check if we're on the default layer
    final isOnDefault = _isOnDefaultLayer(ref);

    if (!isOnDefault) {
      // If not on default layer, cancel any existing timer
      _autoHideTimer?.cancel();
      return;
    }

    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(
      Duration(milliseconds: (prefsState.autoHideDuration * 1000).round()),
      () => handleAutoHide(ref),
    );
  }

  /// Checks if the current layer is the default layer
  bool _isOnDefaultLayer(WidgetRef ref) {
    final keyboardState = ref.read(keyboardProvider);
    final prefsState = ref.read(preferencesProvider);
    return prefsState.isOnDefaultLayer(keyboardState.layout);
  }

  void handleAutoHide(WidgetRef ref) {
    final prefsState = ref.read(preferencesProvider);
    final appState = ref.read(appStateProvider);
    if (prefsState.autoHideEnabled && appState.isWindowVisible) {
      fadeOut(ref);
    }
  }

  void fadeOut(WidgetRef ref) {
    final appState = ref.read(appStateProvider);
    final appNotifier = ref.read(appStateProvider.notifier);
    if (!appState.isWindowVisible) return;
    appNotifier.updateIsWindowVisible(false);
  }

  void cancelAutoHideTimer() {
    _autoHideTimer?.cancel();
  }

  void debouncedOpacityUpdate(
    WidgetRef ref,
    Duration delay,
    Function onTimerComplete,
  ) {
    _opacityDebounceTimer?.cancel();
    _opacityDebounceTimer = Timer(delay, () {
      onTimerComplete();
    });
  }

  void showOverlay(WidgetRef ref, String message, dynamic icon) {
    final appNotifier = ref.read(appStateProvider.notifier);
    appNotifier.showStatusOverlay(message, icon);
    _overlayTimer?.cancel();
    _overlayTimer = Timer(_overlayDuration, () {
      appNotifier.hideStatusOverlay();
    });
  }

  void startMouseTracking(WidgetRef ref, Function onTick) {
    _mouseCheckTimer?.cancel();
    final prefsState = ref.read(preferencesProvider);
    if (prefsState.keyboardFollowsMouse && prefsState.advancedSettingsEnabled) {
      _mouseCheckTimer = Timer.periodic(_mouseCheckInterval, (_) => onTick());
    }
  }

  void stopMouseTracking() {
    _mouseCheckTimer?.cancel();
  }

  void dispose() {
    _autoHideTimer?.cancel();
    _opacityDebounceTimer?.cancel();
    _overlayTimer?.cancel();
    _mouseCheckTimer?.cancel();
  }
}
