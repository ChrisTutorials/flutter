import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/services/premium_service.dart';
import 'package:unit_converter/services/windows_store_access_policy.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WindowsStoreAccessPolicy', () {
    test('non-Windows platforms allow all categories and tools', () async {
      final policy = WindowsStoreAccessPolicy(
        isWindowsPlatform: false,
        premiumStatusLoader: () async => false,
      );

      expect(policy.isWindowsStorePolicyActive, isFalse);
      expect(await policy.canAccessCategory('Currency'), isTrue);
      expect(await policy.canAccessCategory('Volume'), isTrue);
      expect(await policy.canAccessCustomUnits(), isTrue);
      expect(await policy.canAccessCurrency(), isTrue);
    });

    test('Windows free tier keeps core categories open and locks premium ones', () async {
      final policy = WindowsStoreAccessPolicy(
        isWindowsPlatform: true,
        premiumStatusLoader: () async => false,
      );

      expect(policy.isWindowsStorePolicyActive, isTrue);
      expect(await policy.canAccessCategory('Length'), isTrue);
      expect(await policy.canAccessCategory('Weight'), isTrue);
      expect(await policy.canAccessCategory('Temperature'), isTrue);
      expect(await policy.canAccessCategory('Volume'), isFalse);
      expect(await policy.canAccessCategory('Data'), isFalse);
      expect(await policy.canAccessCurrency(), isFalse);
      expect(await policy.canAccessCustomUnits(), isFalse);
    });

    test('Windows premium unlocks all categories and tools', () async {
      final policy = WindowsStoreAccessPolicy(
        isWindowsPlatform: true,
        premiumStatusLoader: () async => true,
      );

      expect(await policy.canAccessCategory('Volume'), isTrue);
      expect(await policy.canAccessCategory('Data'), isTrue);
      expect(await policy.canAccessCurrency(), isTrue);
      expect(await policy.canAccessCustomUnits(), isTrue);
    });

    test('uses persisted premium state when no loader override is provided', () async {
      await PremiumService.setPremium(true);
      final policy = WindowsStoreAccessPolicy(isWindowsPlatform: true);

      expect(await policy.isPremiumUnlocked(), isTrue);
      expect(await policy.canAccessCategory('Pressure'), isTrue);
    });
  });
}
