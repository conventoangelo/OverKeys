import 'package:flutter_test/flutter_test.dart';
import 'package:overkeys/models/keyboard_layouts.dart';

void main() {
  group('KeyboardLayout', () {
    test('creates layout with required fields', () {
      const layout = KeyboardLayout(
        name: 'Test Layout',
        keys: [
          ['A', 'B', 'C'],
          ['D', 'E', 'F'],
        ],
      );

      expect(layout.name, 'Test Layout');
      expect(layout.keys, hasLength(2));
      expect(layout.keys[0], ['A', 'B', 'C']);
      expect(layout.trigger, isNull);
      expect(layout.type, isNull);
      expect(layout.foreign, isNull);
    });

    test('creates layout with optional fields', () {
      const layout = KeyboardLayout(
        name: 'Custom Layout',
        keys: [
          ['Q', 'W'],
        ],
        trigger: 'F13',
        type: 'toggle',
        foreign: true,
      );

      expect(layout.name, 'Custom Layout');
      expect(layout.trigger, 'F13');
      expect(layout.type, 'toggle');
      expect(layout.foreign, true);
    });
  });

  group('Predefined Layouts', () {
    test('QWERTY layout has correct structure', () {
      expect(qwerty.name, 'QWERTY');
      expect(qwerty.keys, hasLength(5));
      expect(qwerty.keys[0], hasLength(14)); // Top row with backspace
      expect(qwerty.keys[1], hasLength(12)); // QWERTY row
      expect(qwerty.keys[2], hasLength(11)); // Home row
      expect(qwerty.keys[3], hasLength(10)); // Bottom row
      expect(qwerty.keys[4], hasLength(1)); // Space
    });

    test('Colemak layout has correct structure', () {
      expect(colemak.name, 'Colemak');
      expect(colemak.keys, hasLength(5));
      expect(colemak.keys[1][0], 'Q');
      expect(colemak.keys[1][1], 'W');
      expect(colemak.keys[1][2], 'F'); // Different from QWERTY
      expect(colemak.keys[1][3], 'P'); // Different from QWERTY
    });

    test('Dvorak layout has correct structure', () {
      expect(dvorak.name, 'Dvorak');
      expect(dvorak.keys, hasLength(5));
      expect(dvorak.keys[1][0], "'"); // Different from QWERTY
      expect(dvorak.keys[1][1], ','); // Different from QWERTY
    });

    test('all predefined layouts have space bar', () {
      final layouts = [
        qwerty,
        colemak,
        dvorak,
        colemakdh,
        colemakdhMatrix,
        workman,
        canary,
        sturdy,
        graphite,
        nerps,
      ];

      for (final layout in layouts) {
        expect(layout.keys.last, [' '],
            reason: '${layout.name} should have space bar');
      }
    });

    test('all predefined layouts have consistent row structure', () {
      final layouts = [
        qwerty,
        colemak,
        dvorak,
        colemakdh,
        colemakdhMatrix,
        workman,
        canary,
        sturdy,
        graphite,
        nerps,
      ];

      for (final layout in layouts) {
        expect(layout.keys, hasLength(5),
            reason: '${layout.name} should have 5 rows');
        expect(layout.keys[0].contains('BSPC'), isTrue,
            reason: '${layout.name} should have backspace key');
      }
    });
  });

  group('Layout Variations', () {
    test('Matrix layouts have correct structure', () {
      expect(colemakdhMatrix.name, contains('Matrix'));
      expect(colemakdhMatrix.keys, hasLength(5));
    });

    test('foreign layouts have foreign flag', () {
      expect(russian.foreign, isTrue);
      expect(arabic.foreign, isTrue);
      expect(greek.foreign, isTrue);
    });
  });

  group('Available Layout List', () {
    test('availableLayouts contains all expected layouts', () {
      expect(availableLayouts.length, greaterThan(20));
      expect(availableLayouts.any((l) => l.name == 'QWERTY'), isTrue);
      expect(availableLayouts.any((l) => l.name == 'Colemak'), isTrue);
      expect(availableLayouts.any((l) => l.name == 'Dvorak'), isTrue);
    });

    test('all available layouts have unique names', () {
      final names = availableLayouts.map((l) => l.name).toList();
      final uniqueNames = names.toSet();
      expect(names.length, uniqueNames.length,
          reason: 'All layout names should be unique');
    });

    test('no available layout has null name', () {
      for (final layout in availableLayouts) {
        expect(layout.name, isNotNull);
        expect(layout.name.isNotEmpty, isTrue);
      }
    });
  });
}
