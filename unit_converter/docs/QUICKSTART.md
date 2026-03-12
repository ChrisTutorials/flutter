# Quick Start Guide - Unit Converter App

## Documentation Navigation
- [Project Overview](README.md)
- [Security Configuration](SECURITY_CONFIG.md)
- [Architecture Documentation](ARCHITECTURE.md)
- [API Documentation](API.md)

## Step 1: Test the App (Android Emulator or Device)

### Option A: Use Android Emulator
1. Open Android Studio
2. Create an AVD (Android Virtual Device)
3. Run: \lutter devices\ to verify emulator is detected
4. Run: \lutter run\

### Option B: Use Physical Android Device
1. Enable Developer Mode on your phone
2. Enable USB Debugging
3. Connect phone via USB
4. Run: \lutter devices\ to verify phone is detected
5. Run: \lutter run\

## Step 2: Build Release APK

\\\ash
flutter build apk --release
\\\

The APK will be at: \uild/app/outputs/flutter-apk/app-release.apk\

## Step 3: Test the APK

1. Transfer the APK to your Android device
2. Install it (you may need to enable "Install from Unknown Sources")
3. Test all features:
   - All 8 conversion categories (including currency)
   - Recent conversions
   - Copy to clipboard
   - Ad display (test ads should show)
   - Currency offline mode

## Step 4: Prepare for Play Store

### 4.1 Create AdMob Account
1. Go to https://admob.google.com
2. Sign up with your Google account
3. Add payment information
4. Create a new app
5. Create ad units:
   - Banner ad (get the ad unit ID)
   - Interstitial ad (get the ad unit ID)
6. Note your App ID

### 4.2 Update AdMob IDs in Code

For detailed AdMob configuration instructions, see [SECURITY_CONFIG.md](SECURITY_CONFIG.md#2-admob-configuration).

Briefly, you need to:
1. Get your AdMob App ID and ad unit IDs from the AdMob Console
2. Update `lib/services/admob_service.dart` with your ad unit IDs
3. Update `android/app/src/main/AndroidManifest.xml` with your App ID

### 4.3 Create App Icons

You need to create app icons in multiple sizes. Use a tool like:
- https://appicon.co
- https://makeappicon.com

Upload your 1024x1024 icon and download the Android icons.

Replace the icons in:
- \ndroid/app/src/main/res/mipmap-mdpi/ic_launcher.png\ (48x48)
- \ndroid/app/src/main/res/mipmap-hdpi/ic_launcher.png\ (72x72)
- \ndroid/app/src/main/res/mipmap-xhdpi/ic_launcher.png\ (96x96)
- \ndroid/app/src/main/res/mipmap-xxhdpi/ic_launcher.png\ (144x144)
- \ndroid/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png\ (192x192)

### 4.4 Update App Version

Edit \pubspec.yaml\:

\\\yaml
version: 1.0.0+1
\\\

The format is: \ersionName+versionCode\
- versionName: 1.0.0 (what users see)
- versionCode: 1 (internal, must increase with each update)

### 4.5 Sign Your App

For complete app signing configuration, including keystore generation and build configuration, see [SECURITY_CONFIG.md](SECURITY_CONFIG.md#1-app-signing-configuration).

Key steps:
1. Generate a production keystore
2. Create a `key.properties` file (not committed to git)
3. Configure signing in `android/app/build.gradle.kts`
4. Build signed release APK

### 4.6 Build Signed Release APK

\\\ash
flutter build apk --release
\\\

## Step 5: Publish to Play Store

### 5.1 Create Google Play Developer Account
1. Go to https://play.google.com/console
2. Pay \ registration fee (one-time)
3. Complete your developer profile

### 5.2 Create New App
1. Click \"Create app\"
2. Fill in app details:
   - App name: Unit Converter
   - Default language: English
   - Free or Paid: Free
   - Ad-supported: Yes

### 5.3 Fill Store Listing
- Title: Unit Converter
- Short description: Convert between 7 unit categories instantly
- Full description: Use the description from README.md
- Screenshots: Take at least 2 screenshots from the app (minimum 2, maximum 8)
   - Use portrait screenshots, not landscape
   - Standard project target: 9:16 aspect ratio
   - Phone: 1080 x 1920 recommended, each side between 320 px and 3840 px
   - 7-inch tablet: 1200 x 1920 recommended, each side between 320 px and 3840 px
   - 10-inch tablet: 1600 x 2560 recommended, each side between 1080 px and 7680 px
   - For promotion eligibility, prepare at least 4 screenshots where both dimensions are at least 1080 px
   - Full rules: [STORE_SCREENSHOT_REQUIREMENTS.md](STORE_SCREENSHOT_REQUIREMENTS.md)

### 5.4 Upload APK
1. Go to \"Release\" section
2. Create a new release
3. Upload your signed APK
4. Add release notes: \"Initial release\"

### 5.5 Content Rating
1. Complete the content rating questionnaire
2. Get your content rating

### 5.6 Pricing & Distribution
- Set price: Free
- Distribute to: All countries (or select specific countries)

### 5.7 Submit for Review
1. Review all information
2. Submit for review
3. Wait for approval (usually 1-3 days)

## Step 6: After Approval

### Monitor Your App
1. Check Play Console for:
   - Downloads
   - Revenue
   - Crash reports
   - User reviews

### Update AdMob
1. Check AdMob dashboard for:
   - Ad impressions
   - Revenue
   - CTR (click-through rate)
   - Fill rate

### Marketing Tips
1. Share on social media
2. Ask friends and family to download and rate
3. Create a simple website
4. Share in relevant communities (Reddit, Discord, etc.)
5. Consider ASO (App Store Optimization)

## Troubleshooting

### App won't install
- Make sure \"Install from Unknown Sources\" is enabled
- Check if your Android version is compatible (min SDK 21)

### Ads not showing
- Check if AdMob IDs are correct
- Make sure internet permission is in AndroidManifest.xml
- Test ads should show immediately
- Real ads may take a few hours to start showing

### Build errors
- Run \lutter clean\
- Run \lutter pub get\
- Check if Flutter SDK is up to date: \lutter upgrade\

## Expected Timeline

- Day 1: Build and test app
- Day 2: Set up AdMob, create icons, sign app
- Day 3: Submit to Play Store
- Day 5-7: App approved and live
- Month 1: 50-200 downloads, \-15 revenue
- Month 3: 200-500 downloads, \-30 revenue
- Month 6: 500-1000 downloads, \-50 revenue

## Next Steps

After your first app is live:
1. Build more simple apps (tip calculator, QR scanner, etc.)
2. Cross-promote your apps
3. Gather user feedback
4. Add premium features (remove ads for \.99)
5. Consider building a portfolio of 10+ apps for \-500/month passive income
