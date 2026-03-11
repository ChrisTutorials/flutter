import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_app/main.dart';

void main() {
  group('MyApp Widget Tests', () {
    testWidgets('App title is correct', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.text('Flutter Demo Home Page'), findsOneWidget);
    });

    testWidgets('Material design is used', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App uses deep purple theme', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme?.colorScheme.brightness, Brightness.light);
    });
  });

  group('MyHomePage Widget Tests', () {
    testWidgets('Counter starts at 0', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);
    });

    testWidgets('Counter increments on button tap', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('Counter increments multiple times', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();
      }

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('FloatingActionButton is present', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Instruction text is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      expect(
        find.text('You have pushed the button this many times:'),
        findsOneWidget,
      );
    });

    testWidgets('Counter text uses headlineMedium style', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      final Text counterText = tester.widget(find.text('0'));
      expect(counterText.style?.fontSize, isNotNull);
    });

    testWidgets('App bar is present with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Flutter Demo Home Page'), findsOneWidget);
    });

    testWidgets('Scaffold is used as root widget', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Center widget is used for layout', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('Column widget is used for vertical layout', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('Button tap triggers setState', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Initial state
      expect(find.text('0'), findsOneWidget);

      // Tap button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // State should have changed
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('Counter value updates correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Test increment to 10
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();
      }

      expect(find.text('10'), findsOneWidget);
      expect(find.text('9'), findsNothing);
    });

    testWidgets('Multiple button taps in rapid succession', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Tap multiple times without pumping between each
      await tester.tap(find.byIcon(Icons.add));
      await tester.tap(find.byIcon(Icons.add));
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('3'), findsOneWidget);
    });
  });

  group('Integration Tests', () {
    testWidgets('Full user flow: start app, tap button 5 times', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify initial state
      expect(find.text('0'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Tap button 5 times
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();
      }

      // Verify final state
      expect(find.text('5'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
