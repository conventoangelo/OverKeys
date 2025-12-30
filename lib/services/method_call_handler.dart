import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:overkeys/models/keyboard_layouts.dart';
import 'package:overkeys/providers/app_state_provider.dart';
import 'package:overkeys/providers/keyboard_provider.dart';
import 'package:overkeys/providers/preferences_provider.dart';
import 'package:overkeys/services/kanata_service.dart';
import 'package:overkeys/services/startup_service.dart';

/// Service for handling method calls from the preferences window
class MethodCallHandler {
  final StartupService _startupService = StartupService();

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
  ) async {
    final keyboardNotifier = ref.read(keyboardNotifierProvider.notifier);
    final prefsNotifier = ref.read(preferencesNotifierProvider.notifier);
    final appNotifier = ref.read(appStateNotifierProvider.notifier);

    switch (call.method) {
      // General settings
      case 'updateLaunchAtStartup':
        final launchAtStartupValue = call.arguments as bool;
        prefsNotifier.updateLaunchAtStartup(launchAtStartupValue);
        await _startupService.handleStartupToggle(launchAtStartupValue);

      case 'updateHideAtStartup':
        final hideAtStartup = call.arguments as bool;
        prefsNotifier.updateHideAtStartup(hideAtStartup);

      case 'updateAutoHideEnabled':
        // Auto hide toggle is handled by caller in app.dart
        break;

      case 'updateReactiveShiftEnabled':
        final reactiveShiftEnabled = call.arguments as bool;
        prefsNotifier.updateReactiveShiftEnabled(reactiveShiftEnabled);

      case 'updateAutoHideDuration':
        final autoHideDuration = call.arguments as double;
        prefsNotifier.updateAutoHideDuration(autoHideDuration);

      case 'updateOpacity':
        final opacity = call.arguments as double;
        prefsNotifier.updateOpacity(opacity);

      case 'updateLayout':
        final layoutName = call.arguments as String;
        final prefsState = ref.read(preferencesNotifierProvider);
        final keyboardState = ref.read(keyboardNotifierProvider);
        if ((keyboardState.kanataEnabled || prefsState.useUserLayout) &&
            prefsState.advancedSettingsEnabled) {
          final layout = availableLayouts
              .firstWhere((layout) => layout.name == layoutName);
          keyboardNotifier.updateLayout(layout);
        } else {
          final layout = availableLayouts
              .firstWhere((layout) => layout.name == layoutName);
          keyboardNotifier.updateLayout(layout);
          keyboardNotifier.updateInitialLayout(layout);
        }
        fadeIn();

      // Keyboard settings
      case 'updateKeymapStyle':
        final keymapStyle = call.arguments as String;
        keyboardNotifier.updateKeymapStyle(keymapStyle);

      case 'updateShowTopRow':
        final showTopRow = call.arguments as bool;
        keyboardNotifier.updateShowTopRow(showTopRow);

      case 'updateShowGraveKey':
        final showGraveKey = call.arguments as bool;
        keyboardNotifier.updateShowGraveKey(showGraveKey);

      case 'updateKeySize':
        final keySize = call.arguments as double;
        keyboardNotifier.updateKeySize(keySize);

      case 'updateKeyBorderRadius':
        final keyBorderRadius = call.arguments as double;
        keyboardNotifier.updateKeyBorderRadius(keyBorderRadius);

      case 'updateKeyBorderThickness':
        final keyBorderThickness = call.arguments as double;
        keyboardNotifier.updateKeyBorderThickness(keyBorderThickness);

      case 'updateKeyPadding':
        final keyPadding = call.arguments as double;
        keyboardNotifier.updateKeyPadding(keyPadding);

      case 'updateSpaceWidth':
        final spaceWidth = call.arguments as double;
        keyboardNotifier.updateSpaceWidth(spaceWidth);

      case 'updateSplitWidth':
        final splitWidth = call.arguments as double;
        keyboardNotifier.updateSplitWidth(splitWidth);

      case 'updateLastRowSplitWidth':
        final lastRowSplitWidth = call.arguments as double;
        keyboardNotifier.updateLastRowSplitWidth(lastRowSplitWidth);

      case 'updateKeyShadowBlurRadius':
        final keyShadowBlurRadius = call.arguments as double;
        keyboardNotifier.updateKeyShadowBlurRadius(keyShadowBlurRadius);

      case 'updateKeyShadowOffsetX':
        final keyShadowOffsetX = call.arguments as double;
        keyboardNotifier.updateKeyShadowOffsetX(keyShadowOffsetX);

      case 'updateKeyShadowOffsetY':
        final keyShadowOffsetY = call.arguments as double;
        keyboardNotifier.updateKeyShadowOffsetY(keyShadowOffsetY);

      // Text settings
      case 'updateFontFamily':
        final fontFamily = call.arguments as String;
        final prefsState = ref.read(preferencesNotifierProvider);
        if (prefsState.customFontEnabled &&
            prefsState.advancedSettingsEnabled) {
          keyboardNotifier.updateFontFamily(fontFamily);
        } else {
          keyboardNotifier.updateFontFamily(fontFamily);
          keyboardNotifier.updateInitialFontFamily(fontFamily);
        }

      case 'updateFontWeight':
        final fontWeightIndex = call.arguments as int;
        keyboardNotifier.updateFontWeight(FontWeight.values[fontWeightIndex]);

      case 'updateKeyFontSize':
        final keyFontSize = call.arguments as double;
        keyboardNotifier.updateKeyFontSize(keyFontSize);

      case 'updateSpaceFontSize':
        final spaceFontSize = call.arguments as double;
        keyboardNotifier.updateSpaceFontSize(spaceFontSize);

      // Markers settings
      case 'updateMarkerOffset':
        final markerOffset = call.arguments as double;
        keyboardNotifier.updateMarkerOffset(markerOffset);

      case 'updateMarkerWidth':
        final markerWidth = call.arguments as double;
        keyboardNotifier.updateMarkerWidth(markerWidth);

      case 'updateMarkerHeight':
        final markerHeight = call.arguments as double;
        keyboardNotifier.updateMarkerHeight(markerHeight);

      case 'updateMarkerBorderRadius':
        final markerBorderRadius = call.arguments as double;
        keyboardNotifier.updateMarkerBorderRadius(markerBorderRadius);

      // Colors settings
      case 'updateKeyColorPressed':
        final keyColorPressed = call.arguments as int;
        keyboardNotifier.updateKeyColorPressed(Color(keyColorPressed));

      case 'updateKeyColorNotPressed':
        final keyColorNotPressed = call.arguments as int;
        keyboardNotifier.updateKeyColorNotPressed(Color(keyColorNotPressed));

      case 'updateMarkerColor':
        final markerColor = call.arguments as int;
        keyboardNotifier.updateMarkerColor(Color(markerColor));

      case 'updateMarkerColorNotPressed':
        final markerColorNotPressed = call.arguments as int;
        keyboardNotifier
            .updateMarkerColorNotPressed(Color(markerColorNotPressed));

      case 'updateKeyTextColor':
        final keyTextColor = call.arguments as int;
        keyboardNotifier.updateKeyTextColor(Color(keyTextColor));

      case 'updateKeyTextColorNotPressed':
        final keyTextColorNotPressed = call.arguments as int;
        keyboardNotifier
            .updateKeyTextColorNotPressed(Color(keyTextColorNotPressed));

      case 'updateKeyBorderColorPressed':
        final keyBorderColorPressed = call.arguments as int;
        keyboardNotifier
            .updateKeyBorderColorPressed(Color(keyBorderColorPressed));

      case 'updateKeyBorderColorNotPressed':
        final keyBorderColorNotPressed = call.arguments as int;
        keyboardNotifier
            .updateKeyBorderColorNotPressed(Color(keyBorderColorNotPressed));

      // Animations settings
      case 'updateAnimationEnabled':
        final animationEnabled = call.arguments as bool;
        keyboardNotifier.updateAnimationEnabled(animationEnabled);

      case 'updateAnimationStyle':
        final animationStyle = call.arguments as String;
        keyboardNotifier.updateAnimationStyle(animationStyle);

      case 'updateAnimationDuration':
        final animationDuration = call.arguments as double;
        keyboardNotifier.updateAnimationDuration(animationDuration);

      case 'updateAnimationScale':
        final animationScale = call.arguments as double;
        keyboardNotifier.updateAnimationScale(animationScale);

      // HotKey settings
      case 'updateHotKeysEnabled':
        final hotKeysEnabled = call.arguments as bool;
        appNotifier.updateHotKeysEnabled(hotKeysEnabled);
        await setupHotKeys();

      case 'updateVisibilityHotKey':
        final hotKeyJson = call.arguments as String;
        final newHotKey = HotKey.fromJson(jsonDecode(hotKeyJson));
        final currentVisibilityHotKey =
            ref.read(appStateNotifierProvider).visibilityHotKey;
        if (currentVisibilityHotKey != null) {
          await hotKeyManager.unregister(currentVisibilityHotKey);
        }
        appNotifier.updateVisibilityHotKey(newHotKey);
        await setupHotKeys();

      case 'updateAutoHideHotKey':
        final hotKeyJson = call.arguments as String;
        final newHotKey = HotKey.fromJson(jsonDecode(hotKeyJson));
        final currentAutoHideHotKey =
            ref.read(appStateNotifierProvider).autoHideHotKey;
        if (currentAutoHideHotKey != null) {
          await hotKeyManager.unregister(currentAutoHideHotKey);
        }
        appNotifier.updateAutoHideHotKey(newHotKey);
        await setupHotKeys();

      case 'updateToggleMoveHotKey':
        final hotKeyJson = call.arguments as String;
        final newHotKey = HotKey.fromJson(jsonDecode(hotKeyJson));
        final currentToggleMoveHotKey =
            ref.read(appStateNotifierProvider).toggleMoveHotKey;
        if (currentToggleMoveHotKey != null) {
          await hotKeyManager.unregister(currentToggleMoveHotKey);
        }
        appNotifier.updateToggleMoveHotKey(newHotKey);
        await setupHotKeys();

      case 'updatePreferencesHotKey':
        final hotKeyJson = call.arguments as String;
        final newHotKey = HotKey.fromJson(jsonDecode(hotKeyJson));
        final currentPreferencesHotKey =
            ref.read(appStateNotifierProvider).preferencesHotKey;
        if (currentPreferencesHotKey != null) {
          await hotKeyManager.unregister(currentPreferencesHotKey);
        }
        appNotifier.updatePreferencesHotKey(newHotKey);
        await setupHotKeys();

      case 'updateIncreaseOpacityHotKey':
        final hotKeyJson = call.arguments as String;
        final newHotKey = HotKey.fromJson(jsonDecode(hotKeyJson));
        final currentIncreaseOpacityHotKey =
            ref.read(appStateNotifierProvider).increaseOpacityHotKey;
        if (currentIncreaseOpacityHotKey != null) {
          await hotKeyManager.unregister(currentIncreaseOpacityHotKey);
        }
        appNotifier.updateIncreaseOpacityHotKey(newHotKey);
        await setupHotKeys();

      case 'updateDecreaseOpacityHotKey':
        final hotKeyJson = call.arguments as String;
        final newHotKey = HotKey.fromJson(jsonDecode(hotKeyJson));
        final currentDecreaseOpacityHotKey =
            ref.read(appStateNotifierProvider).decreaseOpacityHotKey;
        if (currentDecreaseOpacityHotKey != null) {
          await hotKeyManager.unregister(currentDecreaseOpacityHotKey);
        }
        appNotifier.updateDecreaseOpacityHotKey(newHotKey);
        await setupHotKeys();

      case 'updateEnableVisibilityHotKey':
        final enabled = call.arguments as bool;
        appNotifier.updateEnableVisibilityHotKey(enabled);
        await setupHotKeys();

      case 'updateEnableAutoHideHotKey':
        final enabled = call.arguments as bool;
        appNotifier.updateEnableAutoHideHotKey(enabled);
        await setupHotKeys();

      case 'updateEnableToggleMoveHotKey':
        final enabled = call.arguments as bool;
        appNotifier.updateEnableToggleMoveHotKey(enabled);
        await setupHotKeys();

      case 'updateEnablePreferencesHotKey':
        final enabled = call.arguments as bool;
        appNotifier.updateEnablePreferencesHotKey(enabled);
        await setupHotKeys();

      case 'updateEnableIncreaseOpacityHotKey':
        final enabled = call.arguments as bool;
        appNotifier.updateEnableIncreaseOpacityHotKey(enabled);
        await setupHotKeys();

      case 'updateEnableDecreaseOpacityHotKey':
        final enabled = call.arguments as bool;
        appNotifier.updateEnableDecreaseOpacityHotKey(enabled);
        await setupHotKeys();

      // Learning mode settings
      case 'updateLearningModeEnabled':
        final learningModeEnabled = call.arguments as bool;
        keyboardNotifier.updateLearningModeEnabled(learningModeEnabled);

      case 'updatePinkyLeftColor':
        final color = call.arguments as int;
        keyboardNotifier.updatePinkyLeftColor(Color(color));

      case 'updateRingLeftColor':
        final color = call.arguments as int;
        keyboardNotifier.updateRingLeftColor(Color(color));

      case 'updateMiddleLeftColor':
        final color = call.arguments as int;
        keyboardNotifier.updateMiddleLeftColor(Color(color));

      case 'updateIndexLeftColor':
        final color = call.arguments as int;
        keyboardNotifier.updateIndexLeftColor(Color(color));

      case 'updateIndexRightColor':
        final color = call.arguments as int;
        keyboardNotifier.updateIndexRightColor(Color(color));

      case 'updateMiddleRightColor':
        final color = call.arguments as int;
        keyboardNotifier.updateMiddleRightColor(Color(color));

      case 'updateRingRightColor':
        final color = call.arguments as int;
        keyboardNotifier.updateRingRightColor(Color(color));

      case 'updatePinkyRightColor':
        final color = call.arguments as int;
        keyboardNotifier.updatePinkyRightColor(Color(color));

      // Advanced settings
      case 'updateAdvancedSettingsEnabled':
        final advancedSettingsEnabled = call.arguments as bool;
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
          keyboardNotifier.updateShowAltLayout(false);
          if (currentPrefsState.customFontEnabled) {
            keyboardNotifier.updateFontFamily(
                keyboardState.initialFontFamily ?? keyboardState.fontFamily);
          }
          if (currentPrefsState.keyboardFollowsMouse) {
            stopMouseTracking();
          }
        } else {
          if (keyboardState.showAltLayout) {
            loadAltLayout();
          }
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
          if (keyboardState.showAltLayout) {
            loadAltLayout();
          }
          if (currentPrefsState.customFontEnabled) {
            loadCustomFont();
          }
        } else {
          fadeIn();
        }

      case 'updateUseUserLayout':
        final useUserLayout = call.arguments as bool;
        prefsNotifier.updateUseUserLayout(useUserLayout);
        if (useUserLayout) {
          loadUserLayout();
        } else {
          final keyboardState = ref.read(keyboardNotifierProvider);
          if (keyboardState.initialLayout != null &&
              !keyboardState.kanataEnabled) {
            keyboardNotifier.updateLayout(keyboardState.initialLayout!);
          }
          fadeIn();
        }

      case 'updateShowAltLayout':
        final showAltLayout = call.arguments as bool;
        keyboardNotifier.updateShowAltLayout(showAltLayout);
        if (showAltLayout) {
          loadAltLayout();
        }
        fadeIn();

      case 'updateCustomFontEnabled':
        final customFontEnabled = call.arguments as bool;
        prefsNotifier.updateCustomFontEnabled(customFontEnabled);
        final keyboardState = ref.read(keyboardNotifierProvider);
        if (customFontEnabled) {
          loadCustomFont();
        } else {
          keyboardNotifier.updateFontFamily(
              keyboardState.initialFontFamily ?? keyboardState.fontFamily);
        }

      case 'updateUse6ColLayout':
        final use6ColLayout = call.arguments as bool;
        prefsNotifier.updateUse6ColLayout(use6ColLayout);
        fadeIn();

      case 'updateKanataEnabled':
        final kanataEnabled = call.arguments as bool;
        final keyboardState = ref.read(keyboardNotifierProvider);
        if (kanataEnabled && !keyboardState.kanataEnabled) {
          keyboardNotifier.updateInitialLayout(keyboardState.layout);
          keyboardNotifier.updateKanataEnabled(true);
          await useKanata();
        } else if (!kanataEnabled && keyboardState.kanataEnabled) {
          keyboardNotifier.updateKanataEnabled(false);
          kanataService.disconnect();
          if (keyboardState.initialLayout != null) {
            keyboardNotifier.updateLayout(keyboardState.initialLayout!);
            fadeIn();
          }
        }

      case 'updateKeyboardFollowsMouse':
        final keyboardFollowsMouse = call.arguments as bool;
        prefsNotifier.updateKeyboardFollowsMouse(keyboardFollowsMouse);
        final currentPrefsState = ref.read(preferencesNotifierProvider);
        if (keyboardFollowsMouse && currentPrefsState.advancedSettingsEnabled) {
          startMouseTracking(true);
        } else {
          stopMouseTracking();
        }

      case 'updateHideOnDefaultLayer':
        final hideOnDefaultLayer = call.arguments as bool;
        prefsNotifier.updateHideOnDefaultLayer(hideOnDefaultLayer);

      default:
        throw UnimplementedError('Unimplemented method ${call.method}');
    }
  }
}
