import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overkeys/services/config_service.dart';
import 'package:overkeys/services/kanata_service.dart';
import 'package:overkeys/providers/keyboard_provider.dart';
import 'package:overkeys/providers/preferences_provider.dart';
import '../utils/logger.dart';

/// Service for loading user configurations (layouts, fonts, Kanata integration)
class ConfigurationLoader {
  /// Logger instance for this service
  final _log = SimplePrintLogger('ConfigurationLoader');
  final ConfigService _configService;
  final KanataService _kanataService;

  ConfigurationLoader(this._kanataService, {ConfigService? configService})
      : _configService = configService ?? ConfigService();

  /// Clears the cached configuration to force reload from file
  void clearConfigCache() {
    _configService.clearCache();
  }

  Future<void> loadAllConfiguration(WidgetRef ref) async {
    final prefsState = ref.read(preferencesProvider);
    final prefsNotifier = ref.read(preferencesProvider.notifier);

    // Load the full user config first
    final config = await _configService.loadConfig();
    prefsNotifier.updateUserConfig(config);

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
        await loadUserLayout(ref);
        await useKanata(ref);
      }
    }
  }

  Future<void> loadCustomShiftMappings(WidgetRef ref) async {
    final mappings = await _configService.getCustomShiftMappings();
    ref.read(keyboardProvider.notifier).updateCustomShiftMappings(mappings);
  }

  Future<void> loadCustomAliases(WidgetRef ref) async {
    final aliases = await _configService.getCustomAliases();
    ref.read(keyboardProvider.notifier).updateCustomAliases(aliases);
  }

  Future<void> loadUserLayout(WidgetRef ref) async {
    final prefsState = ref.read(preferencesProvider);

    final keyboardNotifier = ref.read(keyboardProvider.notifier);
    final prefsNotifier = ref.read(preferencesProvider.notifier);
    final userLayout = await _configService.getUserLayout();

    if (userLayout != null) {
      prefsNotifier.updateDefaultUserLayout(userLayout.name);

      // Don't update initialLayout here - it should preserve the previous layout
      // so we can restore it when user layout is toggled off
      if (!prefsState.kanataEnabled) {
        keyboardNotifier.updateLayout(userLayout);
      }
    }
  }

  Future<void> loadUserLayers(WidgetRef ref) async {
    final prefsState = ref.read(preferencesProvider);
    if (!prefsState.useUserLayout) return;

    final prefsNotifier = ref.read(preferencesProvider.notifier);
    final layers = await _configService.getUserLayers();

    prefsNotifier.updateUserLayers(layers);
  }

  Future<void> loadAltLayout(WidgetRef ref) async {
    final prefsState = ref.read(preferencesProvider);
    if (!prefsState.showAltLayout) return;

    final prefsNotifier = ref.read(preferencesProvider.notifier);
    final keyboardNotifier = ref.read(keyboardProvider.notifier);
    final altLayout = await _configService.getAltLayout();

    if (altLayout != null) {
      prefsNotifier.updateAltLayout(altLayout.name);
      keyboardNotifier.updateShowAltLayout(true);
    } else {
      prefsNotifier.updateAltLayout(null);
      keyboardNotifier.updateShowAltLayout(false);
    }
  }

  Future<void> loadCustomFont(WidgetRef ref) async {
    final prefsState = ref.read(preferencesProvider);
    if (!prefsState.customFontEnabled || !prefsState.advancedSettingsEnabled) {
      return;
    }

    final keyboardNotifier = ref.read(keyboardProvider.notifier);
    final customFont = await _configService.getCustomFont();

    if (customFont != null) {
      keyboardNotifier.updateFontFamily(customFont);
    }
  }

  Future<void> useKanata(WidgetRef ref) async {
    final keyboardNotifier = ref.read(keyboardProvider.notifier);
    final keyboardState = ref.read(keyboardProvider);
    final prefsState = ref.read(preferencesProvider);

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
        _log.warning('Failed to connect to Kanata', error: e);
      }
    }
  }
}
