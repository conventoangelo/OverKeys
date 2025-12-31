import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overkeys/widgets/status_overlay.dart';

void main() {
  group('StatusOverlay', () {
    testWidgets('renders when visible is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusOverlay(
              visible: true,
              message: 'Test Message',
              icon: const Icon(Icons.check),
              backgroundColor: Colors.green,
              textColor: Colors.white,
              keySize: 60,
              keyBorderRadius: 8,
            ),
          ),
        ),
      );

      expect(find.text('Test Message'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('hides when visible is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusOverlay(
              visible: false,
              message: 'Hidden Message',
              icon: const Icon(Icons.error),
              backgroundColor: Colors.red,
              textColor: Colors.white,
              keySize: 60,
              keyBorderRadius: 8,
            ),
          ),
        ),
      );

      // Widget still renders but with 0 opacity
      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(opacity.opacity, 0.0);
    });

    testWidgets('displays correct message', (tester) async {
      const testMessage = 'Auto-hide enabled';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusOverlay(
              visible: true,
              message: testMessage,
              icon: const Icon(Icons.visibility_off),
              backgroundColor: Colors.blue,
              textColor: Colors.white,
              keySize: 60,
              keyBorderRadius: 8,
            ),
          ),
        ),
      );

      expect(find.text(testMessage), findsOneWidget);
    });

    testWidgets('shows correct icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusOverlay(
              visible: true,
              message: 'Success',
              icon: const Icon(Icons.check_circle),
              backgroundColor: Colors.green,
              textColor: Colors.white,
              keySize: 60,
              keyBorderRadius: 8,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('respects keySize for container dimensions', (tester) async {
      const testKeySize = 80.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusOverlay(
              visible: true,
              message: 'Test',
              icon: const Icon(Icons.info),
              backgroundColor: Colors.blue,
              textColor: Colors.white,
              keySize: testKeySize,
              keyBorderRadius: 10,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnimatedOpacity),
          matching: find.byType(Container),
        ),
      );

      expect(container.constraints?.maxWidth, testKeySize * 2.5);
      expect(container.constraints?.maxHeight, testKeySize * 2.5);
    });

    testWidgets('applies background color correctly', (tester) async {
      const testColor = Color(0xFF123456);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusOverlay(
              visible: true,
              message: 'Test',
              icon: const Icon(Icons.star),
              backgroundColor: testColor,
              textColor: Colors.white,
              keySize: 60,
              keyBorderRadius: 8,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnimatedOpacity),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, testColor);
    });

    testWidgets('applies border radius correctly', (tester) async {
      const testRadius = 15.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusOverlay(
              visible: true,
              message: 'Test',
              icon: const Icon(Icons.done),
              backgroundColor: Colors.green,
              textColor: Colors.white,
              keySize: 60,
              keyBorderRadius: testRadius,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnimatedOpacity),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      final borderRadius = decoration.borderRadius as BorderRadius;
      expect(borderRadius.topLeft.x, testRadius);
    });

    testWidgets('animates opacity changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusOverlay(
              visible: true,
              message: 'Test',
              icon: const Icon(Icons.info),
              backgroundColor: Colors.blue,
              textColor: Colors.white,
              keySize: 60,
              keyBorderRadius: 8,
            ),
          ),
        ),
      );

      var opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(opacity.opacity, 1.0);
      expect(opacity.duration, const Duration(milliseconds: 200));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusOverlay(
              visible: false,
              message: 'Test',
              icon: const Icon(Icons.info),
              backgroundColor: Colors.blue,
              textColor: Colors.white,
              keySize: 60,
              keyBorderRadius: 8,
            ),
          ),
        ),
      );

      opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(opacity.opacity, 0.0);
    });

    testWidgets('centers content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusOverlay(
              visible: true,
              message: 'Test',
              icon: const Icon(Icons.info),
              backgroundColor: Colors.blue,
              textColor: Colors.white,
              keySize: 60,
              keyBorderRadius: 8,
            ),
          ),
        ),
      );

      // StatusOverlay uses Center widget for centering
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('has shadow effect', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusOverlay(
              visible: true,
              message: 'Test',
              icon: const Icon(Icons.info),
              backgroundColor: Colors.blue,
              textColor: Colors.white,
              keySize: 60,
              keyBorderRadius: 8,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnimatedOpacity),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 1);
    });

    testWidgets('displays different messages', (tester) async {
      final messages = [
        'Opacity increased',
        'Opacity decreased',
        'Auto-hide enabled',
        'Window moved',
      ];

      for (final message in messages) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatusOverlay(
                visible: true,
                message: message,
                icon: const Icon(Icons.info),
                backgroundColor: Colors.blue,
                textColor: Colors.white,
                keySize: 60,
                keyBorderRadius: 8,
              ),
            ),
          ),
        );

        expect(find.text(message), findsOneWidget);

        await tester.pumpWidget(Container()); // Clear widget tree
      }
    });

    testWidgets('displays different icons', (tester) async {
      final icons = [
        Icons.check,
        Icons.close,
        Icons.info,
        Icons.warning,
        Icons.visibility_off,
      ];

      for (final iconData in icons) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatusOverlay(
                visible: true,
                message: 'Test',
                icon: Icon(iconData),
                backgroundColor: Colors.blue,
                textColor: Colors.white,
                keySize: 60,
                keyBorderRadius: 8,
              ),
            ),
          ),
        );

        expect(find.byIcon(iconData), findsOneWidget);

        await tester.pumpWidget(Container()); // Clear widget tree
      }
    });
  });
}
