import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../models/user_config.dart';

class ConfigService {
  static const String _configFileName = 'overkeys_config.json';
  UserConfig? _cachedConfig;

  // Get the path to the config file
  Future<String> get _configPath async {
    final directory = await getApplicationSupportDirectory();
    return '${directory.path}\\$_configFileName';
  }

  // Public accessor for config path
  Future<String> get configPath => _configPath;

  // Load configuration from file
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

  // Save configuration to file
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

  // Get Kanata configuration if enabled
  Future<Map<String, dynamic>?> getKanataConfig() async {
    final config = await loadConfig();

    return {
      'host': config.kanataHost,
      'port': config.kanataPort,
      'kanataLayers': config.kanataLayers,
      'defaultLayer': config.defaultLayer,
    };
  }
}
