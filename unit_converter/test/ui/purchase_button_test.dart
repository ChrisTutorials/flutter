import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unit_converter/services/premium_service.dart';
import 'package:unit_converter/widgets/purchase_button.dart';

void main() {
  group('PurchaseButton mobile branch', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PremiumService.setPremium(false);
    });

    testWidgets('should display ad-free purchase button when not premium', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PurchaseButton(isWindowsPlatform: false),
          ),
        ),
      );

      expect(find.text('Ad-free upgrade'), findsOneWidget);
      expect(find.text('Go Ad-Free'), findsOneWidget);
      expect(find.text('Restore'), findsOneWidget);
      expect(find.text('Premium unlock'), findsNothing);
      expect(find.text('Unlock Premium'), findsNothing);
    });

    testWidgets('should display mobile premium status when premium is active', (
      WidgetTester tester,
    ) async {
      await PremiumService.setPremium(true);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PurchaseButton(isWindowsPlatform: false),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Premium Active'), findsOneWidget);
      expect(find.text('Enjoy your ad-free experience!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Ad-free upgrade'), findsNothing);
      expect(find.text('Go Ad-Free'), findsNothing);
    });

    testWidgets('should handle mobile purchase button tap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PurchaseButton(isWindowsPlatform: false),
          ),
        ),
      );

      expect(find.text('Go Ad-Free'), findsOneWidget);
      await tester.tap(find.text('Go Ad-Free'));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('should handle restore button tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PurchaseButton(isWindowsPlatform: false),
          ),
        ),
      );

      expect(find.text('Restore'), findsOneWidget);
      await tester.tap(find.text('Restore'));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('should display correct UI based on initial premium status', (
      WidgetTester tester,
    ) async {
      await PremiumService.setPremium(false);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PurchaseButton(isWindowsPlatform: false),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Ad-free upgrade'), findsOneWidget);
      expect(find.text('Go Ad-Free'), findsOneWidget);
      expect(find.text('Premium Active'), findsNothing);
    });

    testWidgets('should display premium UI when premium status is true at startup', (
      WidgetTester tester,
    ) async {
      await PremiumService.setPremium(true);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PurchaseButton(isWindowsPlatform: false),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Premium Active'), findsOneWidget);
      expect(find.text('Ad-free upgrade'), findsNothing);
      expect(find.text('Go Ad-Free'), findsNothing);
    });

    testWidgets('should have correct styling and layout', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PurchaseButton(isWindowsPlatform: false),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.byIcon(Icons.workspace_premium_outlined), findsOneWidget);
      expect(
        find.text(
          'Remove banner and interstitial ads for a cleaner conversion experience.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should use theme-aware text colors in dark mode', (
      WidgetTester tester,
    ) async {
      final darkTheme = ThemeData.dark();

      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: const Scaffold(
            body: PurchaseButton(isWindowsPlatform: false),
          ),
        ),
      );

      expect(find.text('Ad-free upgrade'), findsOneWidget);
      expect(
        find.text(
          'Remove banner and interstitial ads for a cleaner conversion experience.',
        ),
        findsOneWidget,
      );

      final descriptionText = tester.widget<Text>(
        find.text(
          'Remove banner and interstitial ads for a cleaner conversion experience.',
        ),
      );
      expect(
        descriptionText.style?.color,
        equals(darkTheme.colorScheme.onSurfaceVariant),
      );
    });

    testWidgets('should use theme-aware text colors in light mode', (
      WidgetTester tester,
    ) async {
      final lightTheme = ThemeData.light();

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: const Scaffold(
            body: PurchaseButton(isWindowsPlatform: false),
          ),
        ),
      );

      expect(find.text('Ad-free upgrade'), findsOneWidget);
      expect(
        find.text(
          'Remove banner and interstitial ads for a cleaner conversion experience.',
        ),
        findsOneWidget,
      );

      final descriptionText = tester.widget<Text>(
        find.text(
          'Remove banner and interstitial ads for a cleaner conversion experience.',
        ),
      );
      expect(
        descriptionText.style?.color,
        equals(lightTheme.colorScheme.onSurfaceVariant),
      );
    });
  });

  group('Premium Service Integration', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('should persist premium status', () async {
      await PremiumService.setPremium(true);
      expect(await PremiumService.isPremium(), isTrue);
      expect(await PremiumService.isPremium(), isTrue);
    });

    test('should toggle premium status correctly', () async {
      expect(await PremiumService.isPremium(), isFalse);

      await PremiumService.setPremium(true);
      expect(await PremiumService.isPremium(), isTrue);

      await PremiumService.setPremium(false);
      expect(await PremiumService.isPremium(), isFalse);
    });
  });

  group('Premium state transitions', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('should enable premium state', () async {
      await PremiumService.setPremium(true);
      expect(await PremiumService.isPremium(), isTrue);
    });

    test('should disable premium state', () async {
      await PremiumService.setPremium(true);
      expect(await PremiumService.isPremium(), isTrue);

      await PremiumService.setPremium(false);
      expect(await PremiumService.isPremium(), isFalse);
    });
  });

  group('PurchaseButton Windows branch', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PremiumService.setPremium(false);
    });

    testWidgets('should display Windows premium unlock copy', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PurchaseButton(isWindowsPlatform: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Premium unlock'), findsOneWidget);
      expect(find.text('Unlock Premium'), findsOneWidget);
      expect(
        find.text(
          'Unlock Currency, advanced converters, and Custom Units with a one-time premium purchase.',
        ),
        findsOneWidget,
      );
      expect(find.text('Ad-free upgrade'), findsNothing);
      expect(find.text('Go Ad-Free'), findsNothing);
    });

    testWidgets('should display Windows premium active messaging', (
      WidgetTester tester,
    ) async {
      await PremiumService.setPremium(true);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PurchaseButton(isWindowsPlatform: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Premium Active'), findsOneWidget);
      expect(
        find.text('All premium Windows features are unlocked.'),
        findsOneWidget,
      );
      expect(find.text('Enjoy your ad-free experience!'), findsNothing);
    });
  });
}
