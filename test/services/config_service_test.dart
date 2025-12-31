import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:overkeys/models/keyboard_layouts.dart';
import 'package:overkeys/models/user_config.dart';
import 'package:overkeys/services/config_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  String? _applicationSupportDirectory;

  void setApplicationSupportDirectory(String path) {
    _applicationSupportDirectory = path;
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return _applicationSupportDirectory;
  }
}

void main() {
  group('ConfigService', () {
    late ConfigService configService;
    late MockPathProviderPlatform mockPathProvider;
    late Directory tempDir;

    setUp(() async {
      configService = ConfigService();
      mockPathProvider = MockPathProviderPlatform();
      PathProviderPlatform.instance = mockPathProvider;

      tempDir = await Directory.systemTemp.createTemp('config_test_');
      mockPathProvider.setApplicationSupportDirectory(tempDir.path);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('Configuration file handling', () {
      test('creates default config when file does not exist', () async {
        final config = await configService.loadConfig();

        expect(config, isA<UserConfig>());
        // Default config has no default values set
        expect(config.defaultUserLayout, isNull);
      });

      test('saves and loads config from file', () async {
        final originalConfig = UserConfig(
          defaultUserLayout: 'MyCustomLayout',
          altLayout: 'Dvorak',
        );

        await configService.saveConfig(originalConfig);
        final loadedConfig = await configService.loadConfig();

        expect(loadedConfig.defaultUserLayout, 'MyCustomLayout');
        expect(loadedConfig.altLayout, 'Dvorak');
      });

      test('updates existing config file', () async {
        final firstConfig = UserConfig(defaultUserLayout: 'QWERTY');
        await configService.saveConfig(firstConfig);

        final secondConfig = UserConfig(defaultUserLayout: 'Dvorak');
        await configService.saveConfig(secondConfig);

        final loadedConfig = await configService.loadConfig();
        expect(loadedConfig.defaultUserLayout, 'Dvorak');
      });

      test('caches loaded configuration', () async {
        final config1 = await configService.loadConfig();
        final config2 = await configService.loadConfig();

        expect(identical(config1, config2), true);
      });

      test('updates cache when saving config', () async {
        final newConfig = UserConfig(defaultUserLayout: 'Colemak');
        await configService.saveConfig(newConfig);

        final cachedConfig = await configService.loadConfig();
        expect(cachedConfig.defaultUserLayout, 'Colemak');
      });
    });

    group('getUserLayout', () {
      test('returns null when defaultUserLayout is not defined', () async {
        final config = UserConfig();
        await configService.saveConfig(config);

        final layout = await configService.getUserLayout();
        expect(layout, isNull);
      });

      test('returns layout from userLayouts when available', () async {
        final customLayout = KeyboardLayout(
          name: 'MyCustomLayout',
          keys: [
            ['Q', 'W', 'E', 'R', 'T'],
          ],
        );

        final config = UserConfig(
          defaultUserLayout: 'MyCustomLayout',
          userLayouts: [customLayout],
        );
        await configService.saveConfig(config);

        final layout = await configService.getUserLayout();
        expect(layout, isNotNull);
        expect(layout!.name, 'MyCustomLayout');
      });

      test('returns built-in layout when not in userLayouts', () async {
        final config = UserConfig(defaultUserLayout: 'Colemak');
        await configService.saveConfig(config);

        final layout = await configService.getUserLayout();
        expect(layout, isNotNull);
        expect(layout!.name, 'Colemak');
      });

      test('returns null when layout not found anywhere', () async {
        final config = UserConfig(defaultUserLayout: 'NonExistentLayout');
        await configService.saveConfig(config);

        final layout = await configService.getUserLayout();
        expect(layout, isNull);
      });

      test('prioritizes userLayouts over built-in layouts', () async {
        final customQwerty = KeyboardLayout(
          name: 'QWERTY',
          keys: [
            ['X', 'Y', 'Z'], // Different from built-in QWERTY
          ],
        );

        final config = UserConfig(
          defaultUserLayout: 'QWERTY',
          userLayouts: [customQwerty],
        );
        await configService.saveConfig(config);

        final layout = await configService.getUserLayout();
        expect(layout!.keys.first.first, 'X'); // Custom, not built-in
      });
    });

    group('getAltLayout', () {
      test('returns null when altLayout is not defined', () async {
        final config = UserConfig();
        await configService.saveConfig(config);

        final layout = await configService.getAltLayout();
        expect(layout, isNull);
      });

      test('returns layout from userLayouts when available', () async {
        final customAlt = KeyboardLayout(
          name: 'MyAltLayout',
          keys: [
            ['1', '2', '3'],
          ],
        );

        final config = UserConfig(
          altLayout: 'MyAltLayout',
          userLayouts: [customAlt],
        );
        await configService.saveConfig(config);

        final layout = await configService.getAltLayout();
        expect(layout, isNotNull);
        expect(layout!.name, 'MyAltLayout');
      });

      test('returns built-in layout when not in userLayouts', () async {
        final config = UserConfig(altLayout: 'Dvorak');
        await configService.saveConfig(config);

        final layout = await configService.getAltLayout();
        expect(layout, isNotNull);
        expect(layout!.name, 'Dvorak');
      });

      test('returns null when layout not found', () async {
        final config = UserConfig(altLayout: 'UnknownLayout');
        await configService.saveConfig(config);

        final layout = await configService.getAltLayout();
        expect(layout, isNull);
      });
    });

    group('Custom fonts', () {
      test('loads font path when customFont is set', () async {
        final config = UserConfig(
          customFont: 'C:\\Fonts\\CustomFont.ttf',
        );
        await configService.saveConfig(config);

        final loadedConfig = await configService.loadConfig();
        expect(loadedConfig.customFont, 'C:\\Fonts\\CustomFont.ttf');
      });

      test('handles missing customFont gracefully', () async {
        final config = UserConfig();
        await configService.saveConfig(config);

        final loadedConfig = await configService.loadConfig();
        expect(loadedConfig.customFont, isNull);
      });
    });

    group('Error handling', () {
      test('returns default config on JSON parse error', () async {
        final configPath = await configService.configPath;
        final file = File(configPath);
        await file.writeAsString('invalid json content');

        final config = await configService.loadConfig();
        expect(config, isA<UserConfig>());
      });

      test('returns default config on file read error', () async {
        final configPath = await configService.configPath;
        final file = File(configPath);
        await file.writeAsString('{"valid": "json"}');

        // Make file unreadable by creating a directory with same name
        await file.delete();
        await Directory(configPath).create();

        final config = await configService.loadConfig();
        expect(config, isA<UserConfig>());

        await Directory(configPath).delete();
      });
    });

    group('Config path', () {
      test('returns correct config file path', () async {
        final path = await configService.configPath;
        expect(path, contains('overkeys_config.json'));
        expect(path, contains(tempDir.path));
      });

      test('config path is consistent across calls', () async {
        final path1 = await configService.configPath;
        final path2 = await configService.configPath;
        expect(path1, path2);
      });
    });

    group('userLayouts handling', () {
      test('saves and loads multiple user layouts', () async {
        final layout1 = KeyboardLayout(
          name: 'Custom1',
          keys: [
            ['A', 'B', 'C'],
          ],
        );
        final layout2 = KeyboardLayout(
          name: 'Custom2',
          keys: [
            ['X', 'Y', 'Z'],
          ],
        );

        final config = UserConfig(
          userLayouts: [layout1, layout2],
        );
        await configService.saveConfig(config);

        final loadedConfig = await configService.loadConfig();
        expect(loadedConfig.userLayouts, isNotNull);
        expect(loadedConfig.userLayouts!.length, 2);
        expect(loadedConfig.userLayouts![0].name, 'Custom1');
        expect(loadedConfig.userLayouts![1].name, 'Custom2');
      });

      test('handles empty userLayouts list', () async {
        final config = UserConfig(userLayouts: []);
        await configService.saveConfig(config);

        final loadedConfig = await configService.loadConfig();
        expect(loadedConfig.userLayouts, isEmpty);
      });
    });
  });
}
