---
description: Unified multi-platform deployment workflow for Android, Windows, and iOS
---

# Unified Multi-Platform Deployment Workflow

This workflow provides a unified process for deploying Flutter apps to Android, Windows, and iOS platforms.

## Prerequisites

1. **Flutter SDK** - Latest stable version with required platform support
2. **Ruby & Fastlane** - `gem install fastlane`
3. **Platform-specific credentials** - Set up in `.env` file
4. **PowerShell 7+** - For running deployment scripts

## Platform-Specific Setup

### Android Setup
- Google Play Developer account
- Google Play Console service account credentials
- Production keystore for app signing
- Fastlane configured in `android/fastlane/`

### Windows Setup
- Windows 10/11 with Visual Studio 2022
- Windows 10/11 SDK
- Microsoft Partner Center account
- Windows code signing certificate
- Fastlane configured in `windows/fastlane/`

### iOS Setup (macOS only)
- macOS with Xcode 14 or higher
- Apple Developer Program enrollment ($99/year)
- App Store Connect access
- iOS distribution certificate and provisioning profiles
- Fastlane configured in `ios/fastlane/`

## Configuration

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

## Deployment Steps

### 1. Prepare Release

```powershell
cd unit_converter

# Update version in pubspec.yaml
# Format: version: x.y.z+buildNumber
```

### 2. Generate Screenshots (if needed)

```bash
# Android screenshots
flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens

# iOS screenshots (macOS only)
cd ios
bundle exec fastlane capture_screenshots
```

### 3. Deploy to Platform

#### Android Deployment

```powershell
# Deploy to internal testing
..\scripts\deploy.ps1 -Platform android -Track internal -ReleaseNotes "Internal test"

# Deploy to production
..\scripts\deploy.ps1 -Platform android -Track production -ReleaseNotes "Production release" -SkipConfirmation
```

#### Windows Deployment

```powershell
# Deploy to retail
..\scripts\deploy.ps1 -Platform windows -Track retail -ReleaseNotes "Windows release" -SkipConfirmation
```

#### iOS Deployment (macOS only)

```powershell
# Deploy to TestFlight
../scripts/deploy.ps1 -Platform ios -Track beta -ReleaseNotes "TestFlight release" -SkipConfirmation

# Deploy to production
../scripts/deploy.ps1 -Platform ios -Track production -ReleaseNotes "App Store release" -SkipConfirmation
```

### 4. Monitor Deployment

- **Android**: Monitor in Google Play Console
- **Windows**: Monitor in Microsoft Partner Center
- **iOS**: Monitor in App Store Connect

## Deployment Tracks

### Android
- **Internal** - For your own testing (up to 100 testers)
- **Alpha** - For a small group of trusted testers
- **Beta** - For wider testing before production
- **Production** - For all users

### Windows
- **Internal** - For internal testing
- **Retail** - Public release

### iOS
- **Beta** - TestFlight for beta testing
- **Production** - App Store public release

## Best Practices

1. **Always test on internal track first** - Deploy to internal testing before alpha/beta/production
2. **Use non-interactive mode for CI/CD** - Always use `-SkipConfirmation` flag for automated deployments
3. **Write meaningful release notes** - Be specific about what changed
4. **Keep credentials secure** - Never commit `.env` files to git
5. **Monitor after deployment** - Check store console for crashes and issues
6. **Verify process cleanup** - Ensure deployment scripts clean up zombie processes automatically

## Process Cleanup

The deployment script automatically cleans up zombie processes before and after deployment:

- **Dart/Flutter processes**: Any dangling dart or flutter processes are terminated
- **Ruby/Fastlane processes**: Any hanging ruby or fastlane processes are terminated
- **Automatic cleanup**: Cleanup runs at the start, end, and on error

### Testing Process Cleanup

To verify that processes are cleaned up properly, run the process cleanup test suite:

```powershell
# Run all process cleanup tests
.\scripts\test-process-cleanup.ps1

# Run with detailed output
.\scripts\test-process-cleanup.ps1 -ShowDetails
```

The test suite verifies that:
- Flutter clean cleans up processes
- Flutter pub get cleans up processes
- Flutter build cleans up processes
- Flutter analyze cleans up processes

### CI/CD Process Cleanup Tests

The GitHub Actions workflow includes automated process cleanup tests that run on every push and pull request. See `.github/workflows/test-process-cleanup.yml` for details.

To run the CI/CD tests locally:

```powershell
# Simulate the CI/CD test workflow
.\scripts\test-process-cleanup.ps1 -ShowDetails
```

## CI/CD Integration

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
          ../scripts/deploy.ps1 -Platform android -Track production -SkipConfirmation

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
          ../scripts/deploy.ps1 -Platform windows -Track retail -SkipConfirmation

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
          ../scripts/deploy.ps1 -Platform ios -Track production -SkipConfirmation
```

## Troubleshooting

### Fastlane Not Found
```bash
gem install fastlane
```

### Credential Issues
1. Check `.env` file has correct values
2. Verify service account files exist and are valid
3. Ensure you have the correct store permissions

### Build Failures
```bash
cd unit_converter
flutter clean
flutter pub get
flutter build apk --release  # Test Android build
flutter build windows --release  # Test Windows build
flutter build ios --release  # Test iOS build (macOS only)
```

### iOS Deployment on Windows
iOS deployment requires macOS. Use:
- macOS machine for iOS builds
- GitHub Actions with macOS runner
- Cloud-based macOS build service

## Documentation

- [docs/UNIFIED_DEPLOYMENT.md](../../docs/UNIFIED_DEPLOYMENT.md) - Complete unified deployment guide
- [docs/DEPLOYMENT.md](../../docs/DEPLOYMENT.md) - Android deployment guide
- [scripts/readme.md](../../scripts/readme.md) - Deployment scripts documentation
- [.windsurf/skills/unified-deployment/SKILL.md](../skills/unified-deployment/SKILL.md) - Unified deployment skill

## Related Skills

- [unified-deployment/](../skills/unified-deployment/) - Unified multi-platform deployment
- [production-deployment/](../skills/production-deployment/) - Android production deployment
- [windows-store-deployment/](../skills/windows-store-deployment/) - Windows Store deployment
- [ios-store-deployment/](../skills/ios-store-deployment/) - iOS App Store deployment

