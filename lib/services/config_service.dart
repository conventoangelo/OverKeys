import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../models/user_config.dart';
import '../utils/keyboard_layouts.dart';

class ConfigService {
  static const String _configFileName = 'overkeys_config.json';
  UserConfig? _cachedConfig;

  Future<String> get _configPath async {
    final directory = await getApplicationSupportDirectory();
    return '${directory.path}\\$_configFileName';
  }

  Future<String> get configPath => _configPath;

  Future<UserConfig> loadConfig() async {
    if (_cachedConfig != null) {
      // If config is changed, while app is running, cached config will be returned
      // User needs to restart the app to get the updated config
      return _cachedConfig!;
    }

    try {
      final path = await _configPath;
      if (kDebugMode) {
        print('Config path: $path');
      }
      final file = File(path);

      if (await file.exists()) {
        final contents = await file.readAsString();
        final json = jsonDecode(contents) as Map<String, dynamic>;
        _cachedConfig = UserConfig.fromJson(json);
        if (kDebugMode) {
          final configCopy = _cachedConfig!.toJson();
          configCopy['userLayouts'] =
              _cachedConfig!.userLayouts.map((layout) => layout.name).toList();
          print('Config contents: ${jsonEncode(configCopy)}');
        }
      } else {
        // Create default config if file doesn't exist
        _cachedConfig = UserConfig();
        await saveConfig(_cachedConfig!);
        if (kDebugMode) {
          print('Created default config: $path');
        }
      }
    } catch (e) {
      debugPrint('Error loading config: $e');
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
      debugPrint('Error saving config: $e');
    }
  }

  Future<Map<String, dynamic>?> getKanataConfig() async {
    final config = await loadConfig();

    return {
      'host': config.kanataHost,
      'port': config.kanataPort,
      'userLayouts': config.userLayouts,
      'defaultUserLayout': config.defaultUserLayout,
      'altLayout': config.altLayout,
    };
  }

  Future<KeyboardLayout?> getUserLayout() async {
    final config = await loadConfig();
    final defaultLayoutName = config.defaultUserLayout;

    for (final layout in config.userLayouts) {
      if (layout.name == defaultLayoutName) {
        return layout;
      }
    }

    try {
      return availableLayouts
          .firstWhere((layout) => layout.name == defaultLayoutName);
    } catch (e) {
      if (kDebugMode) {
        print('Default user layout "$defaultLayoutName" not found');
      }
      return null;
    }
  }

  Future<KeyboardLayout?> getAltLayout() async {
    final config = await loadConfig();
    final altLayoutName = config.altLayout;

    for (final layout in config.userLayouts) {
      if (layout.name == altLayoutName) {
        if (kDebugMode) {
          print('Alt layout found: $altLayoutName');
        }
        return layout;
      }
    }

    try {
      return availableLayouts
          .firstWhere((layout) => layout.name == altLayoutName);
    } catch (e) {
      if (kDebugMode) {
        print('Alt layout "$altLayoutName" not found');
      }
      return null;
    }
  }
}
