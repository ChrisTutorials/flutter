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

## Testing

Both utilities come with comprehensive tests:

```bash
cd common
flutter test test/platform_utils_test.dart
flutter test test/navigation_utils_test.dart
```

## Migration from Unit Converter

If you're migrating code from the unit_converter app:

1. Remove the old imports:
   ```dart
   // Remove
   import 'package:unit_converter/utils/platform_utils.dart';
   import 'package:unit_converter/utils/navigation_utils.dart';
   ```

2. Add the new imports:
   ```dart
   // Add
   import 'package:common_flutter_utilities/platform_utils.dart';
   import 'package:common_flutter_utilities/navigation_utils.dart';
   ```

3. No code changes needed - the API is identical!

## What's Next?

These are the highest-value reusables extracted. Future extractions may include:

- ResponsiveLayout (responsive design utilities)
- ThemeController (theme management with persistence)
- PremiumService (premium status management)
- NumberFormatter (number formatting utilities)

## Contributing

When adding new utilities to the common package:

1. Keep them generic and app-agnostic
2. Add comprehensive tests
3. Update the README with usage examples
4. Follow the existing code style
5. Keep dependencies minimal
