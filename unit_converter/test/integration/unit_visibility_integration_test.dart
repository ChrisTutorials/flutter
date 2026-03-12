import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/main.dart';
import '../../lib/services/unit_settings_service.dart';
import '../../lib/models/conversion.dart';
import '../../lib/screens/category_selection_screen.dart';
import '../../lib/screens/conversion_screen.dart';

void main() {
  group('Unit Visibility Integration Tests', () {
    setUp(() async {
      // Reset to defaults before each test
      await UnitSettingsService.resetToDefaults();
    });

    testWidgets('should hide low-value units by default in category selection', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const UnitConverterApp());
      await tester.pumpAndSettle();

      // Navigate to Length category (which has Micrometer as a low-value unit)
      final lengthCard = find.text('Length');
      expect(lengthCard, findsOneWidget);
      await tester.tap(lengthCard);
      await tester.pumpAndSettle();

      // Check that Micrometer is not visible in the conversion screen
      expect(find.text('Micrometer'), findsNothing);
      
      // Verify common units are still visible
      expect(find.text('Meter'), findsOneWidget);
      expect(find.text('Kilometer'), findsOneWidget);
      expect(find.text('Foot'), findsOneWidget);
    });

    testWidgets('should show enabled units in menus after enabling them', (WidgetTester tester) async {
      // First enable Micrometer through settings
      await UnitSettingsService.toggleUnitVisibility('Micrometer');
      
      // Build the app
      await tester.pumpWidget(const UnitConverterApp());
      await tester.pumpAndSettle();

      // Navigate to Length category
      final lengthCard = find.text('Length');
      await tester.tap(lengthCard);
      await tester.pumpAndSettle();

      // Now Micrometer should be visible
      expect(find.text('Micrometer'), findsOneWidget);
      
      // Verify it appears in both input and output dropdowns
      final micrometerButtons = find.text('um');
      expect(micrometerButtons, findsAtLeastNWidgets(1));
    });

    testWidgets('should hide low-value units in Weight category by default', (WidgetTester tester) async {
      await tester.pumpWidget(const UnitConverterApp());
      await tester.pumpAndSettle();

      // Navigate to Weight category
      final weightCard = find.text('Weight');
      await tester.tap(weightCard);
      await tester.pumpAndSettle();

      // Check that Milligram is not visible
      expect(find.text('Milligram'), findsNothing);
      expect(find.text('mg'), findsNothing);
      
      // Verify common weight units are visible
      expect(find.text('Gram'), findsOneWidget);
      expect(find.text('Kilogram'), findsOneWidget);
      expect(find.text('Pound'), findsOneWidget);
    });

    testWidgets('should show enabled weight units after enabling', (WidgetTester tester) async {
      // Enable Milligram
      await UnitSettingsService.toggleUnitVisibility('Milligram');
      
      await tester.pumpWidget(const UnitConverterApp());
      await tester.pumpAndSettle();

      // Navigate to Weight category
      final weightCard = find.text('Weight');
      await tester.tap(weightCard);
      await tester.pumpAndSettle();

      // Milligram should now be visible
      expect(find.text('Milligram'), findsOneWidget);
      expect(find.text('mg'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle multiple low-value units in Cooking category', (WidgetTester tester) async {
      await tester.pumpWidget(const UnitConverterApp());
      await tester.pumpAndSettle();

      // Navigate to Cooking category
      final cookingCard = find.text('Cooking');
      await tester.tap(cookingCard);
      await tester.pumpAndSettle();

      // Both Pinch and Dash should be hidden by default
      expect(find.text('Pinch'), findsNothing);
      expect(find.text('Dash'), findsNothing);
      expect(find.text('pinch'), findsNothing);
      expect(find.text('dash'), findsNothing);
      
      // Common cooking units should be visible
      expect(find.text('Teaspoon'), findsOneWidget);
      expect(find.text('Tablespoon'), findsOneWidget);
      expect(find.text('Cup'), findsOneWidget);
    });

    testWidgets('should show individual cooking units when enabled separately', (WidgetTester tester) async {
      // Enable only Pinch
      await UnitSettingsService.toggleUnitVisibility('Pinch');
      
      await tester.pumpWidget(const UnitConverterApp());
      await tester.pumpAndSettle();

      // Navigate to Cooking category
      final cookingCard = find.text('Cooking');
      await tester.tap(cookingCard);
      await tester.pumpAndSettle();

      // Pinch should be visible, Dash should still be hidden
      expect(find.text('Pinch'), findsOneWidget);
      expect(find.text('Dash'), findsNothing);
      expect(find.text('pinch'), findsAtLeastNWidgets(1));
      expect(find.text('dash'), findsNothing);
    });

    testWidgets('should handle Data category low-value units', (WidgetTester tester) async {
      await tester.pumpWidget(const UnitConverterApp());
      await tester.pumpAndSettle();

      // Navigate to Data category
      final dataCard = find.text('Data');
      await tester.tap(dataCard);
      await tester.pumpAndSettle();

      // Bit should be hidden by default
      expect(find.text('Bit'), findsNothing);
      expect(find.text('b'), findsNothing);
      
      // Common data units should be visible
      expect(find.text('Byte'), findsOneWidget);
      expect(find.text('Kilobyte'), findsOneWidget);
      expect(find.text('Megabyte'), findsOneWidget);
    });

    testWidgets('should show enabled data units after enabling', (WidgetTester tester) async {
      // Enable Bit
      await UnitSettingsService.toggleUnitVisibility('Bit');
      
      await tester.pumpWidget(const UnitConverterApp());
      await tester.pumpAndSettle();

      // Navigate to Data category
      final dataCard = find.text('Data');
      await tester.tap(dataCard);
      await tester.pumpAndSettle();

      // Bit should now be visible
      expect(find.text('Bit'), findsOneWidget);
      expect(find.text('b'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle Area category low-value units', (WidgetTester tester) async {
      await tester.pumpWidget(const UnitConverterApp());
      await tester.pumpAndSettle();

      // Navigate to Area category
      final areaCard = find.text('Area');
      await tester.tap(areaCard);
      await tester.pumpAndSettle();

      // Square Millimeter should be hidden by default
      expect(find.text('Square Millimeter'), findsNothing);
      expect(find.text('mm²'), findsNothing);
      
      // Common area units should be visible
      expect(find.text('Square Meter'), findsOneWidget);
      expect(find.text('Square Kilometer'), findsOneWidget);
      expect(find.text('Acre'), findsOneWidget);
    });

    testWidgets('should persist unit visibility across app restarts', (WidgetTester tester) async {
      // Enable a unit
      await UnitSettingsService.toggleUnitVisibility('Micrometer');
      
      // Verify it's enabled
      expect(await UnitSettingsService.isUnitHidden('Micrometer'), false);
      
      // Simulate app restart by creating new widget
      await tester.pumpWidget(const UnitConverterApp());
      await tester.pumpAndSettle();

      // Navigate to Length category
      final lengthCard = find.text('Length');
      await tester.tap(lengthCard);
      await tester.pumpAndSettle();

      // Unit should still be visible
      expect(find.text('Micrometer'), findsOneWidget);
    });

    testWidgets('should handle conversion with enabled low-value units', (WidgetTester tester) async {
      // Enable Micrometer
      await UnitSettingsService.toggleUnitVisibility('Micrometer');
      
      await tester.pumpWidget(const UnitConverterApp());
      await tester.pumpAndSettle();

      // Navigate to Length category
      final lengthCard = find.text('Length');
      await tester.tap(lengthCard);
      await tester.pumpAndSettle();

      // Select Micrometer as input unit
      final micrometerInput = find.text('Micrometer');
      expect(micrometerInput, findsOneWidget);
      await tester.tap(micrometerInput);
      await tester.pumpAndSettle();

      // Select Meter as output unit  
      final meterOutput = find.text('Meter');
      expect(meterOutput, findsOneWidget);
      await tester.tap(meterOutput);
      await tester.pumpAndSettle();

      // Enter a value and verify conversion works
      final inputField = find.byType(TextField).first;
      await tester.enterText(inputField, '1000');
      await tester.pumpAndSettle();

      // Should show conversion result
      expect(find.text('0.001'), findsOneWidget); // 1000 micrometers = 0.001 meters
    });

    testWidgets('should handle reset to defaults functionality', (WidgetTester tester) async {
      // Enable multiple units
      await UnitSettingsService.toggleUnitVisibility('Micrometer');
      await UnitSettingsService.toggleUnitVisibility('Milligram');
      await UnitSettingsService.toggleUnitVisibility('Bit');
      
      // Verify they're enabled
      expect(await UnitSettingsService.isUnitHidden('Micrometer'), false);
      expect(await UnitSettingsService.isUnitHidden('Milligram'), false);
      expect(await UnitSettingsService.isUnitHidden('Bit'), false);
      
      // Reset to defaults
      await UnitSettingsService.resetToDefaults();
      
      // Verify they're hidden again
      expect(await UnitSettingsService.isUnitHidden('Micrometer'), true);
      expect(await UnitSettingsService.isUnitHidden('Milligram'), true);
      expect(await UnitSettingsService.isUnitHidden('Bit'), true);
      
      // Test in UI
      await tester.pumpWidget(const UnitConverterApp());
      await tester.pumpAndSettle();

      // Navigate to different categories and verify units are hidden
      final lengthCard = find.text('Length');
      await tester.tap(lengthCard);
      await tester.pumpAndSettle();
      expect(find.text('Micrometer'), findsNothing);
    });
  });
}

