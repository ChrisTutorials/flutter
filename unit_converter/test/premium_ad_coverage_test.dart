import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/services/admob_service.dart';
import 'package:unit_converter/services/premium_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Premium entitlement persistence', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('stores ad-free entitlement locally', () async {
      expect(await PremiumService.isPremium(), isFalse);

      await PremiumService.setPremium(true);

      expect(await PremiumService.isPremium(), isTrue);
    });

    test('restores ad-free entitlement from persisted storage on next app start', () async {
      await PremiumService.setPremium(true);

      expect(await PremiumService.isPremium(), isTrue);

      expect(await PremiumService.isPremium(), isTrue);
    });

    test('clearing local storage removes premium state without account restore', () async {
      await PremiumService.setPremium(true);
      expect(await PremiumService.isPremium(), isTrue);

      SharedPreferences.setMockInitialValues({});

      expect(await PremiumService.isPremium(), isFalse);
    });
  });

  group('Ad-free ad gating', () {
    setUp(() {
      AdMobService.resetSessionCounters();
    });

    test('ads are blocked whenever premium mode is enabled', () async {
      await AdMobService.setPremiumStatus(true);

      expect(AdMobService.adsEnabled, isFalse);
      expect(AdMobService.shouldShowInterstitial(), isFalse);

      for (int i = 0; i < 50; i++) {
        AdMobService.trackConversion();
      }

      expect(AdMobService.shouldShowInterstitial(), isFalse);
      expect(AdMobService.conversionCount, 0);
      expect(AdMobService.conversionsSinceLastAd, 0);

      await expectLater(AdMobService.showInterstitialAd(), completes);
      await expectLater(AdMobService.showAppOpenAdIfAvailable(), completes);
    });

    test('premium mode continues blocking ads after many conversions', () async {
      await AdMobService.setPremiumStatus(true);

      for (int i = 0; i < 200; i++) {
        AdMobService.trackConversion();
      }

      expect(AdMobService.adsEnabled, isFalse);
      expect(AdMobService.shouldShowInterstitial(), isFalse);
      expect(AdMobService.sessionInterstitials, 0);
    });
  });
}
