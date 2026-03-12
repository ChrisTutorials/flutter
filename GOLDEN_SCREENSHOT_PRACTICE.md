# Golden Screenshot Workspace Practice

## 📋 Overview

This document establishes `golden_screenshot` as the standard practice for automated store screenshot generation across all Flutter projects in the workspace.

## 🎯 Why golden_screenshot?

- **Industry Standard**: Purpose-built for app store screenshots
- **Automatic Device Frames**: No manual frame editing needed
- **Multi-Device Support**: Phones, tablets, desktops
- **Multi-Language Support**: Easy localization
- **CLI Integration**: Works with CI/CD pipelines
- **Fastlane Integration**: Automatic upload to stores
- **Visual Regression**: Detects UI changes automatically

## 🚀 Quick Start

### 1. Add to Your Project

```yaml
# pubspec.yaml
dev_dependencies:
  golden_screenshot: ^2.0.0
```

### 2. Create Screenshot Tests

```dart
// test/golden_screenshots/store_screenshots_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:your_app/main.dart';

void main() {
  testGoldenScreenshots(
    'Store Screenshots',
    (device, tester) async {
      await tester.pumpWidget(const YourApp());
      await tester.pumpAndSettle();

      // Take screenshot
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshot_${device.name}.png'),
      );
    },
    devices: [
      Device.phone,
      Device.tablet7,
      Device.tablet10,
    ],
  );
}
```

### 3. Generate Screenshots

```bash
# Generate all screenshots
flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens

# Generate screenshots for specific device
flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens --name="phone"
```

## 📐 Standard Device Presets

### Required Screenshots for Play Store

| Device Type | Size | Preset | Required |
|-------------|------|--------|----------|
| Phone | 1080x1920 | `Device.phone` | ✅ Yes (2-8 screenshots) |
| 7-inch Tablet | 1200x1920 | `Device.tablet7` | ✅ Optional |
| 10-inch Tablet | 1600x2560 | `Device.tablet10` | ✅ Optional |

### Available Device Presets

```dart
Device.phone          // 1080x1920 (Pixel 6)
Device.phoneSmall     // 375x667 (iPhone SE)
Device.tablet7        // 1200x1920 (Nexus 7)
Device.tablet10       // 1600x2560 (Pixel C)
Device.desktop        // 1920x1080 (Desktop)
Device.laptop         // 1366x768 (Laptop)
Device.watch          // 336x336 (Apple Watch)
```

## 🎨 Screenshot Requirements

### Content Requirements

1. **Show Real Content**: Use realistic data, not lorem ipsum
2. **Show Key Features**: Highlight main app functionality
3. **Consistent Branding**: Use your brand colors and fonts
4. **No Status Bar**: Device frames include status bar
5. **No Navigation Bar**: Device frames include navigation bar

### Theme Requirements

- **Light Theme**: At least 1 screenshot per device family
- **Dark Theme**: At least 1 screenshot per device family
- **Consistent**: Use same theme across device family

### Composition Requirements

- **Content Dense**: Fill the frame with meaningful content
- **No Empty Space**: Avoid large empty regions
- **Proper Scrolling**: Show scrolled content where appropriate
- **Feature Focus**: Each screenshot should highlight a different feature

## 📁 File Organization

### Standard Directory Structure

```
your_app/
├── test/
│   └── golden_screenshots/
│       ├── store_screenshots_test.dart
│       └── golden/                    # Generated screenshots
│           ├── phone_01_home_light.png
│           ├── phone_02_conversion_dark.png
│           ├── tablet7_01_home_light.png
│           └── tablet10_01_home_light.png
└── marketing/
    └── your_app/
        └── screenshots/
            └── store_screenshots/     # Production screenshots
                ├── phone_01_home_history_light_portrait_1080x1920.png
                ├── phone_02_conversion_light_portrait_1080x1920.png
                └── ...
```

### Naming Convention

Use this naming convention for production screenshots:

```
{device}_{number}_{screen}_{theme}_{orientation}_{width}x{height}.png
```

Examples:
- `phone_01_home_history_light_portrait_1080x1920.png`
- `tablet7_02_conversion_dark_portrait_1200x1920.png`
- `tablet10_03_currency_light_portrait_1600x2560.png`

## 🔄 Workflow

### Development Workflow

```bash
# 1. Make UI changes
# 2. Update screenshot tests if needed
# 3. Generate screenshots locally
flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens

# 4. Review screenshots
# 5. Copy to marketing directory
# 6. Commit changes
```

### Release Workflow

```bash
# 1. Update version
# 2. Generate all screenshots
flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens

# 3. Copy to marketing directory
# 4. Upload to Play Store via Fastlane
cd android
fastlane upload_screenshots

# 5. Commit and push
```

### CI/CD Workflow

```yaml
# GitHub Actions example
- name: Generate Screenshots
  run: |
    flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens

- name: Upload Screenshots
  run: |
    cd android
    fastlane upload_screenshots
```

## 🛠️ Advanced Usage

### Custom Device Presets

```dart
final customDevice = Device(
  name: 'custom_phone',
  size: Size(390, 844),
  devicePixelRatio: 3.0,
  frame: true,
  safeArea: EdgeInsets.zero,
);

testGoldenScreenshots(
  'Custom Device Screenshots',
  (device, tester) async {
    // Your test code
  },
  devices: [customDevice],
);
```

### Multi-Language Screenshots

```dart
testGoldenScreenshots(
  'Multi-Language Screenshots',
  (device, tester) async {
    // English
    await tester.pumpWidget(const YourApp(locale: Locale('en')));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('en_screenshot_${device.name}.png'),
    );

    // Spanish
    await tester.pumpWidget(const YourApp(locale: Locale('es')));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('es_screenshot_${device.name}.png'),
    );
  },
  devices: [Device.phone],
);
```

### Theme Switching

```dart
Future<void> _switchToDarkTheme(WidgetTester tester) async {
  final themeToggle = find.byIcon(Icons.dark_mode);
  if (themeToggle.evaluate().isNotEmpty) {
    await tester.tap(themeToggle);
    await tester.pumpAndSettle();
  }
}
```

## 🔧 Integration with Fastlane

### Update Fastfile

```ruby
# android/fastlane/Fastfile

desc "Generate store screenshots"
lane :generate_screenshots do
  UI.header("📸 Generating Store Screenshots")
  
  Dir.chdir('..') do
    # Generate screenshots
    sh('flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens')
    
    # Copy to marketing directory
    sh('cp test/golden_screenshots/golden/*.png marketing/unit_converter/screenshots/store_screenshots/')
  end
  
  UI.success("✅ Screenshots generated successfully")
end

desc "Generate and upload screenshots"
lane :update_screenshots do
  generate_screenshots
  upload_screenshots
end
```

### Usage

```bash
# Generate screenshots
cd android
fastlane generate_screenshots

# Generate and upload
fastlane update_screenshots
```

## 📊 Best Practices

### 1. Test Coverage

- ✅ Test all major screens
- ✅ Test both light and dark themes
- ✅ Test on all required device sizes
- ✅ Test with realistic data

### 2. Performance

- ✅ Run tests in parallel when possible
- ✅ Use `--update-goldens` only when needed
- ✅ Cache generated screenshots
- ✅ Use CI/CD for automated generation

### 3. Maintenance

- ✅ Update tests when UI changes
- ✅ Review screenshots before release
- ✅ Keep tests organized and documented
- ✅ Use descriptive test names

### 4. Version Control

- ✅ Commit golden files to version control
- ✅ Review changes in pull requests
- ✅ Use meaningful commit messages
- ✅ Tag releases with screenshot versions

## 🐛 Troubleshooting

### Issue: Screenshots don't match golden files

**Solution:**
```bash
# Update golden files
flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens
```

### Issue: Device frames not showing

**Solution:** Ensure `Device.frame` is set to `true` (default is `true`)

### Issue: Screenshots are blurry

**Solution:** Check `devicePixelRatio` in device preset

### Issue: Tests timeout

**Solution:** Increase timeout in test:
```dart
testWidgets('My test', (tester) async {
  // Your test code
}, timeout: const Timeout(Duration(minutes: 5)));
```

## 📚 Resources

- [golden_screenshot Package](https://pub.dev/packages/golden_screenshot)
- [Flutter Golden Tests](https://docs.flutter.dev/cookbook/testing/widget/goldens)
- [Google Play Store Screenshot Guidelines](https://support.google.com/googleplay/android-developer/answer/10788323)
- [Apple App Store Screenshot Guidelines](https://developer.apple.com/app-store/app-store-for-iphone/)

## 🎓 Training

### For New Developers

1. Read this guide
2. Review existing screenshot tests
3. Run screenshot generation locally
4. Practice updating tests
5. Learn Fastlane integration

### For Experienced Developers

1. Review and update this guide
2. Improve test coverage
3. Optimize performance
4. Share best practices
5. Mentor new developers

## 📝 Checklist

### Before Release

- [ ] All screenshot tests pass
- [ ] Screenshots reviewed for quality
- [ ] Screenshots copied to marketing directory
- [ ] Screenshots uploaded to Play Store
- [ ] Screenshots committed to version control

### When UI Changes

- [ ] Update screenshot tests if needed
- [ ] Regenerate screenshots
- [ ] Review changes
- [ ] Update documentation if needed

---

**Last Updated:** March 12, 2026  
**Version:** 1.0.0  
**Maintainer:** MoonBark Studio
