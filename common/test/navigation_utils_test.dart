import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common_flutter_utilities/navigation_utils.dart';

void main() {
  group('NavigationUtils', () {
    testWidgets('pushScreen navigates to new screen', (WidgetTester tester) async {
      const firstScreen = FirstScreen();
      const secondScreen = SecondScreen();

      await tester.pumpWidget(
        MaterialApp(
          home: firstScreen,
        ),
      );

      expect(find.byType(FirstScreen), findsOneWidget);
      expect(find.byType(SecondScreen), findsNothing);

      // Navigate to second screen
      await tester.runAsync(() async {
        await NavigationUtils.pushScreen(
          tester.element(find.byType(FirstScreen)),
          secondScreen,
        );
      });

      await tester.pumpAndSettle();

      expect(find.byType(FirstScreen), findsNothing);
      expect(find.byType(SecondScreen), findsOneWidget);
    });

    testWidgets('pop navigates back', (WidgetTester tester) async {
      const firstScreen = FirstScreen();
      const secondScreen = SecondScreen();

      await tester.pumpWidget(
        MaterialApp(
          home: firstScreen,
          routes: {
            '/second': (context) => secondScreen,
          },
        ),
      );

      // Navigate to second screen
      await tester.runAsync(() async {
        await NavigationUtils.pushScreen(
          tester.element(find.byType(FirstScreen)),
          secondScreen,
        );
      });

      await tester.pumpAndSettle();

      expect(find.byType(SecondScreen), findsOneWidget);

      // Pop back
      NavigationUtils.pop(tester.element(find.byType(SecondScreen)));

      await tester.pumpAndSettle();

      expect(find.byType(FirstScreen), findsOneWidget);
      expect(find.byType(SecondScreen), findsNothing);
    });

    testWidgets('pushReplacement replaces current screen', (WidgetTester tester) async {
      const firstScreen = FirstScreen();
      const secondScreen = SecondScreen();
      const thirdScreen = ThirdScreen();

      await tester.pumpWidget(
        MaterialApp(
          home: firstScreen,
        ),
      );

      // Navigate to second screen
      await tester.runAsync(() async {
        await NavigationUtils.pushScreen(
          tester.element(find.byType(FirstScreen)),
          secondScreen,
        );
      });

      await tester.pumpAndSettle();

      // Replace with third screen
      await tester.runAsync(() async {
        await NavigationUtils.pushReplacement(
          tester.element(find.byType(SecondScreen)),
          thirdScreen,
        );
      });

      await tester.pumpAndSettle();

      expect(find.byType(FirstScreen), findsNothing);
      expect(find.byType(SecondScreen), findsNothing);
      expect(find.byType(ThirdScreen), findsOneWidget);
    });

    testWidgets('pushWithCallback executes callback on pop', (WidgetTester tester) async {
      const firstScreen = FirstScreen();
      const secondScreen = SecondScreen();

      await tester.pumpWidget(
        MaterialApp(
          home: firstScreen,
        ),
      );

      bool callbackExecuted = false;

      // Navigate with callback
      await tester.runAsync(() async {
        await NavigationUtils.pushWithCallback(
          tester.element(find.byType(FirstScreen)),
          secondScreen,
          () {
            callbackExecuted = true;
          },
        );
      });

      await tester.pumpAndSettle();

      expect(callbackExecuted, isFalse);

      // Pop back
      NavigationUtils.pop(tester.element(find.byType(SecondScreen)));

      await tester.pumpAndSettle();

      expect(callbackExecuted, isTrue);
    });

    testWidgets('pushAndRemoveUntil clears back stack', (WidgetTester tester) async {
      const firstScreen = FirstScreen();
      const secondScreen = SecondScreen();
      const thirdScreen = ThirdScreen();

      await tester.pumpWidget(
        MaterialApp(
          home: firstScreen,
        ),
      );

      // Navigate to second screen
      await tester.runAsync(() async {
        await NavigationUtils.pushScreen(
          tester.element(find.byType(FirstScreen)),
          secondScreen,
        );
      });

      await tester.pumpAndSettle();

      // Navigate to third screen
      await tester.runAsync(() async {
        await NavigationUtils.pushScreen(
          tester.element(find.byType(SecondScreen)),
          thirdScreen,
        );
      });

      await tester.pumpAndSettle();

      // Push and remove until first screen (should clear all)
      await tester.runAsync(() async {
        await NavigationUtils.pushAndRemoveUntil(
          tester.element(find.byType(ThirdScreen)),
          firstScreen,
          predicate: (route) => route.isFirst,
        );
      });

      await tester.pumpAndSettle();

      expect(find.byType(FirstScreen), findsOneWidget);
      expect(find.byType(SecondScreen), findsNothing);
      expect(find.byType(ThirdScreen), findsNothing);
    });
  });
}

// Test widgets
class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text('First Screen'),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text('Second Screen'),
    );
  }
}

class ThirdScreen extends StatelessWidget {
  const ThirdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text('Third Screen'),
    );
  }
}
