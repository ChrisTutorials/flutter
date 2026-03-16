# Skill: Unified Multi-Platform Deployment

## 📋 Summary

Deploy Flutter apps to multiple platforms (Android, Windows, iOS) using a **unified deployment workflow**. This skill provides a consistent interface for deploying to any platform from a single command, with non-interactive mode support for CI/CD pipelines.

## 🎯 Supported Platforms

- **Android** - Google Play Store (Internal, Alpha, Beta, Production tracks)
- **Windows** - Microsoft Store (Internal, Retail tracks)
- **iOS** - Apple App Store (TestFlight, Production tracks)

## 🚀 Quick Start

### Deploy to Android

```powershell
cd c:\dev\flutter\unit_converter
..\scripts\deploy.ps1 -Platform android -Track internal -ReleaseNotes "Initial release"
```

### Deploy to Windows

```powershell
cd c:\dev\flutter\unit_converter
..\scripts\deploy.ps1 -Platform windows -Track retail -ReleaseNotes "Windows release"
```

### Deploy to iOS (macOS only)

```powershell
cd c:\dev\flutter\unit_converter
../scripts/deploy.ps1 -Platform ios -Track beta -ReleaseNotes "TestFlight release"
```

## ⚠️ Critical: Always Use Non-Interactive Mode

For CI/CD and automated deployments, **ALWAYS** use the `-SkipConfirmation` flag to prevent blocking on confirmation prompts:

```powershell
# ✅ GOOD - Non-interactive
.\scripts\deploy.ps1 -Platform android -Track production -SkipConfirmation

# ❌ BAD - Will hang on confirmation
.\scripts\deploy.ps1 -Platform android -Track production
```

## 📝 Command Parameters

| Parameter | Required | Description | Default |
|-----------|----------|-------------|---------|
| `-Platform` | Yes | Platform: `android`, `windows`, `ios` | - |
| `-Track` | No | Track: `internal`, `alpha`, `beta`, `production`, `retail` | `internal` |
| `-ReleaseNotes` | No | Release notes | `Bug fixes and improvements` |
| `-SkipScreenshots` | No | Skip screenshot generation | `false` |
| `-SkipMetadata` | No | Skip metadata updates | `false` |
| `-SkipValidation` | No | Skip validation checks | `false` |
| `-SkipConfirmation` | No | Skip confirmation prompts (CI/CD) | `false` |
| `-DoNotSendForReview` | No | Do not submit for store review | `false` |
| `-ProjectPath` | No | Path to Flutter project | Current directory |

## 🎯 Platform-Specific Deployment Tracks

### Android Tracks
- **Internal** - For your own testing (up to 100 testers)
- **Alpha** - For a small group of trusted testers
- **Beta** - For wider testing before production
- **Production** - For all users

### Windows Tracks
- **Internal** - For internal testing
- **Retail** - Public release

### iOS Tracks
- **Beta** - TestFlight for beta testing
- **Production** - App Store public release

## 🔧 Complete Deployment Workflows

### Android Deployment Workflow

```powershell
# Step 1: Deploy to internal testing
cd c:\dev\flutter\unit_converter
..\scripts\deploy.ps1 -Platform android -Track internal -ReleaseNotes "Internal test"

# Step 2: Test thoroughly on internal track
# - Install from internal testing link
# - Test all features
# - Verify ads (if applicable)
# - Test purchase flow (if applicable)

# Step 3: Deploy to alpha/beta
..\scripts\deploy.ps1 -Platform android -Track alpha -ReleaseNotes "Alpha release"
..\scripts\deploy.ps1 -Platform android -Track beta -ReleaseNotes "Beta release"

# Step 4: Deploy to production (non-interactive)
..\scripts\deploy.ps1 -Platform android -Track production -ReleaseNotes "Production release" -SkipConfirmation
```

### Windows Deployment Workflow

```powershell
# Step 1: Deploy to internal testing
cd c:\dev\flutter\unit_converter
..\scripts\deploy.ps1 -Platform windows -Track internal -ReleaseNotes "Internal test"

# Step 2: Test thoroughly
# - Install from internal testing link
# - Test all features
# - Verify Windows-specific functionality

# Step 3: Deploy to retail (non-interactive)
..\scripts\deploy.ps1 -Platform windows -Track retail -ReleaseNotes "Windows release" -SkipConfirmation
```

### iOS Deployment Workflow

```powershell
# Step 1: Deploy to TestFlight
cd c:\dev\flutter\unit_converter
../scripts/deploy.ps1 -Platform ios -Track beta -ReleaseNotes "TestFlight release" -SkipConfirmation

# Step 2: Test with TestFlight users
# - Distribute to beta testers
# - Collect feedback
# - Fix issues

# Step 3: Deploy to production (non-interactive)
../scripts/deploy.ps1 -Platform ios -Track production -ReleaseNotes "App Store release" -SkipConfirmation
```

## 🔍 Validation

### Automatic Validation

The deployment script automatically runs validation checks:
- ✅ Configuration validation
- ✅ Version format validation
- ✅ Signing configuration validation
- ✅ Required permissions validation
- ✅ Platform-specific checks

### Manual Validation

```bash
# Validate Android
cd unit_converter/android
fastlane validate

# Validate Windows
cd unit_converter/windows
fastlane validate

# Validate iOS
cd unit_converter/ios
fastlane validate
```

## 🎓 Best Practices

### 1. Always Use Non-Interactive Flags for CI/CD

```powershell
# ✅ GOOD - Non-interactive
.\scripts\deploy.ps1 -Platform android -Track production -SkipConfirmation

# ❌ BAD - Will hang on confirmation
.\scripts\deploy.ps1 -Platform android -Track production
```

### 2. Test on Internal Track First

```powershell
# Deploy to internal (non-interactive)
.\scripts\deploy.ps1 -Platform android -Track internal -SkipConfirmation

# Test the build
# Then deploy to production (non-interactive)
.\scripts\deploy.ps1 -Platform android -Track production -SkipConfirmation
```

### 3. Use Meaningful Release Notes

```powershell
# ✅ GOOD - Specific release notes
.\scripts\deploy.ps1 -Platform android -Track production -ReleaseNotes "Added dark mode support and improved currency conversion accuracy"

# ❌ BAD - Generic release notes
.\scripts\deploy.ps1 -Platform android -Track production -ReleaseNotes "Bug fixes and improvements"
```

### 4. Skip Screenshots for Hotfixes

```powershell
# Hotfix deployment without updating screenshots
.\scripts\deploy.ps1 -Platform android -Track beta -ReleaseNotes "Critical bug fix" -SkipScreenshots -SkipConfirmation
```

### 5. Use Environment Variables for Credentials

Create a `.env` file in your project root:

```bash
# Android
GOOGLE_PLAY_JSON_KEY_FILE=path/to/google-play-service-account.json

# Windows
PARTNER_CENTER_CLIENT_ID=your-client-id
PARTNER_CENTER_CLIENT_SECRET=your-client-secret
PARTNER_CENTER_TENANT_ID=your-tenant-id
WINDOWS_CERTIFICATE_PATH=path/to/certificate.pfx
WINDOWS_CERTIFICATE_PASSWORD=your-password

# iOS
APP_STORE_CONNECT_API_KEY_ID=your-api-key-id
APP_STORE_CONNECT_API_ISSUER_ID=your-issuer-id
APP_STORE_CONNECT_API_KEY_PATH=path/to/AuthKey.p8
```

## 🔄 CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy to All Platforms

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy-android:
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
          
      - name: Deploy to Android
        env:
          GOOGLE_PLAY_JSON_KEY_FILE: ${{ secrets.GOOGLE_PLAY_JSON_KEY_FILE }}
        run: |
          cd unit_converter
          ../scripts/deploy.ps1 -Platform android -Track production -SkipConfirmation -ReleaseNotes "Release ${{ github.ref_name }}"

  deploy-windows:
    runs-on: windows-latest
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
          
      - name: Deploy to Windows
        env:
          PARTNER_CENTER_CLIENT_ID: ${{ secrets.PARTNER_CENTER_CLIENT_ID }}
          PARTNER_CENTER_CLIENT_SECRET: ${{ secrets.PARTNER_CENTER_CLIENT_SECRET }}
          PARTNER_CENTER_TENANT_ID: ${{ secrets.PARTNER_CENTER_TENANT_ID }}
          WINDOWS_CERTIFICATE_PATH: ${{ secrets.WINDOWS_CERTIFICATE_PATH }}
          WINDOWS_CERTIFICATE_PASSWORD: ${{ secrets.WINDOWS_CERTIFICATE_PASSWORD }}
        run: |
          cd unit_converter
          ../scripts/deploy.ps1 -Platform windows -Track retail -SkipConfirmation -ReleaseNotes "Release ${{ github.ref_name }}"

  deploy-ios:
    runs-on: macos-latest
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
          
      - name: Deploy to iOS
        env:
          APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
          APP_STORE_CONNECT_API_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_API_ISSUER_ID }}
          APP_STORE_CONNECT_API_KEY_PATH: ${{ secrets.APP_STORE_CONNECT_API_KEY_PATH }}
        run: |
          cd unit_converter
          ../scripts/deploy.ps1 -Platform ios -Track production -SkipConfirmation -ReleaseNotes "Release ${{ github.ref_name }}"
```

### Jenkins Example

```groovy
pipeline {
    agent any
    stages {
        stage('Deploy Android') {
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
        
        stage('Deploy Windows') {
            steps {
                script {
                    dir('unit_converter') {
                        withCredentials([
                            string(credentialsId: 'PARTNER_CENTER_CLIENT_ID', variable: 'PARTNER_CENTER_CLIENT_ID'),
                            string(credentialsId: 'PARTNER_CENTER_CLIENT_SECRET', variable: 'PARTNER_CENTER_CLIENT_SECRET'),
                            string(credentialsId: 'PARTNER_CENTER_TENANT_ID', variable: 'PARTNER_CENTER_TENANT_ID'),
                            string(credentialsId: 'WINDOWS_CERTIFICATE_PATH', variable: 'WINDOWS_CERTIFICATE_PATH'),
                            string(credentialsId: 'WINDOWS_CERTIFICATE_PASSWORD', variable: 'WINDOWS_CERTIFICATE_PASSWORD')
                        ]) {
                            powershell """
                                ../scripts/deploy.ps1 -Platform windows -Track retail -SkipConfirmation -ReleaseNotes 'Release ${BUILD_NUMBER}'
                            """
                        }
                    }
                }
            }
        }
        
        stage('Deploy iOS') {
            agent { label 'macos' }
            steps {
                script {
                    dir('unit_converter') {
                        withCredentials([
                            string(credentialsId: 'APP_STORE_CONNECT_API_KEY_ID', variable: 'APP_STORE_CONNECT_API_KEY_ID'),
                            string(credentialsId: 'APP_STORE_CONNECT_API_ISSUER_ID', variable: 'APP_STORE_CONNECT_API_ISSUER_ID'),
                            string(credentialsId: 'APP_STORE_CONNECT_API_KEY_PATH', variable: 'APP_STORE_CONNECT_API_KEY_PATH')
                        ]) {
                            sh """
                                ../scripts/deploy.ps1 -Platform ios -Track production -SkipConfirmation -ReleaseNotes 'Release ${BUILD_NUMBER}'
                            """
                        }
                    }
                }
            }
        }
    }
}
```

## 🐛 Troubleshooting

### Issue: Deployment hangs on confirmation

**Solution:** Always use `-SkipConfirmation` flag

### Issue: Platform prerequisites not met

**Solution:** Check platform-specific prerequisites
- Android: Ensure Android SDK, Java, and Fastlane are installed
- Windows: Ensure Visual Studio, Windows SDK, and Flutter Windows support are enabled
- iOS: Ensure macOS, Xcode, and Apple Developer account are set up

### Issue: Credential errors

**Solution:** 
1. Check `.env` file has correct values
2. Verify service account files exist and are valid
3. Ensure you have the correct store permissions
4. Check environment variables are set correctly

### Issue: Build failures

**Solution:**
```bash
cd unit_converter
flutter clean
flutter pub get
flutter build apk --release  # Test Android build
flutter build windows --release  # Test Windows build
flutter build ios --release  # Test iOS build (macOS only)
```

### Issue: iOS deployment on Windows

**Solution:** iOS deployment requires macOS. Use:
- macOS machine for iOS builds
- GitHub Actions with macOS runner
- Cloud-based macOS build service

## 📚 Related Skills

- **[production-deployment/](../production-deployment/)** - Production deployment for Android
- **[windows-store-deployment/](../windows-store-deployment/)** - Windows Store deployment
- **[fastlane-setup/](../fastlane-setup/)** - Fastlane setup and configuration
- **[take-screenshots/](../take-screenshots/)** - Screenshot generation

## 📖 Documentation

- **[UNIFIED_DEPLOYMENT.md](../../../docs/UNIFIED_DEPLOYMENT.md)** - Complete unified deployment guide
- **[DEPLOYMENT.md](../../../docs/DEPLOYMENT.md)** - Android deployment guide
- **[DEPLOYMENT_ROADMAP.md](../../../docs/DEPLOYMENT_ROADMAP.md)** - Deployment roadmap

## 🎉 Summary

The unified deployment workflow provides:

- ✅ Single interface for all platforms
- ✅ Consistent deployment process
- ✅ Non-interactive mode for CI/CD
- ✅ Comprehensive validation
- ✅ Automated screenshot handling
- ✅ Clear error messages
- ✅ Detailed logging

**Key Rule:** When user requests "deploy to production" or "build for production", **ALWAYS** use `-SkipConfirmation` flag to prevent blocking.

---

## Quick Reference

### Deploy to Android (Production)
```powershell
.\scripts\deploy.ps1 -Platform android -Track production -SkipConfirmation
```

### Deploy to Windows (Retail)
```powershell
.\scripts\deploy.ps1 -Platform windows -Track retail -SkipConfirmation
```

### Deploy to iOS (Production)
```powershell
.\scripts\deploy.ps1 -Platform ios -Track production -SkipConfirmation
```

### Deploy with Custom Release Notes
```powershell
.\scripts\deploy.ps1 -Platform android -Track production -ReleaseNotes "New features" -SkipConfirmation
```

### Hotfix Deployment (Skip Screenshots)
```powershell
.\scripts\deploy.ps1 -Platform android -Track beta -ReleaseNotes "Critical bug fix" -SkipScreenshots -SkipConfirmation
```

