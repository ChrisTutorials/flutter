# Deployment Scripts

This directory contains deployment scripts for Flutter applications.

## Unified Deployment Script

### `deploy.ps1` - Unified Multi-Platform Deployment

The unified deployment script provides a consistent interface for deploying Flutter apps to multiple platforms:

- **Android** - Google Play Store
- **Windows** - Microsoft Store
- **iOS** - Apple App Store (macOS only)

### Quick Start

```powershell
# Deploy to Android
cd unit_converter
..\scripts\deploy.ps1 -Platform android -Track internal -ReleaseNotes "Initial release"

# Deploy to Windows
..\scripts\deploy.ps1 -Platform windows -Track retail -ReleaseNotes "Windows release"

# Deploy to iOS (macOS only)
../scripts/deploy.ps1 -Platform ios -Track beta -ReleaseNotes "TestFlight release"
```

### Parameters

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

### Examples

#### Deploy to Android Production

```powershell
.\scripts\deploy.ps1 -Platform android -Track production -ReleaseNotes "New features" -SkipConfirmation
```

#### Deploy to Windows Retail

```powershell
.\scripts\deploy.ps1 -Platform windows -Track retail -ReleaseNotes "Windows release" -SkipConfirmation
```

#### Deploy to iOS Production

```powershell
../scripts/deploy.ps1 -Platform ios -Track production -ReleaseNotes "App Store release" -SkipConfirmation
```

#### Hotfix Deployment (Skip Screenshots)

```powershell
.\scripts\deploy.ps1 -Platform android -Track beta -ReleaseNotes "Critical bug fix" -SkipScreenshots -SkipConfirmation
```

#### Deploy to Specific Project

```powershell
.\scripts\deploy.ps1 -Platform android -Track production -ProjectPath "C:\dev\flutter\unit_converter" -SkipConfirmation
```

## Platform-Specific Scripts

### `generate-store-screenshots.ps1` - Generate Store Screenshots

Script for generating screenshots for app stores.

## Best Practices

### 1. Use Non-Interactive Mode for CI/CD

Always use `-SkipConfirmation` for automated deployments:

```powershell
.\scripts\deploy.ps1 -Platform android -Track production -SkipConfirmation
```

### 2. Test on Internal Track First

```powershell
# Deploy to internal
.\scripts\deploy.ps1 -Platform android -Track internal

# Test thoroughly

# Deploy to production
.\scripts\deploy.ps1 -Platform android -Track production -SkipConfirmation
```

### 3. Use Meaningful Release Notes

```powershell
.\scripts\deploy.ps1 -Platform android -Track production -ReleaseNotes "Added dark mode support and improved currency conversion accuracy" -SkipConfirmation
```

### 4. Keep Credentials Secure

- Never commit `.env` files to git
- Use environment variables in CI/CD
- Rotate credentials regularly

## Prerequisites

### Common Prerequisites

1. **Flutter SDK** - Latest stable version
2. **Ruby & Fastlane** - `gem install fastlane`
3. **PowerShell 7+** - For running scripts

### Platform-Specific Prerequisites

#### Android
- Android SDK with build tools
- Java JDK 11 or higher
- Google Play Developer account
- Production keystore

#### Windows
- Windows 10/11
- Visual Studio 2022 with "Desktop development with C++" workload
- Windows 10/11 SDK
- Microsoft Partner Center account
- Windows code signing certificate

#### iOS
- macOS with Xcode 14 or higher
- Apple Developer Program enrollment ($99/year)
- App Store Connect access
- iOS distribution certificate

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

## CI/CD Integration

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
          ../scripts/deploy.ps1 -Platform android -Track production -SkipConfirmation
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
flutter build apk --release
```

## Documentation

- **[UNIFIED_DEPLOYMENT.md](../docs/UNIFIED_DEPLOYMENT.md)** - Complete unified deployment guide
- **[DEPLOYMENT.md](../docs/DEPLOYMENT.md)** - Android deployment guide
- **[.windsurf/skills/unified-deployment/SKILL.md](../.windsurf/skills/unified-deployment/SKILL.md)** - Unified deployment skill

## Related Skills

- **[unified-deployment/](../.windsurf/skills/unified-deployment/)** - Unified multi-platform deployment
- **[production-deployment/](../.windsurf/skills/production-deployment/)** - Android production deployment
- **[windows-store-deployment/](../.windsurf/skills/windows-store-deployment/)** - Windows Store deployment
- **[ios-store-deployment/](../.windsurf/skills/ios-store-deployment/)** - iOS App Store deployment

