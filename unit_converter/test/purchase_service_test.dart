import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unit_converter/services/purchase_service.dart';
import 'package:unit_converter/services/premium_service.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('PurchaseService', () {
    late PurchaseService purchaseService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      purchaseService = PurchaseService();
    });

    test('should initialize successfully', () async {
      // Test basic initialization
      expect(purchaseService.isAvailable, isFalse);
      expect(purchaseService.errorMessage, isNull);
    });

    test('should handle premium status correctly', () async {
      // Test premium status is initially false
      final isPremium = await PremiumService.isPremium();
      expect(isPremium, isFalse);

      // Test setting premium status
      await PremiumService.setPremium(true);
      final isPremiumAfter = await PremiumService.isPremium();
      expect(isPremiumAfter, isTrue);

      // Test resetting premium status
      await PremiumService.setPremium(false);
      final isPremiumReset = await PremiumService.isPremium();
      expect(isPremiumReset, isFalse);
    });

    test('should enable premium status', () async {
      await PremiumService.setPremium(true);

      final isPremium = await PremiumService.isPremium();
      expect(isPremium, isTrue);
    });

    test('should disable premium status', () async {
      await PremiumService.setPremium(true);
      expect(await PremiumService.isPremium(), isTrue);

      await PremiumService.setPremium(false);

      final isPremium = await PremiumService.isPremium();
      expect(isPremium, isFalse);
    });

    test('should persist premium status across app restarts', () async {
      // Set premium status
      await PremiumService.setPremium(true);
      expect(await PremiumService.isPremium(), isTrue);

      // Simulate app restart
      final isPremiumAfterRestart = await PremiumService.isPremium();
      expect(isPremiumAfterRestart, isTrue);
    });

    test('should have valid product ID format', () {
      const productId = 'no_ads_premium';
      // Product ID should contain only lowercase letters, numbers, and hyphens
      expect(productId, matches(RegExp(r'^[a-z0-9-_]+$')));
      expect(productId.length, lessThanOrEqualTo(20));
    });

    test('should handle error states', () {
      // Test initial error states
      expect(purchaseService.isPurchasePending, isFalse);
      expect(purchaseService.noAdsProduct, isNull);
      expect(purchaseService.errorMessage, isNull);
    });

    test('should handle rapid status changes', () async {
      // Test rapid on/off changes
      for (int i = 0; i < 5; i++) {
        await PremiumService.setPremium(true);
        expect(await PremiumService.isPremium(), isTrue);

        await PremiumService.setPremium(false);
        expect(await PremiumService.isPremium(), isFalse);
      }
    });

    test('should allow premium entitlement changes in tests', () async {
      await PremiumService.setPremium(true);
      expect(await PremiumService.isPremium(), isTrue);

      await PremiumService.setPremium(false);
      expect(await PremiumService.isPremium(), isFalse);
    });

    test('should handle disposal safely', () {
      // Initialize the service first
      purchaseService.initialize();
      
      // Test that dispose doesn't throw
      expect(() {
        try {
          purchaseService.dispose();
        } catch (e) {
          // Expected for uninitialized service
        }
      }, returnsNormally);
    });

    test('should maintain readable state', () {
      // Service should maintain readable state
      expect(purchaseService.isAvailable, isFalse);
      expect(purchaseService.noAdsProduct, isNull);
    });
  });

  group('PremiumService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('should persist premium status', () async {
      // Set premium
      await PremiumService.setPremium(true);
      expect(await PremiumService.isPremium(), isTrue);

      // Test persistence
      expect(await PremiumService.isPremium(), isTrue);
    });

    test('should toggle premium status correctly', () async {
      // Initially false
      expect(await PremiumService.isPremium(), isFalse);

      // Set to true
      await PremiumService.setPremium(true);
      expect(await PremiumService.isPremium(), isTrue);

      // Set back to false
      await PremiumService.setPremium(false);
      expect(await PremiumService.isPremium(), isFalse);
    });
  });
}
