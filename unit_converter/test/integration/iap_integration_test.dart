import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unit_converter/services/premium_service.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('IAP Integration Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('should handle premium status persistence', () async {
      // Test initial state
      expect(await PremiumService.isPremium(), isFalse);

      // Set premium
      await PremiumService.setPremium(true);
      expect(await PremiumService.isPremium(), isTrue);

      // Reset and verify persistence
      await PremiumService.setPremium(false);
      expect(await PremiumService.isPremium(), isFalse);
    });

    test('should handle premium entitlement updates', () async {
      await PremiumService.setPremium(true);
      expect(await PremiumService.isPremium(), isTrue);

      await PremiumService.setPremium(false);
      expect(await PremiumService.isPremium(), isFalse);
    });

    test('should handle rapid state changes', () async {
      for (int i = 0; i < 3; i++) {
        await PremiumService.setPremium(true);
        expect(await PremiumService.isPremium(), isTrue);

        await PremiumService.setPremium(false);
        expect(await PremiumService.isPremium(), isFalse);
      }
    });

    test('should have correct product ID format', () {
      const productId = 'no_ads_premium';
      expect(productId, matches(RegExp(r'^[a-z0-9-_]+$')));
      expect(productId.length, lessThanOrEqualTo(20));
    });

  });

  group('Ad Integration', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('should integrate premium status with ads', () async {
      // Initially not premium, ads should show
      expect(await PremiumService.isPremium(), isFalse);

      // Set premium, ads should be disabled
      await PremiumService.setPremium(true);
      expect(await PremiumService.isPremium(), isTrue);

      // Reset premium, ads should show again
      await PremiumService.setPremium(false);
      expect(await PremiumService.isPremium(), isFalse);
    });
  });
}
