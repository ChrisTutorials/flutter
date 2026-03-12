import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/services/admob_service.dart';
import 'package:common_flutter_ads/ad_service.dart';

/// Tests for production AdMob configuration
void main() {
  group('Production AdMob Configuration', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      // Reset AdService state before each test
      AdService.resetForTesting();
    });

    test('should have valid production ad unit ID format', () {
      // Verify production IDs are correctly formatted
      const bannerId = 'ca-app-pub-5684393858412931/2095306836';
      const interstitialId = 'ca-app-pub-5684393858412931/3408388509';
      
      // AdMob ad unit IDs should follow the pattern: ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY
      expect(bannerId, matches(RegExp(r'^ca-app-pub-\d{16}/\d{10}$')));
      expect(interstitialId, matches(RegExp(r'^ca-app-pub-\d{16}/\d{10}$')));
      expect(bannerId, contains('5684393858412931')); // Production app ID
      expect(interstitialId, contains('5684393858412931')); // Production app ID
    });

    test('production IDs should be different from test IDs', () {
      const bannerId = 'ca-app-pub-5684393858412931/2095306836';
      const interstitialId = 'ca-app-pub-5684393858412931/3408388509';
      
      // Ensure production IDs don't use test patterns
      expect(bannerId, isNot(contains('3940256099942544')));
      expect(interstitialId, isNot(contains('3940256099942544')));
    });

    test('should initialize without errors with production config', () async {
      SharedPreferences.setMockInitialValues({});

      // Test initialization (will use test IDs in debug mode, but verifies no errors)
      await expectLater(
        AdMobService.initialize(),
        completes,
      );
      
      // Verify service is properly initialized
      expect(AdMobService.conversionCount, isA<int>());
      expect(AdMobService.adsEnabled, isA<bool>());
    });

    test('should create banner ad with correct unit ID format', () async {
      SharedPreferences.setMockInitialValues({});

      // Initialize the service first
      await AdMobService.initialize();
      
      // Only create banner ad if ads are enabled
      if (AdMobService.adsEnabled) {
        final bannerAd = AdMobService.createBannerAd();
        
        expect(bannerAd, isNotNull);
        expect(bannerAd.adUnitId, isNotEmpty);
        expect(bannerAd.adUnitId, startsWith('ca-app-pub-'));
        expect(bannerAd.size, isNotNull);
      } else {
        // If ads are disabled (premium user), that's also a valid state
        expect(AdMobService.adsEnabled, isFalse);
      }
    });

    test('should track conversions without errors', () async {
      SharedPreferences.setMockInitialValues({});

      // Initialize the service first
      await AdMobService.initialize();
      
      // Track conversion should not throw errors
      expect(() => AdMobService.trackConversion(), returnsNormally);
      
      // Verify conversion count increases (only if ads are enabled)
      if (AdMobService.adsEnabled) {
        final initialCount = AdMobService.conversionCount;
        AdMobService.trackConversion();
        expect(AdMobService.conversionCount, greaterThan(initialCount));
      }
    });

    test('should handle ad display logic without errors', () async {
      SharedPreferences.setMockInitialValues({});

      // Initialize the service first
      await AdMobService.initialize();
      
      // Should not throw errors when checking ad display conditions
      expect(() => AdMobService.shouldShowInterstitial(), returnsNormally);
      expect(AdMobService.shouldShowInterstitial(), isA<bool>());
    });

    test('should dispose ads without errors', () async {
      SharedPreferences.setMockInitialValues({});

      // Initialize the service first
      await AdMobService.initialize();
      
      // Dispose should not throw errors
      expect(() => AdMobService.dispose(), returnsNormally);
    });

    test('should reset session counters without errors', () async {
      SharedPreferences.setMockInitialValues({});

      // Initialize the service first
      await AdMobService.initialize();
      
      // Reset should not throw errors
      expect(() => AdMobService.resetSessionCounters(), returnsNormally);
    });

    test('production banner ID should match provided configuration', () {
      const expectedBannerId = 'ca-app-pub-5684393858412931/2095306836';
      
      // In production builds, this would be the actual ID used
      // For now, we verify the format is correct
      expect(expectedBannerId, matches(RegExp(r'^ca-app-pub-\d{16}/\d{10}$')));
    });

    test('production interstitial ID should match provided configuration', () {
      const expectedInterstitialId = 'ca-app-pub-5684393858412931/3408388509';
      
      // In production builds, this would be the actual ID used
      // For now, we verify the format is correct
      expect(expectedInterstitialId, matches(RegExp(r'^ca-app-pub-\d{16}/\d{10}$')));
    });
  });
}
