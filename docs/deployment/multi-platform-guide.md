# Unified Multi-Platform Deployment Guide

## 🚀 Overview

This guide provides a unified deployment workflow for Flutter apps across multiple platforms:
- **Android** - Google Play Store
- **Windows** - Microsoft Store
- **iOS** - Apple App Store (when needed)

The unified deployment script (`deploy.ps1`) provides a consistent interface for deploying to any platform from a single command.

## 📋 Prerequisites

### Common Prerequisites

1. **Flutter SDK** - Latest stable version with required platform support
2. **Ruby & Fastlane** - `gem install fastlane`
3. **Git** - For version control
4. **PowerShell 7+** - For running deployment scripts

### Platform-Specific Prerequisites

#### Android
- Android SDK with build tools
- Java JDK 11 or higher
- Google Play Developer account
- Google Play Console service account credentials
- Production keystore for app signing

#### Windows
- Windows 10/11
- Visual Studio 2022 with "Desktop development with C++" workload
- Windows 10/11 SDK
- Microsoft Partner Center account
- Windows code signing certificate
- Flutter Windows desktop support (`flutter config --enable-windows-desktop`)

#### iOS
- macOS with Xcode 14 or higher
- Apple Developer Program enrollment ($99/year)
- App Store Connect access
- iOS distribution certificate and provisioning profiles
- iOS device for testing (recommended)

## 🎯 Quick Start

### Deploy to Android (Google Play Store)

```powershell
# Deploy to internal testing
cd c:\dev\flutter\unit_converter
..\scripts\deploy.ps1 -Platform android -Track internal -ReleaseNotes "Initial release"

# Deploy to production
..\scripts\deploy.ps1 -Platform android -Track production -ReleaseNotes "New features and bug fixes" -SkipConfirmation

# Hotfix deployment (skip screenshots)
..\scripts\deploy.ps1 -Platform android -Track beta -ReleaseNotes "Critical bug fix" -SkipScreenshots -SkipConfirmation
```

### Deploy to Windows (Microsoft Store)

```powershell
# See docs/deployment/windows-export-signing.md
# for the canonical Windows export, signing, and upload flow
```

### Deploy to iOS (App Store)

```powershell
# Deploy to TestFlight
cd c:\dev\flutter\unit_converter
../scripts/deploy.ps1 -Platform ios -Track beta -ReleaseNotes "TestFlight release" -SkipConfirmation

# Deploy to production
../scripts/deploy.ps1 -Platform ios -Track production -ReleaseNotes "App Store release" -SkipConfirmation
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in your project root (not committed to git):

```bash
# Android
GOOGLE_PLAY_JSON_KEY_FILE=path/to/google-play-service-account.json

# Windows
# See docs/deployment/windows-export-signing.md
# for the canonical Windows signing inputs and MSIX export flow

# iOS
APP_STORE_CONNECT_API_KEY_ID=your-api-key-id
APP_STORE_CONNECT_API_ISSUER_ID=your-issuer-id
APP_STORE_CONNECT_API_KEY_PATH=path/to/AuthKey.p8
```

### Fastlane Configuration

Each platform needs Fastlane configured:

#### Android Fastlane Setup
```bash
cd unit_converter/android
bundle init
bundle add fastlane
bundle exec fastlane init
```

#### Windows Packaging and Signing

Use [windows-export-signing.md](windows-export-signing.md) as the canonical Windows guide.

#### iOS Fastlane Setup
```bash
cd unit_converter/ios
bundle init
bundle add fastlane
bundle exec fastlane init
```

## 📝 Command Parameters

### deploy.ps1 Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Platform` | String | Yes | Platform to deploy: `android`, `windows`, `ios` |
| `-Track` | String | No | Deployment track: `internal`, `alpha`, `beta`, `production`, `retail` (default: `internal`) |
| `-ReleaseNotes` | String | No | Release notes for the deployment (default: `Bug fixes and improvements`) |
| `-SkipScreenshots` | Switch | No | Skip screenshot generation/upload |
| `-SkipMetadata` | Switch | No | Skip metadata updates |
| `-SkipValidation` | Switch | No | Skip validation checks |
| `-SkipConfirmation` | Switch | No | Skip confirmation prompts (use for CI/CD) |
| `-DoNotSendForReview` | Switch | No | Do not submit for store review |
| `-ProjectPath` | String | No | Path to Flutter project (default: current directory) |

## 🚀 Deployment Tracks

### Android Tracks
- **Internal** - For your own testing (up to 100 testers)
- **Alpha** - For a small group of trusted testers
- **Beta** - For wider testing before production
- **Production** - For all users

### Windows Tracks
- **Internal** - For internal testing
- **Retail** - Public release

### iOS Tracks
- **TestFlight (Beta)** - For beta testing
- **Production** - Public release

## 🔄 Deployment Workflow

### Recommended Deployment Flow

1. **Internal Testing** - Deploy to internal track first
2. **Alpha/Beta Testing** - Expand to alpha/beta testers
3. **Production** - Deploy to production after validation

### Example Complete Workflow

```powershell
# Step 1: Deploy to internal testing
.\scripts\deploy.ps1 -Platform android -Track internal -ReleaseNotes "Internal test"

# Step 2: Test thoroughly on internal track
# - Install from internal testing link
# - Test all features
# - Verify ads (if applicable)
# - Test purchase flow (if applicable)

# Step 3: Deploy to alpha/beta
.\scripts\deploy.ps1 -Platform android -Track alpha -ReleaseNotes "Alpha release"
.\scripts\deploy.ps1 -Platform android -Track beta -ReleaseNotes "Beta release"

# Step 4: Deploy to production
.\scripts\deploy.ps1 -Platform android -Track production -ReleaseNotes "Production release" -SkipConfirmation
```

## 📸 Screenshot Management

### Automated Screenshot Handling

The deployment process automatically handles screenshots for each platform:

#### Android Screenshots
- Phone: 1080 x 1920 recommended
- 7-inch tablet: 1200 x 1920 recommended
- 10-inch tablet: 1600 x 2560 recommended
- Naming: `phoneScreenshots-01.png`, `sevenInchScreenshots-01.png`, `tenInchScreenshots-01.png`

#### Windows Screenshots
- Desktop: 1920 x 1080 recommended
- Naming: Follow Microsoft Store requirements

#### iOS Screenshots
- iPhone: 6.7" display: 1290 x 2796, 6.5" display: 1242 x 2688
- iPad: 12.9" display: 2048 x 2732, 11" display: 1668 x 2388
- Naming: Follow App Store Connect requirements

### Generating Screenshots

```bash
# Android screenshots
cd unit_converter
flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens

# Windows screenshots (manual capture)
# Use screenshot tool or built-in Windows screenshot functionality

# iOS screenshots (use Fastlane)
cd unit_converter/ios
bundle exec fastlane capture_screenshots
```

## 🔍 Validation

### Pre-Deployment Validation

The deployment script runs automatic validation checks:

#### Android Validation
- ✅ AndroidManifest.xml validation
- ✅ Build configuration validation
- ✅ Version format validation
- ✅ Required permissions validation
- ✅ AdMob configuration validation (if applicable)
- ✅ Signing configuration validation

#### Windows Validation
- ✅ Windows manifest validation
- ✅ Version format validation
- ✅ Signing configuration validation
- ✅ Certificate validation

#### iOS Validation
- ✅ iOS Info.plist validation
- ✅ Version format validation
- ✅ Provisioning profile validation
- ✅ Certificate validation

### Manual Validation

```bash
# Run validation manually
cd unit_converter/android
fastlane validate

# Windows
# See docs/deployment/windows-export-signing.md

cd ../ios
fastlane validate
```

## 🚨 Common Issues

### Fastlane Not Found

**Problem:** `Fastlane is not installed or not in PATH`

**Solution:**
```bash
gem install fastlane
# Or use bundler
bundle install
bundle exec fastlane --version
```

### Credential Issues

**Problem:** Deployment fails due to credential issues

**Solution:**
1. Check `.env` file has correct values
2. Verify service account files exist and are valid
3. Ensure you have the correct store permissions
4. Check environment variables are set correctly

### Build Failures

**Problem:** Build fails during deployment

**Solution:**
```bash
cd unit_converter
flutter clean
flutter pub get
flutter build apk --release  # Test Android build
# See docs/deployment/windows-export-signing.md for Windows export/signing
flutter build ios --release  # Test iOS build (macOS only)
```

### Version Conflicts

**Problem:** Store rejects build due to version conflict

**Solution:**
```bash
# Check current version
flutter pub deps | grep version

# Update version in pubspec.yaml
# Format: version: x.y.z+buildNumber
# Example: version: 1.0.5+15
```

### iOS Deployment on Windows

**Problem:** iOS deployment fails on Windows

**Solution:** iOS deployment requires macOS. Use:
- macOS machine for iOS builds
- GitHub Actions with macOS runner
- Cloud-based macOS build service

## 🎓 Best Practices

### 1. Use Non-Interactive Flags for CI/CD
```powershell
# Always use -SkipConfirmation for automated deployments
.\scripts\deploy.ps1 -Platform android -Track production -SkipConfirmation
```

### 2. Test on Internal Track First
```powershell
# Always deploy to internal track before production
.\scripts\deploy.ps1 -Platform android -Track internal
# Test thoroughly
.\scripts\deploy.ps1 -Platform android -Track production
```

### 3. Write Meaningful Release Notes
```powershell
# Good release notes are specific
.\scripts\deploy.ps1 -Platform android -Track production -ReleaseNotes "Added dark mode support and improved currency conversion accuracy"
```

### 4. Keep Credentials Secure
- Never commit `.env` files to git
- Use environment variables in CI/CD
- Rotate credentials regularly
- Use secret management services

### 5. Monitor After Deployment
- Check store console for crashes
- Monitor user feedback and ratings
- Track downloads and revenue
- Respond to user reviews

## 🔄 CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy to Android

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'
          
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.0'
          bundler-cache: true
          
      - name: Deploy to Play Store
        env:
          GOOGLE_PLAY_JSON_KEY_FILE: ${{ secrets.GOOGLE_PLAY_JSON_KEY_FILE }}
        run: |
          cd unit_converter
          ../scripts/deploy.ps1 -Platform android -Track production -SkipConfirmation -ReleaseNotes "Release ${{ github.ref_name }}"
```

### Jenkins Example

```groovy
pipeline {
    agent any
    stages {
        stage('Deploy') {
            steps {
                script {
                    dir('unit_converter') {
                        withCredentials([
                            string(credentialsId: 'GOOGLE_PLAY_JSON_KEY', variable: 'GOOGLE_PLAY_JSON_KEY_FILE')
                        ]) {
                            powershell """
                                ../scripts/deploy.ps1 -Platform android -Track production -SkipConfirmation -ReleaseNotes 'Release ${BUILD_NUMBER}'
                            """
                        }
                    }
                }
            }
        }
    }
}
```

## 📚 Additional Resources

### Documentation
- [Android Deployment Guide](../DEPLOYMENT.md) - Detailed Android deployment instructions
- [Windows Export and Signing Guide](windows-export-signing.md) - Canonical Windows export, signing, and upload flow
- [Windows Deployment Skill](../../.windsurf/skills/windows-store-deployment/SKILL.md) - Windows deployment best practices
- [Production Deployment Skill](../../.windsurf/skills/production-deployment/SKILL.md) - Production deployment for Android (Google Play Store)
- [Fastlane Documentation](https://docs.fastlane.tools/) - Official Fastlane documentation

### Platform-Specific Guides
- [Google Play Console](https://play.google.com/console) - Android store management
- [Microsoft Partner Center](https://partner.microsoft.com/) - Windows store management
- [App Store Connect](https://appstoreconnect.apple.com/) - iOS store management

## 🆘 Troubleshooting

### Get Help

If you encounter issues:
1. Check platform-specific documentation
2. Review Fastlane logs in `fastlane/report/`
3. Check store console for error messages
4. Review this guide's Common Issues section

### Debug Mode

Enable debug output:
```powershell
$env:FASTLANE_DISABLE_COLORS = "true"
$env:FASTLANE_HIDE_GITHUB_ISSUES = "true"
.\scripts\deploy.ps1 -Platform android -Track internal -SkipConfirmation
```

## 📊 Deployment Metrics

Track these metrics after deployment:
- Download count
- Crash-free users
- User ratings and reviews
- Active users (DAU/MAU)
- Revenue (if monetized)
- Conversion rate (if freemium)

## 🎉 Summary

The unified deployment workflow provides:
- ✅ Single interface for all platforms
- ✅ Consistent deployment process
- ✅ Non-interactive mode for CI/CD
- ✅ Comprehensive validation
- ✅ Automated screenshot handling
- ✅ Clear error messages
- ✅ Detailed logging

Use this workflow to deploy your Flutter apps efficiently across Android, Windows, and iOS platforms.

