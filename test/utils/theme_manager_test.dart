import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overkeys/utils/theme_manager.dart';

void main() {
  group('ThemeManager', () {
    group('Light Color Scheme', () {
      late ColorScheme lightScheme;

      setUp(() {
        lightScheme = ThemeManager.lightColorScheme;
      });

      test('has correct brightness', () {
        expect(lightScheme.brightness, Brightness.light);
      });

      test('has defined primary colors', () {
        expect(lightScheme.primary, const Color(0xFF742020));
        expect(lightScheme.onPrimary, Colors.white);
        expect(lightScheme.primaryContainer, const Color(0xFFF5D6D6));
        expect(lightScheme.onPrimaryContainer, const Color(0xFF550000));
      });

      test('has defined secondary colors', () {
        expect(lightScheme.secondary, const Color(0xFF8D2A2A));
        expect(lightScheme.onSecondary, Colors.white);
        expect(lightScheme.secondaryContainer, const Color(0xFFF9DCDC));
        expect(lightScheme.onSecondaryContainer, const Color(0xFF5D0000));
      });

      test('has defined tertiary colors', () {
        expect(lightScheme.tertiary, const Color(0xFF6C5D41));
        expect(lightScheme.onTertiary, Colors.white);
        expect(lightScheme.tertiaryContainer, const Color(0xFFF5EFDC));
        expect(lightScheme.onTertiaryContainer, const Color(0xFF413625));
      });

      test('has defined surface colors', () {
        expect(lightScheme.surface, Colors.white);
        expect(lightScheme.onSurface, Colors.grey.shade900);
        expect(lightScheme.surfaceTint, const Color(0xFF742020));
      });

      test('has defined error colors', () {
        expect(lightScheme.error, Colors.red.shade600);
        expect(lightScheme.onError, Colors.white);
      });

      test('has all surface container variants', () {
        expect(lightScheme.surfaceContainerLowest, isNotNull);
        expect(lightScheme.surfaceContainerLow, isNotNull);
        expect(lightScheme.surfaceContainer, isNotNull);
        expect(lightScheme.surfaceContainerHigh, isNotNull);
        expect(lightScheme.surfaceContainerHighest, isNotNull);
      });

      test('has defined outline colors', () {
        expect(lightScheme.outline, Colors.grey.shade400);
        expect(lightScheme.outlineVariant, Colors.grey.shade300);
      });

      test('has inverse colors', () {
        expect(lightScheme.inverseSurface, Colors.grey.shade900);
        expect(lightScheme.onInverseSurface, Colors.white);
        expect(lightScheme.inversePrimary, const Color(0xFFFFB3B3));
      });
    });

    group('Dark Color Scheme', () {
      late ColorScheme darkScheme;

      setUp(() {
        darkScheme = ThemeManager.darkColorScheme;
      });

      test('has correct brightness', () {
        expect(darkScheme.brightness, Brightness.dark);
      });

      test('has defined primary colors', () {
        expect(darkScheme.primary, const Color(0xFFD15959));
        expect(darkScheme.onPrimary, Colors.black);
        expect(darkScheme.primaryContainer, const Color(0xFF8F2C2C));
        expect(darkScheme.onPrimaryContainer, const Color(0xFFFFDADA));
      });

      test('has defined secondary colors', () {
        expect(darkScheme.secondary, const Color(0xFFE77979));
        expect(darkScheme.onSecondary, Colors.black);
        expect(darkScheme.secondaryContainer, const Color(0xFFA13636));
      });
    });

    group('Scheme Consistency', () {
      test('light and dark schemes have opposite brightness', () {
        expect(
          ThemeManager.lightColorScheme.brightness,
          isNot(ThemeManager.darkColorScheme.brightness),
        );
      });

      test('both schemes are accessible as static properties', () {
        expect(ThemeManager.lightColorScheme, isNotNull);
        expect(ThemeManager.darkColorScheme, isNotNull);
      });

      test('schemes return same instance on repeated access', () {
        final light1 = ThemeManager.lightColorScheme;
        final light2 = ThemeManager.lightColorScheme;
        expect(identical(light1, light2), true);

        final dark1 = ThemeManager.darkColorScheme;
        final dark2 = ThemeManager.darkColorScheme;
        expect(identical(dark1, dark2), true);
      });
    });

    group('Color Scheme Completeness', () {
      test('light scheme has all required colors', () {
        final scheme = ThemeManager.lightColorScheme;

        expect(scheme.primary, isNotNull);
        expect(scheme.onPrimary, isNotNull);
        expect(scheme.secondary, isNotNull);
        expect(scheme.onSecondary, isNotNull);
        expect(scheme.error, isNotNull);
        expect(scheme.onError, isNotNull);
        expect(scheme.surface, isNotNull);
        expect(scheme.onSurface, isNotNull);
      });

      test('dark scheme has all required colors', () {
        final scheme = ThemeManager.darkColorScheme;

        expect(scheme.primary, isNotNull);
        expect(scheme.onPrimary, isNotNull);
        expect(scheme.secondary, isNotNull);
        expect(scheme.onSecondary, isNotNull);
        expect(scheme.error, isNotNull);
        expect(scheme.onError, isNotNull);
        expect(scheme.surface, isNotNull);
        expect(scheme.onSurface, isNotNull);
      });
    });

    group('Theme Integration', () {
      testWidgets('light scheme can be used in ThemeData', (tester) async {
        final theme = ThemeData(
          colorScheme: ThemeManager.lightColorScheme,
          useMaterial3: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: const Scaffold(
              body: Text('Test'),
            ),
          ),
        );

        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('dark scheme can be used in ThemeData', (tester) async {
        final theme = ThemeData(
          colorScheme: ThemeManager.darkColorScheme,
          useMaterial3: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: const Scaffold(
              body: Text('Test'),
            ),
          ),
        );

        expect(find.text('Test'), findsOneWidget);
      });
    });
  });
}
