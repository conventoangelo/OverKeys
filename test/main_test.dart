import 'package:flutter_test/flutter_test.dart';
import 'package:overkeys/main.dart';

void main() {
  group('window entrypoint arguments', () {
    test('reads desktop_multi_window arguments', () {
      expect(
        windowArgumentsFromEntrypointArgs([
          'multi_window',
          'window-id',
          'preferences',
        ]),
        'preferences',
      );
    });

    test('ignores malformed secondary window arguments', () {
      expect(windowArgumentsFromEntrypointArgs(['multi_window']), '');
      expect(windowArgumentsFromEntrypointArgs(['other', 'id', 'preferences']),
          '');
    });

    test('maps arguments to window types', () {
      expect(parseWindowType(''), WindowType.main);
      expect(parseWindowType('preferences'), WindowType.preferences);
      expect(parseWindowType('unknown'), WindowType.main);
    });
  });
}
