import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../models/user_config.dart';
import '../models/keyboard_layouts.dart';

/// Service for managing user configuration files
class ConfigService {
  static const String _configFileName = 'overkeys_config.json';

  /// Cached configuration to avoid repeated file reads
  UserConfig? _cachedConfig;

  Future<String> get _configPath async {
    final directory = await getApplicationSupportDirectory();
    return '${directory.path}${Platform.pathSeparator}$_configFileName';
  }

  Future<String> get configPath => _configPath;

  Future<UserConfig> loadConfig() async {
    if (_cachedConfig != null) {
      return _cachedConfig!;
    }

    try {
      final path = await _configPath;
      final file = File(path);

      if (await file.exists()) {
        final contents = await file.readAsString();
        final json = jsonDecode(contents) as Map<String, dynamic>;
        _cachedConfig = UserConfig.fromJson(json);
      } else {
        _cachedConfig = UserConfig();
        await saveConfig(_cachedConfig!);
      }
    } catch (e) {
      _cachedConfig = UserConfig();
    }

    return _cachedConfig!;
  }

  Future<void> saveConfig(UserConfig config) async {
    try {
      final path = await _configPath;
      final file = File(path);
      final jsonString = jsonEncode(config.toJson());
      await file.writeAsString(jsonString);
      _cachedConfig = config;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save config: $e');
      }
      // Config will not be persisted, but cache is updated
    }
  }

  /// Clears the cached configuration, forcing the next loadConfig() call to read from file
  void clearCache() {
    _cachedConfig = null;
  }

  Future<KeyboardLayout?> getUserLayout() async {
    final config = await loadConfig();

    if (config.defaultUserLayout == null) {
      return null;
    }

    final defaultLayoutName = config.defaultUserLayout;

    if (config.userLayouts != null) {
      for (final layout in config.userLayouts!) {
        if (layout.name == defaultLayoutName) {
          return layout;
        }
      }
    }

    try {
      return availableLayouts
          .firstWhere((layout) => layout.name == defaultLayoutName);
    } catch (e) {
      return null;
    }
  }

  Future<KeyboardLayout?> getAltLayout() async {
    final config = await loadConfig();

    if (config.altLayout == null) {
      return null;
    }

    final altLayoutName = config.altLayout;

    if (config.userLayouts != null) {
      for (final layout in config.userLayouts!) {
        if (layout.name == altLayoutName) {
          return layout;
        }
      }
    }

    try {
      return availableLayouts
          .firstWhere((layout) => layout.name == altLayoutName);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getCustomFont() async {
    final config = await loadConfig();

    if (config.customFont == null) {
      if (kDebugMode) {
        debugPrint(
            'Cannot get custom font: customFont is not defined in the config file');
      }
      return null;
    }

    return config.customFont;
  }

  Future<Map<String, String>?> getCustomShiftMappings() async {
    final config = await loadConfig();
    return config.customShiftMappings;
  }

  Future<List<KeyboardLayout>> getUserLayers() async {
    final config = await loadConfig();
    List<KeyboardLayout> layers = [];

    if (config.userLayouts != null) {
      layers.addAll(config.userLayouts!.where((l) => l.trigger != null));
    }

    return layers;
  }
}
