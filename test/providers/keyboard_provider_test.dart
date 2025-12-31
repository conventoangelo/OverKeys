import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overkeys/models/keyboard_layouts.dart';
import 'package:overkeys/providers/keyboard_provider.dart';

void main() {
  group('KeyboardState', () {
    group('Constructor', () {
      test('creates KeyboardState with default values', () {
        final state = KeyboardState(layout: qwerty);

        expect(state.layout, qwerty);
        expect(state.keyPressStates, isEmpty);
        expect(state.keymapStyle, 'Staggered');
        expect(state.showTopRow, false);
        expect(state.showGraveKey, false);
        expect(state.keySize, 52);
        expect(state.keyBorderRadius, 14);
        expect(state.animationEnabled, true);
        expect(state.learningModeEnabled, false);
        expect(state.kanataEnabled, false);
      });

      test('creates KeyboardState with custom values', () {
        final state = KeyboardState(
          layout: colemak,
          keymapStyle: 'Matrix',
          showTopRow: true,
          keySize: 60,
          animationEnabled: false,
          learningModeEnabled: true,
        );

        expect(state.layout, colemak);
        expect(state.keymapStyle, 'Matrix');
        expect(state.showTopRow, true);
        expect(state.keySize, 60);
        expect(state.animationEnabled, false);
        expect(state.learningModeEnabled, true);
      });

      test('initializes with key press states', () {
        final keyStates = {'A': true, 'B': false};
        final state = KeyboardState(
          layout: qwerty,
          keyPressStates: keyStates,
        );

        expect(state.keyPressStates, keyStates);
        expect(state.keyPressStates['A'], true);
        expect(state.keyPressStates['B'], false);
      });
    });

    group('copyWith', () {
      test('creates copy with updated layout', () {
        final original = KeyboardState(layout: qwerty);
        final updated = original.copyWith(layout: colemak);

        expect(updated.layout, colemak);
        expect(original.layout, qwerty);
      });

      test('creates copy with updated key press states', () {
        final original = KeyboardState(
          layout: qwerty,
          keyPressStates: {'A': false},
        );
        final updated = original.copyWith(
          keyPressStates: {'A': true, 'B': true},
        );

        expect(updated.keyPressStates['A'], true);
        expect(updated.keyPressStates['B'], true);
        expect(original.keyPressStates['A'], false);
      });

      test('creates copy with updated styling', () {
        final original = KeyboardState(
          layout: qwerty,
          keySize: 52,
          keyBorderRadius: 14,
          keyPadding: 2,
        );

        final updated = original.copyWith(
          keySize: 60,
          keyBorderRadius: 20,
          keyPadding: 4,
        );

        expect(updated.keySize, 60);
        expect(updated.keyBorderRadius, 20);
        expect(updated.keyPadding, 4);
        expect(original.keySize, 52);
      });

      test('creates copy with updated colors', () {
        final original = KeyboardState(layout: qwerty);
        final newColor = const Color(0xFF00FF00);

        final updated = original.copyWith(
          keyColorPressed: newColor,
          keyTextColor: Colors.red,
        );

        expect(updated.keyColorPressed, newColor);
        expect(updated.keyTextColor, Colors.red);
      });

      test('creates copy with updated animation settings', () {
        final original = KeyboardState(
          layout: qwerty,
          animationEnabled: true,
          animationStyle: 'Raise',
          animationDuration: 80,
        );

        final updated = original.copyWith(
          animationEnabled: false,
          animationStyle: 'Scale',
          animationDuration: 120,
        );

        expect(updated.animationEnabled, false);
        expect(updated.animationStyle, 'Scale');
        expect(updated.animationDuration, 120);
      });

      test('creates copy with updated learning mode settings', () {
        final original = KeyboardState(
          layout: qwerty,
          learningModeEnabled: false,
        );

        final updated = original.copyWith(
          learningModeEnabled: true,
          pinkyLeftColor: Colors.blue,
          indexRightColor: Colors.green,
        );

        expect(updated.learningModeEnabled, true);
        expect(updated.pinkyLeftColor, Colors.blue);
        expect(updated.indexRightColor, Colors.green);
      });

      test('preserves unchanged properties', () {
        final original = KeyboardState(
          layout: qwerty,
          keySize: 52,
          fontFamily: 'DM Mono',
          animationEnabled: true,
        );

        final updated = original.copyWith(keymapStyle: 'Matrix');

        expect(updated.keySize, 52);
        expect(updated.fontFamily, 'DM Mono');
        expect(updated.animationEnabled, true);
        expect(updated.keymapStyle, 'Matrix');
      });
    });

    group('toJson and fromJson', () {
      test('serializes KeyboardState to JSON', () {
        final state = KeyboardState(
          layout: qwerty,
          keymapStyle: 'Matrix',
          keySize: 60,
          animationEnabled: false,
        );

        final json = state.toJson();

        expect(json['layoutName'], 'QWERTY');
        expect(json['keymapStyle'], 'Matrix');
        expect(json['keySize'], 60);
        expect(json['animationEnabled'], false);
      });

      test('deserializes KeyboardState from JSON', () {
        final json = {
          'layoutName': 'Colemak',
          'keymapStyle': 'Split Matrix',
          'keySize': 65.0,
          'animationEnabled': true,
          'learningModeEnabled': true,
        };

        final state = KeyboardState.fromJson(json);

        expect(state.layout.name, 'Colemak');
        expect(state.keymapStyle, 'Split Matrix');
        expect(state.keySize, 65);
        expect(state.animationEnabled, true);
        expect(state.learningModeEnabled, true);
      });

      test('handles missing optional fields in JSON', () {
        final json = {
          'layoutName': 'QWERTY',
        };

        final state = KeyboardState.fromJson(json);

        expect(state.layout.name, 'QWERTY');
        expect(state.keymapStyle, 'Staggered'); // default
        expect(state.animationEnabled, true); // default
      });
    });

    group('Key press state management', () {
      test('can track multiple key presses', () {
        final state = KeyboardState(
          layout: qwerty,
          keyPressStates: {
            'A': true,
            'S': true,
            'D': false,
          },
        );

        expect(state.keyPressStates.length, 3);
        expect(state.keyPressStates['A'], true);
        expect(state.keyPressStates['S'], true);
        expect(state.keyPressStates['D'], false);
      });

      test('can update key press states', () {
        var state = KeyboardState(
          layout: qwerty,
          keyPressStates: {'A': false},
        );

        state = state.copyWith(
          keyPressStates: {'A': true},
        );

        expect(state.keyPressStates['A'], true);
      });

      test('can clear all key press states', () {
        var state = KeyboardState(
          layout: qwerty,
          keyPressStates: {'A': true, 'B': true},
        );

        state = state.copyWith(keyPressStates: {});

        expect(state.keyPressStates, isEmpty);
      });
    });

    group('Layout switching', () {
      test('can switch between layouts', () {
        var state = KeyboardState(layout: qwerty);

        state = state.copyWith(layout: colemak);
        expect(state.layout, colemak);

        state = state.copyWith(layout: dvorak);
        expect(state.layout, dvorak);
      });

      test('preserves styling when switching layouts', () {
        var state = KeyboardState(
          layout: qwerty,
          keySize: 70,
          keyBorderRadius: 15,
        );

        state = state.copyWith(layout: colemak);

        expect(state.layout, colemak);
        expect(state.keySize, 70);
        expect(state.keyBorderRadius, 15);
      });
    });

    group('Color configuration', () {
      test('has default pressed and not pressed colors', () {
        final state = KeyboardState(layout: qwerty);

        expect(state.keyColorPressed, const Color(0xFFA87FFB));
        expect(state.keyColorNotPressed, const Color(0xFF10151D));
        expect(state.keyTextColor, const Color(0xFF10151D));
        expect(state.keyTextColorNotPressed, const Color(0xFFFAFBFE));
      });

      test('can customize all color properties', () {
        final state = KeyboardState(
          layout: qwerty,
          keyColorPressed: Colors.red,
          keyColorNotPressed: Colors.blue,
          keyTextColor: Colors.white,
          keyTextColorNotPressed: Colors.black,
          markerColor: Colors.yellow,
        );

        expect(state.keyColorPressed, Colors.red);
        expect(state.keyColorNotPressed, Colors.blue);
        expect(state.keyTextColor, Colors.white);
        expect(state.keyTextColorNotPressed, Colors.black);
        expect(state.markerColor, Colors.yellow);
      });
    });

    group('Learning mode', () {
      test('has default finger colors for learning mode', () {
        final state = KeyboardState(layout: qwerty);

        expect(state.pinkyLeftColor, const Color(0xFFED3345));
        expect(state.ringLeftColor, const Color(0xFFFAA71D));
        expect(state.middleLeftColor, const Color(0xFF70C27B));
        expect(state.indexLeftColor, const Color(0xFF00AFEB));
      });

      test('can toggle learning mode', () {
        var state = KeyboardState(
          layout: qwerty,
          learningModeEnabled: false,
        );

        state = state.copyWith(learningModeEnabled: true);
        expect(state.learningModeEnabled, true);

        state = state.copyWith(learningModeEnabled: false);
        expect(state.learningModeEnabled, false);
      });
    });
  });
}
