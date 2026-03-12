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

### 4. Responsive Layout (`responsive_layout.dart`)
Responsive design utilities for adaptive layouts.

#### Features
- Screen size detection (mobile, tablet, desktop)
- Grid column calculations
- Responsive padding and spacing
- Card aspect ratio calculations
- Font size scaling
- Orientation detection

### 5. Theme Controller (`theme_controller.dart`)
Theme management with persistence support.

#### Features
- Theme mode switching (light, dark, system)
- SharedPreferences persistence
- Current theme detection
- Simple, extensible API

### 6. Premium Service (`premium_service.dart`)
Premium status management for apps with paid features.

#### Features
- Premium status persistence
- Simple async API
- Enable/disable/clear operations
- No external dependencies
- Integration with Google Play Billing via PurchaseService

### 7. Purchase Service (`purchase_service.dart`)
Google Play Billing integration for one-time purchases.

#### Features
- One-time in-app purchases (non-consumable)
- Purchase verification
- Purchase restoration across devices
- Automatic premium status updates
- Integration with AdService for ad removal
- Callbacks for purchase success/error/pending

### 8. Number Formatter (`number_formatter.dart`)
Number formatting utilities for display.

#### Features
- Compact notation (1K, 1M, 1B)
- Precision formatting
- Currency formatting
- Percentage formatting
- Thousand separators
- Scientific notation
- Truncation and rounding

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
  bannerId: 'ca-app-pub-your-banner-id-here',
  interstitialId: 'ca-app-pub-your-interstitial-id-here',
  appOpenId: 'ca-app-pub-your-app-open-id-here',
);
// IMPORTANT: Replace the above placeholder IDs with your actual AdMob ad unit IDs
// from your AdMob account before building for release.
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

## Responsive Layout Usage

### Basic Responsive Detection

```dart
import 'package:common_flutter_utilities/responsive_layout.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout.isMobile(context)
          ? MobileLayout()
          : DesktopLayout(),
    );
  }
}
```

### Grid Layouts

```dart
// Responsive grid
Widget buildGrid(BuildContext context) {
  final columns = ResponsiveLayout.getGridColumns(context);
  final spacing = ResponsiveLayout.getCardSpacing(context);

  return GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
    ),
    itemBuilder: (context, index) => CardWidget(),
  );
}
```

### Responsive Padding and Spacing

```dart
// Responsive padding
Widget buildContent(BuildContext context) {
  return Padding(
    padding: ResponsiveLayout.getCardPadding(context),
    child: Column(
      children: [
        // Content with responsive section spacing
        SizedBox(height: ResponsiveLayout.getSectionSpacing(context)),
        Section1(),
        SizedBox(height: ResponsiveLayout.getSectionSpacing(context)),
        Section2(),
      ],
    ),
  );
}
```

### Card Aspect Ratio

```dart
// Responsive card with proper aspect ratio
Widget buildCard(BuildContext context) {
  final aspectRatio = ResponsiveLayout.getCardAspectRatio(
    context,
    targetHeight: 200,
  );

  return AspectRatio(
    aspectRatio: aspectRatio,
    child: Card(
      child: Center(child: Text('Responsive Card')),
    ),
  );
}
```

### Font Scaling

```dart
// Scale font size based on screen
Text buildResponsiveText(BuildContext context) {
  final multiplier = ResponsiveLayout.getFontSizeMultiplier(context);
  return Text(
    'Hello',
    style: TextStyle(fontSize: 16 * multiplier),
  );
}
```

## Theme Controller Usage

### Basic Theme Management

```dart
import 'package:common_flutter_utilities/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeController = ThemeController();
  await themeController.load();

  runApp(MyApp(themeController: themeController));
}

class MyApp extends StatelessWidget {
  final ThemeController themeController;

  const MyApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, child) {
        return MaterialApp(
          themeMode: themeController.themeMode,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          home: HomeScreen(themeController: themeController),
        );
      },
    );
  }
}
```

### Theme Switching

```dart
class SettingsScreen extends StatelessWidget {
  final ThemeController themeController;

  const SettingsScreen({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text('Theme Mode'),
          trailing: DropdownButton<AppThemeMode>(
            value: themeController.themeModeSetting,
            items: AppThemeMode.values.map((mode) {
              return DropdownMenuItem(
                value: mode,
                child: Text(themeModeLabel(mode)),
              );
            }).toList(),
            onChanged: (mode) {
              if (mode != null) {
                themeController.updateThemeMode(mode);
              }
            },
          ),
        ),
      ],
    );
  }
}
```

### Check Current Theme

```dart
Widget build(BuildContext context) {
  final isDark = ThemeController().isDarkMode(context);

  return Container(
    color: isDark ? Colors.black : Colors.white,
    child: Text(isDark ? 'Dark Mode' : 'Light Mode'),
  );
}
```

## Premium Service Usage

### Basic Premium Check

```dart
import 'package:common_flutter_utilities/premium_service.dart';

class PremiumFeatures extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: PremiumService.isPremium(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        final isPremium = snapshot.data ?? false;

        if (isPremium) {
          return PremiumContent();
        } else {
          return FreeContent();
        }
      },
    );
  }
}
```

### Enable Premium

```dart
Future<void> purchasePremium() async {
  // After successful purchase
  await PremiumService.enablePremium();
  // Refresh UI
}
```

### Disable Premium

```dart
Future<void> cancelPremium() async {
  // After cancellation
  await PremiumService.disablePremium();
  // Refresh UI
}
```

### Integration with Ad Service

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check premium status
  final isPremium = await PremiumService.isPremium();

  // Configure ad service with premium check
  AdService.configure(
    premiumCheck: () async {
      return await PremiumService.isPremium();
    },
  );

  await AdService.initialize();

  runApp(MyApp());
}
```

## Purchase Service Usage

### Basic Setup

```dart
import 'package:common_flutter_ads/purchase_service.dart';
import 'package:common_flutter_ads/premium_service.dart';
import 'package:common_flutter_ads/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize purchase service
  await PurchaseService.initialize(
    adRemovalProductId: 'ad_removal_one_time', // Must match Google Play Console
    onPurchaseSuccess: (message) {
      // Handle successful purchase
      print('Purchase successful: $message');
      // Refresh UI or show success message
    },
    onPurchaseError: (error) {
      // Handle purchase error
      print('Purchase error: $error');
      // Show error message to user
    },
    onPurchasePending: () {
      // Handle pending purchase (e.g., waiting for approval)
      print('Purchase pending');
    },
  );

  // Initialize ad service (will automatically check premium status)
  await AdService.initialize();

  runApp(MyApp());
}
```

**IMPORTANT**: Before you can use in-app purchases, you must add the BILLING permission to your Android manifest. Add this to your `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Billing permission for in-app purchases -->
    <uses-permission android:name="com.android.vending.BILLING"/>

    <application>
        <!-- Your application configuration -->
    </application>
</manifest>
```

Without this permission, Google Play Console will not allow you to create in-app products. See [GOOGLE_PLAY_CONSOLE_SETUP.md](docs/GOOGLE_PLAY_CONSOLE_SETUP.md) for complete setup instructions.

### Check Purchase Status

```dart
// Check if user has purchased ad removal
final hasPurchased = await PurchaseService.hasPurchasedAdRemoval();

// Or use PremiumService
final isPremium = await PremiumService.isPremium();
```

### Purchase Ad Removal

```dart
// Purchase ad removal
final success = await PurchaseService.purchaseAdRemoval();

// Or use PremiumService convenience method
final success = await PremiumService.purchaseAdRemoval();

if (success) {
  // Purchase initiated successfully
  // Wait for callback to confirm completion
} else {
  // Purchase failed to initiate
}
```

### Restore Purchases

```dart
// Restore previous purchases (call on app startup)
await PurchaseService.restorePurchases();

// Or use PremiumService convenience method
await PremiumService.restorePurchases();
```

### Get Product Price

```dart
// Get the price of ad removal
final price = PurchaseService.adRemovalPrice;

// Or use PremiumService convenience method
final price = PremiumService.getAdRemovalPrice();

// Check if ad removal is available
final isAvailable = PurchaseService.isAdRemovalAvailable;
```

### Complete Purchase UI Example

```dart
import 'package:flutter/material.dart';
import 'package:common_flutter_ads/premium_service.dart';

class AdRemovalPurchaseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Remove Ads')),
      body: FutureBuilder<bool>(
        future: PremiumService.isPremium(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final isPremium = snapshot.data ?? false;

          if (isPremium) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 80, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Ads Removed!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Thank you for your support!'),
                ],
              ),
            );
          }

          final price = PremiumService.getAdRemovalPrice();
          final isAvailable = PremiumService.isAdRemovalAvailable();

          return Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block, size: 80, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Remove Ads Forever',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Enjoy an ad-free experience with a one-time purchase.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 24),
                  if (isAvailable && price != null)
                    ElevatedButton(
                      onPressed: () async {
                        final success = await PremiumService.purchaseAdRemoval();
                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Purchase failed')),
                          );
                        }
                      },
                      child: Text('Purchase for $price'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                    )
                  else if (!isAvailable)
                    Text(
                      'Purchases not available',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    CircularProgressIndicator(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### Integration with Ad Service

The AdService automatically checks premium status via PremiumService. When a user purchases ad removal:

1. The purchase is saved locally
2. The AdService detects the premium status
3. Ads are automatically disabled
4. The premium status persists across app restarts

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize purchase service first
  await PurchaseService.initialize(
    adRemovalProductId: 'ad_removal_one_time',
  );

  // AdService will automatically check premium status
  await AdService.initialize();

  runApp(MyApp());
}
```

### Google Play Console Setup

To use the purchase service, you need to set up your in-app product in Google Play Console. See [GOOGLE_PLAY_CONSOLE_SETUP.md](docs/GOOGLE_PLAY_CONSOLE_SETUP.md) for detailed instructions.

## Number Formatter Usage

### Basic Formatting

```dart
import 'package:common_flutter_utilities/number_formatter.dart';

void main() {
  // Compact notation
  print(NumberFormatter.formatCompact(1500)); // 1.5K
  print(NumberFormatter.formatCompact(1500000)); // 1.5M

  // Precise formatting
  print(NumberFormatter.formatPrecise(42.0)); // 42
  print(NumberFormatter.formatPrecise(42.123456789)); // 42.12345679

  // Number formatting
  print(NumberFormatter.formatNumber(100)); // 100
  print(NumberFormatter.formatNumber(100.5)); // 100.5
}
```

### Currency Formatting

```dart
// Currency
print(NumberFormatter.formatCurrency(1234.56)); // $1,234.56
print(NumberFormatter.formatCurrency(1234.56, currencyCode: 'EUR')); // €1,234.56
print(NumberFormatter.formatCurrency(1234.56, symbol: '£')); // £1,234.56
```

### Percentage Formatting

```dart
// Percentage
print(NumberFormatter.formatPercentage(0.1234)); // 12.3%
print(NumberFormatter.formatPercentage(0.5)); // 50%
```

### Thousand Separators

```dart
// With thousands
print(NumberFormatter.formatWithThousands(1000000)); // 1,000,000
print(NumberFormatter.formatWithThousands(1234.56, decimalPlaces: 2)); // 1,234.56
```

### Truncation and Rounding

```dart
// Truncate (no rounding)
print(NumberFormatter.truncate(3.14159, decimalPlaces: 2)); // 3.14

// Round
print(NumberFormatter.round(3.14159, decimalPlaces: 2)); // 3.14
print(NumberFormatter.round(3.14999, decimalPlaces: 2)); // 3.15
```

## Required Dependencies

Make sure your app includes these dependencies:

```yaml
dependencies:
  google_mobile_ads: ^7.0.0
  shared_preferences: ^2.3.2
  intl: ^0.19.0
  in_app_purchase: ^3.1.13
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
