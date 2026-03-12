import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:unit_converter/main.dart' as app;
import 'package:unit_converter/services/premium_service.dart';
import 'package:unit_converter/services/admob_service.dart';

/// End-to-end tests for ad behavior in real app scenarios
/// These tests simulate actual user interactions and verify ad rendering
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Ad Testing', () {
    testWidgets('should show banner ads for free users', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify user is not premium
      expect(await PremiumService.isPremium(), isFalse);

      // Look for banner ad container
      expect(find.byKey(const Key('banner_ad_container')), findsOneWidget);
      
      // Verify banner ad is loaded (may take a moment)
      await tester.pump(Duration(seconds: 3));
      
      // Banner should be visible
      final bannerFinder = find.byKey(const Key('banner_ad_container'));
      expect(bannerFinder, findsOneWidget);
      
      // Verify banner has non-zero size (indicating ad loaded)
      final bannerWidget = tester.widget<Container>(bannerFinder);
      expect(bannerWidget.constraints?.maxHeight, greaterThan(0));
    });

    testWidgets('should not show banner ads for premium users', (WidgetTester tester) async {
      // Set premium status before starting app
      await PremiumService.setPremium(true);
      
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify user is premium
      expect(await PremiumService.isPremium(), isTrue);

      // Banner ad should NOT be present
      expect(find.byKey(const Key('banner_ad_container')), findsNothing);
    });

    testWidgets('should show interstitial after sufficient conversions', (WidgetTester tester) async {
      // Start app as free user
      app.main();
      await tester.pumpAndSettle();

      // Navigate to conversion screen
      final lengthCategory = find.text('Length');
      expect(lengthCategory, findsOneWidget);
      await tester.tap(lengthCategory);
      await tester.pumpAndSettle();

      // Perform 10 conversions to trigger first interstitial
      for (int i = 0; i < 10; i++) {
        // Enter value
        await tester.enterText(find.byType(TextField), '100');
        
        // Convert
        final convertButton = find.text('Convert');
        expect(convertButton, findsOneWidget);
        await tester.tap(convertButton);
        await tester.pumpAndSettle();

        // Go back for next conversion
        final backButton = find.byIcon(Icons.arrow_back);
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }

      // 11th conversion should trigger interstitial availability
      await tester.tap(lengthCategory);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '200');
      await tester.tap(find.text('Convert'));
      await tester.pumpAndSettle();

      // Check if interstitial should be shown
      expect(AdMobService.shouldShowInterstitial(), isTrue);
    });

    testWidgets('should show the production ad-free purchase flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      final settingsButton = find.byIcon(Icons.settings);
      expect(settingsButton, findsOneWidget);
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      // Find purchase button
      final purchaseButton = find.text('Go Ad-Free');
      expect(purchaseButton, findsOneWidget);

      // Verify purchase UI is present
      expect(find.text('Ad-free upgrade'), findsOneWidget);
      expect(
        find.text('Remove banner and interstitial ads for a cleaner conversion experience.'),
        findsOneWidget,
      );
      expect(find.text('Restore'), findsOneWidget);
      expect(await PremiumService.isPremium(), isFalse);
    });

    testWidgets('should handle ad loading errors gracefully', (WidgetTester tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Banner should be present even if ad fails to load
      expect(find.byKey(const Key('banner_ad_container')), findsOneWidget);
      
      // App should not crash on ad errors
      await tester.pump(Duration(seconds: 5));
      expect(tester.takeException(), isNull);
    });

    testWidgets('should maintain ad behavior across app restarts', (WidgetTester tester) async {
      // Start app and perform conversions
      app.main();
      await tester.pumpAndSettle();

      // Do 5 conversions
      final lengthCategory = find.text('Length');
      await tester.tap(lengthCategory);
      await tester.pumpAndSettle();

      for (int i = 0; i < 5; i++) {
        await tester.enterText(find.byType(TextField), '${100 + i}');
        await tester.tap(find.text('Convert'));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
      }

      // Verify conversion count
      expect(AdMobService.conversionCount, 5);

      // Simulate app restart
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        null,
        (data) {},
      );

      // Restart app
      app.main();
      await tester.pumpAndSettle();

      // Conversion count should persist
      expect(AdMobService.conversionCount, 5);
    });

    testWidgets('should respect frequency caps', (WidgetTester tester) async {
      // Start app as free user
      app.main();
      await tester.pumpAndSettle();

      // Navigate to conversion screen
      await tester.tap(find.text('Length'));
      await tester.pumpAndSettle();

      // Do 30 conversions (should trigger 2 interstitials max)
      for (int i = 0; i < 30; i++) {
        await tester.enterText(find.byType(TextField), '${100 + i}');
        await tester.tap(find.text('Convert'));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
      }

      // Should not exceed session limit
      expect(AdMobService.sessionInterstitials, lessThanOrEqualTo(3));
    });
  });
}
