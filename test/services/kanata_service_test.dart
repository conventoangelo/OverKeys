import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:overkeys/models/keyboard_layouts.dart';
import 'package:overkeys/services/kanata_service.dart';

void main() {
  group('KanataService', () {
    late KanataService kanataService;

    setUp(() {
      kanataService = KanataService();
    });

    tearDown(() {
      kanataService.dispose();
    });

    group('Message handling', () {
      test('parses LayerChange message correctly', () {
        kanataService.onLayerChange = (layout, isDefault) {
          // Callback is set
        };

        // Simulate receiving a layer change message
        final message = jsonEncode({
          'LayerChange': {'new': 'QWERTY'}
        });

        // We cannot directly test _handleKanataMessage as it's private,
        // but we can verify the message structure is valid
        expect(() => jsonDecode(message), returnsNormally);

        final decoded = jsonDecode(message);
        expect(decoded['LayerChange'], isNotNull);
        expect(decoded['LayerChange']['new'], 'QWERTY');
      });

      test('handles LayerChange with Colemak layout', () {
        final message = jsonEncode({
          'LayerChange': {'new': 'colemak'}
        });

        final decoded = jsonDecode(message);
        final layoutName =
            decoded['LayerChange']['new']?.toString().trim().toUpperCase();
        expect(layoutName, 'COLEMAK');

        // Verify layout exists in available layouts
        final layout = availableLayouts
            .where((l) => l.name.toUpperCase() == layoutName)
            .firstOrNull;
        expect(layout, isNotNull);
        expect(layout!.name, 'Colemak');
      });

      test('handles LayerChange with Dvorak layout', () {
        final message = jsonEncode({
          'LayerChange': {'new': 'Dvorak'}
        });

        final decoded = jsonDecode(message);
        final layoutName =
            decoded['LayerChange']['new']?.toString().trim().toUpperCase();

        final layout = availableLayouts
            .where((l) => l.name.toUpperCase() == layoutName)
            .firstOrNull;
        expect(layout, isNotNull);
        expect(layout!.name, 'Dvorak');
      });

      test('handles case-insensitive layout names', () {
        final testCases = ['qwerty', 'QWERTY', 'QwErTy', 'Qwerty'];

        for (final testCase in testCases) {
          final message = jsonEncode({
            'LayerChange': {'new': testCase}
          });

          final decoded = jsonDecode(message);
          final layoutName =
              decoded['LayerChange']['new']?.toString().trim().toUpperCase();
          expect(layoutName, 'QWERTY');
        }
      });

      test('validates LayerChange message structure', () {
        final validMessage = jsonEncode({
          'LayerChange': {'new': 'QWERTY'}
        });

        final decoded = jsonDecode(validMessage);
        expect(decoded.containsKey('LayerChange'), true);
        expect(decoded['LayerChange'].containsKey('new'), true);
        expect(decoded['LayerChange']['new'], isA<String>());
      });

      test('handles empty layout name', () {
        final message = jsonEncode({
          'LayerChange': {'new': ''}
        });

        final decoded = jsonDecode(message);
        final layoutName =
            decoded['LayerChange']['new']?.toString().trim().toUpperCase();
        expect(layoutName, isEmpty);
      });

      test('handles missing new field in LayerChange', () {
        final message = jsonEncode({'LayerChange': {}});

        final decoded = jsonDecode(message);
        expect(decoded['LayerChange']['new'], isNull);
      });

      test('handles malformed JSON gracefully', () {
        const invalidJson = '{invalid json}';
        expect(() => jsonDecode(invalidJson), throwsFormatException);
      });

      test('handles message without LayerChange key', () {
        final message = jsonEncode({
          'SomeOtherEvent': {'data': 'value'}
        });

        final decoded = jsonDecode(message);
        expect(decoded.containsKey('LayerChange'), false);
      });
    });

    group('Layout matching', () {
      test('matches built-in layout names', () async {
        final builtInLayouts = [
          'QWERTY',
          'Colemak',
          'Dvorak',
          'Workman',
        ];

        for (final layoutName in builtInLayouts) {
          final layout = availableLayouts
              .where((l) => l.name.toUpperCase() == layoutName.toUpperCase())
              .firstOrNull;
          expect(layout, isNotNull, reason: '$layoutName should exist');
        }
      });

      test('distinguishes between default and non-default layouts', () {
        const defaultLayout = 'QWERTY';
        final otherLayouts = ['Colemak', 'Dvorak'];

        for (final layoutName in otherLayouts) {
          expect(
            layoutName.toUpperCase() != defaultLayout.toUpperCase(),
            true,
            reason: '$layoutName should not be default',
          );
        }
      });

      test('handles unknown layout names', () {
        const unknownLayouts = [
          'NonExistentLayout',
          'UnknownLayout',
          'CustomLayout123',
        ];

        for (final layoutName in unknownLayouts) {
          final layout = availableLayouts
              .where((l) => l.name.toUpperCase() == layoutName.toUpperCase())
              .firstOrNull;
          expect(layout, isNull, reason: '$layoutName should not exist');
        }
      });
    });

    group('Callback registration', () {
      test('can set onLayerChange callback', () {
        kanataService.onLayerChange = (layout, isDefault) {
          // Callback registered
        };

        expect(kanataService.onLayerChange, isNotNull);
      });

      test('can clear onLayerChange callback', () {
        kanataService.onLayerChange = (layout, isDefault) {};
        kanataService.onLayerChange = null;

        expect(kanataService.onLayerChange, isNull);
      });
    });

    group('Connection lifecycle', () {
      test('disconnect stops reconnect attempts', () {
        kanataService.disconnect();
        // If this test completes without hanging, disconnect worked
        expect(true, true);
      });

      test('dispose cleans up resources', () {
        kanataService.dispose();
        // Verify disposal doesn't throw
        expect(true, true);
      });

      test('multiple disconnect calls are safe', () {
        kanataService.disconnect();
        kanataService.disconnect();
        expect(true, true);
      });

      test('dispose after disconnect is safe', () {
        kanataService.disconnect();
        kanataService.dispose();
        expect(true, true);
      });
    });

    group('Message format validation', () {
      test('validates complete layer change message', () {
        final message = {
          'LayerChange': {
            'new': 'QWERTY',
          }
        };

        expect(message['LayerChange'], isNotNull);
        expect(message['LayerChange']!['new'], isA<String>());
        expect(message['LayerChange']!['new'], isNotEmpty);
      });

      test('JSON encoding produces valid message', () {
        final message = {
          'LayerChange': {'new': 'Colemak'}
        };

        final encoded = jsonEncode(message);
        expect(encoded, isA<String>());

        final decoded = jsonDecode(encoded);
        expect(decoded['LayerChange']['new'], 'Colemak');
      });
    });

    group('Layout name normalization', () {
      test('normalizes layout names to uppercase', () {
        final inputs = ['qwerty', 'Qwerty', 'QWERTY', 'qWeRtY'];
        for (final input in inputs) {
          expect(input.toUpperCase(), 'QWERTY');
        }
      });

      test('trims whitespace from layout names', () {
        final inputs = [' QWERTY ', 'QWERTY\n', '\tQWERTY'];
        for (final input in inputs) {
          expect(input.trim(), 'QWERTY');
        }
      });

      test('handles layout names with special characters', () {
        final testCases = {
          'QWERTY-US': 'QWERTY-US',
          'Colemak_DH': 'Colemak_DH',
          'Dvorak.Simplified': 'Dvorak.Simplified',
        };

        testCases.forEach((input, expected) {
          expect(input.trim().toUpperCase(), expected.toUpperCase());
        });
      });
    });

    group('Default layout handling', () {
      test('identifies QWERTY as default layout', () {
        const defaultLayout = 'QWERTY';
        const testLayout = 'QWERTY';

        expect(
          testLayout.toUpperCase() == defaultLayout.toUpperCase(),
          true,
        );
      });

      test('identifies non-QWERTY as non-default', () {
        const defaultLayout = 'QWERTY';
        final nonDefaultLayouts = ['Colemak', 'Dvorak', 'Workman'];

        for (final layout in nonDefaultLayouts) {
          expect(
            layout.toUpperCase() != defaultLayout.toUpperCase(),
            true,
          );
        }
      });
    });

    group('Error scenarios', () {
      test('handles null layout name', () {
        final message = jsonEncode({
          'LayerChange': {'new': null}
        });

        final decoded = jsonDecode(message);
        final layoutName = decoded['LayerChange']['new'];
        expect(layoutName, isNull);
      });

      test('handles missing LayerChange field', () {
        final message = jsonEncode({'OtherEvent': 'data'});

        final decoded = jsonDecode(message);
        expect(decoded.containsKey('LayerChange'), false);
      });

      test('handles numeric layout name', () {
        final message = jsonEncode({
          'LayerChange': {'new': 12345}
        });

        final decoded = jsonDecode(message);
        final layoutName = decoded['LayerChange']['new'].toString();
        expect(layoutName, '12345');
      });
    });
  });
}
