import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unit_converter/main.dart';
import 'package:unit_converter/services/theme_service.dart';
import 'package:unit_converter/utils/screenshot_scenario.dart';

import 'store_screenshot_catalog.dart';

class StoreScreenshotHarness {
  StoreScreenshotHarness({
    required this.themeController,
    required this.screenshotScenario,
  });

  final ThemeController themeController;
  final ScreenshotScenario screenshotScenario;
}

Future<StoreScreenshotHarness> createStoreScreenshotHarness(
  StoreScreenshotSurfaceConfig surface,
) async {
  SharedPreferences.setMockInitialValues({});
  final themeController = ThemeController();
  await themeController.load();
  final screenshotScenario = await ScreenshotScenario.prepare(
    themeController,
    uri: surface.scenarioUri,
  );
  return StoreScreenshotHarness(
    themeController: themeController,
    screenshotScenario: screenshotScenario,
  );
}

Future<void> pumpStoreScreenshotApp(
  WidgetTester tester, {
  required ScreenshotDevice device,
  required StoreScreenshotHarness harness,
}) async {
  final app = UnitConverterApp(
    themeController: harness.themeController,
    widgetAvailable: false,
    screenshotScenario: harness.screenshotScenario,
  );

  await tester.pumpWidget(
    ScreenshotApp(
      device: device,
      title: 'All-in-One Unit Converter',
      themeMode: harness.themeController.themeMode,
      theme: buildAppTheme(
        palette: harness.themeController.palette,
        brightness: Brightness.light,
      ),
      darkTheme: buildAppTheme(
        palette: harness.themeController.palette,
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
  await tester.pump();
  await tester.loadAssets();
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

String absoluteGoldenDirectory(String rootPath) {
  final normalized = path.normalize(rootPath).replaceAll('\\', '/');
  return normalized.endsWith('/') ? normalized : '$normalized/';
}

String projectAbsolutePath(String relativePath) {
  return path.normalize(path.join(Directory.current.path, relativePath));
}