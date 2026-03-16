# Automated Google Play Console Upload Setup Guide

## Current Status
? App bundle built successfully: build\app\outputs\bundle\release\app-release.aab (46.8MB)
? Deployment script created: scripts\deploy-to-play-store.ps1

## Quick Start - Manual Upload (Recommended for First Release)

### Step 1: Upload AAB to Google Play Console
1. Go to https://play.google.com/console
2. Navigate to your app: https://play.google.com/console/u/2/developers/7048002971075729329/app/4973705976520115383/app-dashboard
3. Click on 'Production' in the left sidebar
4. Click 'Create new release'
5. Click 'Browse files' and select: C:\dev\flutter\unit_converter\build\app\outputs\bundle\release\app-release.aab
6. Wait for Google to process the bundle
7. Add release notes (500 chars max)
8. Click 'Review' then 'Start rollout to Production'

### Step 2: Complete Required Information
Before your app can go live, complete these sections:

1. **Main Store Listing**
   - App name (e.g., 'Unit Converter Pro')
   - Short description (80 chars)
   - Full description (4000 chars)
   - Screenshots (2-8 phone screenshots)
   - App icon (512x512 PNG)

2. **Content Rating**
   - Complete the questionnaire
   - You'll get a rating (likely 'Everyone')

3. **Privacy Policy**
   - Create a privacy policy URL
   - Use a free generator: https://privacypolicygenerator.info

4. **Pricing and Distribution**
   - Set as Free
   - Select countries

## Automated Upload Setup (For Future Releases)

### Prerequisites
1. Java JDK 17+ installed
2. Google Cloud CLI installed
3. Python 3.11+ installed
4. Google Play Console API access

### Step 1: Create Service Account
1. Go to Google Play Console
2. Setup ? API access
3. Create a service account
4. Grant permissions (Admin or Release Manager)
5. Download JSON key file

### Step 2: Set Environment Variable
`powershell
[Environment]::SetEnvironmentVariable('GOOGLE_APPLICATION_CREDENTIALS', 'C:\path\to\service-account-key.json', 'User')
`

### Step 3: Install Required Tools
`ash
# Install Python packages
pip install google-api-python-client google-auth-oauthlib

# Or install fastlane (Ruby-based)
gem install fastlane -NV
`

### Step 4: Use the Deployment Script
`powershell
# Build and prepare for upload
.\scripts\deploy-to-play-store.ps1 -Track 'internal' -ReleaseNotes 'Initial release'
`

## Useful Commands

### Build Commands
`ash
# Build release APK (smaller, for testing)
flutter build apk --release

# Build release AAB (required for Play Store)
flutter build appbundle --release

# Build for different flavors
flutter build appbundle --release --flavor production
`

### Test Commands
`ash
# Run on connected device
flutter run

# Run on specific device
flutter run -d emulator-5554

# Run in release mode
flutter run --release
`

### Clean Commands
`ash
# Clean build artifacts
flutter clean

# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade
`

## Deployment Workflow

### For First Release
1. Complete all required store listing information
2. Build app bundle: flutter build appbundle --release
3. Upload manually to Google Play Console
4. Submit for review
5. Wait for approval (1-3 days)

### For Future Releases
1. Update version in pubspec.yaml
2. Build app bundle
3. Use automated upload script (if configured)
4. Add release notes
5. Submit for review

## Troubleshooting

### Build Issues
`ash
# Clean and rebuild
flutter clean
flutter pub get
flutter build appbundle --release
`

### Upload Issues
- Verify AAB file exists
- Check file size (should be ~46MB)
- Ensure you have correct permissions in Google Play Console

### API Issues
- Verify service account key is correct
- Check GOOGLE_APPLICATION_CREDENTIALS is set
- Verify service account has proper permissions

## Resources
- Google Play Console: https://play.google.com/console
- Flutter Deployment: https://flutter.dev/docs/deployment/android
- Google Play Publisher API: https://developers.google.com/android-publisher


