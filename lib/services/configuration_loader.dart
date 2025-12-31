import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overkeys/services/config_service.dart';
import 'package:overkeys/services/kanata_service.dart';
import 'package:overkeys/providers/keyboard_provider.dart';
import 'package:overkeys/providers/preferences_provider.dart';

/// Service for loading user configurations (layouts, fonts, Kanata integration)
class ConfigurationLoader {
  final ConfigService _configService;
  final KanataService _kanataService;

  ConfigurationLoader(this._kanataService, {ConfigService? configService})
      : _configService = configService ?? ConfigService();

  /// Clears the cached configuration to force reload from file
  void clearConfigCache() {
    _configService.clearCache();
  }

  Future<void> loadAllConfiguration(WidgetRef ref) async {
    final prefsState = ref.read(preferencesNotifierProvider);
    await loadCustomShiftMappings(ref);
    await loadCustomAliases(ref);

    if (prefsState.advancedSettingsEnabled) {
      if (prefsState.useUserLayout) {
        await loadUserLayout(ref);
        await loadUserLayers(ref);
      }
      if (prefsState.showAltLayout) {
        await loadAltLayout(ref);
      }
      if (prefsState.customFontEnabled) {
        await loadCustomFont(ref);
      }
      if (prefsState.kanataEnabled) {
        await useKanata(ref);
      }
    }
  }

  Future<void> loadCustomShiftMappings(WidgetRef ref) async {
    final mappings = await _configService.getCustomShiftMappings();
    ref
        .read(keyboardNotifierProvider.notifier)
        .updateCustomShiftMappings(mappings);
  }

  Future<void> loadCustomAliases(WidgetRef ref) async {
    final aliases = await _configService.getCustomAliases();
    ref.read(keyboardNotifierProvider.notifier).updateCustomAliases(aliases);
  }

  Future<void> loadUserLayout(WidgetRef ref) async {
    final prefsState = ref.read(preferencesNotifierProvider);
    if (!prefsState.useUserLayout) return;

    final keyboardNotifier = ref.read(keyboardNotifierProvider.notifier);
    final prefsNotifier = ref.read(preferencesNotifierProvider.notifier);
    final userLayout = await _configService.getUserLayout();

    if (userLayout != null) {
      prefsNotifier.updateDefaultUserLayout(userLayout);

      // Don't update initialLayout here - it should preserve the previous layout
      // so we can restore it when user layout is toggled off
      if (!prefsState.kanataEnabled) {
        keyboardNotifier.updateLayout(userLayout);
      }
    }
  }

  Future<void> loadUserLayers(WidgetRef ref) async {
    final prefsState = ref.read(preferencesNotifierProvider);
    if (!prefsState.useUserLayout) return;

    final prefsNotifier = ref.read(preferencesNotifierProvider.notifier);
    final layers = await _configService.getUserLayers();

    prefsNotifier.updateUserLayers(layers);
  }

  Future<void> loadAltLayout(WidgetRef ref) async {
    final prefsState = ref.read(preferencesNotifierProvider);
    if (!prefsState.showAltLayout) return;

    final prefsNotifier = ref.read(preferencesNotifierProvider.notifier);
    final keyboardNotifier = ref.read(keyboardNotifierProvider.notifier);
    final altLayout = await _configService.getAltLayout();

    if (altLayout != null) {
      prefsNotifier.updateAltLayout(altLayout);
      keyboardNotifier.updateShowAltLayout(true);
    } else {
      prefsNotifier.updateAltLayout(null);
      keyboardNotifier.updateShowAltLayout(false);
    }
  }

  Future<void> loadCustomFont(WidgetRef ref) async {
    final prefsState = ref.read(preferencesNotifierProvider);
    if (!prefsState.customFontEnabled || !prefsState.advancedSettingsEnabled) {
      return;
    }

    final keyboardNotifier = ref.read(keyboardNotifierProvider.notifier);
    final customFont = await _configService.getCustomFont();

    if (customFont != null) {
      keyboardNotifier.updateFontFamily(customFont);
    }
  }

  Future<void> useKanata(WidgetRef ref) async {
    final keyboardNotifier = ref.read(keyboardNotifierProvider.notifier);
    final keyboardState = ref.read(keyboardNotifierProvider);
    final prefsState = ref.read(preferencesNotifierProvider);

    // Save the current layout as initialLayout so we can restore it when Kanata is disabled
    // This should be the layout that was displayed before Kanata takes control
    if (keyboardState.initialLayout == null) {
      keyboardNotifier.updateInitialLayout(keyboardState.layout);
    }

    if (prefsState.kanataEnabled && prefsState.advancedSettingsEnabled) {
      try {
        await _kanataService.connect();
      } catch (e) {
        // Connection will be retried by the KanataService
        // Log error but don't throw to avoid disrupting app initialization
        if (kDebugMode) {
          print('Failed to connect to Kanata: $e');
        }
      }
    }
  }
}
