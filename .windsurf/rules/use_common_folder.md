---
trigger: always_on
---
# Use Common Folder for Reusable Code

## Overview
When building Flutter apps, always check and use the `common/` folder for reusable code instead of duplicating functionality.

## Available Common Components

The `common/` folder provides these reusable utilities:

### Ad Service (`ad_service.dart`, `ad_config.dart`)
- Banner, Interstitial, and App Open ads
- User experience protection (frequency capping, time limits, session restrictions)
- Premium user support
- Configurable presets for different app types

### Platform Utils (`platform_utils.dart`)
- Mobile platform detection (Android, iOS)
- Desktop platform detection (Windows, macOS, Linux)
- Web platform detection

### Navigation Utils (`navigation_utils.dart`)
- Common navigation patterns
- Callback support for screen dismissal
- Fullscreen dialog support
- Type-safe navigation

## When Building New Apps

1. **Before creating new utilities**, check if they exist in `common/lib/`
2. **Add the common dependency** to your app's `pubspec.yaml`:
   ```yaml
   dependencies:
     common_flutter_utilities:
       path: ../common
   ```
3. **Import and use** common utilities instead of writing custom implementations
4. **Only create new utilities** in your app if they don't exist in common and are app-specific

## Examples

### Ad Integration
Use `AdService` from common instead of implementing your own ad logic:
```dart
import 'package:common_flutter_utilities/ad_service.dart';
import 'package:common_flutter_utilities/ad_config.dart';

// Configure and initialize
AdConfig.configureForUtilityApp();
await AdService.initialize();

// Track conversions
AdService.trackConversion();
```

### Platform Detection
Use `PlatformUtils` instead of manual platform checks:
```dart
import 'package:common_flutter_utilities/platform_utils.dart';

if (PlatformUtils.isMobile) {
  // Mobile-specific code
}
```

### Navigation
Use `NavigationUtils` for consistent navigation patterns:
```dart
import 'package:common_flutter_utilities/navigation_utils.dart';

NavigationUtils.pushScreen(context, DetailScreen());
```

## When to Extend Common

If you need functionality that doesn't exist in common:
1. Consider if it's truly reusable across multiple apps
2. If yes, add it to `common/lib/` instead of a single app
3. Update the common README with documentation
4. If no, keep it app-specific

## Benefits

- **Consistency**: Same behavior across all apps
- **Maintainability**: Fix bugs once in common, benefit all apps
- **Time savings**: Don't reinvent the wheel
- **Quality**: Common code is tested and proven
