import 'package:flutter_test/flutter_test.dart';
import '../../lib/models/conversion.dart';
import '../../lib/services/unit_settings_service.dart';

void main() {
  group('Conversion Data Filtering Tests', () {
    setUp(() async {
      // Reset to defaults before each test
      await UnitSettingsService.resetToDefaults();
    });

    testWidgets('should filter Length category units correctly', (WidgetTester tester) async {
      // Get original units
      final originalUnits = ConversionData.lengthCategory.units;
      expect(originalUnits.length, greaterThan(0));

      // Get filtered units (should have fewer due to hidden Micrometer)
      final filteredUnits = await UnitSettingsService.filterUnits(originalUnits);
      
      // Should have fewer units after filtering
      expect(filteredUnits.length, lessThan(originalUnits.length));
      
      // Micrometer should not be in filtered list
      final hasMicrometer = filteredUnits.any((unit) => unit.name == 'Micrometer');
      expect(hasMicrometer, false);
      
      // Common units should still be present
      expect(filteredUnits.any((unit) => unit.name == 'Meter'), true);
      expect(filteredUnits.any((unit) => unit.name == 'Kilometer'), true);
      expect(filteredUnits.any((unit) => unit.name == 'Foot'), true);
    });

    testWidgets('should filter Weight category units correctly', (WidgetTester tester) async {
      final originalUnits = ConversionData.weightCategory.units;
      final filteredUnits = await UnitSettingsService.filterUnits(originalUnits);
      
      // Should have fewer units
      expect(filteredUnits.length, lessThan(originalUnits.length));
      
      // Milligram should not be in filtered list
      final hasMilligram = filteredUnits.any((unit) => unit.name == 'Milligram');
      expect(hasMilligram, false);
      
      // Common units should still be present
      expect(filteredUnits.any((unit) => unit.name == 'Gram'), true);
      expect(filteredUnits.any((unit) => unit.name == 'Kilogram'), true);
      expect(filteredUnits.any((unit) => unit.name == 'Pound'), true);
    });

    testWidgets('should filter Area category units correctly', (WidgetTester tester) async {
      final originalUnits = ConversionData.areaCategory.units;
      final filteredUnits = await UnitSettingsService.filterUnits(originalUnits);
      
      // Should have fewer units
      expect(filteredUnits.length, lessThan(originalUnits.length));
      
      // Square Millimeter should not be in filtered list
      final hasSquareMillimeter = filteredUnits.any((unit) => unit.name == 'Square Millimeter');
      expect(hasSquareMillimeter, false);
      
      // Common units should still be present
      expect(filteredUnits.any((unit) => unit.name == 'Square Meter'), true);
      expect(filteredUnits.any((unit) => unit.name == 'Square Kilometer'), true);
      expect(filteredUnits.any((unit) => unit.name == 'Acre'), true);
    });

    testWidgets('should filter Cooking category units correctly', (WidgetTester tester) async {
      final originalUnits = ConversionData.cookingCategory.units;
      final filteredUnits = await UnitSettingsService.filterUnits(originalUnits);
      
      // Should have fewer units (both Pinch and Dash hidden)
      expect(filteredUnits.length, lessThan(originalUnits.length));
      expect(originalUnits.length - filteredUnits.length, equals(2));
      
      // Pinch and Dash should not be in filtered list
      final hasPinch = filteredUnits.any((unit) => unit.name == 'Pinch');
      final hasDash = filteredUnits.any((unit) => unit.name == 'Dash');
      expect(hasPinch, false);
      expect(hasDash, false);
      
      // Common units should still be present
      expect(filteredUnits.any((unit) => unit.name == 'Teaspoon'), true);
      expect(filteredUnits.any((unit) => unit.name == 'Tablespoon'), true);
      expect(filteredUnits.any((unit) => unit.name == 'Cup'), true);
    });

    testWidgets('should filter Data category units correctly', (WidgetTester tester) async {
      final originalUnits = ConversionData.dataCategory.units;
      final filteredUnits = await UnitSettingsService.filterUnits(originalUnits);
      
      // Should have fewer units
      expect(filteredUnits.length, lessThan(originalUnits.length));
      
      // Bit should not be in filtered list
      final hasBit = filteredUnits.any((unit) => unit.name == 'Bit');
      expect(hasBit, false);
      
      // Common units should still be present
      expect(filteredUnits.any((unit) => unit.name == 'Byte'), true);
      expect(filteredUnits.any((unit) => unit.name == 'Kilobyte'), true);
      expect(filteredUnits.any((unit) => unit.name == 'Megabyte'), true);
    });

    testWidgets('should not filter categories without low-value units', (WidgetTester tester) async {
      // Temperature category has no low-value units by default
      final originalTempUnits = ConversionData.temperatureCategory.units;
      final filteredTempUnits = await UnitSettingsService.filterUnits(originalTempUnits);
      
      // Should have same number of units
      expect(filteredTempUnits.length, equals(originalTempUnits.length));
      
      // All units should be present
      for (final unit in originalTempUnits) {
        expect(filteredTempUnits.any((u) => u.name == unit.name), true);
      }

      // Speed category also has no low-value units
      final originalSpeedUnits = ConversionData.speedCategory.units;
      final filteredSpeedUnits = await UnitSettingsService.filterUnits(originalSpeedUnits);
      
      expect(filteredSpeedUnits.length, equals(originalSpeedUnits.length));
      
      // Pressure category has no low-value units
      final originalPressureUnits = ConversionData.pressureCategory.units;
      final filteredPressureUnits = await UnitSettingsService.filterUnits(originalPressureUnits);
      
      expect(filteredPressureUnits.length, equals(originalPressureUnits.length));
      
      // Time category has Millisecond but it's not in default hidden units
      final originalTimeUnits = ConversionData.timeCategory.units;
      final filteredTimeUnits = await UnitSettingsService.filterUnits(originalTimeUnits);
      
      expect(filteredTimeUnits.length, equals(originalTimeUnits.length));
    });

    testWidgets('should show enabled units after enabling them', (WidgetTester tester) async {
      // Enable a hidden unit
      await UnitSettingsService.toggleUnitVisibility('Micrometer');
      
      final originalUnits = ConversionData.lengthCategory.units;
      final filteredUnits = await UnitSettingsService.filterUnits(originalUnits);
      
      // Should now have same number of units as original
      expect(filteredUnits.length, equals(originalUnits.length));
      
      // Micrometer should now be present
      expect(filteredUnits.any((unit) => unit.name == 'Micrometer'), true);
    });

    testWidgets('should handle multiple enabled/disabled units', (WidgetTester tester) async {
      // Enable some units, disable others
      await UnitSettingsService.toggleUnitVisibility('Micrometer'); // Enable
      await UnitSettingsService.toggleUnitVisibility('Milligram'); // Enable
      await UnitSettingsService.setHiddenUnits({'Bit', 'Square Millimeter', 'Pinch'}); // Custom set
      
      // Test Length category
      final lengthUnits = ConversionData.lengthCategory.units;
      final filteredLength = await UnitSettingsService.filterUnits(lengthUnits);
      expect(filteredLength.any((unit) => unit.name == 'Micrometer'), true);
      expect(filteredLength.any((unit) => unit.name == 'Square Millimeter'), false);
      
      // Test Weight category
      final weightUnits = ConversionData.weightCategory.units;
      final filteredWeight = await UnitSettingsService.filterUnits(weightUnits);
      expect(filteredWeight.any((unit) => unit.name == 'Milligram'), true);
      
      // Test Data category
      final dataUnits = ConversionData.dataCategory.units;
      final filteredData = await UnitSettingsService.filterUnits(dataUnits);
      expect(filteredData.any((unit) => unit.name == 'Bit'), false);
      
      // Test Cooking category
      final cookingUnits = ConversionData.cookingCategory.units;
      final filteredCooking = await UnitSettingsService.filterUnits(cookingUnits);
      expect(filteredCooking.any((unit) => unit.name == 'Pinch'), false);
      expect(filteredCooking.any((unit) => unit.name == 'Dash'), true); // Dash should be visible
    });

    testWidgets('should get categories with custom units and filtering', (WidgetTester tester) async {
      // Get categories with filtering applied
      final categories = await ConversionData.getCategoriesWithCustomUnits();
      
      expect(categories.length, equals(ConversionData.categories.length));
      
      // Check Length category filtering
      final lengthCategory = categories.firstWhere((cat) => cat.name == 'Length');
      expect(lengthCategory.units.any((unit) => unit.name == 'Micrometer'), false);
      expect(lengthCategory.units.any((unit) => unit.name == 'Meter'), true);
      
      // Check Weight category filtering
      final weightCategory = categories.firstWhere((cat) => cat.name == 'Weight');
      expect(weightCategory.units.any((unit) => unit.name == 'Milligram'), false);
      expect(weightCategory.units.any((unit) => unit.name == 'Kilogram'), true);
    });

    testWidgets('should get specific category with filtering', (WidgetTester tester) async {
      // Get specific category with filtering
      final lengthCategory = await ConversionData.getCategoryWithCustomUnits('Length');
      
      expect(lengthCategory, isNotNull);
      expect(lengthCategory!.name, equals('Length'));
      
      // Should be filtered
      expect(lengthCategory.units.any((unit) => unit.name == 'Micrometer'), false);
      expect(lengthCategory.units.any((unit) => unit.name == 'Meter'), true);
    });

    testWidgets('should handle empty hidden units list', (WidgetTester tester) async {
      // Set empty hidden units (show all units)
      await UnitSettingsService.setHiddenUnits(<String>{});
      
      final originalUnits = ConversionData.lengthCategory.units;
      final filteredUnits = await UnitSettingsService.filterUnits(originalUnits);
      
      // Should have same number of units
      expect(filteredUnits.length, equals(originalUnits.length));
      
      // All units should be present
      for (final unit in originalUnits) {
        expect(filteredUnits.any((u) => u.name == unit.name), true);
      }
    });

    testWidgets('should handle all units hidden', (WidgetTester tester) async {
      // Hide all units in Length category
      final allLengthUnitNames = ConversionData.lengthCategory.units.map((u) => u.name).toSet();
      await UnitSettingsService.setHiddenUnits(allLengthUnitNames);
      
      final originalUnits = ConversionData.lengthCategory.units;
      final filteredUnits = await UnitSettingsService.filterUnits(originalUnits);
      
      // Should have no units
      expect(filteredUnits.length, equals(0));
    });
  });
}

