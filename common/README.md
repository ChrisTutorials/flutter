# Common Flutter Utilities

A collection of reusable, high-value utilities for Flutter applications.

## Packages

### 1. Ad Service (`ad_service.dart`, `ad_config.dart`)
A reusable, user-friendly ad service for Flutter applications with built-in user experience protection.

#### Features
- **Multiple Ad Types**: Banner, Interstitial, and App Open ads
- **User Experience Protection**: Frequency capping, time limits, and session restrictions
- **First-Time User Protection**: No ads until users experience value
- **Premium User Support**: Disable ads for paying customers
- **Configurable**: Easy setup for different app types
- **Reusable**: Use across multiple Flutter projects

### 2. Platform Utils (`platform_utils.dart`)
Platform detection utilities for Flutter applications.

#### Features
- Mobile platform detection (Android, iOS)
- Desktop platform detection (Windows, macOS, Linux)
- Web platform detection
- Simple, static API

### 3. Navigation Utils (`navigation_utils.dart`)
Navigation helper utilities to reduce boilerplate code.

#### Features
- Common navigation patterns (push, pop, pushReplacement)
- Callback support for screen dismissal
- Fullscreen dialog support
- Type-safe navigation

## Quick Start

### 1. Add Dependency

Add this to your app's `pubspec.yaml`:

```yaml
dependencies:
  common_flutter_utilities:
    path: ../common
```

### 2. Basic Setup

```dart
import 'package:common_flutter_utilities/ad_service.dart';
import 'package:common_flutter_utilities/ad_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure for your app type
  AdConfig.configureForUtilityApp(); // or other presets
  
  // Set your ad unit IDs (use test IDs for development)
  AdUnitIds.test.apply(); // Test IDs
  // Or configure production IDs:
  // AdUnitIds.configureProduction(
  //   bannerId: 'your-banner-id',
  //   interstitialId: 'your-interstitial-id', 
  //   appOpenId: 'your-app-open-id',
  // );
  
  // Optional: Set premium user check
  AdService.configure(
    premiumCheck: () async {
      // Return true if user is premium
      return await PremiumService.isPremium();
    },
  );
  
  // Initialize the ad service
  await AdService.initialize();
  
  runApp(MyApp());
}
```

### 3. App Integration

In your main screen or app entry point:

```dart
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    // Reset session counters
    AdService.resetSessionCounters();
    
    // Show app open ad (once per day)
    AdService.showAppOpenAdIfAvailable();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Your app content
          Expanded(child: YourAppContent()),
          
          // Banner ad at bottom
          if (AdService.adsEnabled)
            Container(
              height: 50,
              child: AdWidget(ad: AdService.createBannerAd()),
            ),
        ],
      ),
    );
  }
}
```

### 4. Track Conversions

After users complete actions in your app:

```dart
void onConversionCompleted() {
  // Track the conversion - may show interstitial if conditions are met
  AdService.trackConversion();
  
  // Show result or navigate to next screen
  showConversionResult();
}
```

## Configuration Presets

Choose the right preset for your app type:

### Utility Apps (Converters, Calculators, Tools)
```dart
AdConfig.configureForUtilityApp();
```
- Conservative ad placement
- 10 conversions before first ad
- 20 conversions between ads
- 3 minutes minimum between ads
- 3 ads per session max

### Casual Games
```dart
AdConfig.configureForCasualGame();
```
- More frequent ads
- 3 conversions before first ad
- 10 conversions between ads
- 2 minutes minimum between ads
- 5 ads per session max

### Content Apps (News, Reading)
```dart
AdConfig.configureForContentApp();
```
- Balanced approach
- 5 conversions before first ad
- 15 conversions between ads
- 2.5 minutes minimum between ads
- 4 ads per session max

### Productivity Apps
```dart
AdConfig.configureForProductivityApp();
```
- Very conservative
- 15 conversions before first ad
- 25 conversions between ads
- 5 minutes minimum between ads
- 2 ads per session max

## Advanced Configuration

### Custom Settings
```dart
AdConfig.configureCustom(
  firstAdAfterConversions: 8,
  conversionsBetweenAds: 15,
  minimumSecondsBetweenAds: 120,
  maxAdsPerSession: 4,
);
```

### Premium User Support
```dart
AdService.configure(
  premiumCheck: () async {
    // Check if user has purchased premium version
    return await UserService.isPremium();
  },
);

// Update premium status when user purchases
await AdService.updatePremiumStatus(true);
```

## Ad Unit IDs

### Test IDs (Development)
```dart
AdUnitIds.test.apply();
```

### Production IDs
```dart
AdUnitIds.configureProduction(
  bannerId: 'ca-app-pub-xxxxxxxxxx/yyyyyyyyyy',
  interstitialId: 'ca-app-pub-xxxxxxxxxx/yyyyyyyyyy',
  appOpenId: 'ca-app-pub-xxxxxxxxxx/yyyyyyyyyy',
);
```

## Best Practices

### DO ✅
- Show interstitials AFTER task completion
- Use conservative frequency for utility apps
- Test with test ads first
- Monitor user reviews and retention
- Consider offering a premium version

### DON'T ❌
- Show ads during user interactions
- Use aggressive frequency without testing
- Ignore user feedback about ads
- Forget to set production IDs before release

## Migration from Existing AdMob

If you have an existing AdMob implementation:

1. Replace your AdMob service with `AdService`
2. Use `AdConfig` to match your current settings
3. Update ad unit ID configuration
4. Test thoroughly before release

## Debugging

Enable debug logging to monitor ad behavior:

```dart
// Check current state
print('Ads enabled: ${AdService.adsEnabled}');
print('Conversion count: ${AdService.conversionCount}');
print('Session interstitials: ${AdService.sessionInterstitials}');
print('Conversions since last ad: ${AdService.conversionsSinceLastAd}');
```

## Required Dependencies

Make sure your app includes these dependencies:

```yaml
dependencies:
  google_mobile_ads: ^7.0.0
  shared_preferences: ^2.3.2
```

## Platform Utils Usage

### Basic Platform Detection

```dart
import 'package:common_flutter_utilities/platform_utils.dart';

void checkPlatform() {
  if (PlatformUtils.isMobile) {
    print('Running on mobile device');
  }

  if (PlatformUtils.isAndroid) {
    print('Android specific code');
  }

  if (PlatformUtils.isIOS) {
    print('iOS specific code');
  }

  if (PlatformUtils.isDesktop) {
    print('Running on desktop');
  }

  if (PlatformUtils.isWeb) {
    print('Running on web');
  }
}
```

### Common Use Cases

```dart
// Show mobile-specific features
Widget buildPlatformSpecificWidget() {
  if (PlatformUtils.isMobile) {
    return MobileWidget();
  }
  return DesktopWidget();
}

// Platform-specific behavior
void performAction() {
  if (PlatformUtils.isAndroid) {
    // Android-specific implementation
  } else if (PlatformUtils.isIOS) {
    // iOS-specific implementation
  } else {
    // Fallback for other platforms
  }
}
```

## Navigation Utils Usage

### Basic Navigation

```dart
import 'package:common_flutter_utilities/navigation_utils.dart';

// Push a new screen
void navigateToDetail(BuildContext context) {
  NavigationUtils.pushScreen(
    context,
    DetailScreen(),
  );
}

// Push a fullscreen dialog
void showSettings(BuildContext context) {
  NavigationUtils.pushScreen(
    context,
    SettingsScreen(),
    fullscreenDialog: true,
  );
}

// Pop current screen
void goBack(BuildContext context) {
  NavigationUtils.pop(context);
}
```

### Advanced Navigation

```dart
// Push and wait for result
Future<void> selectItem(BuildContext context) async {
  final result = await NavigationUtils.pushAndAwait<String>(
    context,
    SelectionScreen(),
  );
  print('Selected: $result');
}

// Push with callback
void navigateWithCallback(BuildContext context) {
  NavigationUtils.pushWithCallback(
    context,
    DetailScreen(),
    () {
      // This runs when the screen is popped
      print('Detail screen closed');
      refreshData();
    },
  );
}

// Push replacement (e.g., for login flow)
void navigateToHome(BuildContext context) {
  NavigationUtils.pushReplacement(
    context,
    HomeScreen(),
  );
}

// Push and remove all previous screens (e.g., after logout)
void navigateToLogin(BuildContext context) {
  NavigationUtils.pushAndRemoveUntil(
    context,
    LoginScreen(),
  );
}
```

## License

This package is available for use in your Flutter projects.
