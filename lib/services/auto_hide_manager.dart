import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overkeys/providers/app_state_provider.dart';
import 'package:overkeys/providers/preferences_provider.dart';

/// Service for managing auto-hide functionality and overlay status messages
class AutoHideManager {
  Timer? _autoHideTimer;
  Timer? _opacityDebounceTimer;
  Timer? _overlayTimer;
  Timer? _mouseCheckTimer;

  static const Duration _overlayDuration = Duration(milliseconds: 1000);

  bool autoHideBeforeMove = false;

  void resetAutoHideTimer(WidgetRef ref) {
    final prefsState = ref.read(preferencesNotifierProvider);
    if (!prefsState.autoHideEnabled) return;

    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(
      Duration(milliseconds: (prefsState.autoHideDuration * 1000).round()),
      () => handleAutoHide(ref),
    );
  }

  void handleAutoHide(WidgetRef ref) {
    final prefsState = ref.read(preferencesNotifierProvider);
    final appState = ref.read(appStateNotifierProvider);
    if (prefsState.autoHideEnabled && appState.isWindowVisible) {
      fadeOut(ref);
    }
  }

  void fadeOut(WidgetRef ref) {
    final appState = ref.read(appStateNotifierProvider);
    final appNotifier = ref.read(appStateNotifierProvider.notifier);
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
    final appNotifier = ref.read(appStateNotifierProvider.notifier);
    appNotifier.showStatusOverlay(message, icon);
    _overlayTimer?.cancel();
    _overlayTimer = Timer(_overlayDuration, () {
      appNotifier.hideStatusOverlay();
    });
  }

  void startMouseTracking(WidgetRef ref, Function onTick) {
    _mouseCheckTimer?.cancel();
    final prefsState = ref.read(preferencesNotifierProvider);
    if (prefsState.keyboardFollowsMouse && prefsState.advancedSettingsEnabled) {
      _mouseCheckTimer =
          Timer.periodic(const Duration(milliseconds: 500), (_) => onTick());
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
