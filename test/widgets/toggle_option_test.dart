import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overkeys/widgets/options/toggle_option.dart';

void main() {
  group('ToggleOption Widget', () {
    testWidgets('renders with label and switch', (tester) async {
      bool toggleValue = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleOption(
              label: 'Test Option',
              value: toggleValue,
              onChanged: (value) {
                toggleValue = value;
              },
            ),
          ),
        ),
      );

      expect(find.text('Test Option'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('displays subtitle when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleOption(
              label: 'Test Option',
              value: false,
              onChanged: (_) {},
              subtitle: 'This is a subtitle',
            ),
          ),
        ),
      );

      expect(find.text('Test Option'), findsOneWidget);
      expect(find.text('This is a subtitle'), findsOneWidget);
    });

    testWidgets('does not display subtitle when null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleOption(
              label: 'Test Option',
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Option'), findsOneWidget);
      // Should only find one Text widget (the label)
      expect(find.byType(Text), findsNWidgets(1));
    });

    testWidgets('switch reflects initial value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleOption(
              label: 'Test Option',
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, true);
    });

    testWidgets('calls onChanged when switch is tapped', (tester) async {
      bool toggleValue = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ToggleOption(
                  label: 'Test Option',
                  value: toggleValue,
                  onChanged: (value) {
                    setState(() {
                      toggleValue = value;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(toggleValue, false);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(toggleValue, true);
    });

    testWidgets('can toggle multiple times', (tester) async {
      bool toggleValue = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ToggleOption(
                  label: 'Test Option',
                  value: toggleValue,
                  onChanged: (value) {
                    setState(() {
                      toggleValue = value;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(toggleValue, false);

      // Toggle on
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(toggleValue, true);

      // Toggle off
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(toggleValue, false);

      // Toggle on again
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(toggleValue, true);
    });

    testWidgets('has proper layout structure', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleOption(
              label: 'Test Option',
              value: false,
              onChanged: (_) {},
              subtitle: 'Subtitle text',
            ),
          ),
        ),
      );

      // Check for Row layout
      expect(find.byType(Row), findsOneWidget);

      // Check for Column containing label and subtitle
      expect(find.byType(Column), findsOneWidget);

      // Check for Switch
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('label uses correct text style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleOption(
              label: 'Test Option',
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Test Option'));
      expect(textWidget.style?.fontWeight, FontWeight.w600);
      expect(textWidget.style?.fontSize, 16);
    });
  });
}
