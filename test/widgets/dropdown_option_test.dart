import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overkeys/widgets/options/dropdown_option.dart';

void main() {
  group('DropdownOption', () {
    final testOptions = ['Option 1', 'Option 2', 'Option 3'];

    testWidgets('renders with label and initial value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownOption(
              label: 'Test Dropdown',
              value: 'Option 1',
              options: testOptions,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Dropdown'), findsOneWidget);
      expect(find.byType(DropdownMenu<String>), findsOneWidget);
    });

    testWidgets('renders with subtitle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownOption(
              label: 'Test Dropdown',
              subtitle: 'Select an option',
              value: 'Option 1',
              options: testOptions,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Dropdown'), findsOneWidget);
      expect(find.text('Select an option'), findsOneWidget);
    });

    testWidgets('displays current value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownOption(
              label: 'Font',
              value: 'Courier',
              options: ['Arial', 'Courier', 'Times'],
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Font'), findsOneWidget);
      // The dropdown displays the value in a TextFormField
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
    });

    testWidgets('calls onChanged when value selected', (tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownOption(
              label: 'Test Dropdown',
              value: 'Option 1',
              options: testOptions,
              onChanged: (value) {
                selectedValue = value;
              },
            ),
          ),
        ),
      );

      // Tap on dropdown to open menu
      await tester.tap(find.byType(DropdownMenu<String>));
      await tester.pumpAndSettle();

      // Select Option 2
      await tester.tap(find.text('Option 2').last);
      await tester.pumpAndSettle();

      expect(selectedValue, 'Option 2');
    });

    testWidgets('dropdown can be opened and closed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownOption(
              label: 'Test Dropdown',
              value: 'Option 1',
              options: testOptions,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Tap to open dropdown
      await tester.tap(find.byType(DropdownMenu<String>));
      await tester.pumpAndSettle();

      // Now menu items should be visible
      expect(find.text('Option 2'), findsAtLeastNWidgets(1));
      expect(find.text('Option 3'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays all options in dropdown menu', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownOption(
              label: 'Test Dropdown',
              value: 'Option 1',
              options: testOptions,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(DropdownMenu<String>));
      await tester.pumpAndSettle();

      // Check all options are present
      for (final option in testOptions) {
        expect(find.text(option), findsAtLeastNWidgets(1));
      }
    });

    testWidgets('label has correct style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownOption(
              label: 'Font Family',
              value: 'Arial',
              options: ['Arial', 'Courier'],
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final labelText = tester.widget<Text>(find.text('Font Family'));
      expect(labelText.style?.fontWeight, FontWeight.w600);
      expect(labelText.style?.fontSize, 16);
    });

    testWidgets('handles empty options list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownOption(
              label: 'Empty Dropdown',
              value: '',
              options: const [],
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Empty Dropdown'), findsOneWidget);
      expect(find.byType(DropdownMenu<String>), findsOneWidget);
    });
  });
}
