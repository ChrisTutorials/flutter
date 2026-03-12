import 'package:shared_preferences/shared_preferences.dart';
import 'purchase_service.dart';

/// Service for managing premium status
///
/// Provides premium status management by checking for ad removal purchase.
/// This service integrates with Google Play Billing for one-time purchases.
class PremiumService {
  /// Storage key for premium status (legacy, kept for backward compatibility)
  static const String _premiumKey = 'premium_enabled';

  /// Check if the user has premium status
  ///
  /// Returns true if the user has purchased ad removal via Google Play Billing
  static Future<bool> isPremium() async {
    // Check if user has purchased ad removal
    if (PurchaseService.isInitialized) {
      return await PurchaseService.hasPurchasedAdRemoval();
    }
    
    // Fallback to legacy storage if purchase service not initialized
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_premiumKey) ?? false;
  }

  /// Set premium status (legacy method, kept for backward compatibility)
  ///
  /// Note: This method does not affect Google Play Billing purchases.
  /// For production, use PurchaseService.purchaseAdRemoval() instead.
  @Deprecated('Use PurchaseService.purchaseAdRemoval() instead')
  static Future<void> setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, value);
  }

  /// Enable premium status (legacy method, kept for backward compatibility)
  ///
  /// Note: This method does not affect Google Play Billing purchases.
  /// For production, use PurchaseService.purchaseAdRemoval() instead.
  @Deprecated('Use PurchaseService.purchaseAdRemoval() instead')
  static Future<void> enablePremium() async {
    await setPremium(true);
  }

  /// Disable premium status (legacy method, kept for backward compatibility)
  ///
  /// Note: This method does not affect Google Play Billing purchases.
  /// For production, ad removal cannot be disabled once purchased.
  @Deprecated('Ad removal cannot be disabled once purchased via Google Play')
  static Future<void> disablePremium() async {
    await setPremium(false);
  }

  /// Clear premium status (for testing only)
  ///
  /// Note: This clears both legacy storage and Google Play Billing purchase data.
  /// Use only for testing purposes.
  static Future<void> clearPremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_premiumKey);
    
    // Clear purchase service data
    if (PurchaseService.isInitialized) {
      await PurchaseService.clearAdRemovalPurchase();
    }
  }

  /// Check if premium is enabled synchronously (may not reflect latest changes)
  ///
  /// Note: This is a synchronous approximation.
  /// For accurate results, use isPremium() which is async.
  static bool isPremiumSync() {
    // Note: This is a synchronous approximation
    // For accurate results, use isPremium() which is async
    return false; // Default to false until loaded
  }

  /// Get the price of ad removal
  ///
  /// Returns the price string from Google Play, or null if not available
  static String? getAdRemovalPrice() {
    return PurchaseService.adRemovalPrice;
  }

  /// Check if ad removal is available for purchase
  static bool isAdRemovalAvailable() {
    return PurchaseService.isAdRemovalAvailable;
  }

  /// Purchase ad removal (convenience method)
  ///
  /// This is a convenience method that calls PurchaseService.purchaseAdRemoval()
  static Future<bool> purchaseAdRemoval() async {
    return await PurchaseService.purchaseAdRemoval();
  }

  /// Restore previous purchases (convenience method)
  ///
  /// This is a convenience method that calls PurchaseService.restorePurchases()
  static Future<void> restorePurchases() async {
    await PurchaseService.restorePurchases();
  }
}
