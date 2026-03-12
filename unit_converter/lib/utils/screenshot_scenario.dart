import 'package:flutter/material.dart';

import '../models/conversion.dart';
import '../services/custom_units_service.dart';
import '../services/recent_conversions_service.dart';
import '../services/theme_service.dart';

enum ScreenshotScrollTarget { none, history }

class ScreenshotScenario {
  ScreenshotScenario._({
    required this.scrollTarget,
    required this.screen,
  });

  final ScreenshotScrollTarget scrollTarget;
  final String screen;

  static Future<ScreenshotScenario> prepare(ThemeController themeController) async {
    final uri = Uri.base;
    final theme = uri.queryParameters['theme'];
    final palette = uri.queryParameters['palette'];
    final dataPreset = uri.queryParameters['data'];
    final scroll = uri.queryParameters['scroll'];
    final screen = uri.queryParameters['screen'] ?? 'home';

    if (theme != null) {
      await themeController.updateThemeMode(_parseThemeMode(theme));
    }

    if (palette != null) {
      await themeController.updatePalette(_parsePalette(palette));
    }

    if (dataPreset == 'store') {
      await _seedStoreData();
    }

    return ScreenshotScenario._(
      scrollTarget: scroll == 'history'
          ? ScreenshotScrollTarget.history
          : ScreenshotScrollTarget.none,
      screen: screen,
    );
  }

  static AppThemeMode _parseThemeMode(String value) {
    switch (value.toLowerCase()) {
      case 'dark':
        return AppThemeMode.dark;
      case 'light':
      default:
        return AppThemeMode.light;
    }
  }

  static AppPalette _parsePalette(String value) {
    switch (value.toLowerCase()) {
      case 'terracotta':
        return AppPalette.terracotta;
      case 'ocean':
        return AppPalette.ocean;
      case 'sage':
      default:
        return AppPalette.sage;
    }
  }

  static Future<void> _seedStoreData() async {
    final recentConversionsService = RecentConversionsService();
    final customUnitsService = CustomUnitsService();

    await recentConversionsService.clearRecentConversions();
    for (final conversion in _recentConversions) {
      await recentConversionsService.saveConversion(conversion);
    }

    await customUnitsService.clearAllCustomUnits();
    for (final customUnit in _customUnits) {
      await customUnitsService.saveCustomUnit(customUnit);
    }
  }

  static final List<RecentConversion> _recentConversions = [
    RecentConversion(
      category: 'Area',
      fromUnit: 'm²',
      toUnit: 'ft²',
      inputValue: 42,
      outputValue: 452.084237,
      timestamp: DateTime(2026, 3, 11, 8, 50),
    ),
    RecentConversion(
      category: 'Energy',
      fromUnit: 'kWh',
      toUnit: 'MJ',
      inputValue: 18,
      outputValue: 64.8,
      timestamp: DateTime(2026, 3, 11, 8, 55),
    ),
    RecentConversion(
      category: 'Length',
      fromUnit: 'm',
      toUnit: 'ft',
      inputValue: 12,
      outputValue: 39.37007874,
      timestamp: DateTime(2026, 3, 11, 9, 0),
    ),
    RecentConversion(
      category: 'Weight',
      fromUnit: 'g',
      toUnit: 'lb',
      inputValue: 60,
      outputValue: 0.1322773573,
      timestamp: DateTime(2026, 3, 11, 9, 5),
    ),
    RecentConversion(
      category: 'Pressure',
      fromUnit: 'psi',
      toUnit: 'bar',
      inputValue: 30,
      outputValue: 2.068427188,
      timestamp: DateTime(2026, 3, 11, 9, 10),
    ),
    RecentConversion(
      category: 'Time',
      fromUnit: 'min',
      toUnit: 'h',
      inputValue: 90,
      outputValue: 1.5,
      timestamp: DateTime(2026, 3, 11, 9, 15),
    ),
    RecentConversion(
      category: 'Temperature',
      fromUnit: '°F',
      toUnit: '°C',
      inputValue: 72,
      outputValue: 22.22222222,
      timestamp: DateTime(2026, 3, 11, 9, 20),
    ),
    RecentConversion(
      category: 'Volume',
      fromUnit: 'gal',
      toUnit: 'L',
      inputValue: 3,
      outputValue: 11.356235352,
      timestamp: DateTime(2026, 3, 11, 9, 25),
    ),
    RecentConversion(
      category: 'Speed',
      fromUnit: 'mph',
      toUnit: 'km/h',
      inputValue: 55,
      outputValue: 88.51392,
      timestamp: DateTime(2026, 3, 11, 9, 30),
    ),
    RecentConversion(
      category: 'Data',
      fromUnit: 'MB',
      toUnit: 'GB',
      inputValue: 512,
      outputValue: 0.512,
      timestamp: DateTime(2026, 3, 11, 9, 35),
    ),
    RecentConversion(
      category: 'Currency',
      fromUnit: 'USD',
      toUnit: 'EUR',
      inputValue: 250,
      outputValue: 229.5,
      timestamp: DateTime(2026, 3, 11, 9, 40),
    ),
    RecentConversion(
      category: 'Fuel',
      fromUnit: 'mpg',
      toUnit: 'L/100km',
      inputValue: 32,
      outputValue: 7.350312,
      timestamp: DateTime(2026, 3, 11, 9, 45),
    ),
  ];

  static final List<CustomUnit> _customUnits = [
    CustomUnit(
      id: 'store-1',
      name: 'Coffee Scoop',
      symbol: 'scoop',
      conversionFactor: 0.0147867648,
      categoryName: 'Cooking',
      createdAt: DateTime(2026, 3, 11),
    ),
    CustomUnit(
      id: 'store-2',
      name: 'Desk Span',
      symbol: 'desk',
      conversionFactor: 1.52,
      categoryName: 'Length',
      createdAt: DateTime(2026, 3, 11),
    ),
    CustomUnit(
      id: 'store-3',
      name: 'Barbell Plate',
      symbol: 'plate',
      conversionFactor: 20,
      categoryName: 'Weight',
      createdAt: DateTime(2026, 3, 11),
    ),
    CustomUnit(
      id: 'store-4',
      name: 'Server Rack Unit',
      symbol: 'rack-u',
      conversionFactor: 0.04445,
      categoryName: 'Length',
      createdAt: DateTime(2026, 3, 11),
    ),
    CustomUnit(
      id: 'store-5',
      name: 'Pitcher Fill',
      symbol: 'pitch',
      conversionFactor: 1.7,
      categoryName: 'Volume',
      createdAt: DateTime(2026, 3, 11),
    ),
    CustomUnit(
      id: 'store-6',
      name: 'Sprint Block',
      symbol: 'block',
      conversionFactor: 10,
      categoryName: 'Speed',
      createdAt: DateTime(2026, 3, 11),
    ),
    CustomUnit(
      id: 'store-7',
      name: 'Notebook Page',
      symbol: 'page',
      conversionFactor: 0.00005,
      categoryName: 'Area',
      createdAt: DateTime(2026, 3, 11),
    ),
    CustomUnit(
      id: 'store-8',
      name: 'Backup Set',
      symbol: 'backup',
      conversionFactor: 250,
      categoryName: 'Data',
      createdAt: DateTime(2026, 3, 11),
    ),
    CustomUnit(
      id: 'store-9',
      name: 'Studio Panel',
      symbol: 'panel',
      conversionFactor: 1.82,
      categoryName: 'Area',
      createdAt: DateTime(2026, 3, 11),
    ),
    CustomUnit(
      id: 'store-10',
      name: 'Cafe Batch',
      symbol: 'batch',
      conversionFactor: 2.25,
      categoryName: 'Volume',
      createdAt: DateTime(2026, 3, 11),
    ),
    CustomUnit(
      id: 'store-11',
      name: 'Trail Segment',
      symbol: 'trail',
      conversionFactor: 3.4,
      categoryName: 'Length',
      createdAt: DateTime(2026, 3, 11),
    ),
    CustomUnit(
      id: 'store-12',
      name: 'Launch Window',
      symbol: 'launch',
      conversionFactor: 45,
      categoryName: 'Time',
      createdAt: DateTime(2026, 3, 11),
    ),
    CustomUnit(
      id: 'store-13',
      name: 'Workshop Tray',
      symbol: 'tray',
      conversionFactor: 8,
      categoryName: 'Weight',
      createdAt: DateTime(2026, 3, 11),
    ),
    CustomUnit(
      id: 'store-14',
      name: 'Analytics Pack',
      symbol: 'pack',
      conversionFactor: 128,
      categoryName: 'Data',
      createdAt: DateTime(2026, 3, 11),
    ),
  ];
}