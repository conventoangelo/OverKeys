import 'package:flutter_test/flutter_test.dart';
import 'package:overkeys/utils/font_options.dart';

void main() {
  group('availableFontFamilies', () {
    test('is not empty', () {
      expect(availableFontFamilies, isNotEmpty);
    });

    test('contains common programming fonts', () {
      expect(availableFontFamilies, contains('Fira Code'));
      expect(availableFontFamilies, contains('JetBrains Mono'));
      expect(availableFontFamilies, contains('Consolas'));
      expect(availableFontFamilies, contains('Courier'));
      expect(availableFontFamilies, contains('Monaco'));
    });

    test('contains monospace fonts', () {
      expect(availableFontFamilies, contains('Anonymous Pro'));
      expect(availableFontFamilies, contains('Cascadia Code'));
      expect(availableFontFamilies, contains('Cascadia Mono'));
      expect(availableFontFamilies, contains('Courier Prime'));
      expect(availableFontFamilies, contains('DejaVu Sans Mono'));
      expect(availableFontFamilies, contains('DM Mono'));
      expect(availableFontFamilies, contains('Droid Sans Mono'));
      expect(availableFontFamilies, contains('Hack'));
      expect(availableFontFamilies, contains('IBM Plex Mono'));
      expect(availableFontFamilies, contains('Inconsolata'));
      expect(availableFontFamilies, contains('Iosevka'));
      expect(availableFontFamilies, contains('Liberation Mono'));
      expect(availableFontFamilies, contains('Menlo'));
      expect(availableFontFamilies, contains('Meslo'));
      expect(availableFontFamilies, contains('PT Mono'));
      expect(availableFontFamilies, contains('Roboto Mono'));
      expect(availableFontFamilies, contains('Source Code Pro'));
      expect(availableFontFamilies, contains('Space Mono'));
      expect(availableFontFamilies, contains('Ubuntu Mono'));
      expect(availableFontFamilies, contains('Victor Mono'));
    });

    test('contains Monaspace font variants', () {
      expect(availableFontFamilies, contains('Monaspace Argon'));
      expect(availableFontFamilies, contains('Monaspace Krypton'));
      expect(availableFontFamilies, contains('Monaspace Neon'));
      expect(availableFontFamilies, contains('Monaspace Radon'));
      expect(availableFontFamilies, contains('Monaspace Xenon'));
    });

    test('contains commercial fonts', () {
      expect(availableFontFamilies, contains('Berkeley Mono'));
      expect(availableFontFamilies, contains('Dank Mono'));
      expect(availableFontFamilies, contains('MonoLisa'));
      expect(availableFontFamilies, contains('Operator Mono'));
    });

    test('contains sans-serif fonts', () {
      expect(availableFontFamilies, contains('Alexandria'));
      expect(availableFontFamilies, contains('Cairo'));
      expect(availableFontFamilies, contains('Google Sans'));
      expect(availableFontFamilies, contains('IBM Plex Sans'));
      expect(availableFontFamilies, contains('Inter'));
      expect(availableFontFamilies, contains('Manrope'));
      expect(availableFontFamilies, contains('Montserrat'));
      expect(availableFontFamilies, contains('Noto Sans'));
      expect(availableFontFamilies, contains('Nunito'));
      expect(availableFontFamilies, contains('Open Sans'));
      expect(availableFontFamilies, contains('Poppins'));
      expect(availableFontFamilies, contains('Readex Pro'));
      expect(availableFontFamilies, contains('Roboto'));
      expect(availableFontFamilies, contains('Rubik'));
      expect(availableFontFamilies, contains('Source Sans Pro'));
      expect(availableFontFamilies, contains('Ubuntu'));
    });

    test('contains unique fonts', () {
      expect(availableFontFamilies, contains('Comic Mono'));
      expect(availableFontFamilies, contains('CommitMono'));
      expect(availableFontFamilies, contains('Fantasque Sans Mono'));
      expect(availableFontFamilies, contains('Geist'));
      expect(availableFontFamilies, contains('GeistMono'));
      expect(availableFontFamilies, contains('Hasklig'));
      expect(availableFontFamilies, contains('Input'));
      expect(availableFontFamilies, contains('Monocraft'));
      expect(availableFontFamilies, contains('mononoki'));
      expect(availableFontFamilies, contains('Recursive'));
      expect(availableFontFamilies, contains('SF Mono'));
    });

    test('all entries are non-empty strings', () {
      for (final fontFamily in availableFontFamilies) {
        expect(fontFamily, isNotEmpty);
        expect(fontFamily, isA<String>());
      }
    });

    test('has no duplicate entries', () {
      final uniqueFonts = availableFontFamilies.toSet();
      expect(uniqueFonts.length, equals(availableFontFamilies.length));
    });

    test('contains at least 60 font families', () {
      expect(availableFontFamilies.length, greaterThanOrEqualTo(60));
    });

    test('has expected count of fonts', () {
      // Should have a substantial list of fonts (65 fonts as of current list)
      expect(availableFontFamilies.length, greaterThan(50));
    });

    test('can be used in font selection widgets', () {
      // Verify the list can be iterated for dropdown menus
      final mappedList = availableFontFamilies.map((font) => font).toList();
      expect(mappedList, equals(availableFontFamilies));
    });
  });
}
