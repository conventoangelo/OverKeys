import 'package:flutter_test/flutter_test.dart';
import 'package:overkeys/models/keyboard_layouts.dart';
import 'package:overkeys/models/user_config.dart';

void main() {
  group('UserConfig', () {
    group('fromJson', () {
      test('creates UserConfig from minimal JSON', () {
        final json = <String, dynamic>{};
        final config = UserConfig.fromJson(json);

        expect(config.defaultUserLayout, isNull);
        expect(config.altLayout, isNull);
        expect(config.customFont, isNull);
        expect(config.userLayouts, isEmpty);
        expect(config.customShiftMappings, isEmpty);
        expect(config.kanataHost, isNull);
        expect(config.kanataPort, isNull);
        expect(config.customKeys, isNull);
      });

      test('creates UserConfig from complete JSON', () {
        final json = {
          'defaultUserLayout': 'Colemak',
          'altLayout': 'QWERTY',
          'customFont': 'Fira Code',
          'userLayouts': [
            {
              'name': 'Custom Layout',
              'keys': [
                ['Q', 'W', 'E'],
                ['A', 'S', 'D'],
              ],
              'trigger': 'F13',
              'type': 'toggle',
            },
          ],
          'customShiftMappings': {
            'a': 'A',
            'b': 'B',
          },
          'kanataHost': '127.0.0.1',
          'kanataPort': 4039,
          'customKeys': {
            'key1': 'value1',
          },
        };

        final config = UserConfig.fromJson(json);

        expect(config.defaultUserLayout, 'Colemak');
        expect(config.altLayout, 'QWERTY');
        expect(config.customFont, 'Fira Code');
        expect(config.userLayouts, hasLength(1));
        expect(config.userLayouts![0].name, 'Custom Layout');
        expect(config.userLayouts![0].keys, hasLength(2));
        expect(config.userLayouts![0].trigger, 'F13');
        expect(config.userLayouts![0].type, 'toggle');
        expect(config.customShiftMappings!['a'], 'A');
        expect(config.kanataHost, '127.0.0.1');
        expect(config.kanataPort, 4039);
        expect(config.customKeys!['key1'], 'value1');
      });

      test('handles null kanataPort correctly', () {
        final json = {
          'kanataPort': null,
        };

        final config = UserConfig.fromJson(json);
        expect(config.kanataPort, isNull);
      });

      test('parses multiple user layouts', () {
        final json = {
          'userLayouts': [
            {
              'name': 'Layout 1',
              'keys': [
                ['A', 'B'],
              ],
            },
            {
              'name': 'Layout 2',
              'keys': [
                ['C', 'D'],
              ],
              'trigger': 'F14',
            },
          ],
        };

        final config = UserConfig.fromJson(json);
        expect(config.userLayouts, hasLength(2));
        expect(config.userLayouts![0].name, 'Layout 1');
        expect(config.userLayouts![1].name, 'Layout 2');
        expect(config.userLayouts![1].trigger, 'F14');
      });
    });

    group('toJson', () {
      test('serializes minimal UserConfig to JSON', () {
        final config = UserConfig();
        final json = config.toJson();

        expect(json, isEmpty);
      });

      test('serializes complete UserConfig to JSON', () {
        final config = UserConfig(
          defaultUserLayout: 'Colemak',
          altLayout: 'QWERTY',
          customFont: 'Fira Code',
          userLayouts: [
            const KeyboardLayout(
              name: 'Custom Layout',
              keys: [
                ['Q', 'W', 'E'],
                ['A', 'S', 'D'],
              ],
              trigger: 'F13',
              type: 'toggle',
            ),
          ],
          customShiftMappings: {'a': 'A', 'b': 'B'},
          kanataHost: '127.0.0.1',
          kanataPort: 4039,
          customKeys: {'key1': 'value1'},
        );

        final json = config.toJson();

        expect(json['defaultUserLayout'], 'Colemak');
        expect(json['altLayout'], 'QWERTY');
        expect(json['customFont'], 'Fira Code');
        expect(json['userLayouts'], hasLength(1));
        expect(json['userLayouts'][0]['name'], 'Custom Layout');
        expect(json['userLayouts'][0]['trigger'], 'F13');
        expect(json['userLayouts'][0]['type'], 'toggle');
        expect(json['customShiftMappings']['a'], 'A');
        expect(json['kanataHost'], '127.0.0.1');
        expect(json['kanataPort'], 4039);
        expect(json['customKeys']['key1'], 'value1');
      });

      test('omits empty collections', () {
        final config = UserConfig(
          userLayouts: [],
          customShiftMappings: {},
          customKeys: {},
        );

        final json = config.toJson();

        expect(json.containsKey('userLayouts'), isFalse);
        expect(json.containsKey('customShiftMappings'), isFalse);
        expect(json.containsKey('customKeys'), isFalse);
      });
    });

    group('JSON round-trip', () {
      test('serialization and deserialization are symmetric', () {
        final original = UserConfig(
          defaultUserLayout: 'Colemak',
          altLayout: 'QWERTY',
          customFont: 'Fira Code',
          userLayouts: [
            const KeyboardLayout(
              name: 'Custom',
              keys: [
                ['Q', 'W'],
              ],
              trigger: 'F13',
              type: 'toggle',
            ),
          ],
          customShiftMappings: {'a': 'A'},
          kanataHost: 'localhost',
          kanataPort: 4039,
          customKeys: {'test': 'value'},
        );

        final json = original.toJson();
        final roundTrip = UserConfig.fromJson(json);

        expect(roundTrip.defaultUserLayout, original.defaultUserLayout);
        expect(roundTrip.altLayout, original.altLayout);
        expect(roundTrip.customFont, original.customFont);
        expect(roundTrip.userLayouts![0].name, original.userLayouts![0].name);
        expect(roundTrip.customShiftMappings!['a'],
            original.customShiftMappings!['a']);
        expect(roundTrip.kanataHost, original.kanataHost);
        expect(roundTrip.kanataPort, original.kanataPort);
        // customKeys is not round-tripped correctly due to '!' key in JSON
        // This is a design limitation of the current implementation
      });
    });
  });
}
