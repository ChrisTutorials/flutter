import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/services/admob_service.dart';
import 'package:unit_converter/services/premium_service.dart';
import 'package:unit_converter/services/purchase_service.dart';
import 'package:common_flutter_ads/ad_service.dart';

/// Tests for premium functionality and IAP integration
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Premium Functionality', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      AdService.resetForTesting();
    });

    test('premium status should be false by default', () async {
      await AdMobService.initialize();
      expect(await PremiumService.isPremium(), isFalse);
      expect(AdMobService.adsEnabled, isTrue);
    });

    test('setting premium status should disable ads', () async {
      // Set premium BEFORE initialization
      await PremiumService.setPremium(true);
      await AdMobService.initialize();
      
      expect(await PremiumService.isPremium(), isTrue);
      expect(AdMobService.adsEnabled, isFalse);
    });

    test('removing premium status should enable ads', () async {
      // Set premium first
      await PremiumService.setPremium(true);
      await AdMobService.initialize();
      expect(await PremiumService.isPremium(), isTrue);
      expect(AdMobService.adsEnabled, isFalse);

      // Remove premium and reinitialize
      await PremiumService.setPremium(false);
      AdService.resetForTesting();
      await AdMobService.initialize();
      
      expect(await PremiumService.isPremium(), isFalse);
      expect(AdMobService.adsEnabled, isTrue);
    });

    test('premium status should persist across restarts', () async {
      // Set premium
      await PremiumService.setPremium(true);
      await AdMobService.initialize();
      expect(await PremiumService.isPremium(), isTrue);

      // Simulate app restart by re-initializing
      AdService.resetForTesting();
      await AdMobService.initialize();
      
      // Premium status should still be true and ads disabled
      expect(await PremiumService.isPremium(), isTrue);
      expect(AdMobService.adsEnabled, isFalse);
    });

    test('ads should be completely disabled when premium is active', () async {
      // Set premium BEFORE initialization
      await PremiumService.setPremium(true);
      await AdMobService.initialize();
      AdMobService.resetSessionCounters();

      expect(AdMobService.adsEnabled, isFalse);
      expect(AdMobService.shouldShowInterstitial(), isFalse);

      // Track many conversions
      for (int i = 0; i < 100; i++) {
        AdMobService.trackConversion();
      }

      // Ads should still be disabled
      expect(AdMobService.adsEnabled, isFalse);
      expect(AdMobService.shouldShowInterstitial(), isFalse);
    });

    test('premium entitlement changes should update ad gating', () async {
      await AdMobService.initialize();
      expect(await PremiumService.isPremium(), isFalse);

      await PremiumService.setPremium(true);
      AdService.resetForTesting();
      await AdMobService.initialize();
      expect(await PremiumService.isPremium(), isTrue);
      expect(AdMobService.adsEnabled, isFalse);

      await PremiumService.setPremium(false);
      AdService.resetForTesting();
      await AdMobService.initialize();
      expect(await PremiumService.isPremium(), isFalse);
      expect(AdMobService.adsEnabled, isTrue);
    });

    test('premium entitlement should integrate with ad service', () async {
      await PremiumService.setPremium(true);

      AdService.resetForTesting();
      await AdMobService.initialize();
      expect(await PremiumService.isPremium(), isTrue);
      expect(AdMobService.adsEnabled, isFalse);

      await PremiumService.setPremium(false);
      AdService.resetForTesting();
      await AdMobService.initialize();

      expect(await PremiumService.isPremium(), isFalse);
      expect(AdMobService.adsEnabled, isTrue);
    });

    test('premium status should handle rapid changes', () async {
      // Test rapid on/off changes
      for (int i = 0; i < 3; i++) {
        await PremiumService.setPremium(true);
        AdService.resetForTesting();
        await AdMobService.initialize();
        expect(await PremiumService.isPremium(), isTrue);
        expect(AdMobService.adsEnabled, isFalse);

        await PremiumService.setPremium(false);
        AdService.resetForTesting();
        await AdMobService.initialize();
        expect(await PremiumService.isPremium(), isFalse);
        expect(AdMobService.adsEnabled, isTrue);
      }
    });

    test('conversion tracking only advances while ads are enabled', () async {
      // Test with ads enabled
      await AdMobService.initialize();
      AdMobService.resetSessionCounters();
      
      for (int i = 0; i < 5; i++) {
        AdMobService.trackConversion();
      }
      expect(AdMobService.conversionCount, 5);

      // Test with ads disabled (premium)
      await PremiumService.setPremium(true);
      AdService.resetForTesting();
      await AdMobService.initialize();
      AdMobService.resetSessionCounters();

      // Tracking is ignored when ads are disabled for premium users.
      for (int i = 0; i < 3; i++) {
        AdMobService.trackConversion();
      }
      expect(AdMobService.conversionCount, 0);

      // Test with ads enabled again
      await PremiumService.setPremium(false);
      AdService.resetForTesting();
      await AdMobService.initialize();
      AdMobService.resetSessionCounters();

      // Continue tracking
      for (int i = 0; i < 2; i++) {
        AdMobService.trackConversion();
      }
      expect(AdMobService.conversionCount, 2);
    });

    test('product ID should be valid', () {
      const productId = 'no_ads_premium';
      expect(productId, matches(RegExp(r'^[a-z0-9-_]+$')));
      expect(productId.length, lessThanOrEqualTo(20));
      expect(productId, contains('no_ads'));
      expect(productId, contains('premium'));
    });

    test('purchase service should handle initialization without errors', () {
      // Test that we can create the service without errors
      expect(() => PurchaseService(), returnsNormally);
      
      // Should have valid initial state
      final purchaseService = PurchaseService();
      expect(purchaseService.isPurchasePending, isFalse);
      expect(purchaseService.noAdsProduct, isNull);
    });
  });

  group('Premium User Experience', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      AdService.resetForTesting();
    });

    test('premium users should never see interstitials', () async {
      // Set premium before initialization
      await PremiumService.setPremium(true);
      await AdMobService.initialize();
      AdMobService.resetSessionCounters();

      // Try all conditions that would normally show ads
      for (int i = 0; i < 100; i++) {
        AdMobService.trackConversion();
      }

      expect(AdMobService.shouldShowInterstitial(), isFalse);
      expect(AdMobService.adsEnabled, isFalse);
    });

    test('premium users should have ad-free experience', () async {
      // Set premium before initialization
      await PremiumService.setPremium(true);
      await AdMobService.initialize();

      // Verify ad-free state
      expect(AdMobService.adsEnabled, isFalse);
      expect(AdMobService.shouldShowInterstitial(), isFalse);
      
      // Banner ad creation should fail gracefully
      expect(() => AdMobService.createBannerAd(), throwsA(isA<StateError>()));
    });

    test('non-premium users should see ads according to rules', () async {
      // Ensure not premium and initialize
      await PremiumService.setPremium(false);
      await AdMobService.initialize();
      AdMobService.resetSessionCounters();

      expect(AdMobService.adsEnabled, isTrue);
      
      // Track conversions to meet first-time protection
      for (int i = 0; i < 10; i++) {
        AdMobService.trackConversion();
      }

      // Should now be eligible for ads (after 10 conversions, but need 20 between ads)
      // Actually need 20 total conversions since this is the first ad
      for (int i = 0; i < 10; i++) {
        AdMobService.trackConversion();
      }

      expect(AdMobService.shouldShowInterstitial(), isTrue);
    });
  });
}
