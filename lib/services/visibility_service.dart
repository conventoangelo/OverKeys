import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overkeys/providers/app_state_provider.dart';
import 'package:overkeys/providers/preferences_provider.dart';
import 'package:overkeys/providers/keyboard_provider.dart';

/// Service for managing window visibility and fade operations
class VisibilityService {
  /// Checks if the current keyboard layout is the default layer
  /// Returns true if we're on default layer and should hide the window
  bool isOnDefaultLayer(WidgetRef ref) {
    final keyboardState = ref.read(keyboardNotifierProvider);
    final prefsState = ref.read(preferencesNotifierProvider);

    // If hideOnDefaultLayer is disabled, always allow showing
    if (!prefsState.hideOnDefaultLayer) return false;

    // If advanced settings are not enabled, we're always on default
    if (!prefsState.advancedSettingsEnabled) return true;

    // For Kanata or user layout mode
    if (prefsState.kanataEnabled || prefsState.useUserLayout) {
      // If we have a default user layout, compare with current layout
      if (prefsState.defaultUserLayout != null) {
        return keyboardState.layout.name.toUpperCase() ==
            prefsState.defaultUserLayout!.name.toUpperCase();
      }
      // If no default user layout is set, check against initial layout
      if (prefsState.initialKeyboardLayout != null) {
        return keyboardState.layout.name.toUpperCase() ==
            prefsState.initialKeyboardLayout!.name.toUpperCase();
      }
    }

    // Default case: if we can't determine, don't hide
    return false;
  }

  /// Fades in the keyboard overlay if conditions are met
  void fadeIn(WidgetRef ref, Function resetAutoHideTimer) {
    final appState = ref.read(appStateNotifierProvider);
    final appNotifier = ref.read(appStateNotifierProvider.notifier);

    if (appState.forceHide || appState.isWindowVisible) return;

    // Check if we should hide on default layer
    if (isOnDefaultLayer(ref)) {
      return; // Don't show if we're on default layer and setting is enabled
    }

    appNotifier.updateIsWindowVisible(true);
    resetAutoHideTimer();
  }

  /// Fades out the keyboard overlay
  void fadeOut(WidgetRef ref) {
    final appState = ref.read(appStateNotifierProvider);
    final appNotifier = ref.read(appStateNotifierProvider.notifier);

    if (!appState.isWindowVisible) return;
    appNotifier.updateIsWindowVisible(false);
  }
}
