import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode options
enum AppThemeMode { system, light, dark }

/// Theme controller for managing app themes
/// 
/// Provides theme management with persistence support.
/// The actual color schemes should be provided by the app
/// using this controller.
class ThemeController extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';

  AppThemeMode _themeMode = AppThemeMode.system;

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

  /// Load theme mode from persistent storage
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_themeModeKey);

    if (modeIndex != null &&
        modeIndex >= 0 &&
        modeIndex < AppThemeMode.values.length) {
      _themeMode = AppThemeMode.values[modeIndex];
    }
  }

  /// Update theme mode
  Future<void> updateThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) {
      return;
    }

    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  /// Check if dark mode is currently active
  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Check if light mode is currently active
  bool isLightMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light;
  }

  /// Get the current brightness
  Brightness getCurrentBrightness(BuildContext context) {
    return Theme.of(context).brightness;
  }
}

/// Helper function to get theme mode label
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
