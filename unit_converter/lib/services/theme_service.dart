import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppPalette { sage, terracotta, ocean }

enum AppThemeMode { system, light, dark }

class ThemeController extends ChangeNotifier {
  static const String _paletteKey = 'theme_palette';
  static const String _themeModeKey = 'theme_mode';

  AppPalette _palette = AppPalette.sage;
  AppThemeMode _themeMode = AppThemeMode.system;

  AppPalette get palette => _palette;
  AppThemeMode get themeModeSetting => _themeMode;

  ThemeMode get themeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final paletteIndex = prefs.getInt(_paletteKey);
    final modeIndex = prefs.getInt(_themeModeKey);

    if (paletteIndex != null &&
        paletteIndex >= 0 &&
        paletteIndex < AppPalette.values.length) {
      _palette = AppPalette.values[paletteIndex];
    }
    if (modeIndex != null &&
        modeIndex >= 0 &&
        modeIndex < AppThemeMode.values.length) {
      _themeMode = AppThemeMode.values[modeIndex];
    }
  }

  Future<void> updatePalette(AppPalette palette) async {
    if (_palette == palette) {
      return;
    }

    _palette = palette;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_paletteKey, palette.index);
  }

  Future<void> updateThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) {
      return;
    }

    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }
}

ThemeData buildAppTheme({
  required AppPalette palette,
  required Brightness brightness,
}) {
  final seed = switch (palette) {
    AppPalette.sage => const Color(0xFF0F766E),
    AppPalette.terracotta => const Color(0xFFB45309),
    AppPalette.ocean => const Color(0xFF0F4C81),
  };

  final surface = switch ((palette, brightness)) {
    (AppPalette.sage, Brightness.light) => const Color(0xFFF7F4EE),
    (AppPalette.terracotta, Brightness.light) => const Color(0xFFFCF5ED),
    (AppPalette.ocean, Brightness.light) => const Color(0xFFF2F6FB),
    (AppPalette.sage, Brightness.dark) => const Color(0xFF101A1A),
    (AppPalette.terracotta, Brightness.dark) => const Color(0xFF1E1713),
    (AppPalette.ocean, Brightness.dark) => const Color(0xFF101723),
  };

  final colorScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: brightness,
    surface: surface,
  );

  final textTheme =
      (brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light())
          .textTheme
          .apply(
            bodyColor: colorScheme.onSurface,
            displayColor: colorScheme.onSurface,
            fontFamily: 'Georgia',
          );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: surface,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: brightness == Brightness.dark
          ? colorScheme.surfaceContainerHighest
          : Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      backgroundColor: colorScheme.secondaryContainer.withValues(alpha: 0.65),
      selectedColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: brightness == Brightness.dark
          ? colorScheme.surfaceContainer
          : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
    ),
  );
}

String paletteLabel(AppPalette palette) {
  switch (palette) {
    case AppPalette.sage:
      return 'Sage';
    case AppPalette.terracotta:
      return 'Terracotta';
    case AppPalette.ocean:
      return 'Ocean';
  }
}

String themeModeLabel(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.system:
      return 'System';
    case AppThemeMode.light:
      return 'Light';
    case AppThemeMode.dark:
      return 'Dark';
  }
}
