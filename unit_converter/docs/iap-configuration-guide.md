# IAP Configuration Guide

## Overview
This guide explains how to configure In-App Purchases (IAP) for the Unit Converter app on all platforms.

## Platform-Specific Configuration

### 1. Android (Google Play Console)

#### Product ID
- **Current Product ID:** `no_ads_premium`
- **Type:** Non-consumable (durable)
- **Price:** $0.99 (or your chosen price)

#### Configuration Steps

1. **Open Google Play Console**
   - Go to https://play.google.com/console
   - Select your app

2. **Navigate to Monetize**
   - Click "Monetize" in the left sidebar
   - Click "Products" under "Monetize setup"

3. **Create In-App Product**
   - Click "Create product"
   - Enter Product ID: `no_ads_premium` (must match code exactly)
   - Enter Product name: "Premium Unlock" or "Ad-Free Upgrade"
   - Enter Description: "Remove all ads and support development"
   - Set Price: $0.99 (or your chosen price)

4. **Configure Product Details**
   - **Type:** Non-consumable (one-time purchase)
   - **Status:** Active (not Draft)
   - **Listing:** Add promotional text and images if desired

5. **Enable Billing**
   - Ensure billing is enabled for your app
   - Add test accounts for testing

#### Testing
```bash
# Test IAP on Android
# 1. Build debug APK
flutter build apk --debug

# 2. Install on test device
# 3. Add test email to Google Play Console
# 4. Test purchase flow
```

#### Important Notes
- Product ID must match code exactly: `no_ads_premium`
- Product must be in "Active" state (not "Draft")
- Test purchases require test accounts in Play Console
- Real purchases require app to be published (can be in testing tracks)

### 2. iOS (App Store Connect)

#### Product ID
- **Current Product ID:** `no_ads_premium`
- **Type:** Non-consumable (durable)
- **Price:** $0.99 (or your chosen price)

#### Configuration Steps

1. **Open App Store Connect**
   - Go to https://appstoreconnect.apple.com
   - Select your app

2. **Navigate to In-App Purchases**
   - Click "Features" in the left sidebar
   - Click "In-App Purchases"

3. **Create In-App Purchase**
   - Click "+" button
   - Select "Non-Consumable"
   - Enter Product ID: `no_ads_premium` (must match code exactly)
   - Enter Reference Name: "Premium Unlock"
   - Set Price: $0.99 (or your chosen price)

4. **Configure Product Details**
   - **Display Name:** Premium Unlock
   - **Description:** Remove all ads and support development
   - **Review Information:** Provide review notes for Apple
   - **Screenshots:** Add screenshots if required

5. **Submit for Review**
   - Complete all required fields
   - Submit for Apple review
   - IAP must be approved before app can use it

#### Testing
```bash
# Test IAP on iOS
# 1. Build debug app
flutter build ios --debug

# 2. Install on test device
# 3. Use Sandbox account for testing
# 4. Test purchase flow
```

#### Important Notes
- Product ID must match code exactly: `no_ads_premium`
- IAP must be approved by Apple before use
- Sandbox testing requires special test accounts
- Real purchases require app to be approved

### 3. Windows (Microsoft Partner Center)

#### Product ID
- **Future Product ID:** `windows_premium_unlock` (not yet implemented)
- **Type:** Durable add-on
- **Price:** $0.99 (or your chosen price)

#### Configuration Steps

1. **Open Microsoft Partner Center**
   - Go to https://partner.microsoft.com/dashboard
   - Select your app (9P8DMW35JXQ5)

2. **Navigate to Products**
   - Click "Products" in the left sidebar
   - Click "Add-ons" under your app

3. **Create Add-On**
   - Click "Create a new add-on"
   - Enter Product ID: `windows_premium_unlock` (must match code exactly)
   - Enter Display name: "Premium Unlock"
   - Set Price: $0.99 (or your chosen price)
   - **Type:** Durable (non-consumable)

4. **Configure Add-On Details**
   - **Description:** Remove all ads and unlock premium features
   - **Availability:** Same markets as app
   - **Sale Pricing:** None for launch

5. **Submit Add-On**
   - Complete all required fields
   - Submit for Microsoft certification
   - Add-on must be certified before app can use it

#### Current Status
⚠️ **Windows IAP is not yet implemented in the code.**

See `docs/windows-release-roadmap.md` for implementation plan.

#### Important Notes
- Product ID must match code exactly: `windows_premium_unlock`
- Add-on must be certified before use
- Test purchases require special test accounts
- Real purchases require app to be certified

## Code Configuration

### Current Product IDs

The product IDs are defined in `lib/services/purchase_service.dart`:

```dart
// Mobile (Android/iOS)
static const String _noAdsProductId = 'no_ads_premium';

// Windows (future implementation)
static const String _windowsPremiumProductId = 'windows_premium_unlock';
```

### Changing Product IDs

To change a product ID:

1. **Update the code** in `lib/services/purchase_service.dart`:
   ```dart
   static const String _noAdsProductId = 'your_new_product_id';
   ```

2. **Update the store configuration**:
   - Google Play Console: Create new product with new ID
   - App Store Connect: Create new IAP with new ID
   - Microsoft Partner Center: Create new add-on with new ID

3. **Update tests** if needed:
   - `test/services/purchase_service_test.dart`
   - `test/services/windows_iap_integration_test.dart`

### Adding New Products

To add a new product (e.g., subscription):

1. **Add product ID to code**:
   ```dart
   static const String _subscriptionProductId = 'monthly_premium';
   static const Set<String> _productIds = {
     _noAdsProductId,
     _subscriptionProductId,
   };
   ```

2. **Create product in stores**:
   - Google Play Console: Create subscription product
   - App Store Connect: Create auto-renewable subscription
   - Microsoft Partner Center: Create durable add-on

3. **Update purchase handling**:
   ```dart
   if (purchaseDetails.productID == _noAdsProductId) {
     await PremiumService.setPremium(true);
   } else if (purchaseDetails.productID == _subscriptionProductId) {
     // Handle subscription
   }
   ```

## Testing IAP

### Android Testing

1. **Add Test Account**
   - Go to Google Play Console
   - Settings > License testing
   - Add test email addresses

2. **Test Purchase Flow**
   ```bash
   flutter run
   # Navigate to purchase flow
   # Complete test purchase
   # Verify premium is unlocked
   ```

3. **Test Restore**
   - Uninstall and reinstall app
   - Test restore purchases functionality

### iOS Testing

1. **Create Sandbox Account**
   - Go to App Store Connect
   - Users and Roles > Sandbox
   - Create test account

2. **Test Purchase Flow**
   ```bash
   flutter run
   # Navigate to purchase flow
   # Complete test purchase with Sandbox account
   # Verify premium is unlocked
   ```

3. **Test Restore**
   - Uninstall and reinstall app
   - Test restore purchases functionality

### Windows Testing

⚠️ **Windows IAP not yet implemented - see roadmap**

## Troubleshooting

### Common Issues

#### Product Not Found
**Error:** `Products not found: no_ads_premium`

**Solutions:**
1. Verify product ID matches exactly (case-sensitive)
2. Verify product is in "Active" state (not Draft)
3. Verify product is published to the correct track
4. Wait 24-48 hours after creating product for propagation

#### Purchase Fails
**Error:** Purchase fails with error message

**Solutions:**
1. Verify billing is enabled for the app
2. Verify test account is properly configured
3. Check device has internet connection
4. Check store account is in good standing

#### Restore Fails
**Error:** Restore purchases fails

**Solutions:**
1. Verify user has previously purchased
2. Verify purchase was successful (check receipt)
3. Check device has internet connection
4. Verify product is still available in store

### Debug Mode

Enable debug logging for IAP:

```dart
// In purchase_service.dart
debugPrint('PurchaseService: Product ID: ${purchaseDetails.productID}');
debugPrint('PurchaseService: Status: ${purchaseDetails.status}');
debugPrint('PurchaseService: Error: ${purchaseDetails.error}');
```

## References

- [Google Play Billing Documentation](https://developer.android.com/google/play/billing)
- [App Store In-App Purchase Documentation](https://developer.apple.com/in-app-purchase/)
- [Microsoft Store Add-Ons Documentation](https://docs.microsoft.com/en-us/windows/uwp/monetize/in-app-purchases-and-trials)
- [in_app_purchase Flutter Package](https://pub.dev/packages/in_app_purchase)

## Summary

| Platform | Product ID | Status | Configuration Location |
|----------|-----------|--------|----------------------|
| Android | `no_ads_premium` | ✅ Implemented | Google Play Console |
| iOS | `no_ads_premium` | ✅ Implemented | App Store Connect |
| Windows | `windows_premium_unlock` | ⏳ Not Implemented | Microsoft Partner Center |

## Next Steps

1. **For Mobile (Android/iOS):**
   - Verify products are configured in respective stores
   - Test purchase flow on real devices
   - Test restore purchases functionality

2. **For Windows:**
   - Follow `docs/windows-release-roadmap.md`
   - Implement Windows Store entitlement service
   - Create add-on in Partner Center
   - Test Windows Store purchase flow

