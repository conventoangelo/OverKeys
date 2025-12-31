import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overkeys/widgets/options/slider_option.dart';

void main() {
  group('SliderOption', () {
    testWidgets('renders with label and value', (tester) async {
      double value = 0.5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SliderOption(
              label: 'Test Slider',
              value: value,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              onChanged: (_) {},
              onChangeEnd: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Slider'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('renders with subtitle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SliderOption(
              label: 'Test Slider',
              subtitle: 'This is a subtitle',
              value: 0.5,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              onChanged: (_) {},
              onChangeEnd: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Slider'), findsOneWidget);
      expect(find.text('This is a subtitle'), findsOneWidget);
    });

    testWidgets('calls onChanged when slider moves', (tester) async {
      double capturedValue = 0.0;
      bool onChangedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SliderOption(
              label: 'Test Slider',
              value: 0.5,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              onChanged: (value) {
                capturedValue = value;
                onChangedCalled = true;
              },
              onChangeEnd: (_) {},
            ),
          ),
        ),
      );

      final slider = find.byType(Slider);
      await tester.drag(slider, const Offset(100, 0));
      await tester.pump();

      expect(onChangedCalled, true);
      expect(capturedValue, greaterThan(0.5));
    });

    testWidgets('calls onChangeEnd when slider drag ends', (tester) async {
      bool onChangeEndCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SliderOption(
              label: 'Test Slider',
              value: 0.5,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              onChanged: (_) {},
              onChangeEnd: (value) {
                onChangeEndCalled = true;
              },
            ),
          ),
        ),
      );

      final slider = find.byType(Slider);
      await tester.drag(slider, const Offset(100, 0));
      await tester.pumpAndSettle();

      expect(onChangeEndCalled, true);
    });

    testWidgets('uses custom value formatter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SliderOption(
              label: 'Test Slider',
              value: 2.5,
              min: 0.0,
              max: 5.0,
              divisions: 50,
              onChanged: (_) {},
              onChangeEnd: (_) {},
              valueDisplayFormatter: (value) => '${value.toInt()}s',
            ),
          ),
        ),
      );

      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('respects min and max values', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SliderOption(
              label: 'Test Slider',
              value: 50.0,
              min: 10.0,
              max: 100.0,
              divisions: 90,
              onChanged: (_) {},
              onChangeEnd: (_) {},
            ),
          ),
        ),
      );

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.min, 10.0);
      expect(slider.max, 100.0);
      expect(slider.value, 50.0);
    });

    testWidgets('respects divisions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SliderOption(
              label: 'Test Slider',
              value: 0.5,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              onChanged: (_) {},
              onChangeEnd: (_) {},
            ),
          ),
        ),
      );

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.divisions, 20);
    });

    testWidgets('displays label with correct style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SliderOption(
              label: 'Opacity',
              value: 0.8,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              onChanged: (_) {},
              onChangeEnd: (_) {},
            ),
          ),
        ),
      );

      final labelText = tester.widget<Text>(find.text('Opacity'));
      expect(labelText.style?.fontWeight, FontWeight.w600);
      expect(labelText.style?.fontSize, 16);
    });
  });
}
