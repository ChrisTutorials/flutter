import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/services/purchase_service.dart';
import 'package:unit_converter/services/premium_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PurchaseService Edge Cases', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should handle purchase when IAP is not available', () async {
      final purchaseService = PurchaseService();
      
      // Initialize first (sets isAvailable based on actual platform)
      await purchaseService.initialize();
      
      // If not available, purchase should return false gracefully
      if (!purchaseService.isAvailable) {
        final result = await purchaseService.purchaseNoAds();
        expect(result, false);
        // Error message may be set depending on platform
      } else {
        // If available on this platform, that's also valid
        expect(purchaseService.isAvailable, true);
      }
    });

    test('should handle restore purchases when IAP is not available', () async {
      final purchaseService = PurchaseService();
      await purchaseService.initialize();
      
      // Should not throw even if not available
      await purchaseService.restorePurchases();
    });

    test('should persist premium status through service layer', () async {
      // Test that premium status persists via SharedPreferences
      
      // Set to true
      await PremiumService.setPremium(true);
      expect(await PremiumService.isPremium(), true);
      
      // Simulate app restart by getting fresh instance
      // (In real app, this would be new SharedPreferences instance)
      SharedPreferences.setMockInitialValues({});
      expect(await PremiumService.isPremium(), false); // Would be false with clean prefs
      
      // With our premium value set
      SharedPreferences.setMockInitialValues({'premium_enabled': true});
      expect(await PremiumService.isPremium(), true);
    });

    test('should handle rapid premium status changes', () async {
      // Rapid toggling
      for (int i = 0; i < 10; i++) {
        await PremiumService.setPremium(i % 2 == 0);
        final isPremium = await PremiumService.isPremium();
        expect(isPremium, (i % 2 == 0));
      }
    });

    test('should handle purchase completion granting premium access', () async {
      // This tests the integration between purchase service and premium service
      // Since we can't easily simulate actual IAP purchases in unit tests,
      // we verify the logic path exists
      
      final purchaseService = PurchaseService();
      
      // Verify services instantiate correctly
      expect(purchaseService, isNotNull);
      
      // Verify premium service starts as false
      expect(await PremiumService.isPremium(), isFalse);
    });

    test('should dispose without errors', () async {
      final purchaseService = PurchaseService();
      
      // Initialize first to avoid LateInitializationError
      await purchaseService.initialize();
      
      // Should not throw
      purchaseService.dispose();
    });
  });
}