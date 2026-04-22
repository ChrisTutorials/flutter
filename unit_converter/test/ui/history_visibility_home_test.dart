import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/screens/category_selection_screen.dart';
import 'package:unit_converter/services/theme_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('home shows history section by default when enabled', (tester) async {
    SharedPreferences.setMockInitialValues({
      'history_enabled': true,
    });

    await tester.pumpWidget(
      MaterialApp(
        home: CategorySelectionScreen(
          themeController: ThemeController.instance,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
  });

  testWidgets('home hides history section when disabled', (tester) async {
    SharedPreferences.setMockInitialValues({
      'history_enabled': false,
    });

    await tester.pumpWidget(
      MaterialApp(
        home: CategorySelectionScreen(
          themeController: ThemeController.instance,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('History'), findsNothing);
  });
}