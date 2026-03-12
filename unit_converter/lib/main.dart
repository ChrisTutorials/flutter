import 'package:flutter/material.dart';

import 'models/conversion.dart';
import 'models/quick_preset.dart';
import 'screens/category_selection_screen.dart';
import 'screens/conversion_screen.dart';
import 'screens/currency_converter_screen.dart';
import 'screens/custom_units_screen.dart';
import 'screens/settings_screen.dart';
import 'services/admob_service.dart';
import 'services/purchase_service.dart';
import 'services/theme_service.dart';
import 'services/widget_service.dart';
import 'utils/screenshot_scenario.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = ThemeController();
  await themeController.load();
  final screenshotScenario = await ScreenshotScenario.prepare(themeController);
  await AdMobService.initialize();
  await PurchaseService().initialize();
  final widgetAvailable = await WidgetService.isAvailable();
  AdMobService.resetSessionCounters(); // Reset session counters on app start
  runApp(
    UnitConverterApp(
      themeController: themeController,
      widgetAvailable: widgetAvailable,
      screenshotScenario: screenshotScenario,
    ),
  );
}

class UnitConverterApp extends StatelessWidget {
  const UnitConverterApp({
    super.key,
    required this.themeController,
    required this.widgetAvailable,
    required this.screenshotScenario,
  });

  final ThemeController themeController;
  final bool widgetAvailable;
  final ScreenshotScenario screenshotScenario;

  Widget _buildInitialScreen() {
    final uri = Uri.base;
    switch (screenshotScenario.screen) {
      case 'settings':
        return SettingsScreen(
          themeController: themeController,
          widgetAvailable: widgetAvailable,
        );
      case 'custom-units':
        return const CustomUnitsScreen();
      case 'currency':
        return CurrencyConverterScreen(preset: _buildCurrencyPreset(uri));
      case 'conversion':
        final category = _resolveCategory(uri.queryParameters['category']);
        return ConversionScreen(
          category: category,
          initialFromSymbol: uri.queryParameters['from'],
          initialToSymbol: uri.queryParameters['to'],
          initialInput: uri.queryParameters['value'],
          presetLabel: uri.queryParameters['label'],
        );
      case 'home':
      default:
        return CategorySelectionScreen(
          themeController: themeController,
          initialScrollTarget: screenshotScenario.scrollTarget,
        );
    }
  }

  QuickPreset? _buildCurrencyPreset(Uri uri) {
    final fromSymbol = uri.queryParameters['from'];
    final toSymbol = uri.queryParameters['to'];
    final sampleValue = double.tryParse(uri.queryParameters['value'] ?? '');
    if (fromSymbol == null || toSymbol == null) {
      return null;
    }

    return QuickPreset.currency(
      label: uri.queryParameters['label'] ?? '$fromSymbol to $toSymbol',
      subtitle: uri.queryParameters['subtitle'] ?? 'Live rates',
      fromSymbol: fromSymbol,
      toSymbol: toSymbol,
      sampleValue: sampleValue ?? 1,
    );
  }

  ConversionCategory _resolveCategory(String? categoryName) {
    if (categoryName == null) {
      return ConversionData.lengthCategory;
    }

    return ConversionData.categories.firstWhere(
      (category) => category.name.toLowerCase() == categoryName.toLowerCase(),
      orElse: () => ConversionData.lengthCategory,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'All-in-One Unit Converter',
          debugShowCheckedModeBanner: false,
          themeMode: themeController.themeMode,
          theme: buildAppTheme(
            palette: themeController.palette,
            brightness: Brightness.light,
          ),
          darkTheme: buildAppTheme(
            palette: themeController.palette,
            brightness: Brightness.dark,
          ),
          home: _buildInitialScreen(),
        );
      },
    );
  }
}

