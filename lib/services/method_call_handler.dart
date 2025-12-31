import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:overkeys/models/keyboard_layouts.dart';
import 'package:overkeys/providers/app_state_provider.dart';
import 'package:overkeys/providers/keyboard_provider.dart';
import 'package:overkeys/providers/preferences_provider.dart';
import 'package:overkeys/services/kanata_service.dart';
import 'package:overkeys/services/startup_service.dart';

/// Service for handling method calls from the preferences window
/// Processes UI changes and updates to application state from the preferences screen
class MethodCallHandler {
  final StartupService _startupService = StartupService();

  /// Safely casts arguments with a fallback value
  T _safeArgument<T>(dynamic value, T fallback) {
    if (value is T) {
      return value;
    }
    if (kDebugMode) {
      debugPrint(
          'Warning: Invalid argument type, expected $T, got ${value.runtimeType}');
    }
    return fallback;
  }

  /// Handles method calls and routes them to appropriate state updates
  Future<void> handleMethodCall(
    MethodCall call,
    WidgetRef ref,
    KanataService kanataService,
    Function() setupHotKeys,
    Function() loadAltLayout,
    Function() loadCustomFont,
    Function() loadUserLayout,
    Function() useKanata,
    Function(bool) startMouseTracking,
    Function() stopMouseTracking,
    Function() fadeIn,
    Function() clearConfigCache,
  ) async {
    final keyboardNotifier = ref.read(keyboardNotifierProvider.notifier);
    final prefsNotifier = ref.read(preferencesNotifierProvider.notifier);
    final appNotifier = ref.read(appStateNotifierProvider.notifier);

    switch (call.method) {
      // General settings
      case 'updateLaunchAtStartup':
        final launchAtStartupValue = _safeArgument<bool>(call.arguments, false);
        prefsNotifier.updateLaunchAtStartup(launchAtStartupValue);
        final success =
            await _startupService.handleStartupToggle(launchAtStartupValue);
        if (!success) {
          // Revert the toggle on failure
          prefsNotifier.updateLaunchAtStartup(!launchAtStartupValue);
        }

      case 'updateHideAtStartup':
        final hideAtStartup = _safeArgument<bool>(call.arguments, false);
        prefsNotifier.updateHideAtStartup(hideAtStartup);

      case 'updateAutoHideEnabled':
        // Auto hide toggle is handled by caller in app.dart
        break;

      case 'updateReactiveShiftEnabled':
        final reactiveShiftEnabled = _safeArgument<bool>(call.arguments, false);
        prefsNotifier.updateReactiveShiftEnabled(reactiveShiftEnabled);

      case 'updateAutoHideDuration':
        final autoHideDuration = _safeArgument<double>(call.arguments, 3.0);
        prefsNotifier.updateAutoHideDuration(autoHideDuration);

      case 'updateOpacity':
        final opacity = _safeArgument<double>(call.arguments, 1.0);
        prefsNotifier.updateOpacity(opacity);

      case 'updateLayout':
        final layoutName = _safeArgument<String>(call.arguments, 'QWERTY');
        final prefsState = ref.read(preferencesNotifierProvider);
        final keyboardState = ref.read(keyboardNotifierProvider);
        final layout =
            availableLayouts.firstWhere((layout) => layout.name == layoutName);

        // If Kanata or user layout is active, only update the initialLayout
        // (the layout to revert to when those features are disabled)
        if ((keyboardState.kanataEnabled || prefsState.useUserLayout) &&
            prefsState.advancedSettingsEnabled) {
          keyboardNotifier.updateInitialLayout(layout);
        } else {
          // Otherwise, update both current and initial layout
          keyboardNotifier.updateLayout(layout);
          keyboardNotifier.updateInitialLayout(layout);
        }
        fadeIn();

      // Keyboard settings
      case 'updateKeymapStyle':
        final keymapStyle = _safeArgument<String>(call.arguments, 'ISO');
        keyboardNotifier.updateKeymapStyle(keymapStyle);

      case 'updateShowTopRow':
        final showTopRow = _safeArgument<bool>(call.arguments, true);
        keyboardNotifier.updateShowTopRow(showTopRow);

      case 'updateShowGraveKey':
        final showGraveKey = _safeArgument<bool>(call.arguments, true);
        keyboardNotifier.updateShowGraveKey(showGraveKey);

      case 'updateKeySize':
        final keySize = _safeArgument<double>(call.arguments, 100.0);
        keyboardNotifier.updateKeySize(keySize);

      case 'updateKeyBorderRadius':
        final keyBorderRadius = _safeArgument<double>(call.arguments, 8.0);
        keyboardNotifier.updateKeyBorderRadius(keyBorderRadius);

      case 'updateKeyBorderThickness':
        final keyBorderThickness = _safeArgument<double>(call.arguments, 2.0);
        keyboardNotifier.updateKeyBorderThickness(keyBorderThickness);

      case 'updateKeyPadding':
        final keyPadding = _safeArgument<double>(call.arguments, 8.0);
        keyboardNotifier.updateKeyPadding(keyPadding);

      case 'updateSpaceWidth':
        final spaceWidth = _safeArgument<double>(call.arguments, 100.0);
        keyboardNotifier.updateSpaceWidth(spaceWidth);

      case 'updateSplitWidth':
        final splitWidth = _safeArgument<double>(call.arguments, 15.0);
        keyboardNotifier.updateSplitWidth(splitWidth);

      case 'updateLastRowSplitWidth':
        final lastRowSplitWidth = _safeArgument<double>(call.arguments, 15.0);
        keyboardNotifier.updateLastRowSplitWidth(lastRowSplitWidth);

      case 'updateKeyShadowBlurRadius':
        final keyShadowBlurRadius = _safeArgument<double>(call.arguments, 0.0);
        keyboardNotifier.updateKeyShadowBlurRadius(keyShadowBlurRadius);

      case 'updateKeyShadowOffsetX':
        final keyShadowOffsetX = _safeArgument<double>(call.arguments, 0.0);
        keyboardNotifier.updateKeyShadowOffsetX(keyShadowOffsetX);

      case 'updateKeyShadowOffsetY':
        final keyShadowOffsetY = _safeArgument<double>(call.arguments, 0.0);
        keyboardNotifier.updateKeyShadowOffsetY(keyShadowOffsetY);

      // Text settings
      case 'updateFontFamily':
        final fontFamily = _safeArgument<String>(call.arguments, '');
        final prefsState = ref.read(preferencesNotifierProvider);
        keyboardNotifier.updateFontFamily(fontFamily);
        if (!(prefsState.customFontEnabled &&
            prefsState.advancedSettingsEnabled)) {
          keyboardNotifier.updateInitialFontFamily(fontFamily);
        }

      case 'updateFontWeight':
        final fontWeightIndex = _safeArgument<int>(call.arguments, 3);
        keyboardNotifier.updateFontWeight(FontWeight.values[fontWeightIndex]);

      case 'updateKeyFontSize':
        final keyFontSize = _safeArgument<double>(call.arguments, 28.0);
        keyboardNotifier.updateKeyFontSize(keyFontSize);

      case 'updateSpaceFontSize':
        final spaceFontSize = _safeArgument<double>(call.arguments, 20.0);
        keyboardNotifier.updateSpaceFontSize(spaceFontSize);

      // Markers settings
      case 'updateMarkerOffset':
        final markerOffset = _safeArgument<double>(call.arguments, 0.0);
        keyboardNotifier.updateMarkerOffset(markerOffset);

      case 'updateMarkerWidth':
        final markerWidth = _safeArgument<double>(call.arguments, 6.0);
        keyboardNotifier.updateMarkerWidth(markerWidth);

      case 'updateMarkerHeight':
        final markerHeight = _safeArgument<double>(call.arguments, 6.0);
        keyboardNotifier.updateMarkerHeight(markerHeight);

      case 'updateMarkerBorderRadius':
        final markerBorderRadius = _safeArgument<double>(call.arguments, 3.0);
        keyboardNotifier.updateMarkerBorderRadius(markerBorderRadius);

      // Colors settings
      case 'updateKeyColorPressed':
        final keyColorPressed = _safeArgument<int>(call.arguments, 0xFF2196F3);
        keyboardNotifier.updateKeyColorPressed(Color(keyColorPressed));

      case 'updateKeyColorNotPressed':
        final keyColorNotPressed =
            _safeArgument<int>(call.arguments, 0xFF212121);
        keyboardNotifier.updateKeyColorNotPressed(Color(keyColorNotPressed));

      case 'updateMarkerColor':
        final markerColor = _safeArgument<int>(call.arguments, 0xFF4CAF50);
        keyboardNotifier.updateMarkerColor(Color(markerColor));

      case 'updateMarkerColorNotPressed':
        final markerColorNotPressed =
            _safeArgument<int>(call.arguments, 0xFF9E9E9E);
        keyboardNotifier
            .updateMarkerColorNotPressed(Color(markerColorNotPressed));

      case 'updateKeyTextColor':
        final keyTextColor = _safeArgument<int>(call.arguments, 0xFFFFFFFF);
        keyboardNotifier.updateKeyTextColor(Color(keyTextColor));

      case 'updateKeyTextColorNotPressed':
        final keyTextColorNotPressed =
            _safeArgument<int>(call.arguments, 0xFFFFFFFF);
        keyboardNotifier
            .updateKeyTextColorNotPressed(Color(keyTextColorNotPressed));

      case 'updateKeyBorderColorPressed':
        final keyBorderColorPressed =
            _safeArgument<int>(call.arguments, 0xFF2196F3);
        keyboardNotifier
            .updateKeyBorderColorPressed(Color(keyBorderColorPressed));

      case 'updateKeyBorderColorNotPressed':
        final keyBorderColorNotPressed =
            _safeArgument<int>(call.arguments, 0xFF616161);
        keyboardNotifier
            .updateKeyBorderColorNotPressed(Color(keyBorderColorNotPressed));

      // Animations settings
      case 'updateAnimationEnabled':
        final animationEnabled = _safeArgument<bool>(call.arguments, true);
        keyboardNotifier.updateAnimationEnabled(animationEnabled);

      case 'updateAnimationStyle':
        final animationStyle = _safeArgument<String>(call.arguments, 'scale');
        keyboardNotifier.updateAnimationStyle(animationStyle);

      case 'updateAnimationDuration':
        final animationDuration = _safeArgument<double>(call.arguments, 0.1);
        keyboardNotifier.updateAnimationDuration(animationDuration);

      case 'updateAnimationScale':
        final animationScale = _safeArgument<double>(call.arguments, 0.95);
        keyboardNotifier.updateAnimationScale(animationScale);

      // HotKey settings
      case 'updateHotKeysEnabled':
        final hotKeysEnabled = _safeArgument<bool>(call.arguments, true);
        appNotifier.updateHotKeysEnabled(hotKeysEnabled);
        await setupHotKeys();

      case 'updateVisibilityHotKey':
        final hotKeyJson = _safeArgument<String>(call.arguments, '{}');
        final newHotKey = HotKey.fromJson(jsonDecode(hotKeyJson));
        final currentVisibilityHotKey =
            ref.read(appStateNotifierProvider).visibilityHotKey;
        if (currentVisibilityHotKey != null) {
          await hotKeyManager.unregister(currentVisibilityHotKey);
        }
        appNotifier.updateVisibilityHotKey(newHotKey);
        await setupHotKeys();

      case 'updateAutoHideHotKey':
        final hotKeyJson = _safeArgument<String>(call.arguments, '{}');
        final newHotKey = HotKey.fromJson(jsonDecode(hotKeyJson));
        final currentAutoHideHotKey =
            ref.read(appStateNotifierProvider).autoHideHotKey;
        if (currentAutoHideHotKey != null) {
          await hotKeyManager.unregister(currentAutoHideHotKey);
        }
        appNotifier.updateAutoHideHotKey(newHotKey);
        await setupHotKeys();

      case 'updateToggleMoveHotKey':
        final hotKeyJson = _safeArgument<String>(call.arguments, '{}');
        final newHotKey = HotKey.fromJson(jsonDecode(hotKeyJson));
        final currentToggleMoveHotKey =
            ref.read(appStateNotifierProvider).toggleMoveHotKey;
        if (currentToggleMoveHotKey != null) {
          await hotKeyManager.unregister(currentToggleMoveHotKey);
        }
        appNotifier.updateToggleMoveHotKey(newHotKey);
        await setupHotKeys();

      case 'updatePreferencesHotKey':
        final hotKeyJson = _safeArgument<String>(call.arguments, '{}');
        final newHotKey = HotKey.fromJson(jsonDecode(hotKeyJson));
        final currentPreferencesHotKey =
            ref.read(appStateNotifierProvider).preferencesHotKey;
        if (currentPreferencesHotKey != null) {
          await hotKeyManager.unregister(currentPreferencesHotKey);
        }
        appNotifier.updatePreferencesHotKey(newHotKey);
        await setupHotKeys();

      case 'updateIncreaseOpacityHotKey':
        final hotKeyJson = _safeArgument<String>(call.arguments, '{}');
        final newHotKey = HotKey.fromJson(jsonDecode(hotKeyJson));
        final currentIncreaseOpacityHotKey =
            ref.read(appStateNotifierProvider).increaseOpacityHotKey;
        if (currentIncreaseOpacityHotKey != null) {
          await hotKeyManager.unregister(currentIncreaseOpacityHotKey);
        }
        appNotifier.updateIncreaseOpacityHotKey(newHotKey);
        await setupHotKeys();

      case 'updateDecreaseOpacityHotKey':
        final hotKeyJson = _safeArgument<String>(call.arguments, '{}');
        final newHotKey = HotKey.fromJson(jsonDecode(hotKeyJson));
        final currentDecreaseOpacityHotKey =
            ref.read(appStateNotifierProvider).decreaseOpacityHotKey;
        if (currentDecreaseOpacityHotKey != null) {
          await hotKeyManager.unregister(currentDecreaseOpacityHotKey);
        }
        appNotifier.updateDecreaseOpacityHotKey(newHotKey);
        await setupHotKeys();

      case 'updateEnableVisibilityHotKey':
        final enabled = _safeArgument<bool>(call.arguments, true);
        appNotifier.updateEnableVisibilityHotKey(enabled);
        await setupHotKeys();

      case 'updateEnableAutoHideHotKey':
        final enabled = _safeArgument<bool>(call.arguments, true);
        appNotifier.updateEnableAutoHideHotKey(enabled);
        await setupHotKeys();

      case 'updateEnableToggleMoveHotKey':
        final enabled = _safeArgument<bool>(call.arguments, true);
        appNotifier.updateEnableToggleMoveHotKey(enabled);
        await setupHotKeys();

      case 'updateEnablePreferencesHotKey':
        final enabled = _safeArgument<bool>(call.arguments, true);
        appNotifier.updateEnablePreferencesHotKey(enabled);
        await setupHotKeys();

      case 'updateEnableIncreaseOpacityHotKey':
        final enabled = _safeArgument<bool>(call.arguments, true);
        appNotifier.updateEnableIncreaseOpacityHotKey(enabled);
        await setupHotKeys();

      case 'updateEnableDecreaseOpacityHotKey':
        final enabled = _safeArgument<bool>(call.arguments, true);
        appNotifier.updateEnableDecreaseOpacityHotKey(enabled);
        await setupHotKeys();

      // Learning mode settings
      case 'updateLearningModeEnabled':
        final learningModeEnabled = _safeArgument<bool>(call.arguments, false);
        keyboardNotifier.updateLearningModeEnabled(learningModeEnabled);

      case 'updatePinkyLeftColor':
        final color = _safeArgument<int>(call.arguments, 0xFFFF5722);
        keyboardNotifier.updatePinkyLeftColor(Color(color));

      case 'updateRingLeftColor':
        final color = _safeArgument<int>(call.arguments, 0xFFFF9800);
        keyboardNotifier.updateRingLeftColor(Color(color));

      case 'updateMiddleLeftColor':
        final color = _safeArgument<int>(call.arguments, 0xFFFFC107);
        keyboardNotifier.updateMiddleLeftColor(Color(color));

      case 'updateIndexLeftColor':
        final color = _safeArgument<int>(call.arguments, 0xFF8BC34A);
        keyboardNotifier.updateIndexLeftColor(Color(color));

      case 'updateIndexRightColor':
        final color = _safeArgument<int>(call.arguments, 0xFF2196F3);
        keyboardNotifier.updateIndexRightColor(Color(color));

      case 'updateMiddleRightColor':
        final color = _safeArgument<int>(call.arguments, 0xFF3F51B5);
        keyboardNotifier.updateMiddleRightColor(Color(color));

      case 'updateRingRightColor':
        final color = _safeArgument<int>(call.arguments, 0xFF9C27B0);
        keyboardNotifier.updateRingRightColor(Color(color));

      case 'updatePinkyRightColor':
        final color = _safeArgument<int>(call.arguments, 0xFFE91E63);
        keyboardNotifier.updatePinkyRightColor(Color(color));

      // Advanced settings
      case 'updateAdvancedSettingsEnabled':
        final advancedSettingsEnabled =
            _safeArgument<bool>(call.arguments, false);
        prefsNotifier.updateAdvancedSettingsEnabled(advancedSettingsEnabled);
        final keyboardState = ref.read(keyboardNotifierProvider);
        final currentPrefsState = ref.read(preferencesNotifierProvider);

        if (!advancedSettingsEnabled) {
          if (keyboardState.kanataEnabled) {
            kanataService.disconnect();
            keyboardNotifier.updateLayout(
                keyboardState.initialLayout ?? keyboardState.layout);
          }
          if (currentPrefsState.useUserLayout) {
            keyboardNotifier.updateLayout(
                keyboardState.initialLayout ?? keyboardState.layout);
          }
          // Don't clear altLayout data - just hide it so it can be restored later
          keyboardNotifier.updateShowAltLayout(false);
          if (currentPrefsState.customFontEnabled) {
            keyboardNotifier.updateFontFamily(
                keyboardState.initialFontFamily ?? keyboardState.fontFamily);
          }
          if (currentPrefsState.keyboardFollowsMouse) {
            stopMouseTracking();
          }
          // Ensure keyboard is visible if it was hidden by advanced features
        } else {
          // Clear cached config when re-enabling advanced settings
          // to ensure recent changes to the config file are reflected
          clearConfigCache();
          if (currentPrefsState.keyboardFollowsMouse) {
            startMouseTracking(true);
          }
        }

        if (advancedSettingsEnabled) {
          if (keyboardState.kanataEnabled) {
            await useKanata();
          }
          if (currentPrefsState.useUserLayout && !keyboardState.kanataEnabled) {
            loadUserLayout();
          }
          if (currentPrefsState.showAltLayout) {
            loadAltLayout();
          }
          if (currentPrefsState.customFontEnabled) {
            loadCustomFont();
          }
        } else {
          fadeIn();
        }

      case 'updateUseUserLayout':
        final useUserLayout = _safeArgument<bool>(call.arguments, false);
        final keyboardState = ref.read(keyboardNotifierProvider);

        if (useUserLayout) {
          // Save the current layout before switching to user layout
          // so we can restore it when toggling off
          if (!keyboardState.kanataEnabled) {
            keyboardNotifier.updateInitialLayout(keyboardState.layout);
          }
          prefsNotifier.updateUseUserLayout(useUserLayout);
          loadUserLayout();
        } else {
          prefsNotifier.updateUseUserLayout(useUserLayout);
          // Restore the layout that was active before user layout was enabled
          if (keyboardState.initialLayout != null &&
              !keyboardState.kanataEnabled) {
            keyboardNotifier.updateLayout(keyboardState.initialLayout!);
          }
          fadeIn();
        }

      case 'updateShowAltLayout':
        final showAltLayout = _safeArgument<bool>(call.arguments, false);
        prefsNotifier.updateShowAltLayout(showAltLayout);
        if (showAltLayout) {
          loadAltLayout();
        } else {
          // Clear the alternative layout when toggling off
          prefsNotifier.updateAltLayout(null);
          keyboardNotifier.updateShowAltLayout(false);
        }
        fadeIn();

      case 'updateCustomFontEnabled':
        final customFontEnabled = _safeArgument<bool>(call.arguments, false);
        final keyboardState = ref.read(keyboardNotifierProvider);

        if (customFontEnabled) {
          // Save the current font before switching to custom font
          // so we can restore it when toggling off
          keyboardNotifier.updateInitialFontFamily(keyboardState.fontFamily);
          prefsNotifier.updateCustomFontEnabled(customFontEnabled);
          loadCustomFont();
        } else {
          prefsNotifier.updateCustomFontEnabled(customFontEnabled);
          // Restore the font that was active before custom font was enabled
          if (keyboardState.initialFontFamily != null) {
            keyboardNotifier.updateFontFamily(keyboardState.initialFontFamily!);
          }
        }

      case 'updateUse6ColLayout':
        final use6ColLayout = _safeArgument<bool>(call.arguments, false);
        prefsNotifier.updateUse6ColLayout(use6ColLayout);
        fadeIn();

      case 'updateKanataEnabled':
        final kanataEnabled = _safeArgument<bool>(call.arguments, false);
        final keyboardState = ref.read(keyboardNotifierProvider);
        if (kanataEnabled && !keyboardState.kanataEnabled) {
          // Turning Kanata ON
          if (kDebugMode) {
            print(
                'Enabling Kanata. Saving current layout: ${keyboardState.layout.name}');
          }
          keyboardNotifier.updateInitialLayout(keyboardState.layout);
          keyboardNotifier.updateKanataEnabled(true);
          prefsNotifier.updateKanataEnabled(true);
          await useKanata();
        } else if (!kanataEnabled && keyboardState.kanataEnabled) {
          // Turning Kanata OFF
          if (kDebugMode) {
            print(
                'Disabling Kanata. Restoring layout: ${keyboardState.initialLayout?.name ?? "null"}');
          }
          // First, restore the layout that was active before Kanata was enabled
          if (keyboardState.initialLayout != null) {
            keyboardNotifier.updateLayout(keyboardState.initialLayout!);
          }
          // Then update states and disconnect
          keyboardNotifier.updateKanataEnabled(false);
          prefsNotifier.updateKanataEnabled(false);
          kanataService.disconnect();
          fadeIn();
        }

      case 'updateKeyboardFollowsMouse':
        final keyboardFollowsMouse = _safeArgument<bool>(call.arguments, false);
        prefsNotifier.updateKeyboardFollowsMouse(keyboardFollowsMouse);
        final currentPrefsState = ref.read(preferencesNotifierProvider);
        if (keyboardFollowsMouse && currentPrefsState.advancedSettingsEnabled) {
          startMouseTracking(true);
        } else {
          stopMouseTracking();
        }

      case 'updateHideOnDefaultLayer':
        final hideOnDefaultLayer = _safeArgument<bool>(call.arguments, false);
        prefsNotifier.updateHideOnDefaultLayer(hideOnDefaultLayer);
        if (!hideOnDefaultLayer) {
          fadeIn();
        }

      default:
        debugPrint('Warning: Unimplemented method ${call.method}');
    }
  }
}
