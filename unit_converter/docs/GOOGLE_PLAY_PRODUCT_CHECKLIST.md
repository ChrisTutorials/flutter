# Google Play Console Product Configuration Checklist

Use this checklist to verify the `no_ads_premium` product is properly configured in Google Play Console.

## Pre-Release Checklist

Before releasing a new version, verify the following:

### 1. Product Registration
- [ ] Product ID is exactly `no_ads_premium` (case-sensitive)
- [ ] Product exists in Google Play Console
- [ ] Product Type is "In-app product" (NOT subscription)
- [ ] Product Status is "Active" (NOT Draft)

### 2. Product Details
- [ ] Product Name is filled in (e.g., "Remove Ads")
- [ ] Product Description is filled in
- [ ] Price is set (e.g., $0.99 USD)
- [ ] Tax Category is set (e.g., "Digital app sales")
- [ ] Age Rating is set (e.g., "All ages")

### 3. Product Listings
- [ ] At least one language listing is configured
- [ ] Listing title is filled in
- [ ] Listing description is filled in

### 4. Account Configuration
- [ ] Merchant account is configured for payments
- [ ] Tax information is filled in
- [ ] Developer account is in good standing

### 5. Testing
- [ ] Product loads successfully in release build
- [ ] Purchase flow works on physical device
- [ ] Restore purchases works
- [ ] Premium status is applied after purchase
- [ ] Ads are disabled after purchase

## How to Configure the Product

If any of the above items are not checked, follow these steps:

### Step 1: Create or Edit the Product

1. Go to Google Play Console
2. Navigate to your app
3. Go to **Monetize** → **Monetize setup**
4. Click on **In-app products**
5. If the product doesn't exist:
   - Click "Create in-app product"
   - Set Product ID to `no_ads_premium`
   - Click "Continue"
6. If the product exists:
   - Click on the product to edit it

### Step 2: Configure Product Details

1. Set **Product Type** to "In-app product" (NOT subscription)
2. Fill in **Product Name** (e.g., "Remove Ads")
3. Fill in **Product Description**
4. Set **Price** (e.g., $0.99 USD)
5. Set **Tax Category** to "Digital app sales"
6. Set **Age Rating** to "All ages"
7. Click "Save"

### Step 3: Configure Listings

1. Click on "Listings" tab
2. Add a language listing (e.g., English - United States)
3. Fill in the listing title and description
4. Click "Save"

### Step 4: Activate the Product

1. Go back to the product details page
2. Click the "Activate" button
3. Wait a few minutes for the change to propagate

### Step 5: Test the Product

1. Build a release version of the app:
   ```bash
   flutter build appbundle --release
   ```
2. Install the AAB on a physical device
3. Navigate to Settings → Upgrades
4. Verify the purchase button shows the price
5. Test the purchase flow
6. Verify premium status is applied
7. Verify ads are disabled

## Common Issues and Solutions

### Issue: "Products not found: no_ads_premium"

**Cause**: Product not registered or in Draft state

**Solution**:
1. Verify product exists in Google Play Console
2. Verify product is in Active state (not Draft)
3. Wait a few minutes for changes to propagate
4. Clear Play Store cache: `adb shell pm clear com.android.vending`

### Issue: "ProductDetails is not a subtype of GooglePlayProductDetails"

**Cause**: Product type mismatch or configuration error

**Solution**:
1. Verify product type is "In-app product" (NOT subscription)
2. Verify product is in Active state
3. Verify app is signed with correct key
4. See [docs/PRODUCT_LOADING_BUG.md](PRODUCT_LOADING_BUG.md) for detailed debugging

### Issue: Purchase button doesn't show price

**Cause**: Product not loaded successfully

**Solution**:
1. Check `PurchaseService().errorMessage` for error details
2. Verify product is properly configured
3. Test with release build on physical device
4. Check Android logcat for Play Billing errors

### Issue: Premium status not applied after purchase

**Cause**: Purchase not completed or not verified

**Solution**:
1. Verify purchase completed successfully in Play Store
2. Check for pending purchases in Play Store
3. Try "Restore" button in Settings
4. Check Android logcat for purchase errors

## Verification Commands

Use these commands to verify the product configuration:

```bash
# Check if product loads
flutter run --release
# Then check PurchaseService().errorMessage in the app

# Monitor Play Billing errors
adb logcat | grep -E "Billing|Purchase|ProductDetails"

# Check for type casting errors
adb logcat | grep -E "subtype|GooglePlayProductDetails"

# Clear Play Store cache
adb shell pm clear com.android.vending
```

## Documentation

For more detailed information, see:
- [Product Loading Bug Documentation](PRODUCT_LOADING_BUG.md)
- [IAP Implementation Summary](../IAP_IMPLEMENTATION_SUMMARY.md)
- [Play Store Release Runbook](../docs/PLAY_STORE_RELEASE_RUNBOOK.md)
