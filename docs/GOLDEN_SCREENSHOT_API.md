# Golden Screenshot API Documentation

## Overview

The `golden_screenshot` package provides a comprehensive API for automating screenshot generation in Flutter applications. It extends Flutter's built-in golden testing capabilities to create production-ready screenshots for app stores (Google Play Store, Apple App Store, F-Droid, Flathub) with automatic device frames, multi-device support, and visual regression testing.

**Key Features:**
- Automatic device frames for realistic screenshots
- Multi-device support (phones, tablets, desktops)
- Multi-language support for localized screenshots
- Visual regression testing with fuzzy comparison
- CI/CD integration ready
- Custom device and frame creation

## Installation

Add to your `pubspec.yaml`:

```yaml
dev_dependencies:
  golden_screenshot: ^10.0.0
```

Install the package:

```bash
flutter pub get
```

## Core API Components

### 1. Test Functions

#### `testGoldens()`

Enhanced version of `testWidgets()` specifically for golden screenshot testing.

**Signature:**
```dart
void testGoldens(
  String description,
  GoldenTesterCallback callback, {
  bool? skip,
  Timeout? timeout,
  dynamic tags,
  GoldenVariant? variant,
  bool semanticsEnabled = false,
})
```

**Key Differences from `testWidgets()`:**
- Enables shadows in golden tests (disabled by default in Flutter)
- Enables fuzzy comparator for non-pixel-perfect comparisons
- Provides access to `tester.expectScreenshot()` method

**Example:**
```dart
testGoldens('Home Screen Screenshot', (tester) async {
  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle();
  
  await tester.expectScreenshot(
    GoldenScreenshotDevices.androidPhone.device,
    'home_screen',
  );
});
```

### 2. WidgetTester Extensions

#### `tester.expectScreenshot()`

Convenience method for taking screenshots with automatic path resolution.

**Signature:**
```dart
Future<void> expectScreenshot(
  ScreenshotDevice device,
  String name, {
  Locale? locale,
  String? customPath,
})
```

**Parameters:**
- `device`: The device configuration to use for the screenshot
- `name`: Base name for the screenshot file
- `locale`: Optional locale for localized screenshots
- `customPath`: Optional custom path override

**Example:**
```dart
await tester.expectScreenshot(
  GoldenScreenshotDevices.androidPhone.device,
  'home_screen',
  locale: Locale('en', 'US'),
);
```

#### `tester.loadAssets()`

Loads fonts and images for golden tests.

**Signature:**
```dart
Future<void> loadAssets()
```

**Behavior:**
- Loads all bundled assets (fonts, images)
- Replaces missing fonts with Inter font
- Must be called before taking screenshots

**Example:**
```dart
await tester.loadAssets();
await tester.pump();
await expectLater(
  find.byType(MaterialApp),
  matchesGoldenFile('screenshot.png'),
);
```

### 3. Device Configuration

#### `ScreenshotDevice`

Core class defining device properties for screenshots.

**Properties:**
```dart
class ScreenshotDevice {
  final TargetPlatform platform;
  final Size resolution;
  final double pixelRatio;
  final String goldenSubFolder;
  final ScreenshotFrameBuilder frameBuilder;
  final ScreenshotFrameColors? frameColors;
  final EdgeInsets safeArea;
  
  // Static property for custom screenshot directory
  static String screenshotsFolder = '../metadata/$localeCode/images/';
}
```

**Constructor:**
```dart
ScreenshotDevice({
  required TargetPlatform platform,
  required Size resolution,
  required double pixelRatio,
  required String goldenSubFolder,
  required ScreenshotFrameBuilder frameBuilder,
  ScreenshotFrameColors? frameColors,
  EdgeInsets? safeArea,
})
```

**Example - Custom Device:**
```dart
final customPhone = ScreenshotDevice(
  platform: TargetPlatform.android,
  resolution: Size(1080, 1920),
  pixelRatio: 3.0,
  goldenSubFolder: 'phoneScreenshots/',
  frameBuilder: ScreenshotFrame.android,
  safeArea: EdgeInsets.zero,
);
```

### 4. Device Presets

#### `GoldenScreenshotDevices`

Enum containing pre-configured device presets for common devices.

**Available Devices:**
```dart
enum GoldenScreenshotDevices {
  iphone(ScreenshotDevice(...)),      // iPhone 14 Pro
  androidPhone(ScreenshotDevice(...)), // Pixel 7
  sevenInchTablet(ScreenshotDevice(...)), // iPad mini
  tenInchTablet(ScreenshotDevice(...)),   // iPad Pro
  desktop(ScreenshotDevice(...)),         // Desktop (1920x1080)
  laptop(ScreenshotDevice(...)),          // Laptop (1366x768)
}
```

**Usage:**
```dart
await tester.expectScreenshot(
  GoldenScreenshotDevices.iphone.device,
  'screenshot_name',
);
```

#### `GoldenSmallDevices`

Alternative device presets with lower resolution for faster test execution.

**Available Devices:**
```dart
enum GoldenSmallDevices {
  iphone(ScreenshotDevice(...)),
  androidPhone(ScreenshotDevice(...)),
  sevenInchTablet(ScreenshotDevice(...)),
  tenInchTablet(ScreenshotDevice(...)),
  desktop(ScreenshotDevice(...)),
  laptop(ScreenshotDevice(...)),
}
```

### 5. Device Frames

#### `ScreenshotFrame`

Static class providing built-in device frame builders.

**Available Frames:**
```dart
class ScreenshotFrame {
  static Widget android({
    required ScreenshotDevice device,
    ScreenshotFrameColors? frameColors,
    required Widget child,
  })
  
  static Widget ios({
    required ScreenshotDevice device,
    ScreenshotFrameColors? frameColors,
    required Widget child,
  })
  
  static Widget desktop({
    required ScreenshotDevice device,
    ScreenshotFrameColors? frameColors,
    required Widget child,
  })
  
  static Widget laptop({
    required ScreenshotDevice device,
    ScreenshotFrameColors? frameColors,
    required Widget child,
  })
}
```

#### `ScreenshotFrameColors`

Configuration for frame appearance.

**Properties:**
```dart
class ScreenshotFrameColors {
  final Color? frame;
  final Color? screen;
  final Color? statusBar;
  final Color? navigationBar;
}
```

### 6. Screenshot App Wrapper

#### `ScreenshotApp`

Widget wrapper that adds device frames to your app for screenshots.

**Constructor:**
```dart
ScreenshotApp({
  Key? key,
  required ScreenshotDevice device,
  ScreenshotFrameColors? frameColors,
  required Widget child,
})
```

**Alternative Constructor with Title Bar:**
```dart
ScreenshotApp.withConditionalTitlebar({
  Key? key,
  required ScreenshotDevice device,
  ScreenshotFrameColors? frameColors,
  required Widget child,
  String? title,
})
```

**Example:**
```dart
final app = ScreenshotApp(
  device: GoldenScreenshotDevices.iphone.device,
  home: MyApp(),
);

await tester.pumpWidget(app);
```

## API Usage Patterns

### Pattern 1: Basic Screenshot Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:my_app/main.dart';

void main() {
  testGoldens('Home Screen', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();
    
    await tester.expectScreenshot(
      GoldenScreenshotDevices.androidPhone.device,
      'home_screen',
    );
  });
}
```

### Pattern 2: Multi-Device Screenshot Test

```dart
void main() {
  for (final device in GoldenScreenshotDevices.values) {
    testGoldens('Home Screen on ${device.name}', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      await tester.expectScreenshot(
        device.device,
        'home_screen',
      );
    });
  }
}
```

### Pattern 3: Multi-Language Screenshot Test

```dart
void main() {
  final locales = [
    Locale('en', 'US'),
    Locale('es', 'ES'),
    Locale('fr', 'FR'),
  ];
  
  for (final locale in locales) {
    testGoldens('Home Screen in ${locale.languageCode}', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          home: MyApp(),
        ),
      );
      await tester.pumpAndSettle();
      
      await tester.expectScreenshot(
        GoldenScreenshotDevices.androidPhone.device,
        'home_screen',
        locale: locale,
      );
    });
  }
}
```

### Pattern 4: Theme Switching Test

```dart
void main() {
  testGoldens('Home Screen Light Theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    
    await tester.expectScreenshot(
      GoldenScreenshotDevices.androidPhone.device,
      'home_screen_light',
    );
  });
  
  testGoldens('Home Screen Dark Theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    
    await tester.expectScreenshot(
      GoldenScreenshotDevices.androidPhone.device,
      'home_screen_dark',
    );
  });
}
```

### Pattern 5: Custom Device Test

```dart
void main() {
  final customDevice = ScreenshotDevice(
    platform: TargetPlatform.android,
    resolution: Size(390, 844), // iPhone 13 size
    pixelRatio: 3.0,
    goldenSubFolder: 'customPhone/',
    frameBuilder: ScreenshotFrame.android,
  );
  
  testGoldens('Custom Device Screenshot', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();
    
    await tester.expectScreenshot(
      customDevice,
      'custom_device',
    );
  });
}
```

### Pattern 6: Regular Golden Test with Frame

```dart
void main() {
  testGoldens('Regular Golden Test', (tester) async {
    final app = ScreenshotApp(
      device: GoldenScreenshotDevices.iphone.device,
      home: MyApp(),
    );
    
    await tester.pumpWidget(app);
    await tester.loadAssets();
    await tester.pump();
    
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('regular_golden.png'),
    );
  });
}
```

### Pattern 7: Navigation and Scrolling Test

```dart
void main() {
  testGoldens('Scrollable Content Screenshot', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();
    
    // Navigate to a screen
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    
    // Scroll to bottom
    await tester.drag(
      find.byType(Scrollable),
      Offset(0, -500),
    );
    await tester.pumpAndSettle();
    
    await tester.expectScreenshot(
      GoldenScreenshotDevices.androidPhone.device,
      'settings_scrolled',
    );
  });
}
```

## Advanced Customization

### Custom Device Enum

```dart
enum MyCustomDevices {
  phone(ScreenshotDevice(
    platform: TargetPlatform.android,
    resolution: Size(1440, 3120),
    pixelRatio: 10 / 3,
    goldenSubFolder: 'phoneScreenshots/',
    frameBuilder: ScreenshotFrame.android,
  )),
  
  tablet(ScreenshotDevice(
    platform: TargetPlatform.android,
    resolution: Size(2732, 2048),
    pixelRatio: 2,
    goldenSubFolder: 'tabletScreenshots/',
    frameBuilder: ScreenshotFrame.android,
  ));
  
  const MyCustomDevices(this.device);
  final ScreenshotDevice device;
}
```

### Custom Frame Builder

```dart
class MyCustomFrame extends StatelessWidget {
  const MyCustomFrame({
    super.key,
    required this.device,
    this.frameColors,
    required this.child,
  });
  
  final ScreenshotDevice device;
  final ScreenshotFrameColors? frameColors;
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: frameColors?.frame ?? Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      home: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        home: child,
      ),
    );
  }
}

// Usage
final customDevice = ScreenshotDevice(
  platform: TargetPlatform.android,
  resolution: Size(1080, 1920),
  pixelRatio: 3.0,
  goldenSubFolder: 'custom/',
  frameBuilder: (context, device, frameColors, child) {
    return MyCustomFrame(
      device: device,
      frameColors: frameColors,
      home: child,
    );
  },
);
```

### Custom Screenshot Directory

```dart
void main() {
  // Set custom screenshot directory
  ScreenshotDevice.screenshotsFolder = 'marketing/screenshots/';
  
  testGoldens('My Screenshot', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();
    
    await tester.expectScreenshot(
      GoldenScreenshotDevices.androidPhone.device,
      'screenshot',
    );
  });
}
```

## File Organization

### Default Directory Structure

```
your_app/
├── test/
│   └── golden_screenshots/
│       ├── store_screenshots_test.dart
│       └── metadata/
│           └── en-US/
│               └── images/
│                   ├── phoneScreenshots/
│                   │   ├── 1_home.png
│                   │   └── 2_settings.png
│                   ├── tabletScreenshots/
│                   │   └── 1_home.png
│                   └── desktopScreenshots/
│                       └── 1_home.png
```

### Custom Directory Structure

```dart
void main() {
  ScreenshotDevice.screenshotsFolder = '../marketing/screenshots/';
  
  testGoldens('My Screenshot', (tester) async {
    // Screenshots will be saved to:
    // marketing/screenshots/en-US/images/phoneScreenshots/1_home.png
  });
}
```

## Command Line Usage

### Generate All Screenshots

```bash
flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens
```

### Generate Specific Test

```bash
flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens --name="Home Screen"
```

### Run Tests Without Updating

```bash
flutter test test/golden_screenshots/store_screenshots_test.dart
```

### Generate for Specific Device

```bash
flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens --name="Phone"
```

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Generate Screenshots

on:
  push:
    branches: [main]

jobs:
  screenshots:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Generate screenshots
        run: flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens
      
      - name: Upload screenshots
        uses: actions/upload-artifact@v3
        with:
          name: screenshots
          path: test/golden_screenshots/metadata/
```

### Fastlane Integration

```ruby
# android/fastlane/Fastfile

desc "Generate store screenshots"
lane :generate_screenshots do
  UI.header("📸 Generating Store Screenshots")
  
  Dir.chdir('..') do
    sh('flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens')
    sh('cp test/golden_screenshots/metadata/en-US/images/phoneScreenshots/*.png marketing/screenshots/')
  end
  
  UI.success("✅ Screenshots generated successfully")
end

desc "Upload screenshots to Play Store"
lane :upload_screenshots do
  upload_to_play_store(
    skip_upload_apk: true,
    skip_upload_metadata: true,
    skip_upload_images: false,
    screenshot_paths: Dir['marketing/screenshots/*.png'],
  )
end

desc "Generate and upload screenshots"
lane :update_screenshots do
  generate_screenshots
  upload_screenshots
end
```

## Best Practices

### 1. Test Organization

- Group related screenshots in test groups
- Use descriptive test names
- Separate test files for different screenshot types

### 2. Device Selection

- Test on all required device sizes for your target stores
- Use `GoldenSmallDevices` for faster iteration during development
- Use `GoldenScreenshotDevices` for final production screenshots

### 3. Theme Coverage

- Test both light and dark themes
- Ensure consistent theme usage across device families
- Document theme requirements in test comments

### 4. Localization

- Test all supported locales
- Use locale-aware screenshot names
- Organize screenshots by locale in directory structure

### 5. Performance

- Use `GoldenSmallDevices` for development
- Run tests in parallel when possible
- Cache generated screenshots locally

### 6. Version Control

- Commit golden files to version control
- Review screenshot changes in pull requests
- Use meaningful commit messages

### 7. Maintenance

- Update tests when UI changes
- Review screenshots before release
- Keep tests well-documented

## Troubleshooting

### Issue: Screenshots don't match golden files

**Solution:**
```bash
# Update golden files
flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens
```

### Issue: Device frames not showing

**Solution:** Ensure you're using `find.byType(MaterialApp)` not `find.byType(MyWidget)`:

```dart
// Correct
await expectLater(
  find.byType(MaterialApp),
  matchesGoldenFile('screenshot.png'),
);

// Incorrect - frame won't be included
await expectLater(
  find.byType(MyWidget),
  matchesGoldenFile('screenshot.png'),
);
```

### Issue: Screenshots are blurry

**Solution:** Check `pixelRatio` in device configuration:

```dart
final device = ScreenshotDevice(
  pixelRatio: 3.0, // Higher value = sharper screenshots
  // ...
);
```

### Issue: Tests timeout

**Solution:** Increase timeout in test:

```dart
testGoldens('My test', (tester) async {
  // Your test code
}, timeout: const Timeout(Duration(minutes: 5)));
```

### Issue: Fonts not loading correctly

**Solution:** Ensure fonts are bundled and call `tester.loadAssets()`:

```dart
await tester.loadAssets();
await tester.pump();
```

### Issue: Shadows appearing as black borders

**Solution:** Use `testGoldens` instead of `testWidgets`:

```dart
// testGoldens automatically handles shadows
testGoldens('My test', (tester) async {
  // ...
});
```

## API Reference Summary

### Key Classes

| Class | Purpose |
|-------|---------|
| `ScreenshotDevice` | Device configuration for screenshots |
| `ScreenshotFrame` | Built-in device frame builders |
| `ScreenshotFrameColors` | Frame color customization |
| `ScreenshotApp` | Widget wrapper for device frames |

### Key Enums

| Enum | Purpose |
|------|---------|
| `GoldenScreenshotDevices` | Pre-configured high-resolution devices |
| `GoldenSmallDevices` | Pre-configured low-resolution devices (faster) |

### Key Extensions

| Extension | Method | Purpose |
|-----------|--------|---------|
| `WidgetTester` | `expectScreenshot()` | Take screenshot with automatic path |
| `WidgetTester` | `loadAssets()` | Load fonts and images |

### Key Functions

| Function | Purpose |
|----------|---------|
| `testGoldens()` | Enhanced test widget function for golden tests |

## Resources

- [Package on pub.dev](https://pub.dev/packages/golden_screenshot)
- [API Documentation](https://pub.dev/documentation/golden_screenshot/latest/)
- [Flutter Golden Tests](https://docs.flutter.dev/cookbook/testing/widget/goldens)
- [Google Play Store Screenshot Guidelines](https://support.google.com/googleplay/android-developer/answer/10788323)
- [Apple App Store Screenshot Guidelines](https://developer.apple.com/app-store/app-store-for-iphone/)

## Version Information

- **Current Version**: 10.0.0
- **Minimum Flutter SDK**: 3.11.1
- **License**: MIT
- **Publisher**: adil.hanney.org

---

**Last Updated:** March 12, 2026  
**Version:** 1.0.0  
**Maintainer:** MoonBark Studio


