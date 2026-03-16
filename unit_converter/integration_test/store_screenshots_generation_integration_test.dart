import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/main.dart';
import 'package:unit_converter/services/theme_service.dart';
import 'package:unit_converter/utils/screenshot_scenario.dart';

import '../test/support/store_screenshot_catalog.dart';

/// Integration test for generating store screenshots with proper text rendering
/// This test runs on a real device/emulator and captures screenshots with full font support
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Store Screenshot Generation (Integration)', () {
    for (final device in storeScreenshotDevices) {
      testWidgets('Generate ${device.testLabel} screenshots', (
        WidgetTester tester,
      ) async {
        final binding = tester.binding as IntegrationTestWidgetsFlutterBinding;
        SharedPreferences.setMockInitialValues({});
        final themeController = ThemeController();
        await themeController.load();
        await binding.convertFlutterSurfaceToImage();

        for (final surface in storeScreenshotSurfaces) {
          await _generateScreenshot(
            tester,
            themeController,
            device.rawGoldenName(surface),
            device.size,
            surface.scenarioUri,
            surface.themeMode,
          );
        }
      });
    }
  });
}

Future<void> _generateScreenshot(
  WidgetTester tester,
  ThemeController themeController,
  String filename,
  Size size,
  Uri scenarioUri,
  AppThemeMode themeMode,
) async {
  // Prepare scenario
  final screenshotScenario = await ScreenshotScenario.prepare(
    themeController,
    uri: scenarioUri,
  );

  // Set surface size using binding
  final binding = tester.binding as IntegrationTestWidgetsFlutterBinding;
  await binding.setSurfaceSize(size);

  // Pump the app
  final app = UnitConverterApp(
    themeController: themeController,
    widgetAvailable: false,
    screenshotScenario: screenshotScenario,
  );

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light,
      theme: buildAppTheme(
        palette: themeController.palette,
        brightness: Brightness.light,
      ),
      darkTheme: buildAppTheme(
        palette: themeController.palette,
        brightness: Brightness.dark,
      ),
      home: MediaQuery(
        data: const MediaQueryData(
          padding: EdgeInsets.zero,
          viewPadding: EdgeInsets.zero,
        ),
        child: app.buildInitialScreen(),
      ),
    ),
  );

  // Pump and settle to ensure everything renders
  await tester.pump();
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Additional pumping to ensure fonts are loaded
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();

  await tester.pumpAndSettle();

  // Take screenshot
  await binding.takeScreenshot(filename);
  await binding.setSurfaceSize(null);
}
