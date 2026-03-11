import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/models/conversion.dart';
import 'package:unit_converter/screens/category_selection_screen.dart';
import 'package:unit_converter/screens/conversion_screen.dart';
import 'package:unit_converter/screens/custom_units_screen.dart';
import 'package:unit_converter/screens/settings_screen.dart';
import 'package:unit_converter/services/theme_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const phoneSize = Size(1080, 1920);
  const tablet7Size = Size(1200, 1920);
  const tablet10Size = Size(1600, 2560);
  const outputDir = 'screenshots/store_screenshots';

  Future<void> configureViewport(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget buildLightApp(Widget home) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(
        palette: AppPalette.sage,
        brightness: Brightness.light,
      ),
      darkTheme: buildAppTheme(
        palette: AppPalette.sage,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.light,
      home: home,
    );
  }

  Future<ThemeController> createThemeController() async {
    final controller = ThemeController();
    await controller.updatePalette(AppPalette.sage);
    await controller.updateThemeMode(AppThemeMode.light);
    return controller;
  }

  List<Map<String, Object?>> sampleCustomUnits() {
    final createdAt = DateTime(2026, 3, 11).toIso8601String();
    return [
      {
        'id': 'ru-length',
        'name': 'Rack Unit',
        'symbol': 'RU',
        'conversionFactor': 0.04445,
        'categoryName': 'Length',
        'createdAt': createdAt,
      },
      {
        'id': 'sheet-area',
        'name': 'Sheet',
        'symbol': 'sht',
        'conversionFactor': 0.74322432,
        'categoryName': 'Area',
        'createdAt': createdAt,
      },
      {
        'id': 'ops-speed',
        'name': 'Ops Cycle',
        'symbol': 'opc',
        'conversionFactor': 0.2777777778,
        'categoryName': 'Speed',
        'createdAt': createdAt,
      },
    ];
  }

  void seedPrefs({bool premium = false, bool withCustomUnits = false}) {
    final initialValues = <String, Object>{
      'premium_enabled': premium,
    };

    if (withCustomUnits) {
      initialValues['custom_units'] = jsonEncode(sampleCustomUnits());
    }

    SharedPreferences.setMockInitialValues(initialValues);
  }

  Future<void> exportScreenshot(
    WidgetTester tester, {
    required String fileName,
    required Size size,
    required Widget app,
  }) async {
    final boundaryKey = GlobalKey();
    await configureViewport(tester, size);

    await tester.pumpWidget(
      RepaintBoundary(
        key: boundaryKey,
        child: MediaQuery(
          data: MediaQueryData(size: size),
          child: app,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 200));

    final boundary = tester.renderObject(find.byKey(boundaryKey));
    final image = await (boundary as RenderRepaintBoundary).toImage(
      pixelRatio: 1.0,
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    final file = File('$outputDir/$fileName');
    file.parent.createSync(recursive: true);
    await file.writeAsBytes(byteData!.buffer.asUint8List(), flush: true);

    expect(file.existsSync(), isTrue);
    expect(file.lengthSync(), greaterThan(0));
  }

  testWidgets('export phone home screenshot', (tester) async {
    seedPrefs();
    final controller = await createThemeController();

    await exportScreenshot(
      tester,
      fileName: 'phone_01_home_1080x1920.png',
      size: phoneSize,
      app: buildLightApp(
        CategorySelectionScreen(themeController: controller),
      ),
    );
  });

  testWidgets('export phone conversion screenshot', (tester) async {
    seedPrefs();

    await exportScreenshot(
      tester,
      fileName: 'phone_02_conversion_1080x1920.png',
      size: phoneSize,
      app: buildLightApp(
        ConversionScreen(
          category: ConversionData.lengthCategory,
          initialFromSymbol: 'm',
          initialToSymbol: 'ft',
          initialInput: '12.5',
        ),
      ),
    );
  });

  testWidgets('export phone custom units screenshot', (tester) async {
    seedPrefs(withCustomUnits: true);

    await exportScreenshot(
      tester,
      fileName: 'phone_03_custom_units_1080x1920.png',
      size: phoneSize,
      app: buildLightApp(const CustomUnitsScreen()),
    );
  });

  testWidgets('export phone settings screenshot', (tester) async {
    seedPrefs(premium: true);
    final controller = await createThemeController();

    await exportScreenshot(
      tester,
      fileName: 'phone_04_settings_1080x1920.png',
      size: phoneSize,
      app: buildLightApp(
        SettingsScreen(themeController: controller, widgetAvailable: true),
      ),
    );
  });

  testWidgets('export 7-inch tablet home screenshot', (tester) async {
    seedPrefs();
    final controller = await createThemeController();

    await exportScreenshot(
      tester,
      fileName: 'tablet7_01_home_1200x1920.png',
      size: tablet7Size,
      app: buildLightApp(
        CategorySelectionScreen(themeController: controller),
      ),
    );
  });

  testWidgets('export 7-inch tablet custom units screenshot', (tester) async {
    seedPrefs(withCustomUnits: true);

    await exportScreenshot(
      tester,
      fileName: 'tablet7_02_custom_units_1200x1920.png',
      size: tablet7Size,
      app: buildLightApp(const CustomUnitsScreen()),
    );
  });

  testWidgets('export 10-inch tablet home screenshot', (tester) async {
    seedPrefs();
    final controller = await createThemeController();

    await exportScreenshot(
      tester,
      fileName: 'tablet10_01_home_1600x2560.png',
      size: tablet10Size,
      app: buildLightApp(
        CategorySelectionScreen(themeController: controller),
      ),
    );
  });

  testWidgets('export 10-inch tablet settings screenshot', (tester) async {
    seedPrefs(premium: true);
    final controller = await createThemeController();

    await exportScreenshot(
      tester,
      fileName: 'tablet10_02_settings_1600x2560.png',
      size: tablet10Size,
      app: buildLightApp(
        SettingsScreen(themeController: controller, widgetAvailable: true),
      ),
    );
  });
}