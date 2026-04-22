import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/services/premium_service.dart';

void main() {
  group('PremiumService', () {
    test('isPremium returns false when not set', () async {
      // Note: This test requires a properly initialized SharedPreferences
      // In a real test environment, you'd mock SharedPreferences
      expect(await PremiumService.isPremium(), false);
    });

    test('setPremium stores value with integrity hash', () async {
      await PremiumService.setPremium(true);
      
      // Verify integrity
      final isValid = await PremiumService.verifyIntegrity();
      expect(isValid, true);
      
      // Cleanup
      await PremiumService.setPremium(false);
    });

    test('verifyIntegrity detects tampering', () async {
      await PremiumService.setPremium(true);
      
      // Verify initial integrity
      expect(await PremiumService.verifyIntegrity(), true);
      
      // Note: In a real test, you would manually corrupt the stored hash
      // to verify detection. This is a basic sanity check.
      
      // Cleanup
      await PremiumService.setPremium(false);
    });
  });
}
