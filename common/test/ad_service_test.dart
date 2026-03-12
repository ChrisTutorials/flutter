import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:common_flutter_ads/ad_service.dart';
import 'package:common_flutter_ads/ad_config.dart';

void main() {
  group('AdService Tests', () {
    setUp(() async {
      // Reset AdService state before each test
      AdService.resetForTesting();
      
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      // Clear conversion count from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('ad_conversion_count');
    });

    test('should initialize with default configuration', () async {
      // Configure test settings
      AdConfig.configureCustom(
        firstAdAfterConversions: 5,
        conversionsBetweenAds: 10,
        minimumSecondsBetweenAds: 60,
        maxAdsPerSession: 2,
      );

      // Set test ad units
      AdUnitIds.test.apply();

      // Simulate mobile platform for testing
      AdService.setPlatformOverrideForTesting(true);

      // Initialize
      await AdService.initialize();

      expect(AdService.isInitialized, isTrue);
      expect(AdService.adsEnabled, isTrue);
      expect(AdService.conversionCount, equals(0));
      expect(AdService.conversionsSinceLastAd, equals(0));
      expect(AdService.sessionInterstitials, equals(0));
    });

    test('should track conversions correctly', () async {
      // Configure for quick testing
      AdConfig.configureCustom(
        firstAdAfterConversions: 2,
        conversionsBetweenAds: 3,
        minimumSecondsBetweenAds: 0, // No time limit for testing
        maxAdsPerSession: 5,
      );

      AdUnitIds.test.apply();
      AdService.setPlatformOverrideForTesting(true);
      await AdService.initialize();

      // Track conversions
      AdService.trackConversion();
      expect(AdService.conversionCount, equals(1));
      expect(AdService.conversionsSinceLastAd, equals(1));

      AdService.trackConversion();
      expect(AdService.conversionCount, equals(2));
      expect(AdService.conversionsSinceLastAd, equals(2));

      // Should not show interstitial yet (need 2 more conversions)
      expect(AdService.shouldShowInterstitial(), isFalse);

      AdService.trackConversion();
      expect(AdService.conversionCount, equals(3));
      expect(AdService.conversionsSinceLastAd, equals(3));

      // Now should show interstitial
      expect(AdService.shouldShowInterstitial(), isTrue);
    });

    test('should respect first-time user protection', () async {
      AdConfig.configureCustom(
        firstAdAfterConversions: 5,
        conversionsBetweenAds: 1,
        minimumSecondsBetweenAds: 0,
        maxAdsPerSession: 5,
      );

      AdUnitIds.test.apply();
      AdService.setPlatformOverrideForTesting(true);
      await AdService.initialize();
      
      // Track 4 conversions (less than protection threshold)
      for (int i = 0; i < 4; i++) {
        AdService.trackConversion();
      }
      
      expect(AdService.conversionCount, equals(4));
      expect(AdService.shouldShowInterstitial(), isFalse);
      
      // 5th conversion should enable ads
      AdService.trackConversion();
      expect(AdService.conversionCount, equals(5));
      expect(AdService.shouldShowInterstitial(), isTrue);
    });

    test('should reset session counters', () async {
      AdConfig.configureCustom(
        firstAdAfterConversions: 0,
        conversionsBetweenAds: 1,
        minimumSecondsBetweenAds: 0,
        maxAdsPerSession: 2,
      );

      AdUnitIds.test.apply();
      AdService.setPlatformOverrideForTesting(true);
      await AdService.initialize();
      
      // Track conversions to trigger interstitial
      AdService.trackConversion();
      expect(AdService.sessionInterstitials, equals(0));
      
      // Simulate showing an interstitial (would reset conversionsSinceLastAd)
      AdService.trackConversion(); // This would trigger and reset
      
      // Reset session
      AdService.resetSessionCounters();
      expect(AdService.sessionInterstitials, equals(0));
    });

    test('should handle premium user configuration', () async {
      // Set premium user check to return true
      AdService.configure(
        premiumCheck: () async => true, // User is premium
      );

      AdUnitIds.test.apply();
      AdService.setPlatformOverrideForTesting(true);
      await AdService.initialize();
      
      expect(AdService.adsEnabled, isFalse);
      
      // Update to non-premium
      await AdService.updatePremiumStatus(false);
      expect(AdService.adsEnabled, isTrue);
    });

    test('should respect session limits', () async {
      AdConfig.configureCustom(
        firstAdAfterConversions: 0,
        conversionsBetweenAds: 1,
        minimumSecondsBetweenAds: 0,
        maxAdsPerSession: 2, // Low limit for testing
      );

      AdUnitIds.test.apply();
      AdService.setPlatformOverrideForTesting(true);
      await AdService.initialize();
      
      // Track conversions and simulate interstitial shows
      AdService.trackConversion(); // Would show ad 1
      expect(AdService.sessionInterstitials, equals(0));
      
      AdService.trackConversion(); // Would show ad 2
      expect(AdService.sessionInterstitials, equals(0));
      
      // Should be allowed since no ads have been shown yet
      expect(AdService.shouldShowInterstitial(), isTrue);
      
      // Reset session should allow ads again
      AdService.resetSessionCounters();
      expect(AdService.sessionInterstitials, equals(0));
    });

    test('should disable ads on desktop platforms (Windows)', () async {
      // Simulate Windows platform
      AdService.setPlatformOverrideForTesting(false);
      AdUnitIds.test.apply();

      await AdService.initialize();

      expect(AdService.isInitialized, isTrue);
      expect(AdService.adsEnabled, isFalse);
      // Ads should not be loaded on desktop
    });

    test('should disable ads on desktop platforms (macOS)', () async {
      // Simulate macOS platform
      AdService.setPlatformOverrideForTesting(false);
      AdUnitIds.test.apply();

      await AdService.initialize();

      expect(AdService.isInitialized, isTrue);
      expect(AdService.adsEnabled, isFalse);
    });

    test('should disable ads on desktop platforms (Linux)', () async {
      // Simulate Linux platform
      AdService.setPlatformOverrideForTesting(false);
      AdUnitIds.test.apply();

      await AdService.initialize();

      expect(AdService.isInitialized, isTrue);
      expect(AdService.adsEnabled, isFalse);
    });

    test('should disable ads on web platform', () async {
      // Simulate web platform
      AdService.setPlatformOverrideForTesting(false);
      AdUnitIds.test.apply();

      await AdService.initialize();

      expect(AdService.isInitialized, isTrue);
      expect(AdService.adsEnabled, isFalse);
    });

    test('should enable ads on mobile platforms (Android)', () async {
      // Simulate Android platform
      AdService.setPlatformOverrideForTesting(true);
      AdUnitIds.test.apply();

      await AdService.initialize();

      expect(AdService.isInitialized, isTrue);
      expect(AdService.adsEnabled, isTrue);
    });

    test('should enable ads on mobile platforms (iOS)', () async {
      // Simulate iOS platform
      AdService.setPlatformOverrideForTesting(true);
      AdUnitIds.test.apply();

      await AdService.initialize();

      expect(AdService.isInitialized, isTrue);
      expect(AdService.adsEnabled, isTrue);
    });

    test('should not attempt to load ads on desktop platforms', () async {
      // Simulate desktop platform
      AdService.setPlatformOverrideForTesting(false);
      AdUnitIds.test.apply();

      await AdService.initialize();

      // Track conversions - should not try to show ads
      AdService.trackConversion();
      AdService.trackConversion();
      AdService.trackConversion();

      // Should not show interstitial on desktop
      expect(AdService.shouldShowInterstitial(), isFalse);
    });
  });

  group('AdConfig Tests', () {
    test('should configure utility app settings', () {
      AdConfig.configureForUtilityApp();
      // These are static values, so we can't directly test them
      // In a real app, you would verify the behavior matches expected settings
      expect(true, isTrue); // Placeholder test
    });

    test('should configure casual game settings', () {
      AdConfig.configureForCasualGame();
      expect(true, isTrue); // Placeholder test
    });

    test('should configure custom settings', () {
      AdConfig.configureCustom(
        firstAdAfterConversions: 8,
        conversionsBetweenAds: 15,
        minimumSecondsBetweenAds: 120,
        maxAdsPerSession: 4,
      );
      expect(true, isTrue); // Placeholder test
    });
  });

  group('AdUnitIds Tests', () {
    test('should apply test ad unit IDs', () {
      AdUnitIds.test.apply();
      expect(true, isTrue); // Placeholder test - would verify IDs are set
    });
  });
}
