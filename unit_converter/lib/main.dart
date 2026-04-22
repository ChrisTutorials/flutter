import 'package:flutter/material.dart';

import 'models/conversion.dart';
import 'models/quick_preset.dart';
import 'screens/category_selection_screen.dart';
import 'screens/conversion_screen.dart';
import 'screens/currency_converter_screen.dart';
import 'screens/custom_units_screen.dart';
import 'screens/settings_screen.dart';
import 'services/admob_service.dart';
import 'services/currency_service.dart';
import 'services/purchase_service.dart';
import 'services/theme_service.dart';
import 'services/widget_service.dart';
import 'utils/screenshot_scenario.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = ThemeController.instance;
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

  Widget buildInitialScreen() {
    switch (screenshotScenario.screen) {
      case 'settings':
        return SettingsScreen(
          themeController: themeController,
          widgetAvailable: widgetAvailable,
        );
      case 'custom-units':
        return const CustomUnitsScreen();
      case 'currency':
        return CurrencyConverterScreen(
          preset: _buildCurrencyPreset(),
          demoCurrencies: screenshotScenario.usesStoreData
              ? _buildStoreCurrencies()
              : null,
          demoQuote: screenshotScenario.usesStoreData
              ? _buildStoreCurrencyQuote()
              : null,
        );
      case 'conversion':
        final category = _resolveCategory(screenshotScenario.categoryName);
        return ConversionScreen(
          category: category,
          initialFromSymbol: screenshotScenario.fromSymbol,
          initialToSymbol: screenshotScenario.toSymbol,
          initialInput: screenshotScenario.value,
          presetLabel: screenshotScenario.label,
        );
      case 'home':
      default:
        return CategorySelectionScreen(
          themeController: themeController,
          initialScrollTarget: screenshotScenario.scrollTarget,
        );
    }
  }

  QuickPreset? _buildCurrencyPreset() {
    final fromSymbol = screenshotScenario.fromSymbol;
    final toSymbol = screenshotScenario.toSymbol;
    final sampleValue = double.tryParse(screenshotScenario.value ?? '');
    if (fromSymbol == null || toSymbol == null) {
      return null;
    }

    return QuickPreset.currency(
      label: screenshotScenario.label ?? '$fromSymbol to $toSymbol',
      subtitle: screenshotScenario.subtitle ?? 'Live rates',
      fromSymbol: fromSymbol,
      toSymbol: toSymbol,
      sampleValue: sampleValue ?? 1,
    );
  }

  Map<String, String> _buildStoreCurrencies() {
    return const {
      'USD': 'US Dollar',
      'EUR': 'Euro',
      'GBP': 'British Pound',
      'JPY': 'Japanese Yen',
      'CAD': 'Canadian Dollar',
      'AUD': 'Australian Dollar',
    };
  }

  CurrencyQuote? _buildStoreCurrencyQuote() {
    final fromSymbol = screenshotScenario.fromSymbol;
    final toSymbol = screenshotScenario.toSymbol;
    final amount = double.tryParse(screenshotScenario.value ?? '');
    if (fromSymbol == null || toSymbol == null || amount == null) {
      return null;
    }

    final rate = switch ('$fromSymbol:$toSymbol') {
      'USD:EUR' => 0.918,
      'EUR:USD' => 1.0893246187,
      _ when fromSymbol == toSymbol => 1.0,
      _ => null,
    };
    if (rate == null) {
      return null;
    }

    return CurrencyQuote(
      from: fromSymbol,
      to: toSymbol,
      amount: amount,
      convertedAmount: amount * rate,
      rate: rate,
      effectiveDate: DateTime(2026, 3, 11),
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
          home: buildInitialScreen(),
        );
      },
    );
  }
}

