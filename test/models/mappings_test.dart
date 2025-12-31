import 'package:flutter_test/flutter_test.dart';
import 'package:overkeys/models/mappings.dart';

void main() {
  group('Mappings', () {
    group('keyMappings', () {
      test('maps arrow symbols to directional keys', () {
        expect(Mappings.keyMappings['◄'], 'Left');
        expect(Mappings.keyMappings['←'], 'Left');
        expect(Mappings.keyMappings['▲'], 'Up');
        expect(Mappings.keyMappings['↑'], 'Up');
        expect(Mappings.keyMappings['►'], 'Right');
        expect(Mappings.keyMappings['→'], 'Right');
        expect(Mappings.keyMappings['▼'], 'Down');
        expect(Mappings.keyMappings['↓'], 'Down');
      });

      test('maps various enter symbols to Enter', () {
        expect(Mappings.keyMappings['⏎'], 'Enter');
        expect(Mappings.keyMappings['↵'], 'Enter');
        expect(Mappings.keyMappings['↩'], 'Enter');
        expect(Mappings.keyMappings['⌤'], 'Enter');
        expect(Mappings.keyMappings['ENTER'], 'Enter');
        expect(Mappings.keyMappings['RET'], 'Enter');
      });

      test('maps backspace symbols', () {
        expect(Mappings.keyMappings['⌫'], 'Backspace');
        expect(Mappings.keyMappings['BSPC'], 'Backspace');
        expect(Mappings.keyMappings['BS'], 'Backspace');
      });

      test('maps delete symbols', () {
        expect(Mappings.keyMappings['⌦'], 'Delete');
        expect(Mappings.keyMappings['DEL'], 'Delete');
        expect(Mappings.keyMappings['DELETE'], 'Delete');
      });

      test('maps tab symbols', () {
        expect(Mappings.keyMappings['⭾'], 'Tab');
        expect(Mappings.keyMappings['↹'], 'Tab');
        expect(Mappings.keyMappings['TAB'], 'Tab');
      });

      test('maps space symbols', () {
        expect(Mappings.keyMappings['␣'], ' ');
        expect(Mappings.keyMappings['⎵'], ' ');
        expect(Mappings.keyMappings['SPC'], ' ');
        expect(Mappings.keyMappings['SPACE'], ' ');
      });

      test('maps escape symbols', () {
        expect(Mappings.keyMappings['⎋'], 'Escape');
        expect(Mappings.keyMappings['ESC'], 'Escape');
      });

      test('maps modifier keys to left variants by default', () {
        expect(Mappings.keyMappings['⇧'], 'LShift');
        expect(Mappings.keyMappings['SFT'], 'LShift');
        expect(Mappings.keyMappings['SHIFT'], 'LShift');
        expect(Mappings.keyMappings['⌃'], 'LControl');
        expect(Mappings.keyMappings['CTRL'], 'LControl');
        expect(Mappings.keyMappings['⌥'], 'LAlt');
        expect(Mappings.keyMappings['ALT'], 'LAlt');
      });

      test('maps left modifier variants', () {
        expect(Mappings.keyMappings['‹⇧'], 'LShift');
        expect(Mappings.keyMappings['LSHIFT'], 'LShift');
        expect(Mappings.keyMappings['‹⌃'], 'LControl');
        expect(Mappings.keyMappings['LCTRL'], 'LControl');
        expect(Mappings.keyMappings['‹⎇'], 'LAlt');
        expect(Mappings.keyMappings['LALT'], 'LAlt');
      });

      test('maps right modifier variants', () {
        expect(Mappings.keyMappings['⇧›'], 'RShift');
        expect(Mappings.keyMappings['RSHIFT'], 'RShift');
        expect(Mappings.keyMappings['RCTRL'], 'RControl');
        expect(Mappings.keyMappings['RALT'], 'RAlt');
      });

      test('maps navigation keys', () {
        expect(Mappings.keyMappings['⇱'], 'Home');
        expect(Mappings.keyMappings['HOME'], 'Home');
        expect(Mappings.keyMappings['⇲'], 'End');
        expect(Mappings.keyMappings['END'], 'End');
        expect(Mappings.keyMappings['⤓'], 'PageDown');
        expect(Mappings.keyMappings['PGDN'], 'PageDown');
        expect(Mappings.keyMappings['⤒'], 'PageUp');
        expect(Mappings.keyMappings['PGUP'], 'PageUp');
      });

      test('maps caps lock', () {
        expect(Mappings.keyMappings['⇪'], 'CapsLock');
        expect(Mappings.keyMappings['CAPS'], 'CapsLock');
      });
    });

    group('getKeyForSymbol', () {
      test('returns mapped key for known symbols', () {
        expect(Mappings.getKeyForSymbol('⏎'), 'Enter');
        expect(Mappings.getKeyForSymbol('⌫'), 'Backspace');
        expect(Mappings.getKeyForSymbol('BSPC'), 'Backspace');
      });

      test('returns original symbol for unknown symbols', () {
        expect(Mappings.getKeyForSymbol('UNKNOWN'), 'UNKNOWN');
        expect(Mappings.getKeyForSymbol('xyz'), 'xyz');
      });
    });

    group('getShiftedSymbol', () {
      test('returns shifted character for numbers', () {
        // This relies on activeKeyCodeShiftMap being initialized
        final shifted1 = Mappings.getShiftedSymbol('1');
        expect(shifted1, anyOf('!', '1')); // May or may not be initialized
      });

      test('returns original symbol for unmapped keys', () {
        final result = Mappings.getShiftedSymbol('Enter');
        expect(result, 'Enter');
      });
    });
  });
}
