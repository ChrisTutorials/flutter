import '../services/premium_service.dart';
import '../utils/platform_utils.dart';

class WindowsStoreAccessPolicy {
  WindowsStoreAccessPolicy({
    bool? isWindowsPlatform,
    Future<bool> Function()? premiumStatusLoader,
  }) : _isWindowsPlatform = isWindowsPlatform,
       _premiumStatusLoader = premiumStatusLoader;

  static const Set<String> freeCategoryNames = {
    'Length',
    'Weight',
    'Temperature',
  };

  final bool? _isWindowsPlatform;
  final Future<bool> Function()? _premiumStatusLoader;

  bool get isWindowsStorePolicyActive =>
      _isWindowsPlatform ?? PlatformUtils.isWindows;

  bool isPremiumCategory(String categoryName) {
    return !freeCategoryNames.contains(categoryName);
  }

  bool isCurrencyPremium() => isWindowsStorePolicyActive;

  bool isCustomUnitsPremium() => isWindowsStorePolicyActive;

  Future<bool> isPremiumUnlocked() async {
    if (!isWindowsStorePolicyActive) {
      return true;
    }

    final loader = _premiumStatusLoader;
    if (loader != null) {
      return loader();
    }

    return PremiumService.isPremium();
  }

  Future<bool> canAccessCategory(String categoryName) async {
    if (!isWindowsStorePolicyActive || !isPremiumCategory(categoryName)) {
      return true;
    }

    return isPremiumUnlocked();
  }

  Future<bool> canAccessCurrency() async {
    if (!isCurrencyPremium()) {
      return true;
    }

    return isPremiumUnlocked();
  }

  Future<bool> canAccessCustomUnits() async {
    if (!isCustomUnitsPremium()) {
      return true;
    }

    return isPremiumUnlocked();
  }
}
