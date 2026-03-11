import 'package:flutter/material.dart';

import 'models/conversion.dart';
import 'models/quick_preset.dart';
import 'screens/category_selection_screen.dart';
import 'screens/currency_converter_screen.dart';
import 'screens/custom_units_screen.dart';
import 'screens/settings_screen.dart';
import 'services/admob_service.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = ThemeController();
  await themeController.load();
  await AdMobService.initialize();
  AdMobService.resetSessionCounters(); // Reset session counters on app start
  runApp(UnitConverterApp(themeController: themeController));
}

class UnitConverterApp extends StatelessWidget {
  const UnitConverterApp({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Unit Converter',
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
          home: CategorySelectionScreen(themeController: themeController),
        );
      },
    );
  }
}

