# Android Play Store Deployment Checklist

Canonical release workflow: see `docs/PLAY_STORE_RELEASE_RUNBOOK.md` for the current automation path for metadata, screenshots, validation, and Fastlane upload.

## ✅ Completed Steps
- [x] App version configured (1.0.4+3)
- [x] Production keystore setup
- [x] Release AAB built (47.5MB)
- [x] AdMob production IDs configured
- [x] IAP for ad removal implemented
- [x] Code obfuscation enabled
- [x] Production signing configured
- [x] Privacy policy created and hosted
- [x] AdMob Application ID uncommented in AndroidManifest.xml
- [x] Advertising ID permission added for Android 13+ compliance
- [x] Pre-deployment test suites created
- [x] Fastlane installed and configured for automated deployment

## 🔄 In Progress
- [ ] Google Play Console store listing
- [ ] AdMob product configuration

## 📋 Remaining Tasks

### Google Play Console Setup
1. **Store Listing**
   - [ ] App name: "Unit Converter Pro"
   - [ ] Short description (80 chars)
   - [ ] Full description (4000 chars)
   - [ ] Screenshots (2-8 phone screenshots)
   - [ ] App icon (512x512 PNG)
   - [ ] Feature graphic (1024x500 JPG)
   - [ ] Privacy policy URL

2. **Content Rating**
   - [ ] Complete content rating questionnaire
   - [ ] Verify rating (expected: "Everyone")

3. **Pricing & Distribution**
   - [ ] Set as Free app
   - [ ] Select distribution countries
   - [ ] Content guidelines acceptance

4. **App Content**
   - [ ] Target audience
   - [ ] Content rating questionnaire
   - [ ] Privacy policy

### AdMob & IAP Setup
1. **AdMob Configuration**
   - [ ] Verify app is created in AdMob console
   - [ ] Production ad units configured
   - [ ] App store linking completed

2. **In-App Purchase Setup**
   - [ ] Add BILLING permission to AndroidManifest.xml
   - [ ] Create product: `no_ads_premium`
   - [ ] Set price (e.g., $1.99)
   - [ ] Configure as one-time purchase
   - [ ] Add test accounts for license testing

### Upload & Release
1. **Pre-Deployment Verification**
   - [ ] Run Fastlane validation: `cd android && fastlane validate`
   - [ ] Run Flutter tests: `cd android && fastlane test`
   - [ ] Run complete CI pipeline: `cd android && fastlane ci`
   - [ ] Fix any failing checks

2. **Internal Testing**
   - [ ] Deploy to internal testing: `cd android && fastlane deploy_internal`
   - [ ] Add test accounts
   - [ ] Test purchase flow on real device
   - [ ] Verify ads work correctly
   - [ ] Verify IAP removes ads

3. **Alpha/Beta Testing**
   - [ ] Deploy to alpha: `cd android && fastlane deploy_alpha`
   - [ ] Deploy to beta: `cd android && fastlane deploy_beta`
   - [ ] Add beta testers
   - [ ] Collect feedback
   - [ ] Fix any issues

4. **Production Release**
   - [ ] Bump version: `cd android && fastlane bump_build_number`
   - [ ] Deploy to production: `cd android && fastlane deploy_production`
   - [ ] Add release notes
   - [ ] Submit for review
   - [ ] Monitor review status

## 🚀 Quick Commands

### Fastlane Commands (Recommended)
```bash
# Validate configuration before deployment
cd android
fastlane validate

# Run complete CI pipeline (test + validate + build)
fastlane ci

# Build release AAB
fastlane build_release

# Deploy to internal testing
fastlane deploy_internal

# Deploy to alpha
fastlane deploy_alpha

# Deploy to beta
fastlane deploy_beta

# Deploy to production
fastlane deploy_production

# Bump version number
fastlane bump_build_number

# Show current version
fastlane show_version

# Upload screenshots
fastlane upload_screenshots

# Upload metadata
fastlane upload_metadata
```

### Manual Build Commands
```bash
# Clean and build release AAB
flutter clean
flutter pub get
flutter build appbundle --release

# Build release APK
flutter build apk --release

# Run Flutter tests
flutter test
```

### PowerShell Deployment Script (Legacy)
```bash
# Auto-increment version and build release AAB
powershell -ExecutionPolicy Bypass -File scripts\deploy-to-play-store.ps1 -Track 'internal' -ReleaseNotes 'Bug fixes and improvements'

# Skip version bump (keep current version)
powershell -ExecutionPolicy Bypass -File scripts\deploy-to-play-store.ps1 -Track 'internal' -SkipVersionBump

# Manual build (no version bump)
flutter clean
flutter pub get

# Build release AAB
flutter build appbundle --release
```

### Test Commands
```bash
# Run on device
flutter run

# Run tests
flutter test

# Build APK for testing
flutter build apk --release
```

## 📱 Store Assets Needed

### Screenshots (Required)
- Phone screenshots (2-8 images)
- 1080x1920 pixels (portrait)
- PNG or JPG format
- Show: Main screen, conversion screens, settings

### Graphics (Required)
- App icon: 512x512 PNG
- Feature graphic: 1024x500 JPG
- Promo video (optional)

### Text Content
- **App Name**: Unit Converter Pro
- **Short Description**: Convert units instantly with precision
- **Full Description**: 
  ```
  The most comprehensive unit converter for Android! Convert between 500+ units across 8 categories:
  
  📏 Length: meters, feet, inches, miles, kilometers
  ⚖️ Weight: kg, pounds, ounces, grams, tons
  🌡️ Temperature: Celsius, Fahrenheit, Kelvin
  💧 Volume: liters, gallons, cups, milliliters
  📐 Area: square meters, acres, square feet
  ⚡ Speed: mph, km/h, m/s, knots
  ⏱️ Time: seconds, minutes, hours, days
  💱 Currency: Real-time rates with 150+ currencies
  
  ✨ Key Features:
  • Instant conversion as you type
  • Bidirectional conversion with one tap
  • Smart history with recent conversions
  • Custom units creation
  • Dark/Light themes with 5 color schemes
  • Android home screen widgets
  • Offline mode for most conversions
  • Material Design 3 interface
  • No internet required for basic conversions
  
  Perfect for students, engineers, cooks, travelers, and anyone who needs quick, accurate unit conversions.
  ```

## 🔧 Technical Details

### App Information
- **Package Name**: com.unitconverter.unit_converter
- **Version**: 1.0.1
- **Target SDK**: 34 (Android 14)
- **Min SDK**: 21 (Android 5.0)
- **Size**: 47.4MB

### Permissions Used
- INTERNET: For currency conversion
- BILLING: For ad removal purchase
- NETWORK_STATE: For connectivity checks

### Monetization
- **Free app with AdMob ads**
- **One-time IAP to remove ads**: $1.99
- **Ad frequency**: Conservative (10 conversions before first ad)
- **Ad types**: Banner, Interstitial, App Open

## ⚠️ Important Notes

### Before Release
1. Test on physical device (not just emulator)
2. Verify IAP purchase flow works
3. Confirm ads display correctly
4. Test premium mode removes all ads
5. Validate currency conversion works

### After Release
1. Monitor crash reports
2. Track ad revenue in AdMob
3. Monitor IAP revenue in Play Console
4. Respond to user reviews
5. Fix any critical bugs quickly

## 📞 Support Links

- Google Play Console: https://play.google.com/console
- AdMob Console: https://apps.admob.com
- Flutter Deployment Guide: https://flutter.dev/docs/deployment/android

---

**Status**: Ready for Play Store deployment! ✅
