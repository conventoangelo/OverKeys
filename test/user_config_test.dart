import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
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
}
