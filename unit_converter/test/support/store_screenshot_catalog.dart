import 'package:flutter/material.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:unit_converter/services/theme_service.dart';

class StoreScreenshotSurfaceConfig {
  const StoreScreenshotSurfaceConfig({
    required this.id,
    required this.testLabel,
    required this.rawStem,
    required this.scenarioUri,
    required this.themeMode,
  });

  final String id;
  final String testLabel;
  final String rawStem;
  final Uri scenarioUri;
  final AppThemeMode themeMode;
}

class StoreScreenshotDeviceConfig {
  const StoreScreenshotDeviceConfig({
    required this.id,
    required this.testLabel,
    required this.filePrefix,
    required this.sizeLabel,
    required this.size,
    required this.rawDevice,
    required this.framedDevice,
  });

  final String id;
  final String testLabel;
  final String filePrefix;
  final String sizeLabel;
  final Size size;
  final ScreenshotDevice rawDevice;
  final ScreenshotDevice framedDevice;

  String rawGoldenName(StoreScreenshotSurfaceConfig surface) {
    return '${filePrefix}_${surface.rawStem}_$sizeLabel';
  }

  String framedGoldenName(StoreScreenshotSurfaceConfig surface) {
    return '${filePrefix}_${surface.rawStem}_${sizeLabel}_framed';
  }
}

final List<StoreScreenshotSurfaceConfig> storeScreenshotSurfaces = [
  StoreScreenshotSurfaceConfig(
    id: 'home',
    testLabel: 'Home with history',
    rawStem: '01_home_history_light_portrait',
    scenarioUri: Uri(
      scheme: 'https',
      host: 'example.invalid',
      query: 'screen=home&data=store&theme=light&scroll=history',
    ),
    themeMode: AppThemeMode.light,
  ),
  StoreScreenshotSurfaceConfig(
    id: 'conversion',
    testLabel: 'Conversion',
    rawStem: '02_conversion_light_portrait',
    scenarioUri: Uri(
      scheme: 'https',
      host: 'example.invalid',
      query:
          'screen=conversion&category=Weight&from=g&to=lb&value=60&label=60%20g%20to%20lb&data=store&theme=light',
    ),
    themeMode: AppThemeMode.light,
  ),
  StoreScreenshotSurfaceConfig(
    id: 'currency',
    testLabel: 'Currency',
    rawStem: '03_currency_dark_portrait',
    scenarioUri: Uri(
      scheme: 'https',
      host: 'example.invalid',
      query:
          'screen=currency&from=USD&to=EUR&value=250&label=USD%20to%20EUR&subtitle=Travel%20rates&data=store&theme=dark',
    ),
    themeMode: AppThemeMode.dark,
  ),
  StoreScreenshotSurfaceConfig(
    id: 'custom_units',
    testLabel: 'Custom Units',
    rawStem: '04_custom_units_dark_portrait',
    scenarioUri: Uri(
      scheme: 'https',
      host: 'example.invalid',
      query: 'screen=custom-units&data=store&theme=dark',
    ),
    themeMode: AppThemeMode.dark,
  ),
];

const List<StoreScreenshotDeviceConfig> storeScreenshotDevices = [
  StoreScreenshotDeviceConfig(
    id: 'phone',
    testLabel: 'Phone',
    filePrefix: 'phone',
    sizeLabel: '1080x1920',
    size: Size(1080, 1920),
    rawDevice: ScreenshotDevice(
      platform: TargetPlatform.android,
      resolution: Size(1080, 1920),
      pixelRatio: 1,
      goldenSubFolder: 'raw_store_screenshots/',
      frameBuilder: ScreenshotFrame.noFrame,
    ),
    framedDevice: ScreenshotDevice(
      platform: TargetPlatform.android,
      resolution: Size(1080, 1920),
      pixelRatio: 1,
      goldenSubFolder: 'phoneScreenshots/',
      frameBuilder: ScreenshotFrame.androidPhone,
    ),
  ),
  StoreScreenshotDeviceConfig(
    id: 'tablet7',
    testLabel: 'Tablet 7',
    filePrefix: 'tablet7',
    sizeLabel: '1200x1920',
    size: Size(1200, 1920),
    rawDevice: ScreenshotDevice(
      platform: TargetPlatform.android,
      resolution: Size(1200, 1920),
      pixelRatio: 1,
      goldenSubFolder: 'raw_store_screenshots/',
      frameBuilder: ScreenshotFrame.noFrame,
    ),
    framedDevice: ScreenshotDevice(
      platform: TargetPlatform.android,
      resolution: Size(1200, 1920),
      pixelRatio: 1,
      goldenSubFolder: 'sevenInchScreenshots/',
      frameBuilder: ScreenshotFrame.androidTablet,
    ),
  ),
  StoreScreenshotDeviceConfig(
    id: 'tablet10',
    testLabel: 'Tablet 10',
    filePrefix: 'tablet10',
    sizeLabel: '1600x2560',
    size: Size(1600, 2560),
    rawDevice: ScreenshotDevice(
      platform: TargetPlatform.android,
      resolution: Size(1600, 2560),
      pixelRatio: 1,
      goldenSubFolder: 'raw_store_screenshots/',
      frameBuilder: ScreenshotFrame.noFrame,
    ),
    framedDevice: ScreenshotDevice(
      platform: TargetPlatform.android,
      resolution: Size(1600, 2560),
      pixelRatio: 1,
      goldenSubFolder: 'tenInchScreenshots/',
      frameBuilder: ScreenshotFrame.androidTablet,
    ),
  ),
];
