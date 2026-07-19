import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:overkeys/models/keyboard_layouts.dart';
import 'package:overkeys/models/user_config.dart';

void main() {
  test('UserConfig parses ignoredKeys correctly', () {
    final jsonString = '''
    {
      "ignoredKeys": ["A", "B", "Enter"]
    }
    ''';
    final json = jsonDecode(jsonString);
    final config = UserConfig.fromJson(json);

    expect(config.ignoredKeys, isNotNull);
    expect(config.ignoredKeys!.length, 3);
    expect(config.ignoredKeys, contains("A"));
    expect(config.ignoredKeys, contains("B"));
    expect(config.ignoredKeys, contains("Enter"));
  });

  test('UserConfig parses ignoredKeys as null when missing', () {
    final jsonString = '{}';
    final json = jsonDecode(jsonString);
    final config = UserConfig.fromJson(json);

    expect(config.ignoredKeys, isNull);
  });

  test('UserConfig toJson includes ignoredKeys', () {
    final config = UserConfig(ignoredKeys: ["X", "Y"]);
    final json = config.toJson();

    expect(json['ignoredKeys'], isNotNull);
    expect(json['ignoredKeys'], ["X", "Y"]);
  });

  test('UserConfig parses typed key objects with top labels', () {
    final jsonString = '''
    {
      "userLayouts": [
        {
          "name": "Layer",
          "keys": [
            ["A", {"h": "Shift", "t": "T", "type": "held"}]
          ]
        }
      ]
    }
    ''';
    final json = jsonDecode(jsonString);
    final config = UserConfig.fromJson(json);

    final layout = config.userLayouts!.first;
    expect(layout.keys[0][1], 'T');
    expect(layout.keySpecAt(0, 1), isNotNull);
    expect(layout.keySpecAt(0, 1)!.topLabel, 'Shift');
    expect(layout.keySpecAt(0, 1)!.trackedKey, 'T');
    expect(layout.isKeyPressedType(0, 1), isTrue);
  });

  test('UserConfig toJson preserves typed key objects', () {
    const layout = KeyboardLayout(
      name: 'Layer',
      keys: [
        ['A', 'T']
      ],
      keySpecs: [
        [
          null,
          KeyboardKeySpec(trackedKey: 'T', topLabel: 'Shift', type: 'held')
        ]
      ],
    );
    final config = UserConfig(userLayouts: [layout]);
    final json = config.toJson();

    final userLayouts = json['userLayouts'] as List<dynamic>;
    final keys = userLayouts.first['keys'] as List<dynamic>;
    final typedKey = keys[0][1] as Map<String, dynamic>;

    expect(typedKey['h'], 'Shift');
    expect(typedKey['t'], 'T');
    expect(typedKey['type'], 'held');
  });
}
