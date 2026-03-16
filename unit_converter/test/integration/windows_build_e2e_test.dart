import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/services/admob_service.dart';
import 'package:unit_converter/services/premium_service.dart';
import 'package:unit_converter/services/purchase_service.dart';
import 'package:unit_converter/services/windows_store_access_policy.dart';
import 'package:common_flutter_ads/ad_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

void main() {
  group('Windows Build End-to-End Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});

      // Reset all services
      AdService.resetForTesting();
      await PremiumService.setPremium(false);

      // Set platform to Windows (non-mobile) for all tests
      AdService.setPlatformOverrideForTesting(false);

      // Initialize services
      await AdMobService.initialize();

      // Create PurchaseService with Windows not supported
      final purchaseService = PurchaseService.test(
        inAppPurchase: _MockInAppPurchase(),
        platformSupported: false,
      );
      await purchaseService.initialize();
      purchaseService.dispose();
    });

    test('Windows app initializes without ads', () async {
      // Verify ads are disabled
      expect(AdMobService.adsEnabled, isFalse,
          reason: 'Ads should be disabled on Windows');
    });

    test('Windows app shows free categories to non-premium users', () async {
      // Create Windows store access policy for free tier
      final policy = WindowsStoreAccessPolicy(
        isWindowsPlatform: true,
        premiumStatusLoader: () async => false,
      );

      // Verify free categories are accessible
      expect(await policy.canAccessCategory('Length'), isTrue,
          reason: 'Length should be accessible on Windows free tier');
      expect(await policy.canAccessCategory('Weight'), isTrue,
          reason: 'Weight should be accessible on Windows free tier');
      expect(await policy.canAccessCategory('Temperature'), isTrue,
          reason: 'Temperature should be accessible on Windows free tier');
    });

    test('Windows app locks premium categories for non-premium users', () async {
      // Create Windows store access policy for free tier
      final policy = WindowsStoreAccessPolicy(
        isWindowsPlatform: true,
        premiumStatusLoader: () async => false,
      );

      // Verify premium categories are locked
      expect(await policy.canAccessCategory('Volume'), isFalse,
          reason: 'Volume should be locked on Windows free tier');
      expect(await policy.canAccessCategory('Data'), isFalse,
          reason: 'Data should be locked on Windows free tier');
      expect(await policy.canAccessCurrency(), isFalse,
          reason: 'Currency should be locked on Windows free tier');
      expect(await policy.canAccessCustomUnits(), isFalse,
          reason: 'Custom Units should be locked on Windows free tier');
    });

    test('Windows app unlocks all categories for premium users', () async {
      // Set premium status
      await PremiumService.setPremium(true);

      // Create Windows store access policy for premium tier
      final policy = WindowsStoreAccessPolicy(
        isWindowsPlatform: true,
        premiumStatusLoader: () async => true,
      );

      // Verify all categories are accessible
      expect(await policy.canAccessCategory('Length'), isTrue);
      expect(await policy.canAccessCategory('Weight'), isTrue);
      expect(await policy.canAccessCategory('Temperature'), isTrue);
      expect(await policy.canAccessCategory('Volume'), isTrue,
          reason: 'Volume should be accessible on Windows premium tier');
      expect(await policy.canAccessCategory('Data'), isTrue,
          reason: 'Data should be accessible on Windows premium tier');
      expect(await policy.canAccessCurrency(), isTrue,
          reason: 'Currency should be accessible on Windows premium tier');
      expect(await policy.canAccessCustomUnits(), isTrue,
          reason: 'Custom Units should be accessible on Windows premium tier');

      // Reset for other tests
      await PremiumService.setPremium(false);
    });

    test('Windows app does not show banner ads', () async {
      // Verify ads are disabled
      expect(AdMobService.adsEnabled, isFalse);

      // Attempting to create banner ad should throw
      expect(
        () => AdMobService.createBannerAd(),
        throwsA(isA<StateError>()),
        reason: 'Banner ad creation should fail on Windows',
      );
    });

    test('Windows app does not show interstitial ads', () async {
      // Verify ads are disabled
      expect(AdMobService.adsEnabled, isFalse);

      // Track many conversions
      for (int i = 0; i < 25; i++) {
        AdMobService.trackConversion();
      }

      // Verify no interstitials were shown
      expect(AdMobService.conversionCount, equals(0),
          reason: 'Conversions should not be tracked when ads are disabled');
      expect(AdMobService.sessionInterstitials, equals(0),
          reason: 'No interstitials should be shown on Windows');
    });

    test('Windows app does not show app open ads', () async {
      // Verify ads are disabled
      expect(AdMobService.adsEnabled, isFalse);

      // Try to show app open ad
      await AdMobService.showAppOpenAdIfAvailable();

      // Should complete without error and no ads shown
      expect(AdMobService.adsEnabled, isFalse);
    });

    test('Windows IAP is not available', () async {
      // Create PurchaseService with Windows not supported
      final purchaseService = PurchaseService.test(
        inAppPurchase: _MockInAppPurchase(),
        platformSupported: false,
      );
      await purchaseService.initialize();

      // Verify IAP is not available
      expect(purchaseService.isAvailable, isFalse,
          reason: 'IAP should not be available on Windows yet');

      // Verify no product is loaded
      expect(purchaseService.noAdsProduct, isNull,
          reason: 'No product should be loaded on Windows');

      purchaseService.dispose();
    });

    test('Windows app handles purchase attempts gracefully', () async {
      // Create PurchaseService with Windows not supported
      final purchaseService = PurchaseService.test(
        inAppPurchase: _MockInAppPurchase(),
        platformSupported: false,
      );
      await purchaseService.initialize();

      // Attempt to purchase - should fail gracefully
      final result = await purchaseService.purchaseNoAds();
      expect(result, isFalse,
          reason: 'Purchase should fail gracefully on Windows');

      // Verify error message is set (expected behavior when purchase not available)
      expect(purchaseService.errorMessage, isNotNull,
          reason: 'Error message should be set when purchase not available');

      purchaseService.dispose();
    });

    test('Windows app handles restore purchases gracefully', () async {
      // Create PurchaseService with Windows not supported
      final purchaseService = PurchaseService.test(
        inAppPurchase: _MockInAppPurchase(),
        platformSupported: false,
      );
      await purchaseService.initialize();

      // Attempt to restore purchases - should complete without error
      await expectLater(
        purchaseService.restorePurchases(),
        completes,
        reason: 'Restore purchases should complete without error on Windows',
      );

      purchaseService.dispose();
    });

    test('Windows premium status persists across app restarts', () async {
      // Set premium status
      await PremiumService.setPremium(true);
      expect(await PremiumService.isPremium(), isTrue);

      // Simulate app restart by checking SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('premium_enabled'), isTrue,
          reason: 'Premium status should persist in SharedPreferences');

      // Clear premium status
      await PremiumService.setPremium(false);
      expect(await PremiumService.isPremium(), isFalse);
    });

    test('Windows app functions correctly without ads or IAP', () async {
      // Verify ads are disabled
      expect(AdMobService.adsEnabled, isFalse);

      // Verify IAP is not available
      final purchaseService = PurchaseService.test(
        inAppPurchase: _MockInAppPurchase(),
        platformSupported: false,
      );
      await purchaseService.initialize();
      expect(purchaseService.isAvailable, isFalse);
      purchaseService.dispose();

      // Verify app can still function
      // (App should work in free mode without ads or IAP)
      expect(await PremiumService.isPremium(), isFalse);

      // Set premium status manually (simulating Windows Store entitlement)
      await PremiumService.setPremium(true);
      expect(await PremiumService.isPremium(), isTrue);

      // Reset for other tests
      await PremiumService.setPremium(false);
    });

    test('Windows app handles all ad service calls safely', () async {
      // Call all ad service methods - should all complete without error
      expect(AdMobService.loadInterstitialAd(), completes);
      expect(AdMobService.loadAppOpenAd(), completes);
      expect(AdMobService.showInterstitialAd(), completes);
      expect(AdMobService.showAppOpenAdIfAvailable(), completes);
      AdMobService.trackConversion();
      AdMobService.resetSessionCounters();
      AdMobService.dispose();

      // Verify all operations completed safely
      expect(AdMobService.adsEnabled, isFalse);
    });

    test('Windows app handles all purchase service calls safely', () async {
      // Create PurchaseService with Windows not supported
      final purchaseService = PurchaseService.test(
        inAppPurchase: _MockInAppPurchase(),
        platformSupported: false,
      );
      await purchaseService.initialize();

      // Call all purchase service methods - should all complete without error
      expect(purchaseService.purchaseNoAds(), completion(isFalse));
      expect(purchaseService.restorePurchases(), completes);
      expect(() => purchaseService.dispose(), returnsNormally);

      // Verify all operations completed safely
      expect(purchaseService.isAvailable, isFalse);
      expect(purchaseService.noAdsProduct, isNull);
      expect(purchaseService.isPurchasePending, isFalse);

      purchaseService.dispose();
    });

    test('Windows app maintains premium status changes', () async {
      // Start with free tier
      await PremiumService.setPremium(false);
      expect(await PremiumService.isPremium(), isFalse);

      // Create Windows store access policy
      final policy = WindowsStoreAccessPolicy(
        isWindowsPlatform: true,
        premiumStatusLoader: () async => false,
      );

      // Verify premium categories are locked
      expect(await policy.canAccessCategory('Volume'), isFalse);

      // Upgrade to premium
      await PremiumService.setPremium(true);
      expect(await PremiumService.isPremium(), isTrue);

      // Create new policy with premium status
      final premiumPolicy = WindowsStoreAccessPolicy(
        isWindowsPlatform: true,
        premiumStatusLoader: () async => true,
      );

      // Verify premium categories are unlocked
      expect(await premiumPolicy.canAccessCategory('Volume'), isTrue);

      // Downgrade to free
      await PremiumService.setPremium(false);
      expect(await PremiumService.isPremium(), isFalse);

      // Verify premium categories are locked again
      expect(await policy.canAccessCategory('Volume'), isFalse);
    });

    test('Windows app does not crash with concurrent service calls', () async {
      // Create PurchaseService
      final purchaseService = PurchaseService.test(
        inAppPurchase: _MockInAppPurchase(),
        platformSupported: false,
      );
      await purchaseService.initialize();

      // Call multiple services concurrently
      final futures = <Future>[];
      futures.add(AdMobService.loadInterstitialAd());
      futures.add(AdMobService.loadAppOpenAd());
      futures.add(purchaseService.restorePurchases());
      futures.add(PremiumService.setPremium(true));
      futures.add(PremiumService.setPremium(false));

      // All should complete without error
      await expectLater(
        Future.wait(futures),
        completes,
        reason: 'All concurrent service calls should complete without error',
      );

      purchaseService.dispose();
    });
  });

  group('Windows Build End-to-End Regression Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      AdService.resetForTesting();
      await PremiumService.setPremium(false);
      AdService.setPlatformOverrideForTesting(false);
      await AdMobService.initialize();
    });

    test('Windows app never attempts to show ads', () async {
      // Track many conversions
      for (int i = 0; i < 100; i++) {
        AdMobService.trackConversion();
      }

      // Verify no ads were shown
      expect(AdMobService.conversionCount, equals(0));
      expect(AdMobService.conversionsSinceLastAd, equals(0));
      expect(AdMobService.sessionInterstitials, equals(0));
      expect(AdMobService.adsEnabled, isFalse);
    });

    test('Windows app never attempts to load ads', () async {
      // Try to load ads multiple times
      for (int i = 0; i < 10; i++) {
        await AdMobService.loadInterstitialAd();
        await AdMobService.loadAppOpenAd();
      }

      // Verify ads are still disabled
      expect(AdMobService.adsEnabled, isFalse);
    });

    test('Windows app never initializes MobileAds SDK', () async {
      // Verify ads are disabled (which means MobileAds was not initialized)
      expect(AdMobService.adsEnabled, isFalse);

      // Verify AdService is initialized
      expect(AdService.isInitialized, isTrue);
    });

    test('Windows app purchase attempts always fail gracefully', () async {
      // Create PurchaseService
      final purchaseService = PurchaseService.test(
        inAppPurchase: _MockInAppPurchase(),
        platformSupported: false,
      );
      await purchaseService.initialize();

      // Try to purchase multiple times
      for (int i = 0; i < 10; i++) {
        final result = await purchaseService.purchaseNoAds();
        expect(result, isFalse);
      }

      // Verify error message is set
      expect(purchaseService.errorMessage, isNotNull);

      purchaseService.dispose();
    });
  });

  group('Windows Build Future IAP Implementation Tests', () {
    // These tests document the expected behavior once Windows IAP is implemented

    test('Windows app should use Windows Store for IAP', () async {
      // TODO: Implement Windows Store IAP
      // Expected behavior:
      // - PurchaseService should support Windows platform
      // - Should use Windows Store SDK instead of in_app_purchase
      // - Should check for windows_premium_unlock entitlement
      // - Should trigger Windows Store purchase UI

      // Skip until Windows IAP is implemented
      expect(true, isTrue);
    }, skip: true);

    test('Windows app should unlock premium after successful purchase', () async {
      // TODO: Implement Windows Store IAP
      // Expected behavior:
      // - After successful purchase, premium should be unlocked
      // - Premium status should persist across app restarts
      // - All premium features should be accessible

      // Skip until Windows IAP is implemented
      expect(true, isTrue);
    }, skip: true);

    test('Windows app should support restore purchases from Store', () async {
      // TODO: Implement Windows Store IAP
      // Expected behavior:
      // - restorePurchases() should query Windows Store
      // - Should refresh premium status based on Store entitlements
      // - Should handle offline scenarios with cached entitlement

      // Skip until Windows IAP is implemented
      expect(true, isTrue);
    }, skip: true);

    test('Windows app should show Windows-specific purchase UI', () async {
      // TODO: Implement Windows Store IAP
      // Expected behavior:
      // - Purchase button should say "Premium unlock"
      // - Purchase dialog should reference Windows Store
      // - Error messages should be Windows-appropriate

      // Skip until Windows IAP is implemented
      expect(true, isTrue);
    }, skip: true);
  });
}

/// Mock InAppPurchase for testing
class _MockInAppPurchase implements InAppPurchase {
  @override
  Future<bool> isAvailable() async => false;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => const Stream.empty();

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {}

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async => false;

  @override
  Future<bool> buyConsumable({required PurchaseParam purchaseParam, bool autoConsume = true}) async => false;

  @override
  Future<void> completePurchase(PurchaseDetails purchaseDetails) async {}

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> productIdentifiers) async {
    return ProductDetailsResponse(
      productDetails: [],
      notFoundIDs: productIdentifiers.toList(),
    );
  }

  @override
  Future<String> countryCode() async => 'US';

  @override
  T getPlatformAddition<T extends InAppPurchasePlatformAddition?>() {
    throw UnimplementedError('getPlatformAddition not implemented in mock');
  }
}
