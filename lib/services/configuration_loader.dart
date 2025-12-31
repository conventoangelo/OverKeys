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

  Future<void> loadAllConfiguration(WidgetRef ref) async {
    final prefsState = ref.read(preferencesNotifierProvider);
    await loadCustomShiftMappings(ref);

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

  Future<void> loadUserLayout(WidgetRef ref) async {
    final prefsState = ref.read(preferencesNotifierProvider);
    if (!prefsState.useUserLayout) return;

    final keyboardNotifier = ref.read(keyboardNotifierProvider.notifier);
    final userLayout = await _configService.getUserLayout();

    if (userLayout != null) {
      keyboardNotifier.updateInitialLayout(userLayout);
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
    final prefsState = ref.read(preferencesNotifierProvider);
    final userLayout = await _configService.getUserLayout();

    if (userLayout != null) {
      keyboardNotifier.updateInitialLayout(userLayout);
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
