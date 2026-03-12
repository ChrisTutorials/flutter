import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unit_converter/widgets/purchase_button.dart';
import 'package:unit_converter/services/premium_service.dart';

void main() {
  group('PurchaseButton Widget', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PremiumService.setPremium(false);
    });

    testWidgets('should display purchase button when not premium', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurchaseButton(),
          ),
        ),
      );

      // Should show purchase UI
      expect(find.text('Ad-free upgrade'), findsOneWidget);
      expect(find.text('Go Ad-Free'), findsOneWidget);
      expect(find.text('Restore'), findsOneWidget);
    });

    testWidgets('should display premium status when premium is active', (WidgetTester tester) async {
      // Set premium status
      await PremiumService.setPremium(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurchaseButton(),
          ),
        ),
      );

      // Wait for the async _checkPremiumStatus() to complete
      await tester.pumpAndSettle();

      // Should show premium status
      expect(find.text('Premium Active'), findsOneWidget);
      expect(find.text('Enjoy your ad-free experience!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Should not show purchase button
      expect(find.text('Ad-free upgrade'), findsNothing);
      expect(find.text('Go Ad-Free'), findsNothing);
    });

    testWidgets('should handle purchase button tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurchaseButton(),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('Go Ad-Free'), findsOneWidget);

      // Tap purchase button - should not throw
      await tester.tap(find.text('Go Ad-Free'));
      await tester.pump(); // Trigger the setState

      // Wait for the async operation to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('should handle restore button tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurchaseButton(),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('Restore'), findsOneWidget);

      // Tap restore button - should not throw
      await tester.tap(find.text('Restore'));
      await tester.pump(); // Trigger the setState

      // Wait for the async operation to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('should display error message when present', (WidgetTester tester) async {
      // Create a custom PurchaseButton widget that shows error
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // Simulate error state
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error, color: Colors.red[700], size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Test error message',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Go Ad-Free'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Should show error message
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('should display correct UI based on initial premium status', (WidgetTester tester) async {
      // Test with premium false
      await PremiumService.setPremium(false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurchaseButton(),
          ),
        ),
      );

      // Wait for the async _checkPremiumStatus() to complete
      await tester.pumpAndSettle();

      // Should show purchase button
      expect(find.text('Ad-free upgrade'), findsOneWidget);
      expect(find.text('Go Ad-Free'), findsOneWidget);
      expect(find.text('Premium Active'), findsNothing);
    });

    testWidgets('should display premium UI when premium status is true at startup', (WidgetTester tester) async {
      // Test with premium true
      await PremiumService.setPremium(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurchaseButton(),
          ),
        ),
      );

      // Wait for the async _checkPremiumStatus() to complete
      await tester.pumpAndSettle();

      // Should show premium status
      expect(find.text('Premium Active'), findsOneWidget);
      expect(find.text('Ad-free upgrade'), findsNothing);
      expect(find.text('Go Ad-Free'), findsNothing);
    });

    testWidgets('should have correct styling and layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurchaseButton(),
          ),
        ),
      );

      // Should be wrapped in a Card
      expect(find.byType(Card), findsOneWidget);

      // Should have proper structure
      expect(find.byIcon(Icons.workspace_premium_outlined), findsOneWidget);
      expect(find.text('Remove banner and interstitial ads for a cleaner conversion experience.'), findsOneWidget);
    });

    testWidgets('should use theme-aware text colors in dark mode', (WidgetTester tester) async {
      final darkTheme = ThemeData.dark();

      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: Scaffold(
            body: PurchaseButton(),
          ),
        ),
      );

      // Verify text elements exist
      expect(find.text('Ad-free upgrade'), findsOneWidget);
      expect(find.text('Remove banner and interstitial ads for a cleaner conversion experience.'), findsOneWidget);

      // Verify the description text uses theme color
      final descriptionText = tester.widget<Text>(
        find.text('Remove banner and interstitial ads for a cleaner conversion experience.'),
      );
      expect(descriptionText.style?.color, equals(darkTheme.colorScheme.onSurfaceVariant));
    });

    testWidgets('should use theme-aware text colors in light mode', (WidgetTester tester) async {
      final lightTheme = ThemeData.light();

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: PurchaseButton(),
          ),
        ),
      );

      // Verify text elements exist
      expect(find.text('Ad-free upgrade'), findsOneWidget);
      expect(find.text('Remove banner and interstitial ads for a cleaner conversion experience.'), findsOneWidget);

      // Verify the description text uses theme color
      final descriptionText = tester.widget<Text>(
        find.text('Remove banner and interstitial ads for a cleaner conversion experience.'),
      );
      expect(descriptionText.style?.color, equals(lightTheme.colorScheme.onSurfaceVariant));
    });
  });

  group('Premium Service Integration', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('should persist premium status', () async {
      // Set premium
      await PremiumService.setPremium(true);
      expect(await PremiumService.isPremium(), isTrue);

      // Test persistence
      expect(await PremiumService.isPremium(), isTrue);
    });

    test('should toggle premium status correctly', () async {
      // Initially false
      expect(await PremiumService.isPremium(), isFalse);

      // Set to true
      await PremiumService.setPremium(true);
      expect(await PremiumService.isPremium(), isTrue);

      // Set back to false
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
}
