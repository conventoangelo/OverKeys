import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:overkeys/widgets/options/color_option.dart';

void main() {
  group('ColorOption', () {
    testWidgets('renders with label and color indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorOption(
              label: 'Primary Color',
              currentColor: Colors.blue,
              onColorChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Primary Color'), findsOneWidget);
      expect(find.byType(ColorIndicator), findsOneWidget);
    });

    testWidgets('displays current color in indicator', (tester) async {
      const testColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorOption(
              label: 'Test Color',
              currentColor: testColor,
              onColorChanged: (_) {},
            ),
          ),
        ),
      );

      final colorIndicator =
          tester.widget<ColorIndicator>(find.byType(ColorIndicator));
      expect(colorIndicator.color, testColor);
    });

    testWidgets('opens color picker dialog on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorOption(
              label: 'Background Color',
              currentColor: Colors.white,
              onColorChanged: (_) {},
            ),
          ),
        ),
      );

      // Tap color indicator
      await tester.tap(find.byType(ColorIndicator));
      await tester.pumpAndSettle();

      // Color picker dialog should be visible
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Select color'), findsOneWidget);
    });

    testWidgets('color picker shows ColorPicker widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorOption(
              label: 'Text Color',
              currentColor: Colors.black,
              onColorChanged: (_) {},
            ),
          ),
        ),
      );

      // Open color picker
      await tester.tap(find.byType(ColorIndicator));
      await tester.pumpAndSettle();

      expect(find.byType(ColorPicker), findsOneWidget);
    });

    testWidgets('label has correct style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorOption(
              label: 'Accent Color',
              currentColor: Colors.green,
              onColorChanged: (_) {},
            ),
          ),
        ),
      );

      final labelText = tester.widget<Text>(find.text('Accent Color'));
      expect(labelText.style?.fontWeight, FontWeight.w600);
      expect(labelText.style?.fontSize, 16);
    });

    testWidgets('color indicator has correct dimensions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorOption(
              label: 'Border Color',
              currentColor: Colors.grey,
              onColorChanged: (_) {},
            ),
          ),
        ),
      );

      final colorIndicator =
          tester.widget<ColorIndicator>(find.byType(ColorIndicator));
      expect(colorIndicator.width, 44);
      expect(colorIndicator.height, 44);
      expect(colorIndicator.borderRadius, 11);
    });

    testWidgets('displays label and indicator in row layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorOption(
              label: 'Foreground Color',
              currentColor: Colors.yellow,
              onColorChanged: (_) {},
            ),
          ),
        ),
      );

      // Should find a Row containing both label and indicator
      final row = find.ancestor(
        of: find.text('Foreground Color'),
        matching: find.byType(Row),
      );
      expect(row, findsOneWidget);
    });

    testWidgets('handles different colors correctly', (tester) async {
      final testColors = [
        Colors.red,
        Colors.blue,
        Colors.green,
        const Color(0xFF123456),
        const Color(0xFFFFFFFF),
        const Color(0xFF000000),
      ];

      for (final color in testColors) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ColorOption(
                label: 'Test Color',
                currentColor: color,
                onColorChanged: (_) {},
              ),
            ),
          ),
        );

        final colorIndicator =
            tester.widget<ColorIndicator>(find.byType(ColorIndicator));
        expect(colorIndicator.color, color);

        await tester.pumpWidget(Container()); // Clear widget tree
      }
    });

    testWidgets('calls onColorChanged when color is selected', (tester) async {
      Color? selectedColor;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorOption(
              label: 'Test Color',
              currentColor: Colors.blue,
              onColorChanged: (color) {
                selectedColor = color;
              },
            ),
          ),
        ),
      );

      // Open color picker
      await tester.tap(find.byType(ColorIndicator));
      await tester.pumpAndSettle();

      // Tap OK button in dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(selectedColor, isNotNull);
    });
  });
}
