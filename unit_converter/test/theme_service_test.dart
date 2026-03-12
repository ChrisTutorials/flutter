import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/services/theme_service.dart';

void main() {
  setUp(() async {
    // Clear shared preferences before each test
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeController', () {
    test('should load default theme settings', () async {
      final controller = ThemeController();
      await controller.load();

      expect(controller.palette, AppPalette.sage);
      expect(controller.themeModeSetting, AppThemeMode.system);
    });

    test('should load saved palette from storage', () async {
      SharedPreferences.setMockInitialValues({
        'theme_palette': 1, // terracotta
      });

      final controller = ThemeController();
      await controller.load();

      expect(controller.palette, AppPalette.terracotta);
    });

    test('should load saved theme mode from storage', () async {
      SharedPreferences.setMockInitialValues({
        'theme_mode': 2, // dark
      });

      final controller = ThemeController();
      await controller.load();

      expect(controller.themeModeSetting, AppThemeMode.dark);
      expect(controller.themeMode, ThemeMode.dark);
    });

    test('should update palette and notify listeners', () async {
      final controller = ThemeController();
      bool notified = false;
      controller.addListener(() => notified = true);

      await controller.updatePalette(AppPalette.ocean);

      expect(controller.palette, AppPalette.ocean);
      expect(notified, isTrue);
    });

    test('should not notify if palette is unchanged', () async {
      final controller = ThemeController();
      await controller.load();
      
      bool notified = false;
      controller.addListener(() => notified = true);

      await controller.updatePalette(AppPalette.sage);

      expect(notified, isFalse);
    });

    test('should update theme mode and notify listeners', () async {
      final controller = ThemeController();
      bool notified = false;
      controller.addListener(() => notified = true);

      await controller.updateThemeMode(AppThemeMode.light);

      expect(controller.themeModeSetting, AppThemeMode.light);
      expect(controller.themeMode, ThemeMode.light);
      expect(notified, isTrue);
    });

    test('should return correct ThemeMode for each setting', () async {
      final controller = ThemeController();
      
      await controller.updateThemeMode(AppThemeMode.system);
      expect(controller.themeMode, ThemeMode.system);
      
      await controller.updateThemeMode(AppThemeMode.light);
      expect(controller.themeMode, ThemeMode.light);
      
      await controller.updateThemeMode(AppThemeMode.dark);
      expect(controller.themeMode, ThemeMode.dark);
    });

    test('should handle invalid palette index gracefully', () async {
      SharedPreferences.setMockInitialValues({
        'theme_palette': 999,
      });

      final controller = ThemeController();
      await controller.load();

      expect(controller.palette, AppPalette.sage); // default
    });

    test('should handle invalid theme mode index gracefully', () async {
      SharedPreferences.setMockInitialValues({
        'theme_mode': 999,
      });

      final controller = ThemeController();
      await controller.load();

      expect(controller.themeModeSetting, AppThemeMode.system); // default
    });
  });

  group('buildAppTheme', () {
    test('should create sage light theme', () {
      final theme = buildAppTheme(palette: AppPalette.sage, brightness: Brightness.light);
      
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.brightness, Brightness.light);
    });

    test('should create ocean dark theme', () {
      final theme = buildAppTheme(palette: AppPalette.ocean, brightness: Brightness.dark);
      
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('should create terracotta light theme', () {
      final theme = buildAppTheme(palette: AppPalette.terracotta, brightness: Brightness.light);
      
      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, const Color(0xFFFCF5ED));
    });

    test('should create terracotta dark theme', () {
      final theme = buildAppTheme(palette: AppPalette.terracotta, brightness: Brightness.dark);
      
      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF1E1713));
    });

    test('should have correct card theme shape', () {
      final theme = buildAppTheme(palette: AppPalette.sage, brightness: Brightness.light);
      
      expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
    });

    test('should have correct input decoration theme', () {
      final theme = buildAppTheme(palette: AppPalette.sage, brightness: Brightness.light);
      
      expect(theme.inputDecorationTheme.border, isA<OutlineInputBorder>());
    });

    test('should use dark system bar icons in light theme', () {
      final theme = buildAppTheme(
        palette: AppPalette.sage,
        brightness: Brightness.light,
      );

      expect(theme.appBarTheme.systemOverlayStyle, isNotNull);
      expect(
        theme.appBarTheme.systemOverlayStyle?.statusBarIconBrightness,
        Brightness.dark,
      );
      expect(
        theme.appBarTheme.systemOverlayStyle?.systemNavigationBarIconBrightness,
        Brightness.dark,
      );
      expect(
        theme.appBarTheme.systemOverlayStyle?.statusBarColor,
        Colors.transparent,
      );
    });

    test('should use light system bar icons in dark theme', () {
      final theme = buildAppTheme(
        palette: AppPalette.ocean,
        brightness: Brightness.dark,
      );

      expect(theme.appBarTheme.systemOverlayStyle, isNotNull);
      expect(
        theme.appBarTheme.systemOverlayStyle?.statusBarIconBrightness,
        Brightness.light,
      );
      expect(
        theme.appBarTheme.systemOverlayStyle?.systemNavigationBarIconBrightness,
        Brightness.light,
      );
    });

    test('should keep popup and dialog surfaces readable', () {
      final theme = buildAppTheme(
        palette: AppPalette.terracotta,
        brightness: Brightness.dark,
      );

      expect(theme.popupMenuTheme.color, isNotNull);
      expect(theme.popupMenuTheme.textStyle?.color, theme.colorScheme.onSurface);
      expect(theme.dialogTheme.backgroundColor, isNotNull);
      expect(theme.bottomSheetTheme.backgroundColor, isNotNull);
    });
  });

  group('paletteLabel', () {
    test('should return correct labels', () {
      expect(paletteLabel(AppPalette.sage), 'Sage');
      expect(paletteLabel(AppPalette.terracotta), 'Terracotta');
      expect(paletteLabel(AppPalette.ocean), 'Ocean');
    });
  });

  group('themeModeLabel', () {
    test('should return correct labels', () {
      expect(themeModeLabel(AppThemeMode.system), 'System');
      expect(themeModeLabel(AppThemeMode.light), 'Light');
      expect(themeModeLabel(AppThemeMode.dark), 'Dark');
    });
  });

  group('Theme Persistence Across App Restarts', () {
    test('should persist dark theme mode across app restarts', () async {
      // Arrange - First app instance
      SharedPreferences.setMockInitialValues({});
      final controller1 = ThemeController();
      await controller1.load();
      await controller1.updateThemeMode(AppThemeMode.dark);

      // Act - Simulate app restart by creating new controller
      final controller2 = ThemeController();
      await controller2.load();

      // Assert
      expect(controller2.themeModeSetting, AppThemeMode.dark);
      expect(controller2.themeMode, ThemeMode.dark);
    });

    test('should persist light theme mode across app restarts', () async {
      // Arrange - First app instance
      SharedPreferences.setMockInitialValues({});
      final controller1 = ThemeController();
      await controller1.load();
      await controller1.updateThemeMode(AppThemeMode.light);

      // Act - Simulate app restart
      final controller2 = ThemeController();
      await controller2.load();

      // Assert
      expect(controller2.themeModeSetting, AppThemeMode.light);
      expect(controller2.themeMode, ThemeMode.light);
    });

    test('should persist system theme mode across app restarts', () async {
      // Arrange - First app instance
      SharedPreferences.setMockInitialValues({});
      final controller1 = ThemeController();
      await controller1.load();
      await controller1.updateThemeMode(AppThemeMode.system);

      // Act - Simulate app restart
      final controller2 = ThemeController();
      await controller2.load();

      // Assert
      expect(controller2.themeModeSetting, AppThemeMode.system);
      expect(controller2.themeMode, ThemeMode.system);
    });

    test('should persist both theme mode and palette across app restarts', () async {
      // Arrange - First app instance
      SharedPreferences.setMockInitialValues({});
      final controller1 = ThemeController();
      await controller1.load();
      await controller1.updateThemeMode(AppThemeMode.dark);
      await controller1.updatePalette(AppPalette.terracotta);

      // Act - Simulate app restart
      final controller2 = ThemeController();
      await controller2.load();

      // Assert
      expect(controller2.themeModeSetting, AppThemeMode.dark);
      expect(controller2.themeMode, ThemeMode.dark);
      expect(controller2.palette, AppPalette.terracotta);
    });

    test('should restore complete theme configuration after restart', () async {
      // Arrange - First app instance
      SharedPreferences.setMockInitialValues({});
      final controller1 = ThemeController();
      await controller1.load();
      await controller1.updateThemeMode(AppThemeMode.light);
      await controller1.updatePalette(AppPalette.ocean);

      // Act - Simulate app restart
      final controller2 = ThemeController();
      await controller2.load();

      // Assert
      expect(controller2.themeModeSetting, AppThemeMode.light);
      expect(controller2.themeMode, ThemeMode.light);
      expect(controller2.palette, AppPalette.ocean);
    });

    test('should handle multiple theme changes with persistence', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      final controller1 = ThemeController();
      await controller1.load();

      // Act - Multiple changes
      await controller1.updateThemeMode(AppThemeMode.dark);
      await controller1.updatePalette(AppPalette.terracotta);
      await controller1.updateThemeMode(AppThemeMode.light);
      await controller1.updatePalette(AppPalette.ocean);

      // Simulate app restart
      final controller2 = ThemeController();
      await controller2.load();

      // Assert - Should have last saved values
      expect(controller2.themeModeSetting, AppThemeMode.light);
      expect(controller2.palette, AppPalette.ocean);
    });

    test('should maintain persistence after switching between all theme modes', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      final controller1 = ThemeController();
      await controller1.load();

      // Act - Cycle through all modes
      await controller1.updateThemeMode(AppThemeMode.light);
      await controller1.updateThemeMode(AppThemeMode.dark);
      await controller1.updateThemeMode(AppThemeMode.system);
      await controller1.updateThemeMode(AppThemeMode.light);

      // Simulate app restart
      final controller2 = ThemeController();
      await controller2.load();

      // Assert
      expect(controller2.themeModeSetting, AppThemeMode.light);
    });
  });

  group('Palette Persistence Across App Restarts', () {
    test('should persist sage palette across app restarts', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      final controller1 = ThemeController();
      await controller1.load();
      await controller1.updatePalette(AppPalette.sage);

      // Act
      final controller2 = ThemeController();
      await controller2.load();

      // Assert
      expect(controller2.palette, AppPalette.sage);
    });

    test('should persist terracotta palette across app restarts', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      final controller1 = ThemeController();
      await controller1.load();
      await controller1.updatePalette(AppPalette.terracotta);

      // Act
      final controller2 = ThemeController();
      await controller2.load();

      // Assert
      expect(controller2.palette, AppPalette.terracotta);
    });

    test('should persist ocean palette across app restarts', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      final controller1 = ThemeController();
      await controller1.load();
      await controller1.updatePalette(AppPalette.ocean);

      // Act
      final controller2 = ThemeController();
      await controller2.load();

      // Assert
      expect(controller2.palette, AppPalette.ocean);
    });
  });

  group('Theme Mode Switching', () {
    test('should switch from light to dark theme', () async {
      // Arrange
      final controller = ThemeController();
      await controller.load();
      await controller.updateThemeMode(AppThemeMode.light);

      // Act
      await controller.updateThemeMode(AppThemeMode.dark);

      // Assert
      expect(controller.themeModeSetting, AppThemeMode.dark);
      expect(controller.themeMode, ThemeMode.dark);
    });

    test('should switch from dark to light theme', () async {
      // Arrange
      final controller = ThemeController();
      await controller.load();
      await controller.updateThemeMode(AppThemeMode.dark);

      // Act
      await controller.updateThemeMode(AppThemeMode.light);

      // Assert
      expect(controller.themeModeSetting, AppThemeMode.light);
      expect(controller.themeMode, ThemeMode.light);
    });

    test('should switch from system to light theme', () async {
      // Arrange
      final controller = ThemeController();
      await controller.load();
      await controller.updateThemeMode(AppThemeMode.system);

      // Act
      await controller.updateThemeMode(AppThemeMode.light);

      // Assert
      expect(controller.themeModeSetting, AppThemeMode.light);
      expect(controller.themeMode, ThemeMode.light);
    });

    test('should switch from system to dark theme', () async {
      // Arrange
      final controller = ThemeController();
      await controller.load();
      await controller.updateThemeMode(AppThemeMode.system);

      // Act
      await controller.updateThemeMode(AppThemeMode.dark);

      // Assert
      expect(controller.themeModeSetting, AppThemeMode.dark);
      expect(controller.themeMode, ThemeMode.dark);
    });
  });

  group('Edge Cases for Persistence', () {
    test('should handle missing preferences gracefully on first launch', () async {
      // Arrange - No preferences set
      SharedPreferences.setMockInitialValues({});

      // Act
      final controller = ThemeController();
      await controller.load();

      // Assert - Should use defaults
      expect(controller.themeModeSetting, AppThemeMode.system);
      expect(controller.palette, AppPalette.sage);
    });

    test('should handle partial preferences (only theme mode)', () async {
      // Arrange - Only theme mode saved
      SharedPreferences.setMockInitialValues({
        'theme_mode': AppThemeMode.dark.index,
      });

      // Act
      final controller = ThemeController();
      await controller.load();

      // Assert
      expect(controller.themeModeSetting, AppThemeMode.dark);
      expect(controller.palette, AppPalette.sage); // Default
    });

    test('should handle partial preferences (only palette)', () async {
      // Arrange - Only palette saved
      SharedPreferences.setMockInitialValues({
        'theme_palette': AppPalette.terracotta.index,
      });

      // Act
      final controller = ThemeController();
      await controller.load();

      // Assert
      expect(controller.themeModeSetting, AppThemeMode.system); // Default
      expect(controller.palette, AppPalette.terracotta);
    });

    test('should handle corrupted theme mode index gracefully', () async {
      // Arrange - Set invalid theme mode index
      SharedPreferences.setMockInitialValues({
        'theme_mode': 999, // Invalid index
      });

      // Act
      final controller = ThemeController();
      await controller.load();

      // Assert - Should fall back to default
      expect(controller.themeModeSetting, AppThemeMode.system);
    });

    test('should handle corrupted palette index gracefully', () async {
      // Arrange - Set invalid palette index
      SharedPreferences.setMockInitialValues({
        'theme_palette': 999, // Invalid index
      });

      // Act
      final controller = ThemeController();
      await controller.load();

      // Assert - Should fall back to default
      expect(controller.palette, AppPalette.sage);
    });
  });

  group('SharedPreferences Integration', () {
    test('should save light theme mode to SharedPreferences', () async {
      // Arrange
      final controller = ThemeController();
      await controller.load();

      // Act
      await controller.updateThemeMode(AppThemeMode.light);

      // Assert
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getInt('theme_mode');
      expect(savedMode, AppThemeMode.light.index);
    });

    test('should save dark theme mode to SharedPreferences', () async {
      // Arrange
      final controller = ThemeController();
      await controller.load();

      // Act
      await controller.updateThemeMode(AppThemeMode.dark);

      // Assert
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getInt('theme_mode');
      expect(savedMode, AppThemeMode.dark.index);
    });

    test('should save system theme mode to SharedPreferences', () async {
      // Arrange
      final controller = ThemeController();
      await controller.load();

      // Act
      await controller.updateThemeMode(AppThemeMode.system);

      // Assert
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getInt('theme_mode');
      expect(savedMode, AppThemeMode.system.index);
    });

    test('should save palette to SharedPreferences', () async {
      // Arrange
      final controller = ThemeController();
      await controller.load();

      // Act
      await controller.updatePalette(AppPalette.terracotta);

      // Assert
      final prefs = await SharedPreferences.getInstance();
      final savedPalette = prefs.getInt('theme_palette');
      expect(savedPalette, AppPalette.terracotta.index);
    });
  });
}
