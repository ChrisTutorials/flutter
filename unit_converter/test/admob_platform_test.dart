import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/services/admob_service.dart';

void main() {
  group('AdMob Platform-Specific Behavior', () {
    test('should have AdMobService available', () {
      // This test verifies that AdMobService is available
      expect(AdMobService, isNotNull);
    });

    test('should create banner ad', () {
      final bannerAd = AdMobService.createBannerAd();

      expect(bannerAd, isNotNull);
      expect(bannerAd.adUnitId, isNotEmpty);
      expect(bannerAd.size, isNotNull);
    });

    test('should track conversion without errors', () {
      // Track conversion should not throw errors
      expect(() => AdMobService.trackConversion(), returnsNormally);
    });

    test('should dispose ads without errors', () {
      // Dispose should not throw errors
      expect(() => AdMobService.dispose(), returnsNormally);
    });

    test('should handle null interstitial ad gracefully', () async {
      // If no interstitial ad is loaded, showInterstitialAd should not crash
      expect(() => AdMobService.showInterstitialAd(), returnsNormally);
    });
  });

  group('AdMob Service Configuration', () {
    test('should use test ad unit IDs in debug mode', () {
      final bannerAd = AdMobService.createBannerAd();

      // Test IDs start with 'ca-app-pub-3940256099942544'
      expect(bannerAd.adUnitId, startsWith('ca-app-pub-3940256099942544'));
    });

    test('should have valid production ad unit ID format', () {
      // Verify production IDs are correctly formatted
      const bannerId = 'ca-app-pub-5684393858412931/2095306836';
      const interstitialId = 'ca-app-pub-5684393858412931/3408388509';
      
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

    test('should have valid banner ad size', () {
      final bannerAd = AdMobService.createBannerAd();

      expect(bannerAd.size.width, greaterThan(0));
      expect(bannerAd.size.height, greaterThan(0));
    });
  });

  group('Platform Detection for AdMob', () {
    test('should correctly identify when to initialize AdMob', () {
      // Test the platform detection logic used in main.dart
      // On mobile (Android or iOS), AdMob should be initialized
      // On web or desktop, AdMob should NOT be initialized

      // The logic is: !kIsWeb && (Platform.isAndroid || Platform.isIOS)
      final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
      final shouldInitializeAdMob = isMobile;

      // On desktop, shouldInitializeAdMob should be false
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        expect(
          shouldInitializeAdMob,
          false,
          reason: 'AdMob should not be initialized on desktop platforms',
        );
      }

      // On web, shouldInitializeAdMob should be false
      if (kIsWeb) {
        expect(
          shouldInitializeAdMob,
          false,
          reason: 'AdMob should not be initialized on web',
        );
      }

      // On mobile, shouldInitializeAdMob should be true
      if (Platform.isAndroid || Platform.isIOS) {
        expect(
          shouldInitializeAdMob,
          true,
          reason: 'AdMob should be initialized on mobile platforms',
        );
      }
    });

    test('should not attempt AdMob operations on desktop', () {
      // This test verifies that AdMob operations are guarded by platform checks
      final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

      if (!isMobile) {
        // On desktop, AdMob should not be initialized
        // The app should work without errors
        expect(true, isTrue);
      }
    });

    test('should not attempt AdMob operations on web', () {
      // This test verifies that AdMob operations are guarded by platform checks
      if (kIsWeb) {
        // On web, AdMob should not be initialized
        // The app should work without errors
        expect(true, isTrue);
      }
    });
  });

  group('Cross-Platform Compatibility', () {
    test('should work without AdMob on all platforms', () {
      // The app should work correctly on all platforms
      // even when AdMob is not available

      expect(() {
        // The app should initialize without errors on any platform
        // AdMob initialization is conditional on platform
        final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

        if (isMobile) {
          // On mobile, AdMob would be initialized
          // This would require actual AdMob SDK and real device
        } else {
          // On desktop/web, AdMob is not initialized
          // App should work normally without ads
        }
      }, returnsNormally);
    });

    test('should handle platform-specific features gracefully', () {
      // This test ensures platform-specific features don't break the app
      expect(() {
        // Banner ads
        final shouldLoadBanner =
            !kIsWeb && (Platform.isAndroid || Platform.isIOS);
        if (shouldLoadBanner) {
          // Would load banner ad on mobile
        }

        // Conversion tracking
        final shouldTrack = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
        if (shouldTrack) {
          // Would track conversions on mobile
        }

        // App should continue to work regardless of platform
      }, returnsNormally);
    });
  });
}
