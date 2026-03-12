# Common Utilities Migration Guide

This guide explains how to use the extracted common utilities in your next Flutter app.

## What Was Extracted

### 1. PlatformUtils
**Source**: `unit_converter/lib/utils/platform_utils.dart`
**Location**: `common/lib/platform_utils.dart`

A universal platform detection utility that works across mobile, desktop, and web platforms.

### 2. NavigationUtils
**Source**: `unit_converter/lib/utils/navigation_utils.dart`
**Location**: `common/lib/navigation_utils.dart`

A set of navigation helpers that reduce boilerplate code for common navigation patterns.

### 3. ResponsiveLayout
**Source**: `unit_converter/lib/utils/responsive_layout.dart` (generalized)
**Location**: `common/lib/responsive_layout.dart`

Comprehensive responsive design utilities for adaptive layouts across different screen sizes.

### 4. ThemeController
**Source**: `unit_converter/lib/services/theme_service.dart` (generalized)
**Location**: `common/lib/theme_controller.dart`

Theme management with persistence support, without app-specific color schemes.

### 5. PremiumService
**Source**: `unit_converter/lib/services/premium_service.dart`
**Location**: `common/lib/premium_service.dart`

Simple premium status management for apps with paid features.

### 6. NumberFormatter
**Source**: `unit_converter/lib/utils/number_formatter.dart` (enhanced)
**Location**: `common/lib/number_formatter.dart`

Comprehensive number formatting utilities for display.

## How to Use in Your Next App

### Step 1: Add Dependency

Add the common package to your app's `pubspec.yaml`:

```yaml
dependencies:
  common_flutter_utilities:
    path: ../common
```

### Step 2: Import and Use

#### PlatformUtils Example

```dart
import 'package:common_flutter_utilities/platform_utils.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Platform-specific UI
    if (PlatformUtils.isMobile) {
      return MobileLayout();
    }
    return DesktopLayout();
  }
}

// Platform-specific behavior
void performAction() {
  if (PlatformUtils.isAndroid) {
    // Android-specific code
  } else if (PlatformUtils.isIOS) {
    // iOS-specific code
  } else if (PlatformUtils.isWeb) {
    // Web-specific code
  } else {
    // Desktop fallback
  }
}
```

#### NavigationUtils Example

```dart
import 'package:common_flutter_utilities/navigation_utils.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Simple navigation
            NavigationUtils.pushScreen(
              context,
              DetailScreen(),
            );
          },
          child: Text('Go to Details'),
        ),
      ),
    );
  }
}

// Advanced usage with callback
void navigateWithRefresh(BuildContext context) {
  NavigationUtils.pushWithCallback(
    context,
    EditScreen(),
    () {
      // This runs when EditScreen is popped
      refreshData();
    },
  );
}

// Navigation with result
Future<void> selectItem(BuildContext context) async {
  final result = await NavigationUtils.pushAndAwait<String>(
    context,
    SelectionScreen(),
  );
  if (result != null) {
    print('Selected: $result');
  }
}
```

#### ResponsiveLayout Example

```dart
import 'package:common_flutter_utilities/responsive_layout.dart';

class ResponsiveGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}

// Platform-specific UI
Widget buildPlatformSpecific(BuildContext context) {
  if (ResponsiveLayout.isMobile(context)) {
    return MobileLayout();
  }
  return DesktopLayout();
}
```

#### ThemeController Example

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

#### PremiumService Example

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

// Enable premium after purchase
Future<void> purchasePremium() async {
  await PremiumService.enablePremium();
}
```

#### NumberFormatter Example

```dart
import 'package:common_flutter_utilities/number_formatter.dart';

void formatNumbers() {
  // Compact notation
  print(NumberFormatter.formatCompact(1500)); // 1.5K
  print(NumberFormatter.formatCompact(1500000)); // 1.5M

  // Currency
  print(NumberFormatter.formatCurrency(1234.56)); // $1,234.56

  // Percentage
  print(NumberFormatter.formatPercentage(0.1234)); // 12.3%

  // With thousands
  print(NumberFormatter.formatWithThousands(1000000)); // 1,000,000
}
```

## Benefits

### PlatformUtils
- **Universal**: Works on all Flutter platforms (Android, iOS, Web, Windows, macOS, Linux)
- **Simple**: Static API, no initialization required
- **Type-safe**: Returns boolean values
- **Zero dependencies**: Only uses Flutter's built-in platform detection

### NavigationUtils
- **Less boilerplate**: Reduces repetitive navigation code
- **Type-safe**: Generic type support for navigation results
- **Callback support**: Easy to handle screen dismissal
- **Consistent API**: Uniform navigation patterns across your app

### ResponsiveLayout
- **Adaptive**: Works across all screen sizes
- **Flexible**: Configurable breakpoints and parameters
- **Comprehensive**: Grids, spacing, fonts, aspect ratios
- **Zero dependencies**: Only uses Flutter's built-in MediaQuery

### ThemeController
- **Persistent**: Theme mode saved to SharedPreferences
- **Simple**: Easy to use API
- **Flexible**: Works with any color scheme
- **Reactive**: Notifies listeners on changes

### PremiumService
- **Simple**: Minimal API for premium status
- **Persistent**: Status saved to SharedPreferences
- **Reusable**: Works across any app with premium features
- **No external dependencies**: Only uses SharedPreferences

### NumberFormatter
- **Comprehensive**: Multiple formatting options
- **Flexible**: Configurable decimal places, symbols, etc.
- **International**: Uses intl package for proper localization
- **Type-safe**: All methods return strings

## Testing

The common utilities are tested in the unit_converter project which uses them. Key test files:

```bash
cd unit_converter
flutter test test/theme_service_test.dart
flutter test test/responsive_layout_test.dart
flutter test test/platform_utils_test.dart
flutter test test/navigation_utils_test.dart
```

Note: ThemeController tests are in `theme_service_test.dart` (not `theme_controller_test.dart`). Some utilities like PremiumService and NumberFormatter are tested indirectly through integration tests in the unit_converter app.

## Migration from Unit Converter

If you're migrating code from the unit_converter app:

1. Remove the old imports:
   ```dart
   // Remove
   import 'package:unit_converter/utils/platform_utils.dart';
   import 'package:unit_converter/utils/navigation_utils.dart';
   import 'package:unit_converter/utils/responsive_layout.dart';
   import 'package:unit_converter/services/theme_service.dart';
   import 'package:unit_converter/services/premium_service.dart';
   import 'package:unit_converter/utils/number_formatter.dart';
   ```

2. Add the new imports:
   ```dart
   // Add
   import 'package:common_flutter_utilities/platform_utils.dart';
   import 'package:common_flutter_utilities/navigation_utils.dart';
   import 'package:common_flutter_utilities/responsive_layout.dart';
   import 'package:common_flutter_utilities/theme_controller.dart';
   import 'package:common_flutter_utilities/premium_service.dart';
   import 'package:common_flutter_utilities/number_formatter.dart';
   ```

3. For ThemeController, note that:
   - The AppPalette enum is not included (app-specific)
   - You need to provide your own color schemes
   - The API is otherwise identical

4. For ResponsiveLayout, note that:
   - Some app-specific methods were generalized
   - Methods like `getCategoryGridColumns` are now `getGridColumns`
   - Additional parameters were added for flexibility

## Dependencies

The common package requires these dependencies in your app:

```yaml
dependencies:
  google_mobile_ads: ^7.0.0      # Required for AdService
  shared_preferences: ^2.3.2     # Required for ThemeController, PremiumService, AdService
  intl: ^0.19.0                  # Required for NumberFormatter
```

## What's Next?

All high-value reusables have been extracted. Future additions may include:
- Storage service wrappers
- Analytics service
- Error handling utilities
- Logging utilities
- More responsive utilities

## Contributing

When adding new utilities to the common package:

1. Keep them generic and app-agnostic
2. Add comprehensive tests
3. Update the README with usage examples
4. Follow the existing code style
5. Keep dependencies minimal
6. Document any breaking changes
