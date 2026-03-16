# Flutter Utility App Template

## Overview

This template provides a starting point for building utility apps (calculators, converters, tools) that need to be deployed across Android, Windows, and iOS platforms.

## 🎯 Template Features

### Out of the Box
- ✅ Multi-platform support (Android, Windows, iOS)
- ✅ Pre-configured Fastlane for all platforms
- ✅ Process cleanup integrated
- ✅ Common utilities imported
- ✅ Testing infrastructure set up
- ✅ CI/CD workflows ready
- ✅ Ad integration ready (disabled by default)
- ✅ IAP integration ready (disabled by default)
- ✅ Premium gating template
- ✅ Golden screenshot testing ready

### Architecture
- Clean architecture with clear separation of concerns
- Service layer for business logic
- State management ready
- Responsive design
- Dark/light theme support

## 📁 Template Structure

```
flutter-utility-app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   ├── services/                 # Business logic
│   │   ├── app_service.dart      # Main app service
│   │   ├── settings_service.dart # Settings management
│   │   └── analytics_service.dart # Analytics (optional)
│   ├── screens/                  # UI screens
│   │   ├── home_screen.dart      # Home screen
│   │   ├── settings_screen.dart  # Settings screen
│   │   └── premium_screen.dart   # Premium upgrade screen
│   ├── widgets/                  # Reusable widgets
│   │   ├── app_bar.dart          # Custom app bar
│   │   └── premium_banner.dart   # Premium upgrade banner
│   └── utils/                    # Utilities
│       └── constants.dart        # App constants
├── test/
│   ├── unit/                     # Unit tests
│   ├── integration/              # Integration tests
│   └── e2e/                      # End-to-end tests
├── android/
│   ├── app/
│   │   └── src/main/
│   │       └── AndroidManifest.xml
│   └── fastlane/
│       ├── Fastfile              # Pre-configured Fastlane
│       └── Appfile               # App configuration
├── windows/
│   └── fastlane/
│       ├── Fastfile              # Pre-configured Fastlane
│       └── Appfile               # App configuration
├── ios/
│   └── fastlane/
│       ├── Fastfile              # Pre-configured Fastlane
│       └── Appfile               # App configuration
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

## 🚀 Getting Started

### Using the Setup Script

The easiest way to create a new app from the template is to use the setup script:

```powershell
# Navigate to the flutter workspace
cd c:\dev\flutter

# Run the setup script
.\scripts\setup-new-app.ps1

# Follow the prompts:
# - App name: My Utility App
# - Package name: com.example.myapp
# - Platforms: android, windows, ios
# - Include ads: no
# - Include IAP: no
```

### Manual Setup

If you prefer to set up manually:

1. **Copy the template**
   ```bash
   cp -r templates/flutter-utility-app my-new-app
   cd my-new-app
   ```

2. **Update pubspec.yaml**
   ```yaml
   name: my_new_app
   description: A new utility app
   version: 1.0.0+1
   ```

3. **Update package names**
   - Android: Update `android/app/build.gradle.kts`
   - Windows: Update `windows/CMakeLists.txt`
   - iOS: Update `ios/Runner/Info.plist`

4. **Update app icons**
   - Replace placeholder icons in `android/app/src/main/res/`
   - Replace placeholder icons in `windows/runner/resources/`
   - Replace placeholder icons in `ios/Runner/Assets.xcassets/`

5. **Configure Fastlane**
   - Android: Update `android/fastlane/Appfile`
   - Windows: Update `windows/fastlane/Appfile`
   - iOS: Update `ios/fastlane/Appfile`

6. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your values
   ```

7. **Initialize Git**
   ```bash
   git init
   git add .
   git commit -m "Initial commit from template"
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

  # UI
  cupertino_icons: ^1.0.0
```

### Development Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

  # Testing
  mockito: ^5.0.0
  integration_test:
    sdk: flutter

  # Screenshots
  flutter_test: any
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

## 🏗️ Architecture Patterns

### Service Layer

Services encapsulate business logic and can be easily tested:

```dart
// lib/services/app_service.dart
class AppService {
  final SettingsService _settingsService;

  AppService(this._settingsService);

  Future<void> initialize() async {
    await _settingsService.initialize();
  }

  Future<bool> isPremium() async {
    return await _settingsService.isPremium();
  }

  Future<void> setPremium(bool value) async {
    await _settingsService.setPremium(value);
  }
}
```

### Premium Gating

Use the premium service to gate features:

```dart
// lib/screens/premium_screen.dart
class PremiumScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: PremiumService.isPremium(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return PremiumFeaturesWidget();
        } else {
          return UpgradePromptWidget();
        }
      },
    );
  }
}
```

### Responsive Design

Use layout builder for responsive design:

```dart
// lib/widgets/responsive_layout.dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget desktop;

  const ResponsiveLayout({
    required this.mobile,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return desktop;
        }
        return mobile;
      },
    );
  }
}
```

## 🧪 Testing

### Unit Tests

```dart
// test/unit/services/app_service_test.dart
void main() {
  group('AppService', () {
    test('should initialize settings', () async {
      final settingsService = MockSettingsService();
      final appService = AppService(settingsService);

      await appService.initialize();

      verify(settingsService.initialize()).called(1);
    });
  });
}
```

### Integration Tests

```dart
// test/integration/app_test.dart
void main() {
  testWidgets('app should launch', (tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Welcome'), findsOneWidget);
  });
}
```

### Golden Screenshots

```dart
// test/golden_screenshots/home_screen_test.dart
void main() {
  testWidgets('home screen golden', (tester) async {
    await tester.pumpWidget(MyApp());
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home_screen.png'),
    );
  });
}
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

Deployment is automated via GitHub Actions:

```bash
# Tag a release
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions will:
# 1. Run tests
# 2. Build for all platforms
# 3. Deploy to all platforms
```

## 🎨 Customization

### Adding Features

1. **Create a service** for the feature
2. **Add unit tests** for the service
3. **Create a screen** that uses the service
4. **Add integration tests** for the screen
5. **Update navigation** to include the screen
6. **Add screenshots** if needed

### Adding Platforms

1. Enable the platform in Flutter:
   ```bash
   flutter config --enable-web
   flutter config --enable-macos-desktop
   ```

2. Configure Fastlane for the new platform
3. Add CI/CD workflow for the new platform
4. Update deployment script

### Adding Ads

1. Uncomment ad dependencies in `pubspec.yaml`
2. Configure AdMob in `lib/services/ad_service.dart`
3. Add ad placements in screens
4. Test ads on test devices

### Adding IAP

1. Uncomment IAP dependencies in `pubspec.yaml`
2. Configure products in store consoles
3. Implement purchase flow in `lib/services/purchase_service.dart`
4. Test purchases

## 📊 Best Practices

### Code Organization
- Keep screens focused on UI
- Put business logic in services
- Use widgets for reusable UI components
- Keep models simple

### Testing
- Write unit tests for services
- Write integration tests for screens
- Write E2E tests for critical flows
- Maintain good test coverage

### Deployment
- Test on internal track first
- Use semantic versioning
- Write clear release notes
- Monitor after deployment

### Documentation
- Document app-specific decisions
- Keep README up to date
- Add comments for complex logic
- Update deployment docs as needed

## 🔧 Troubleshooting

### Build Fails
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build <platform>
```

### Fastlane Issues
```bash
# Update Fastlane
gem update fastlane

# Check Fastlane version
fastlane --version
```

### Process Cleanup Issues
```bash
# Run process cleanup tests
.\scripts\test-process-cleanup.ps1 -ShowDetails
```

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Multi-Platform Deployment Guide](deployment/multi-platform-guide.md)
- [Fastlane Patterns](deployment/fastlane-patterns.md)
- [CI/CD Patterns](deployment/ci-cd-patterns.md)
- [Testing Strategies](testing/coverage-strategies.md)

## 🎯 Next Steps

1. Customize the app for your needs
2. Add your features
3. Write tests
4. Test on all platforms
5. Deploy to internal testing
6. Gather feedback
7. Iterate and improve

---

*This template is maintained as part of the reusable documentation. See [index.md](index.md) for more resources.*

