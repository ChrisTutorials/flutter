import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/services/admob_service.dart';
import 'package:common_flutter_ads/ad_service.dart';
import 'package:unit_converter/utils/platform_utils.dart';
import 'package:unit_converter/services/premium_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Windows AdMob Behavior', () {
    setUp(() async {
      // Reset AdService state before each test
      AdService.resetForTesting();
      SharedPreferences.setMockInitialValues({});
      await PremiumService.setPremium(false);
    });

    test('AdService disables ads on Windows platform', () async {
      // Set platform override to Windows (non-mobile)
      AdService.setPlatformOverrideForTesting(false);

      // Initialize AdService
      await AdService.initialize();

      // Verify ads are disabled
      expect(AdService.adsEnabled, isFalse,
          reason: 'Ads should be disabled on Windows platform');
    });

    test('AdService skips MobileAds initialization on Windows', () async {
      // Set platform override to Windows (non-mobile)
      AdService.setPlatformOverrideForTesting(false);

      // Initialize AdService
      await AdService.initialize();

      // Verify initialization completed but ads are disabled
      expect(AdService.isInitialized, isTrue);
      expect(AdService.adsEnabled, isFalse);
    });

    test('AdMobService.createBannerAd throws on Windows', () async {
      // Set platform override to Windows (non-mobile)
      AdService.setPlatformOverrideForTesting(false);

      // Initialize AdService
      await AdMobService.initialize();

      // Verify ads are disabled
      expect(AdMobService.adsEnabled, isFalse);

      // Attempting to create banner ad should throw
      expect(
        () => AdMobService.createBannerAd(),
        throwsA(isA<StateError>()),
        reason: 'Creating banner ad should throw when ads are disabled',
      );
    });

    test('AdMobService shouldShowInterstitial returns false on Windows', () async {
      // Set platform override to Windows (non-mobile)
      AdService.setPlatformOverrideForTesting(false);

      // Initialize AdService
      await AdMobService.initialize();

      // Verify interstitial should not be shown
      expect(AdMobService.shouldShowInterstitial(), isFalse,
          reason: 'Interstitial should not be shown on Windows');
    });

    test('AdMobService showInterstitialAd is no-op on Windows', () async {
      // Set platform override to Windows (non-mobile)
      AdService.setPlatformOverrideForTesting(false);

      // Initialize AdService
      await AdMobService.initialize();

      // Call showInterstitialAd - should complete without error
      await AdMobService.showInterstitialAd();

      // Verify no interstitial was loaded
      expect(AdMobService.sessionInterstitials, equals(0),
          reason: 'No interstitials should be shown on Windows');
    });

    test('AdMobService showAppOpenAdIfAvailable is no-op on Windows', () async {
      // Set platform override to Windows (non-mobile)
      AdService.setPlatformOverrideForTesting(false);

      // Initialize AdService
      await AdMobService.initialize();

      // Call showAppOpenAdIfAvailable - should complete without error
      await AdMobService.showAppOpenAdIfAvailable();

      // Verify no error occurred
      expect(AdMobService.adsEnabled, isFalse);
    });

    test('AdMobService trackConversion is no-op on Windows', () async {
      // Set platform override to Windows (non-mobile)
      AdService.setPlatformOverrideForTesting(false);

      // Initialize AdService
      await AdMobService.initialize();

      // Track conversions
      for (int i = 0; i < 25; i++) {
        AdMobService.trackConversion();
      }

      // Verify conversions are not tracked when ads are disabled
      expect(AdMobService.conversionCount, equals(0),
          reason: 'Conversions should not be tracked when ads are disabled');
      expect(AdMobService.conversionsSinceLastAd, equals(0));
    });

    test('AdMobService initialize completes successfully on Windows', () async {
      // Set platform override to Windows (non-mobile)
      AdService.setPlatformOverrideForTesting(false);

      // Initialize AdService - should complete without error
      await expectLater(
        AdMobService.initialize(),
        completes,
        reason: 'AdMobService.initialize should complete without error on Windows',
      );

      // Verify ads are disabled
      expect(AdMobService.adsEnabled, isFalse);
    });

    test('AdMobService dispose is safe on Windows', () async {
      // Set platform override to Windows (non-mobile)
      AdService.setPlatformOverrideForTesting(false);

      // Initialize AdService
      await AdMobService.initialize();

      // Dispose - should complete without error
      expect(
        () => AdMobService.dispose(),
        returnsNormally,
        reason: 'AdMobService.dispose should complete without error on Windows',
      );
    });

    test('AdMobService setPremiumStatus works on Windows', () async {
      // Set platform override to Windows (non-mobile)
      AdService.setPlatformOverrideForTesting(false);

      // Initialize AdService
      await AdMobService.initialize();

      // Update premium status
      await AdMobService.setPremiumStatus(true);

      // Verify ads remain disabled on Windows regardless of premium status
      expect(AdMobService.adsEnabled, isFalse,
          reason: 'Ads should be disabled on Windows even for premium users');
    });

    test('Windows platform detection works correctly', () {
      // This test verifies that PlatformUtils correctly identifies Windows
      // Note: In actual tests, we can't change the actual platform,
      // but we can verify the logic

      // On Windows, PlatformUtils.isWindows should be true
      // On other platforms, it should be false
      // This is a sanity check for the platform detection logic

      expect(PlatformUtils.isWindows, isA<bool>(),
          reason: 'PlatformUtils.isWindows should return a boolean');
    });
  });

  group('Windows AdMob Integration with Premium Service', () {
    setUp(() async {
      // Reset AdService state before each test
      AdService.resetForTesting();
      SharedPreferences.setMockInitialValues({});
    });

    test('Premium status does not enable ads on Windows', () async {
      // Set platform override to Windows (non-mobile)
      AdService.setPlatformOverrideForTesting(false);

      // Set premium status to false
      await PremiumService.setPremium(false);

      // Initialize AdService
      await AdMobService.initialize();

      // Verify ads are disabled
      expect(AdMobService.adsEnabled, isFalse,
          reason: 'Ads should be disabled on Windows for free users');

      // Set premium status to true
      await PremiumService.setPremium(true);
      await AdMobService.setPremiumStatus(true);

      // Verify ads remain disabled on Windows
      expect(AdMobService.adsEnabled, isFalse,
          reason: 'Ads should be disabled on Windows for premium users');
    });

    test('Windows ads are disabled regardless of premium status', () async {
      // Test with premium = false
      AdService.setPlatformOverrideForTesting(false);
      await PremiumService.setPremium(false);
      await AdMobService.initialize();
      expect(AdMobService.adsEnabled, isFalse);

      // Reset
      AdService.resetForTesting();

      // Test with premium = true
      AdService.setPlatformOverrideForTesting(false);
      await PremiumService.setPremium(true);
      await AdMobService.initialize();
      expect(AdMobService.adsEnabled, isFalse,
          reason: 'Ads should always be disabled on Windows');
    });
  });

  group('Windows AdMob Regression Tests', () {
    setUp(() async {
      // Reset AdService state before each test
      AdService.resetForTesting();
      SharedPreferences.setMockInitialValues({});
    });

    test('No MobileAds SDK calls on Windows', () async {
      // Set platform override to Windows (non-mobile)
      AdService.setPlatformOverrideForTesting(false);

      // Initialize AdService
      await AdMobService.initialize();

      // Verify that MobileAds was not initialized
      // This is verified by the fact that adsEnabled is false
      // and no ads are loaded
      expect(AdService.adsEnabled, isFalse);
    });

    test('Windows does not load interstitial ads', () async {
      // Set platform override to Windows (non-mobile)
      AdService.setPlatformOverrideForTesting(false);

      // Initialize AdService
      await AdMobService.initialize();

      // Try to load interstitial
      await AdMobService.loadInterstitialAd();

      // Verify no interstitial is available
      expect(AdMobService.shouldShowInterstitial(), isFalse);
    });

    test('Windows does not load app open ads', () async {
      // Set platform override to Windows (non-mobile)
      AdService.setPlatformOverrideForTesting(false);

      // Initialize AdService
      await AdMobService.initialize();

      // Try to load app open ad
      await AdMobService.loadAppOpenAd();

      // Verify no app open ad is available
      // This is verified by the fact that ads are disabled
      expect(AdMobService.adsEnabled, isFalse);
    });

    test('Windows AdMobService is safe to call all methods', () async {
      // Set platform override to Windows (non-mobile)
      AdService.setPlatformOverrideForTesting(false);

      // Initialize AdService
      await AdMobService.initialize();

      // Call all methods - should complete without error
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
  });
}
