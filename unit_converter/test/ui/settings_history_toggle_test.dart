import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/screens/settings_screen.dart';
import 'package:unit_converter/services/theme_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('settings shows history card with toggle', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(
          themeController: ThemeController.instance,
          widgetAvailable: false,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Conversion history'), findsOneWidget);
    expect(find.text('Enable history'), findsOneWidget);
  });

  testWidgets('history toggle shows current state', (tester) async {
    SharedPreferences.setMockInitialValues({
      'history_enabled': true,
    });

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(
          themeController: ThemeController.instance,
          widgetAvailable: false,
        ),
      ),
    );

    await tester.pumpAndSettle();

    final switchFinder = find.byType(SwitchListTile);
    final switchTile = tester.widget<SwitchListTile>(switchFinder.first);
    expect(switchTile.value, isTrue);
  });

  testWidgets('history toggle reflects disabled state', (tester) async {
    SharedPreferences.setMockInitialValues({
      'history_enabled': false,
    });

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(
          themeController: ThemeController.instance,
          widgetAvailable: false,
        ),
      ),
    );

    await tester.pumpAndSettle();

    final switchFinder = find.byType(SwitchListTile);
    final switchTile = tester.widget<SwitchListTile>(switchFinder.first);
    expect(switchTile.value, isFalse);
  });
}