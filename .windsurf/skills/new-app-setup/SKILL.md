# Skill: New App Setup

## 📋 Summary

Create a new Flutter app from the utility app template, configured for multi-platform deployment (Android, Windows, iOS) with testing infrastructure, CI/CD workflows, and reusable patterns.

## 🎯 When to Use

Use this skill when:
- Creating a new Flutter utility app
- Setting up a new project from scratch
- Need a consistent starting point for new apps
- Want to use reusable patterns and infrastructure

## 🚀 Quick Start

### Using the Setup Script (Recommended)

```powershell
# Navigate to the flutter workspace
cd c:\dev\flutter

# Run the setup script
.\scripts\setup-new-app.ps1

# Follow the interactive prompts
```

### Manual Setup

See [Utility App Template](../../docs/app-templates/utility-app.md) for detailed manual setup instructions.

## 📋 Setup Script Workflow

### Step 1: Interactive Configuration

The script will prompt for:

1. **App Name**: Display name of the app
2. **Package Name**: Reverse domain name (e.g., com.example.myapp)
3. **Platforms**: Select platforms (android, windows, ios)
4. **Include Ads**: Enable ad integration (disabled by default)
5. **Include IAP**: Enable in-app purchases (disabled by default)
6. **App Type**: Utility, Game, or Other

### Step 2: Template Copying

The script will:
1. Copy the template to the new location
2. Update package names in all configuration files
3. Update app names in all files
4. Configure platform-specific settings

### Step 3: Fastlane Configuration

The script will:
1. Configure Fastlane for selected platforms
2. Set up Appfile with package information
3. Configure Fastfile with deployment lanes
4. Set up credential placeholders

### Step 4: CI/CD Setup

The script will:
1. Create GitHub Actions workflows
2. Configure test workflow
3. Configure build workflow
4. Configure deployment workflow
5. Set up environment variable placeholders

### Step 5: Documentation Generation

The script will:
1. Create app-specific README
2. Create implementation notes template
3. Create feature roadmap template
4. Set up documentation structure

## 🏗️ Template Structure

The new app will have this structure:

```
my-new-app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   ├── services/                 # Business logic
│   ├── screens/                  # UI screens
│   ├── widgets/                  # Reusable widgets
│   └── utils/                    # Utilities
├── test/
│   ├── unit/                     # Unit tests
│   ├── integration/              # Integration tests
│   └── e2e/                      # End-to-end tests
├── android/
│   └── fastlane/
│       ├── Fastfile              # Pre-configured
│       └── Appfile               # Configured for app
├── windows/
│   └── fastlane/
│       ├── Fastfile              # Pre-configured
│       └── Appfile               # Configured for app
├── ios/
│   └── fastlane/
│       ├── Fastfile              # Pre-configured
│       └── Appfile               # Configured for app
├── .github/
│   └── workflows/
│       ├── test.yml              # Test workflow
│       ├── build.yml             # Build workflow
│       └── deploy.yml            # Deploy workflow
├── pubspec.yaml                  # Dependencies
├── .env.example                  # Environment variables template
├── readme.md                     # App documentation
└── .gitignore                    # Git ignore rules
```

## 🔧 Configuration

### Environment Variables

Copy `.env.example` to `.env` and configure:

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

### App Icons

Replace placeholder icons:
- Android: `android/app/src/main/res/mipmap-*`
- Windows: `windows/runner/resources/`
- iOS: `ios/Runner/Assets.xcassets/`

### App Name

Update app name in:
- `pubspec.yaml`
- `android/app/src/main/AndroidManifest.xml`
- `windows/runner/main.cpp`
- `ios/Runner/Info.plist`

## 🧪 Testing

### Run Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test

# E2E tests
flutter test e2e
```

### Process Cleanup Tests

```bash
# Run process cleanup tests
cd c:\dev\flutter
.\scripts\test-process-cleanup.ps1
```

## 🚀 Deployment

### Local Deployment

```powershell
# Deploy to Android (internal)
.\scripts\deploy.ps1 -Platform android -Track internal

# Deploy to Windows (retail)
.\scripts\deploy.ps1 -Platform windows -Track retail

# Deploy to iOS (beta)
.\scripts\deploy.ps1 -Platform ios -Track beta
```

### CI/CD Deployment

```bash
# Tag a release
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions will automatically:
# 1. Run tests
# 2. Build for all platforms
# 3. Deploy to all platforms
```

## 📦 Dependencies

### Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  common_flutter_utilities:
    path: ../../common

  # State management
  provider: ^6.0.0

  # Storage
  shared_preferences: ^2.0.0
```

### Optional Dependencies

#### Ads
```yaml
dependencies:
  google_mobile_ads: ^3.0.0
  common_flutter_ads:
    path: ../../common
```

#### In-App Purchases
```yaml
dependencies:
  in_app_purchase: ^3.0.0
```

## 🎨 Customization

### Adding Features

1. Create a service for the feature
2. Add unit tests for the service
3. Create a screen that uses the service
4. Add integration tests for the screen
5. Update navigation to include the screen
6. Add screenshots if needed

### Adding Platforms

1. Enable the platform in Flutter
2. Configure Fastlane for the new platform
3. Add CI/CD workflow for the new platform
4. Update deployment script

### Enabling Ads

1. Uncomment ad dependencies in `pubspec.yaml`
2. Configure AdMob in `lib/services/ad_service.dart`
3. Add ad placements in screens
4. Test ads on test devices

### Enabling IAP

1. Uncomment IAP dependencies in `pubspec.yaml`
2. Configure products in store consoles
3. Implement purchase flow in `lib/services/purchase_service.dart`
4. Test purchases

## 🔧 Troubleshooting

### Issue: Setup Script Fails

**Symptoms**: Setup script fails with errors

**Solutions**:
1. Check PowerShell version (requires 7+)
2. Verify template exists
3. Check file permissions
4. Run as administrator if needed

### Issue: Build Fails

**Symptoms**: Flutter build fails

**Solutions**:
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build <platform>
```

### Issue: Fastlane Issues

**Symptoms**: Fastlane commands fail

**Solutions**:
```bash
# Update Fastlane
gem update fastlane

# Check Fastlane version
fastlane --version

# Reinstall Fastlane
gem uninstall fastlane
gem install fastlane
```

## 📚 Cross-References

### Documentation
- [Utility App Template](../../docs/app-templates/utility-app.md) - Complete template documentation
- [Multi-Platform Deployment](../../docs/deployment/multi-platform-guide.md) - Deployment guide
- [Fastlane Patterns](../../docs/deployment/fastlane-patterns.md) - Fastlane configuration
- [CI/CD Patterns](../../docs/deployment/ci-cd-patterns.md) - CI/CD setup

### Scripts
- [setup-new-app.ps1](../../scripts/setup-new-app.ps1) - Setup script (TODO)
- [deploy.ps1](../../scripts/deploy.ps1) - Deployment script
- [test-process-cleanup.ps1](../../scripts/test-process-cleanup.ps1) - Process cleanup tests

### Templates
- [flutter-utility-app/](../../templates/flutter-utility-app/) - App template (TODO)

### Related Skills
- [ci-cd-setup/](./ci-cd-setup/) - CI/CD configuration
- [unified-deployment/](./unified-deployment/) - Multi-platform deployment
- [process-cleanup/](./process-cleanup/) - Process cleanup

## 🎯 AI Assistant Instructions

When this skill is invoked, the AI should:

1. **Gather requirements**:
   - Ask for app name
   - Ask for package name
   - Ask which platforms to include
   - Ask if ads/IAP should be enabled

2. **Set up the app**:
   - Copy template to new location
   - Update all configuration files
   - Configure Fastlane for selected platforms
   - Set up CI/CD workflows
   - Generate documentation

3. **Verify setup**:
   - Check that all files were created
   - Verify configuration is correct
   - Test that the app can be built
   - Run initial tests

4. **Provide guidance**:
   - Explain what was set up
   - Provide next steps for customization
   - Explain how to deploy
   - Provide troubleshooting tips

5. **Document the setup**:
   - Create app-specific README
   - Add implementation notes
   - Record any customizations
   - Update documentation index

## 📝 Checklist

Before setup:
- [ ] Determine app name
- [ ] Determine package name
- [ ] Select platforms to support
- [ ] Decide if ads are needed
- [ ] Decide if IAP is needed
- [ ] Review template documentation

After setup:
- [ ] Verify app builds for all platforms
- [ ] Run all tests
- [ ] Configure environment variables
- [ ] Replace placeholder icons
- [ ] Customize app content
- [ ] Test deployment locally
- [ ] Set up CI/CD secrets
- [ ] Update documentation

## 🔗 Related Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Project Structure](https://docs.flutter.dev/resources/architectural-overview)
- [Best Practices](https://docs.flutter.dev/development/best-practices)

---

*This skill is part of the AI assistant toolkit. See [skills/readme.md](./readme.md) for all available skills.*

