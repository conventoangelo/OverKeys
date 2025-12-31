import 'package:flutter_test/flutter_test.dart';
import 'package:overkeys/utils/key_code.dart';
import 'package:win32/win32.dart';

void main() {
  group('Key Code Utilities', () {
    setUp(() {
      // Reset active map before each test
      activeKeyCodeShiftMap =
          Map<(int, bool), String>.from(defaultKeyCodeShiftMap);
    });

    group('defaultKeyCodeMap', () {
      test('maps letter keys correctly', () {
        expect(defaultKeyCodeMap[VK_A], 'A');
        expect(defaultKeyCodeMap[VK_B], 'B');
        expect(defaultKeyCodeMap[VK_Z], 'Z');
      });

      test('maps function keys correctly', () {
        expect(defaultKeyCodeMap[VK_F1], 'F1');
        expect(defaultKeyCodeMap[VK_F12], 'F12');
        expect(defaultKeyCodeMap[VK_F24], 'F24');
      });

      test('maps navigation keys correctly', () {
        expect(defaultKeyCodeMap[VK_LEFT], 'Left');
        expect(defaultKeyCodeMap[VK_RIGHT], 'Right');
        expect(defaultKeyCodeMap[VK_UP], 'Up');
        expect(defaultKeyCodeMap[VK_DOWN], 'Down');
        expect(defaultKeyCodeMap[VK_HOME], 'Home');
        expect(defaultKeyCodeMap[VK_END], 'End');
        expect(defaultKeyCodeMap[VK_PRIOR], 'PageUp');
        expect(defaultKeyCodeMap[VK_NEXT], 'PageDown');
      });

      test('maps special keys correctly', () {
        expect(defaultKeyCodeMap[VK_RETURN], 'Enter');
        expect(defaultKeyCodeMap[VK_TAB], 'Tab');
        expect(defaultKeyCodeMap[VK_BACK], 'Backspace');
        expect(defaultKeyCodeMap[VK_ESCAPE], 'Escape');
        expect(defaultKeyCodeMap[VK_DELETE], 'Delete');
        expect(defaultKeyCodeMap[VK_INSERT], 'Insert');
        expect(defaultKeyCodeMap[VK_SPACE], ' ');
      });

      test('maps modifier keys correctly', () {
        expect(defaultKeyCodeMap[VK_LSHIFT], 'LShift');
        expect(defaultKeyCodeMap[VK_RSHIFT], 'RShift');
        expect(defaultKeyCodeMap[VK_LCONTROL], 'LControl');
        expect(defaultKeyCodeMap[VK_RCONTROL], 'RControl');
        expect(defaultKeyCodeMap[VK_LMENU], 'LAlt');
        expect(defaultKeyCodeMap[VK_RMENU], 'RAlt');
        expect(defaultKeyCodeMap[VK_LWIN], 'Win');
        expect(defaultKeyCodeMap[VK_RWIN], 'RWin');
      });

      test('maps lock keys correctly', () {
        expect(defaultKeyCodeMap[VK_CAPITAL], 'CapsLock');
        expect(defaultKeyCodeMap[VK_NUMLOCK], 'NumLock');
        expect(defaultKeyCodeMap[VK_SCROLL], 'ScrollLock');
      });

      test('maps numpad keys to regular numbers', () {
        expect(defaultKeyCodeMap[VK_NUMPAD0], '0');
        expect(defaultKeyCodeMap[VK_NUMPAD5], '5');
        expect(defaultKeyCodeMap[VK_NUMPAD9], '9');
        expect(defaultKeyCodeMap[VK_MULTIPLY], '*');
        expect(defaultKeyCodeMap[VK_ADD], '+');
        expect(defaultKeyCodeMap[VK_SUBTRACT], '-');
        expect(defaultKeyCodeMap[VK_DECIMAL], '.');
        expect(defaultKeyCodeMap[VK_DIVIDE], '/');
      });
    });

    group('defaultKeyCodeShiftMap', () {
      test('maps number keys without shift', () {
        expect(defaultKeyCodeShiftMap[(0x30, false)], '0');
        expect(defaultKeyCodeShiftMap[(0x31, false)], '1');
        expect(defaultKeyCodeShiftMap[(0x39, false)], '9');
      });

      test('maps number keys with shift', () {
        expect(defaultKeyCodeShiftMap[(0x30, true)], ')');
        expect(defaultKeyCodeShiftMap[(0x31, true)], '!');
        expect(defaultKeyCodeShiftMap[(0x32, true)], '@');
        expect(defaultKeyCodeShiftMap[(0x33, true)], '#');
        expect(defaultKeyCodeShiftMap[(0x34, true)], '\$');
        expect(defaultKeyCodeShiftMap[(0x35, true)], '%');
        expect(defaultKeyCodeShiftMap[(0x36, true)], '^');
        expect(defaultKeyCodeShiftMap[(0x37, true)], '&');
        expect(defaultKeyCodeShiftMap[(0x38, true)], '*');
        expect(defaultKeyCodeShiftMap[(0x39, true)], '(');
      });

      test('maps punctuation keys without shift', () {
        expect(defaultKeyCodeShiftMap[(VK_OEM_COMMA, false)], ',');
        expect(defaultKeyCodeShiftMap[(VK_OEM_PERIOD, false)], '.');
        expect(defaultKeyCodeShiftMap[(VK_OEM_1, false)], ';');
        expect(defaultKeyCodeShiftMap[(VK_OEM_2, false)], '/');
        expect(defaultKeyCodeShiftMap[(VK_OEM_4, false)], '[');
        expect(defaultKeyCodeShiftMap[(VK_OEM_6, false)], ']');
        expect(defaultKeyCodeShiftMap[(VK_OEM_5, false)], '\\');
        expect(defaultKeyCodeShiftMap[(VK_OEM_3, false)], '`');
        expect(defaultKeyCodeShiftMap[(VK_OEM_7, false)], "'");
        expect(defaultKeyCodeShiftMap[(VK_OEM_PLUS, false)], '=');
        expect(defaultKeyCodeShiftMap[(VK_OEM_MINUS, false)], '-');
      });

      test('maps punctuation keys with shift', () {
        expect(defaultKeyCodeShiftMap[(VK_OEM_COMMA, true)], '<');
        expect(defaultKeyCodeShiftMap[(VK_OEM_PERIOD, true)], '>');
        expect(defaultKeyCodeShiftMap[(VK_OEM_1, true)], ':');
        expect(defaultKeyCodeShiftMap[(VK_OEM_2, true)], '?');
        expect(defaultKeyCodeShiftMap[(VK_OEM_4, true)], '{');
        expect(defaultKeyCodeShiftMap[(VK_OEM_6, true)], '}');
        expect(defaultKeyCodeShiftMap[(VK_OEM_5, true)], '|');
        expect(defaultKeyCodeShiftMap[(VK_OEM_3, true)], '~');
        expect(defaultKeyCodeShiftMap[(VK_OEM_7, true)], '"');
        expect(defaultKeyCodeShiftMap[(VK_OEM_PLUS, true)], '+');
        expect(defaultKeyCodeShiftMap[(VK_OEM_MINUS, true)], '_');
      });
    });

    group('getKeyFromKeyCodeShift', () {
      test('returns correct key for letter without shift', () {
        final result = getKeyFromKeyCodeShift(VK_A, false);
        expect(result, 'A');
      });

      test('returns correct key for letter with shift', () {
        final result = getKeyFromKeyCodeShift(VK_A, true);
        expect(result, 'A'); // Letters use defaultKeyCodeMap
      });

      test('returns correct character for number without shift', () {
        final result = getKeyFromKeyCodeShift(0x31, false);
        expect(result, '1');
      });

      test('returns correct character for number with shift', () {
        final result = getKeyFromKeyCodeShift(0x31, true);
        expect(result, '!');
      });

      test('returns correct character for punctuation without shift', () {
        final result = getKeyFromKeyCodeShift(VK_OEM_COMMA, false);
        expect(result, ',');
      });

      test('returns correct character for punctuation with shift', () {
        final result = getKeyFromKeyCodeShift(VK_OEM_COMMA, true);
        expect(result, '<');
      });

      test('returns empty string for unknown key code', () {
        final result = getKeyFromKeyCodeShift(0xFF, false);
        expect(result, '');
      });

      test('uses activeKeyCodeShiftMap when available', () {
        // Modify active map
        activeKeyCodeShiftMap[(0x31, false)] = 'Custom1';
        activeKeyCodeShiftMap[(0x31, true)] = 'Custom!';

        expect(getKeyFromKeyCodeShift(0x31, false), 'Custom1');
        expect(getKeyFromKeyCodeShift(0x31, true), 'Custom!');
      });

      test('falls back to defaultKeyCodeMap when not in shift map', () {
        // Remove from shift map, should fall back to default
        activeKeyCodeShiftMap.remove((VK_A, false));

        final result = getKeyFromKeyCodeShift(VK_A, false);
        expect(result, 'A'); // Falls back to defaultKeyCodeMap
      });
    });

    group('activeKeyCodeShiftMap manipulation', () {
      test('can be modified independently', () {
        final original = activeKeyCodeShiftMap[(0x31, false)];
        activeKeyCodeShiftMap[(0x31, false)] = 'Modified';

        expect(activeKeyCodeShiftMap[(0x31, false)], 'Modified');
        expect(defaultKeyCodeShiftMap[(0x31, false)], original);
      });

      test('reset works correctly', () {
        activeKeyCodeShiftMap[(0x31, false)] = 'Modified';
        activeKeyCodeShiftMap =
            Map<(int, bool), String>.from(defaultKeyCodeShiftMap);

        expect(activeKeyCodeShiftMap[(0x31, false)], '1');
      });
    });
  });
}
