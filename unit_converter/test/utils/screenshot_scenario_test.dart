import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/services/theme_service.dart';
import 'package:unit_converter/utils/screenshot_scenario.dart';

void main() {
  group('ScreenshotScenario.prepare', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('parses deterministic screenshot route parameters', () async {
      final themeController = ThemeController();
      await themeController.load();

      final scenario = await ScreenshotScenario.prepare(
        themeController,
        uri: Uri.https('example.invalid', '/', {
          'screen': 'currency',
          'theme': 'dark',
          'palette': 'ocean',
          'data': 'store',
          'scroll': 'history',
          'from': 'USD',
          'to': 'EUR',
          'value': '250',
          'label': 'USD to EUR',
          'subtitle': 'Travel rates',
        }),
      );

      expect(scenario.screen, 'currency');
      expect(scenario.scrollTarget, ScreenshotScrollTarget.history);
      expect(scenario.usesStoreData, isTrue);
      expect(scenario.fromSymbol, 'USD');
      expect(scenario.toSymbol, 'EUR');
      expect(scenario.value, '250');
      expect(scenario.label, 'USD to EUR');
      expect(scenario.subtitle, 'Travel rates');
      expect(themeController.themeModeSetting, AppThemeMode.dark);
      expect(themeController.palette, AppPalette.ocean);
    });
  });
}