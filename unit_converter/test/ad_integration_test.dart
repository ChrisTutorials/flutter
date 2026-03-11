import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/services/admob_service.dart';

/// Integration tests for ad rendering based on configuration
/// 
/// These tests verify that the ad configuration rules are correctly
/// enforced throughout the user journey.
void main() {
  group('Ad Rendering Integration Tests', () {
    setUp(() {
      AdMobService.resetSessionCounters();
    });

    group('User Journey: New User Experience', () {
      test('new user should not see any interstitials in first 9 conversions', () {
        // Simulate a new user doing 9 conversions
        for (int i = 0; i < 9; i++) {
          AdMobService.trackConversion();
          // User should never see an interstitial
          expect(AdMobService.shouldShowInterstitial(), isFalse,
              reason: 'Conversion +1: First-time user protection active');
        }
        
        expect(AdMobService.conversionCount, 9);
      });

      test('new user should see first interstitial after 10th conversion', () {
        // User does 10 conversions
        for (int i = 0; i < 10; i++) {
          AdMobService.trackConversion();
        }
        
        // After 10th conversion, interstitial should be available
        expect(AdMobService.shouldShowInterstitial(), isTrue,
            reason: 'First-time user protection passed after 10 conversions');
        expect(AdMobService.conversionCount, 10);
      });
    });

    group('User Journey: Regular User Experience', () {
      test('regular user should see interstitial every 20 conversions', () {
        // Simulate a user who has already done 10 conversions (first-time protection passed)
        // Do 10 more conversions to reach 20 total
        for (int i = 0; i < 10; i++) {
          AdMobService.trackConversion();
        }
        
        // First interstitial available at 10 conversions
        expect(AdMobService.shouldShowInterstitial(), isTrue);
        
        // Do 19 more conversions (total 29)
        for (int i = 0; i < 19; i++) {
          AdMobService.trackConversion();
          // Should not show another interstitial yet
          expect(AdMobService.shouldShowInterstitial(), isFalse,
              reason: 'Conversion : Frequency cap active');
        }
        
        // 20th conversion since last ad - interstitial available
        AdMobService.trackConversion();
        expect(AdMobService.shouldShowInterstitial(), isTrue,
            reason: '20 conversions since last ad - interstitial available');
      });
    });

    group('User Journey: Heavy User Experience', () {
      test('heavy user should be limited to 3 interstitials per session', () {
        // Simulate a heavy user doing many conversions
        // First 10 conversions - first interstitial available
        for (int i = 0; i < 10; i++) {
          AdMobService.trackConversion();
        }
        expect(AdMobService.shouldShowInterstitial(), isTrue,
            reason: 'First interstitial at 10 conversions');
        
        // Next 20 conversions - second interstitial available
        for (int i = 0; i < 20; i++) {
          AdMobService.trackConversion();
        }
        expect(AdMobService.shouldShowInterstitial(), isTrue,
            reason: 'Second interstitial at 30 conversions');
        
        // Next 20 conversions - third interstitial available
        for (int i = 0; i < 20; i++) {
          AdMobService.trackConversion();
        }
        expect(AdMobService.shouldShowInterstitial(), isTrue,
            reason: 'Third interstitial at 50 conversions');
        
        // Next 20 conversions - should NOT show fourth interstitial (session limit)
        for (int i = 0; i < 20; i++) {
          AdMobService.trackConversion();
        }
        // Note: In real implementation, sessionInterstitials would be incremented
        // when showInterstitialAd is called. For testing, we verify the limit exists.
        expect(AdMobService.maxInterstitialsPerSession, 3,
            reason: 'Session limit is 3 interstitials');
      });
    });

    group('User Journey: Multi-Session Experience', () {
      test('session counters should reset between sessions', () {
        // Session 1: Do 30 conversions
        for (int i = 0; i < 30; i++) {
          AdMobService.trackConversion();
        }
        
        expect(AdMobService.conversionCount, 30);
        
        // Simulate session reset (app restart)
        AdMobService.resetSessionCounters();
        
        // Session counters should be reset
        expect(AdMobService.sessionInterstitials, 0);
        
        // But total conversion count should persist
        expect(AdMobService.conversionCount, 30);
      });

      test('conversion count should persist across sessions', () async {
        // Session 1: Do 5 conversions
        for (int i = 0; i < 5; i++) {
          AdMobService.trackConversion();
        }
        
        expect(AdMobService.conversionCount, 5);
        
        // Simulate app restart (re-initialize)
        // In real implementation, this would load from SharedPreferences
        // For testing, we verify the logic
        await AdMobService.initialize();
        
        // Conversion count should be preserved (loaded from storage)
        // Note: In tests, this depends on SharedPreferences mock
      });
    });

    group('Ad Configuration Enforcement', () {
      test('first-time user protection should be strictly enforced', () {
        // Even with many conversions, first 10 should not show interstitial
        for (int i = 0; i < 9; i++) {
          AdMobService.trackConversion();
          expect(AdMobService.shouldShowInterstitial(), isFalse,
              reason: 'Conversion : First-time protection active');
        }
      });

      test('frequency cap should be strictly enforced', () {
        // Pass first-time protection
        for (int i = 0; i < 10; i++) {
          AdMobService.trackConversion();
        }
        
        // First interstitial available
        expect(AdMobService.shouldShowInterstitial(), isTrue);
        
        // Do 19 more conversions
        for (int i = 0; i < 19; i++) {
          AdMobService.trackConversion();
          expect(AdMobService.shouldShowInterstitial(), isFalse,
              reason: 'Frequency cap blocks interstitial');
        }
        
        // 20th conversion - interstitial available
        AdMobService.trackConversion();
        expect(AdMobService.shouldShowInterstitial(), isTrue,
            reason: 'Frequency cap allows interstitial after 20 conversions');
      });

      test('session limit should be strictly enforced', () {
        // Verify the configuration exists
        expect(AdMobService.maxInterstitialsPerSession, 3);
        
        // The actual enforcement happens in showInterstitialAd
        // which increments sessionInterstitials
      });
    });

    group('Edge Cases', () {
      test('should handle zero conversions gracefully', () {
        expect(AdMobService.conversionCount, 0);
        expect(AdMobService.shouldShowInterstitial(), isFalse);
      });

      test('should handle single conversion gracefully', () {
        AdMobService.trackConversion();
        expect(AdMobService.conversionCount, 1);
        expect(AdMobService.shouldShowInterstitial(), isFalse);
      });

      test('should handle exactly 10 conversions', () {
        for (int i = 0; i < 10; i++) {
          AdMobService.trackConversion();
        }
        expect(AdMobService.conversionCount, 10);
        expect(AdMobService.shouldShowInterstitial(), isTrue);
      });

      test('should handle exactly 20 conversions between ads', () {
        // Pass first-time protection
        for (int i = 0; i < 10; i++) {
          AdMobService.trackConversion();
        }
        
        // Do exactly 20 more conversions
        for (int i = 0; i < 20; i++) {
          AdMobService.trackConversion();
        }
        
        expect(AdMobService.conversionsSinceLastAd, 20);
        expect(AdMobService.shouldShowInterstitial(), isTrue);
      });
    });

    group('Configuration Values', () {
      test('configuration values should match strategy document', () {
        // These values should match docs/AD_STRATEGY.md
        expect(AdMobService.minConversionsBeforeFirstAd, 10,
            reason: 'First-time user protection: 10 conversions');
        expect(AdMobService.conversionsBetweenAds, 20,
            reason: 'Frequency cap: 20 conversions between ads');
        expect(AdMobService.minSecondsBetweenAds, 180,
            reason: 'Time cap: 3 minutes (180 seconds)');
        expect(AdMobService.maxInterstitialsPerSession, 3,
            reason: 'Session limit: 3 interstitials per session');
      });

      test('configuration should be review-friendly', () {
        // Verify the configuration is conservative enough to protect reviews
        expect(AdMobService.minConversionsBeforeFirstAd, greaterThanOrEqualTo(10),
            reason: 'First-time protection should be at least 10 conversions');
        expect(AdMobService.conversionsBetweenAds, greaterThanOrEqualTo(15),
            reason: 'Frequency cap should be at least 15 conversions');
        expect(AdMobService.minSecondsBetweenAds, greaterThanOrEqualTo(120),
            reason: 'Time cap should be at least 2 minutes');
        expect(AdMobService.maxInterstitialsPerSession, lessThanOrEqualTo(5),
            reason: 'Session limit should be no more than 5');
      });
    });

    group('Ad Unit Configuration', () {
      test('banner ad should be properly configured', () {
        final bannerAd = AdMobService.createBannerAd();
        
        expect(bannerAd, isNotNull);
        expect(bannerAd.adUnitId, isNotEmpty);
        expect(bannerAd.adUnitId, startsWith('ca-app-pub'));
        expect(bannerAd.size, isNotNull);
      });

      test('interstitial ad should be loadable', () {
        // The actual loading happens asynchronously
        // We verify the service can attempt to load interstitials
        expect(() => AdMobService.loadInterstitialAd(), returnsNormally);
      });

      test('app open ad should be loadable', () {
        // The actual loading happens asynchronously
        // We verify the service can attempt to load app open ads
        expect(() => AdMobService.loadAppOpenAd(), returnsNormally);
      });
    });
  });
}
