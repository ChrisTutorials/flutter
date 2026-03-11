# Quick Start Guide - Publishing Your First Release

## ✅ What's Ready
- App bundle built successfully (46.8MB)
- Deployment script working
- AAB file ready at: build\app\outputs\bundle\release\app-release.aab

## 🚀 Next Steps - Upload to Google Play Console

### Option 1: Manual Upload (Recommended for First Release)
1. Open: https://play.google.com/console/u/2/developers/7048002971075729329/app/4973705976520115383/app-dashboard
2. Click 'Production' in the left sidebar
3. Click 'Create new release'
4. Click 'Browse files'
5. Navigate to: C:\dev\flutter\unit_converter\build\app\outputs\bundle\release\app-release.aab
6. Upload the file
7. Add release notes: 'Initial release with custom units, live currency, and quick presets'
8. Click 'Review'
9. Click 'Start rollout to Production'

### Option 2: Use Deployment Script (Build Only)
`powershell
cd C:\dev\flutter\unit_converter
.\scripts\deploy-to-play-store.ps1 -Track 'internal' -ReleaseNotes 'Initial release'
`
Then manually upload the AAB file as shown in Option 1.

## 📋 Required Information Before Publishing

You must complete these sections in Google Play Console:

### 1. Main Store Listing
- **App Name**: Unit Converter Pro (or your chosen name)
- **Short Description**: Convert units, create custom measurements, live currency rates
- **Full Description**: 
  `
  The ultimate unit converter for professionals and everyday users.
  
  KEY FEATURES:
  • 8+ Unit Categories - Length, Weight, Temperature, Volume, Area, Speed, Time, Currency
  • Custom Units - Create your own conversion units for specialized needs
  • Live Currency - Real-time exchange rates with offline fallback
  • Quick Presets - One-tap common conversions (°F↔°C, kg↔lb, in↔cm, gal↔L, USD↔EUR, EUR↔GBP)
  • Beautiful Themes - 5 color palettes with dark/light/system modes
  • Offline-First - Works without internet for most features
  • Recent Conversions - Quick access to previous conversions
  • Smart Search - Find converters, presets, and custom units instantly
  • Favorites - Save your most-used conversions
  
  PERFECT FOR:
  • Engineers and scientists with specialized measurement needs
  • Travelers needing currency conversion
  • Students and educators
  • Professionals who need reliable conversions
  • Anyone who values precision and convenience
  
    `
- **Screenshots**: 2-8 phone screenshots showing:
  1. Main category screen
  2. Conversion screen
  3. Currency converter
  4. Quick presets
  5. Theme settings
  6. Custom units
- **App Icon**: 512x512 PNG (create from your logo)

### 2. Content Rating
- Complete the questionnaire
- Your app will likely get 'Everyone' rating

### 3. Privacy Policy
- Create a free privacy policy: https://privacypolicygenerator.info
- Upload it to a website (GitHub Pages, Netlify, etc.)
- Add the URL to Google Play Console

### 4. Pricing and Distribution
- Set as Free
- Select all countries or specific ones
- Accept content guidelines

## 📸 How to Take Screenshots

### Using Android Emulator
1. Make sure the app is running on emulator
2. Use these keyboard shortcuts:
   - Windows: Ctrl + S (in Android Studio) or use emulator toolbar
   - Or use: adb shell screencap -p > screenshot.png
3. Take screenshots of key screens
4. Edit to 1080x1920 or 1080x2400 pixels

### Screenshots to Capture:
1. Home screen with categories and presets
2. Length conversion screen
3. Currency converter screen
4. Theme settings screen
5. Custom units screen
6. Search functionality

## 🔧 Build Commands Reference

`ash
# Build release AAB (required for Play Store)
flutter build appbundle --release

# Build release APK (for testing)
flutter build apk --release

# Clean build
flutter clean

# Get dependencies
flutter pub get
`

## 📝 Version Management

Update version in pubspec.yaml before each release:
`yaml
version: 1.0.0+1
`
Format: major.minor.patch+buildNumber

## 🚦 Deployment Checklist

Before submitting:
- [ ] App name chosen
- [ ] Short description written
- [ ] Full description written
- [ ] 2-8 screenshots taken
- [ ] App icon created (512x512)
- [ ] Content rating completed
- [ ] Privacy policy URL added
- [ ] Pricing set to Free
- [ ] Countries selected
- [ ] Release notes written
- [ ] AAB file built successfully
- [ ] AAB file uploaded to Play Console

## 🎯 After Submission

1. Google will review your app (1-3 days)
2. You'll get email notifications
3. If rejected, fix issues and resubmit
4. Once approved, your app goes live!

## 📞 Support

- Google Play Console Help: https://support.google.com/googleplay/android-developer
- Flutter Deployment Docs: https://flutter.dev/docs/deployment/android

