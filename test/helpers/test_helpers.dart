import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Test helper utilities and common test data

/// Sample keyboard layout for testing
const testLayout = {
  'name': 'Test Layout',
  'keys': [
    ['Q', 'W', 'E'],
    ['A', 'S', 'D'],
  ],
};

/// Sample user config JSON for testing
const sampleUserConfigJson = {
  'defaultUserLayout': 'Colemak',
  'altLayout': 'QWERTY',
  'userLayouts': [
    {
      'name': 'Custom Layout',
      'keys': [
        ['A', 'B', 'C'],
        ['D', 'E', 'F'],
      ],
      'trigger': 'F13',
      'type': 'toggle',
    },
  ],
  'customShiftMappings': {
    'a': '@',
    'b': '#',
  },
  'kanataHost': '127.0.0.1',
  'kanataPort': 4039,
};

/// Sample hotkey configuration JSON
const sampleHotKeyConfig = {
  'hotKeysEnabled': true,
  'enableVisibilityHotKey': true,
  'enableAutoHideHotKey': false,
};

/// Creates a temporary directory for file-based tests
/// Returns the directory path
Future<String> createTempTestDirectory() async {
  final dir = await Directory.systemTemp.createTemp('overkeys_test');
  return dir.path;
}

/// Cleans up a temporary test directory
Future<void> cleanupTempDirectory(String path) async {
  final dir = Directory(path);
  if (await dir.exists()) {
    await dir.delete(recursive: true);
  }
}

/// Matcher for testing Set equality
Matcher equalsSet(Set expected) {
  return predicate((actual) {
    if (actual is! Set) return false;
    return actual.length == expected.length &&
        actual.every((element) => expected.contains(element));
  }, 'equals set $expected');
}

/// Matcher for testing if a string contains any of the given substrings
Matcher containsAny(List<String> substrings) {
  return predicate((actual) {
    if (actual is! String) return false;
    return substrings.any((substring) => actual.contains(substring));
  }, 'contains any of $substrings');
}
