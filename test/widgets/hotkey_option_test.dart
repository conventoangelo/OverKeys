import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overkeys/widgets/options/hotkey_option.dart';

void main() {
  group('HotKeyOption', () {
    testWidgets('renders with label and subtitle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotKeyOption(
              label: 'Visibility HotKey',
              subtitle: 'Toggle keyboard visibility',
              formattedHotKey: 'Ctrl + Shift + K',
              enabled: true,
              isEnabled: true,
              onToggleChanged: (_) {},
              onChangePressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Visibility HotKey'), findsOneWidget);
      expect(find.text('Toggle keyboard visibility'), findsOneWidget);
    });

    testWidgets('displays formatted hotkey', (tester) async {
      const testHotKey = 'Alt + F1';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotKeyOption(
              label: 'Test HotKey',
              subtitle: 'Test subtitle',
              formattedHotKey: testHotKey,
              enabled: true,
              isEnabled: true,
              onToggleChanged: (_) {},
              onChangePressed: () {},
            ),
          ),
        ),
      );

      expect(find.text(testHotKey), findsOneWidget);
    });

    testWidgets('shows switch widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotKeyOption(
              label: 'Test',
              subtitle: 'Test',
              formattedHotKey: 'Ctrl + A',
              enabled: true,
              isEnabled: true,
              onToggleChanged: (_) {},
              onChangePressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('shows change button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotKeyOption(
              label: 'Test',
              subtitle: 'Test',
              formattedHotKey: 'Ctrl + A',
              enabled: true,
              isEnabled: true,
              onToggleChanged: (_) {},
              onChangePressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Change'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('calls onToggleChanged when switch is toggled', (tester) async {
      bool toggledValue = false;
      bool callbackInvoked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotKeyOption(
              label: 'Test',
              subtitle: 'Test',
              formattedHotKey: 'Ctrl + A',
              enabled: false,
              isEnabled: true,
              onToggleChanged: (value) {
                toggledValue = value;
                callbackInvoked = true;
              },
              onChangePressed: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(callbackInvoked, true);
      expect(toggledValue, true);
    });

    testWidgets('calls onChangePressed when Change button is pressed',
        (tester) async {
      bool changePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotKeyOption(
              label: 'Test',
              subtitle: 'Test',
              formattedHotKey: 'Ctrl + A',
              enabled: true,
              isEnabled: true,
              onToggleChanged: (_) {},
              onChangePressed: () {
                changePressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Change'));
      await tester.pump();

      expect(changePressed, true);
    });

    testWidgets('switch reflects enabled state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotKeyOption(
              label: 'Test',
              subtitle: 'Test',
              formattedHotKey: 'Ctrl + A',
              enabled: true,
              isEnabled: true,
              onToggleChanged: (_) {},
              onChangePressed: () {},
            ),
          ),
        ),
      );

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, true);
    });

    testWidgets('disables change button when enabled is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotKeyOption(
              label: 'Test',
              subtitle: 'Test',
              formattedHotKey: 'Ctrl + A',
              enabled: false,
              isEnabled: true,
              onToggleChanged: (_) {},
              onChangePressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('label has correct style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotKeyOption(
              label: 'Auto Hide HotKey',
              subtitle: 'Test',
              formattedHotKey: 'Ctrl + H',
              enabled: true,
              isEnabled: true,
              onToggleChanged: (_) {},
              onChangePressed: () {},
            ),
          ),
        ),
      );

      final labelText = tester.widget<Text>(find.text('Auto Hide HotKey'));
      expect(labelText.style?.fontWeight, FontWeight.w600);
      expect(labelText.style?.fontSize, 16);
    });

    testWidgets('displays different hotkey formats', (tester) async {
      final hotkeys = [
        'Ctrl + Alt + Delete',
        'Shift + F12',
        'Win + L',
        'Alt + Tab',
      ];

      for (final hotkey in hotkeys) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HotKeyOption(
                label: 'Test',
                subtitle: 'Test',
                formattedHotKey: hotkey,
                enabled: true,
                isEnabled: true,
                onToggleChanged: (_) {},
                onChangePressed: () {},
              ),
            ),
          ),
        );

        expect(find.text(hotkey), findsOneWidget);

        await tester.pumpWidget(Container()); // Clear
      }
    });

    testWidgets('handles enabled and disabled states', (tester) async {
      // Test enabled state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotKeyOption(
              label: 'Test',
              subtitle: 'Test',
              formattedHotKey: 'Ctrl + A',
              enabled: true,
              isEnabled: true,
              onToggleChanged: (_) {},
              onChangePressed: () {},
            ),
          ),
        ),
      );

      var switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, true);

      // Test disabled state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotKeyOption(
              label: 'Test',
              subtitle: 'Test',
              formattedHotKey: 'Ctrl + A',
              enabled: false,
              isEnabled: true,
              onToggleChanged: (_) {},
              onChangePressed: () {},
            ),
          ),
        ),
      );

      switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, false);
    });

    testWidgets('has row layout for components', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotKeyOption(
              label: 'Test',
              subtitle: 'Test',
              formattedHotKey: 'Ctrl + A',
              enabled: true,
              isEnabled: true,
              onToggleChanged: (_) {},
              onChangePressed: () {},
            ),
          ),
        ),
      );

      // HotKeyOption uses multiple Row widgets
      expect(find.byType(Row), findsWidgets);
    });
  });
}
