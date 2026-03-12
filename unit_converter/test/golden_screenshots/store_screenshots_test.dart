import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:unit_converter/main.dart';

/// Automated store screenshots for Google Play Store and Apple App Store
/// 
/// This test generates all required store screenshots with proper device frames
/// for phone and tablet sizes in both light and dark themes.
/// 
/// Usage:
/// ```bash
/// # Generate all screenshots
/// flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens
/// 
/// # Generate screenshots for specific device
/// flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens --name="phone"
/// ```
void main() {
  group('Store Screenshots', () {
    // Phone screenshots (1080x1920)
    testGoldenScreenshots(
      'Phone Screenshots',
      (device, tester) async {
        // Initialize the app
        await tester.pumpWidget(const UnitConverterApp());
        await tester.pumpAndSettle();

        // Screenshot 1: Home screen with history (Light theme)
        await _navigateToHomeWithHistory(tester);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('phone_01_home_history_light_${device.name}.png'),
        );

        // Screenshot 2: Conversion screen (Light theme)
        await _navigateToConversion(tester);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('phone_02_conversion_light_${device.name}.png'),
        );

        // Screenshot 3: Currency screen (Dark theme)
        await _navigateToCurrency(tester, isDark: true);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('phone_03_currency_dark_${device.name}.png'),
        );

        // Screenshot 4: Custom units screen (Dark theme)
        await _navigateToCustomUnits(tester, isDark: true);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('phone_04_custom_units_dark_${device.name}.png'),
        );
      },
      devices: [
        Device.phone, // 1080x1920
      ],
    );

    // 7-inch tablet screenshots (1200x1920)
    testGoldenScreenshots(
      '7-inch Tablet Screenshots',
      (device, tester) async {
        // Initialize the app
        await tester.pumpWidget(const UnitConverterApp());
        await tester.pumpAndSettle();

        // Screenshot 1: Home screen with history (Light theme)
        await _navigateToHomeWithHistory(tester);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('tablet7_01_home_history_light_${device.name}.png'),
        );

        // Screenshot 2: Conversion screen (Light theme)
        await _navigateToConversion(tester);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('tablet7_02_conversion_light_${device.name}.png'),
        );

        // Screenshot 3: Currency screen (Dark theme)
        await _navigateToCurrency(tester, isDark: true);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('tablet7_03_currency_dark_${device.name}.png'),
        );

        // Screenshot 4: Custom units screen (Dark theme)
        await _navigateToCustomUnits(tester, isDark: true);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('tablet7_04_custom_units_dark_${device.name}.png'),
        );
      },
      devices: [
        Device.tablet7, // 1200x1920
      ],
    );

    // 10-inch tablet screenshots (1600x2560)
    testGoldenScreenshots(
      '10-inch Tablet Screenshots',
      (device, tester) async {
        // Initialize the app
        await tester.pumpWidget(const UnitConverterApp());
        await tester.pumpAndSettle();

        // Screenshot 1: Home screen with history (Light theme)
        await _navigateToHomeWithHistory(tester);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('tablet10_01_home_history_light_${device.name}.png'),
        );

        // Screenshot 2: Conversion screen (Light theme)
        await _navigateToConversion(tester);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('tablet10_02_conversion_light_${device.name}.png'),
        );

        // Screenshot 3: Currency screen (Dark theme)
        await _navigateToCurrency(tester, isDark: true);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('tablet10_03_currency_dark_${device.name}.png'),
        );

        // Screenshot 4: Custom units screen (Dark theme)
        await _navigateToCustomUnits(tester, isDark: true);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('tablet10_04_custom_units_dark_${device.name}.png'),
        );
      },
      devices: [
        Device.tablet10, // 1600x2560
      ],
    );
  });
}

/// Navigate to home screen with history visible
Future<void> _navigateToHomeWithHistory(WidgetTester tester) async {
  // Ensure we're on the home screen
  await tester.pumpAndSettle();

  // Scroll down to show history section
  await tester.fling(
    find.byType(Scrollable).first,
    const Offset(0, -500),
    1000,
  );
  await tester.pumpAndSettle();
}

/// Navigate to conversion screen
Future<void> _navigateToConversion(WidgetTester tester) async {
  // Tap on a category (e.g., Weight)
  final categoryButton = find.text('Weight');
  if (categoryButton.evaluate().isNotEmpty) {
    await tester.tap(categoryButton);
    await tester.pumpAndSettle();
  }
}

/// Navigate to currency screen
Future<void> _navigateToCurrency(WidgetTester tester, {bool isDark = false}) async {
  // Tap on currency category
  final currencyButton = find.text('Currency');
  if (currencyButton.evaluate().isNotEmpty) {
    await tester.tap(currencyButton);
    await tester.pumpAndSettle();
  }

  // Switch to dark theme if needed
  if (isDark) {
    final themeToggle = find.byIcon(Icons.dark_mode);
    if (themeToggle.evaluate().isNotEmpty) {
      await tester.tap(themeToggle);
      await tester.pumpAndSettle();
    }
  }
}

/// Navigate to custom units screen
Future<void> _navigateToCustomUnits(WidgetTester tester, {bool isDark = false}) async {
  // Navigate to custom units (via settings or bottom nav if available)
  final customUnitsButton = find.text('Custom Units');
  if (customUnitsButton.evaluate().isNotEmpty) {
    await tester.tap(customUnitsButton);
    await tester.pumpAndSettle();
  }

  // Switch to dark theme if needed
  if (isDark) {
    final themeToggle = find.byIcon(Icons.dark_mode);
    if (themeToggle.evaluate().isNotEmpty) {
      await tester.tap(themeToggle);
      await tester.pumpAndSettle();
    }
  }
}
