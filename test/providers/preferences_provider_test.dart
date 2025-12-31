import 'package:flutter_test/flutter_test.dart';
import 'package:overkeys/models/keyboard_layouts.dart';
import 'package:overkeys/models/user_config.dart';
import 'package:overkeys/providers/preferences_provider.dart';

void main() {
  group('PreferencesState', () {
    group('Constructor', () {
      test('creates PreferencesState with default values', () {
        final state = PreferencesState();

        expect(state.launchAtStartup, false);
        expect(state.hideAtStartup, false);
        expect(state.autoHideEnabled, false);
        expect(state.reactiveShiftEnabled, true);
        expect(state.autoHideDuration, 0.5);
        expect(state.opacity, 0.5);
        expect(state.useUserLayout, false);
        expect(state.showAltLayout, false);
        expect(state.customFontEnabled, false);
        expect(state.kanataEnabled, false);
        expect(state.keyboardFollowsMouse, false);
        expect(state.hideOnDefaultLayer, false);
        expect(state.userLayers, isEmpty);
      });

      test('creates PreferencesState with custom values', () {
        final state = PreferencesState(
          launchAtStartup: true,
          hideAtStartup: true,
          autoHideEnabled: true,
          autoHideDuration: 2.0,
          opacity: 0.8,
          kanataEnabled: true,
          keyboardFollowsMouse: true,
        );

        expect(state.launchAtStartup, true);
        expect(state.hideAtStartup, true);
        expect(state.autoHideEnabled, true);
        expect(state.autoHideDuration, 2.0);
        expect(state.opacity, 0.8);
        expect(state.kanataEnabled, true);
        expect(state.keyboardFollowsMouse, true);
      });

      test('initializes with layouts', () {
        final state = PreferencesState(
          initialKeyboardLayout: qwerty,
          defaultUserLayout: colemak,
          altLayout: dvorak,
        );

        expect(state.initialKeyboardLayout, qwerty);
        expect(state.defaultUserLayout, colemak);
        expect(state.altLayout, dvorak);
      });
    });

    group('copyWith', () {
      test('creates copy with updated general settings', () {
        final original = PreferencesState(
          launchAtStartup: false,
          hideAtStartup: false,
          autoHideEnabled: false,
        );

        final updated = original.copyWith(
          launchAtStartup: true,
          hideAtStartup: true,
          autoHideEnabled: true,
        );

        expect(updated.launchAtStartup, true);
        expect(updated.hideAtStartup, true);
        expect(updated.autoHideEnabled, true);
        expect(original.launchAtStartup, false);
      });

      test('creates copy with updated auto-hide settings', () {
        final original = PreferencesState(
          autoHideEnabled: false,
          autoHideDuration: 0.5,
        );

        final updated = original.copyWith(
          autoHideEnabled: true,
          autoHideDuration: 3.0,
        );

        expect(updated.autoHideEnabled, true);
        expect(updated.autoHideDuration, 3.0);
      });

      test('creates copy with updated opacity', () {
        final original = PreferencesState(opacity: 0.5);
        final updated = original.copyWith(opacity: 0.9);

        expect(updated.opacity, 0.9);
        expect(original.opacity, 0.5);
      });

      test('creates copy with updated layout preferences', () {
        final original = PreferencesState(
          useUserLayout: false,
          showAltLayout: false,
        );

        final updated = original.copyWith(
          useUserLayout: true,
          showAltLayout: true,
          defaultUserLayout: colemak,
        );

        expect(updated.useUserLayout, true);
        expect(updated.showAltLayout, true);
        expect(updated.defaultUserLayout, colemak);
      });

      test('creates copy with updated font settings', () {
        final original = PreferencesState(
          customFontEnabled: false,
          customFont: null,
        );

        final updated = original.copyWith(
          customFontEnabled: true,
          customFont: 'Fira Code',
        );

        expect(updated.customFontEnabled, true);
        expect(updated.customFont, 'Fira Code');
      });

      test('creates copy with updated Kanata settings', () {
        final original = PreferencesState(
          kanataEnabled: false,
          kanataHost: null,
          kanataPort: null,
        );

        final updated = original.copyWith(
          kanataEnabled: true,
          kanataHost: '127.0.0.1',
          kanataPort: 4039,
        );

        expect(updated.kanataEnabled, true);
        expect(updated.kanataHost, '127.0.0.1');
        expect(updated.kanataPort, 4039);
      });

      test('creates copy with updated advanced settings', () {
        final original = PreferencesState(
          advancedSettingsEnabled: false,
          keyboardFollowsMouse: false,
          hideOnDefaultLayer: false,
        );

        final updated = original.copyWith(
          advancedSettingsEnabled: true,
          keyboardFollowsMouse: true,
          hideOnDefaultLayer: true,
        );

        expect(updated.advancedSettingsEnabled, true);
        expect(updated.keyboardFollowsMouse, true);
        expect(updated.hideOnDefaultLayer, true);
      });

      test('preserves unchanged properties', () {
        final original = PreferencesState(
          launchAtStartup: true,
          opacity: 0.7,
          kanataEnabled: true,
        );

        final updated = original.copyWith(autoHideEnabled: true);

        expect(updated.launchAtStartup, true);
        expect(updated.opacity, 0.7);
        expect(updated.kanataEnabled, true);
        expect(updated.autoHideEnabled, true);
      });
    });

    group('toJson and fromJson', () {
      test('serializes PreferencesState to JSON', () {
        final state = PreferencesState(
          launchAtStartup: true,
          autoHideEnabled: true,
          autoHideDuration: 2.5,
          opacity: 0.8,
          kanataEnabled: true,
        );

        final json = state.toJson();

        expect(json['launchAtStartup'], true);
        expect(json['autoHideEnabled'], true);
        expect(json['autoHideDuration'], 2.5);
        expect(json['opacity'], 0.8);
        expect(json['kanataEnabled'], true);
      });

      test('deserializes PreferencesState from JSON', () {
        final json = {
          'launchAtStartup': true,
          'hideAtStartup': true,
          'autoHideEnabled': true,
          'autoHideDuration': 3.0,
          'opacity': 0.75,
          'kanataEnabled': true,
          'kanataHost': 'localhost',
          'kanataPort': 4039,
        };

        final state = PreferencesState.fromJson(json);

        expect(state.launchAtStartup, true);
        expect(state.hideAtStartup, true);
        expect(state.autoHideEnabled, true);
        expect(state.autoHideDuration, 3.0);
        expect(state.opacity, 0.75);
        expect(state.kanataEnabled, true);
        expect(state.kanataHost, 'localhost');
        expect(state.kanataPort, 4039);
      });

      test('handles missing optional fields in JSON', () {
        final json = {
          'launchAtStartup': true,
        };

        final state = PreferencesState.fromJson(json);

        expect(state.launchAtStartup, true);
        expect(state.autoHideEnabled, false); // default
        expect(state.opacity, 0.5); // default
      });

      test('round-trip serialization preserves state', () {
        final original = PreferencesState(
          launchAtStartup: true,
          autoHideEnabled: true,
          autoHideDuration: 2.0,
          opacity: 0.9,
          kanataEnabled: true,
          kanataHost: '127.0.0.1',
          kanataPort: 4039,
        );

        final json = original.toJson();
        final roundTrip = PreferencesState.fromJson(json);

        expect(roundTrip.launchAtStartup, original.launchAtStartup);
        expect(roundTrip.autoHideEnabled, original.autoHideEnabled);
        expect(roundTrip.autoHideDuration, original.autoHideDuration);
        expect(roundTrip.opacity, original.opacity);
        expect(roundTrip.kanataEnabled, original.kanataEnabled);
        expect(roundTrip.kanataHost, original.kanataHost);
        expect(roundTrip.kanataPort, original.kanataPort);
      });
    });

    group('User layers management', () {
      test('can store user layers', () {
        final userLayouts = [
          const KeyboardLayout(name: 'Custom 1', keys: [
            ['A']
          ]),
          const KeyboardLayout(name: 'Custom 2', keys: [
            ['B']
          ]),
        ];

        final state = PreferencesState(userLayers: userLayouts);

        expect(state.userLayers, hasLength(2));
        expect(state.userLayers[0].name, 'Custom 1');
        expect(state.userLayers[1].name, 'Custom 2');
      });

      test('can update user layers', () {
        final original = PreferencesState(userLayers: []);
        final newLayouts = [
          const KeyboardLayout(name: 'New', keys: [
            ['C']
          ]),
        ];

        final updated = original.copyWith(userLayers: newLayouts);

        expect(updated.userLayers, hasLength(1));
        expect(updated.userLayers[0].name, 'New');
      });
    });

    group('User config management', () {
      test('can store user config', () {
        final config = UserConfig(
          defaultUserLayout: 'Colemak',
          kanataHost: '127.0.0.1',
        );

        final state = PreferencesState(userConfig: config);

        expect(state.userConfig, isNotNull);
        expect(state.userConfig!.defaultUserLayout, 'Colemak');
      });

      test('can update user config', () {
        final original = PreferencesState();
        final config = UserConfig(defaultUserLayout: 'QWERTY');

        final updated = original.copyWith(userConfig: config);

        expect(updated.userConfig, isNotNull);
        expect(updated.userConfig!.defaultUserLayout, 'QWERTY');
      });
    });

    group('Feature toggles', () {
      test('can toggle multiple features', () {
        var state = PreferencesState();

        // Toggle all features on
        state = state.copyWith(
          launchAtStartup: true,
          autoHideEnabled: true,
          reactiveShiftEnabled: true,
          customFontEnabled: true,
          kanataEnabled: true,
          keyboardFollowsMouse: true,
          hideOnDefaultLayer: true,
        );

        expect(state.launchAtStartup, true);
        expect(state.autoHideEnabled, true);
        expect(state.reactiveShiftEnabled, true);
        expect(state.customFontEnabled, true);
        expect(state.kanataEnabled, true);
        expect(state.keyboardFollowsMouse, true);
        expect(state.hideOnDefaultLayer, true);
      });
    });

    group('Numeric settings validation', () {
      test('stores valid opacity values', () {
        final state = PreferencesState(opacity: 0.75);
        expect(state.opacity, 0.75);
      });

      test('stores valid auto-hide duration', () {
        final state = PreferencesState(autoHideDuration: 5.0);
        expect(state.autoHideDuration, 5.0);
      });

      test('stores valid Kanata port', () {
        final state = PreferencesState(kanataPort: 4039);
        expect(state.kanataPort, 4039);
      });
    });
  });
}
