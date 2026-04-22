import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/screens/settings_screen.dart';
import 'package:unit_converter/services/theme_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('settings shows currency visibility card', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(
          themeController: ThemeController.instance,
          widgetAvailable: false,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Currency visibility'), findsOneWidget);
  });

  testWidgets('currency visibility card shows reset button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(
          themeController: ThemeController.instance,
          widgetAvailable: false,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Reset to defaults'), findsWidgets);
  });
}