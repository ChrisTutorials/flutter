import 'package:flutter_test/flutter_test.dart';

import 'package:unit_converter/models/conversion.dart';
import 'package:unit_converter/services/formula_service.dart';

void main() {
  group('FormulaService', () {
    group('buildFormula', () {
      test('returns placeholder when fromUnit is null', () {
        final formula = FormulaService.buildFormula(
          categoryName: 'Length',
          fromUnit: null,
          toUnit: ConversionData.lengthCategory.units.firstWhere(
            (unit) => unit.symbol == 'm',
          ),
        );
        expect(formula, 'Select two units to view the formula.');
      });

      test('returns placeholder when toUnit is null', () {
        final formula = FormulaService.buildFormula(
          categoryName: 'Length',
          fromUnit: ConversionData.lengthCategory.units.firstWhere(
            (unit) => unit.symbol == 'm',
          ),
          toUnit: null,
        );
        expect(formula, 'Select two units to view the formula.');
      });

      test('uses factor math for non-temperature categories', () {
        final formula = FormulaService.buildFormula(
          categoryName: 'Length',
          fromUnit: ConversionData.lengthCategory.units.firstWhere(
            (unit) => unit.symbol == 'ft',
          ),
          toUnit: ConversionData.lengthCategory.units.firstWhere(
            (unit) => unit.symbol == 'm',
          ),
        );

        expect(formula, contains('0.3048'));
        expect(formula, contains('÷'));
      });

      test('returns correct formula for Celsius to Fahrenheit', () {
        final formula = FormulaService.buildFormula(
          categoryName: 'Temperature',
          fromUnit: ConversionData.temperatureCategory.units.firstWhere(
            (unit) => unit.symbol == '°C',
          ),
          toUnit: ConversionData.temperatureCategory.units.firstWhere(
            (unit) => unit.symbol == '°F',
          ),
        );
        expect(formula, '(value × 9 / 5) + 32');
      });

      test('returns correct formula for Fahrenheit to Celsius', () {
        final formula = FormulaService.buildFormula(
          categoryName: 'Temperature',
          fromUnit: ConversionData.temperatureCategory.units.firstWhere(
            (unit) => unit.symbol == '°F',
          ),
          toUnit: ConversionData.temperatureCategory.units.firstWhere(
            (unit) => unit.symbol == '°C',
          ),
        );
        expect(formula, '(value - 32) × 5 / 9');
      });

      test('returns correct formula for Celsius to Kelvin', () {
        final formula = FormulaService.buildFormula(
          categoryName: 'Temperature',
          fromUnit: ConversionData.temperatureCategory.units.firstWhere(
            (unit) => unit.symbol == '°C',
          ),
          toUnit: ConversionData.temperatureCategory.units.firstWhere(
            (unit) => unit.symbol == 'K',
          ),
        );
        expect(formula, 'value + 273.15');
      });

      test('returns correct formula for Kelvin to Celsius', () {
        final formula = FormulaService.buildFormula(
          categoryName: 'Temperature',
          fromUnit: ConversionData.temperatureCategory.units.firstWhere(
            (unit) => unit.symbol == 'K',
          ),
          toUnit: ConversionData.temperatureCategory.units.firstWhere(
            (unit) => unit.symbol == '°C',
          ),
        );
        expect(formula, 'value - 273.15');
      });

      test('returns correct formula for Fahrenheit to Kelvin', () {
        final formula = FormulaService.buildFormula(
          categoryName: 'Temperature',
          fromUnit: ConversionData.temperatureCategory.units.firstWhere(
            (unit) => unit.symbol == '°F',
          ),
          toUnit: ConversionData.temperatureCategory.units.firstWhere(
            (unit) => unit.symbol == 'K',
          ),
        );
        expect(formula, '((value - 32) × 5 / 9) + 273.15');
      });

      test('returns correct formula for Kelvin to Fahrenheit', () {
        final formula = FormulaService.buildFormula(
          categoryName: 'Temperature',
          fromUnit: ConversionData.temperatureCategory.units.firstWhere(
            (unit) => unit.symbol == 'K',
          ),
          toUnit: ConversionData.temperatureCategory.units.firstWhere(
            (unit) => unit.symbol == '°F',
          ),
        );
        expect(formula, '((value - 273.15) × 9 / 5) + 32');
      });

      test('returns "value" when same temperature unit', () {
        final formula = FormulaService.buildFormula(
          categoryName: 'Temperature',
          fromUnit: ConversionData.temperatureCategory.units.firstWhere(
            (unit) => unit.symbol == '°C',
          ),
          toUnit: ConversionData.temperatureCategory.units.firstWhere(
            (unit) => unit.symbol == '°C',
          ),
        );
        expect(formula, 'value');
      });
    });

    group('buildCalculation', () {
      test('returns null when fromUnit is null', () {
        final calculation = FormulaService.buildCalculation(
          categoryName: 'Length',
          fromUnit: null,
          toUnit: ConversionData.lengthCategory.units.firstWhere(
            (unit) => unit.symbol == 'm',
          ),
          inputValue: 100,
        );
        expect(calculation, isNull);
      });

      test('returns null when inputValue is null', () {
        final calculation = FormulaService.buildCalculation(
          categoryName: 'Length',
          fromUnit: ConversionData.lengthCategory.units.firstWhere(
            (unit) => unit.symbol == 'm',
          ),
          toUnit: ConversionData.lengthCategory.units.firstWhere(
            (unit) => unit.symbol == 'km',
          ),
          inputValue: null,
        );
        expect(calculation, isNull);
      });

      test('builds correct calculation for length conversion', () {
        final calculation = FormulaService.buildCalculation(
          categoryName: 'Length',
          fromUnit: ConversionData.lengthCategory.units.firstWhere(
            (unit) => unit.symbol == 'm',
          ),
          toUnit: ConversionData.lengthCategory.units.firstWhere(
            (unit) => unit.symbol == 'km',
          ),
          inputValue: 1000,
        );
        expect(calculation, isNotNull);
        expect(calculation, contains('×'));
        expect(calculation, contains('÷'));
        expect(calculation, contains('1000'));
      });

      test('uses temperature-specific math for Celsius to Fahrenheit', () {
        final calculation = FormulaService.buildCalculation(
          categoryName: 'Temperature',
          fromUnit: ConversionData.temperatureCategory.units.firstWhere(
            (unit) => unit.symbol == '°C',
          ),
          toUnit: ConversionData.temperatureCategory.units.firstWhere(
            (unit) => unit.symbol == '°F',
          ),
          inputValue: 10,
        );

        expect(calculation, contains('× 9 / 5'));
        expect(calculation, contains('50'));
      });

      test('uses temperature-specific math for Fahrenheit to Celsius', () {
        final calculation = FormulaService.buildCalculation(
          categoryName: 'Temperature',
          fromUnit: ConversionData.temperatureCategory.units.firstWhere(
            (unit) => unit.symbol == '°F',
          ),
          toUnit: ConversionData.temperatureCategory.units.firstWhere(
            (unit) => unit.symbol == '°C',
          ),
          inputValue: 212,
        );

        expect(calculation, contains('- 32'));
        expect(calculation, contains('× 5 / 9'));
        expect(calculation, contains('100'));
      });

      test('uses temperature-specific math for Celsius to Kelvin', () {
        final calculation = FormulaService.buildCalculation(
          categoryName: 'Temperature',
          fromUnit: ConversionData.temperatureCategory.units.firstWhere(
            (unit) => unit.symbol == '°C',
          ),
          toUnit: ConversionData.temperatureCategory.units.firstWhere(
            (unit) => unit.symbol == 'K',
          ),
          inputValue: 0,
        );

        expect(calculation, contains('+ 273.15'));
        expect(calculation, contains('273.15'));
      });

      test('uses temperature-specific math for Kelvin to Celsius', () {
        final calculation = FormulaService.buildCalculation(
          categoryName: 'Temperature',
          fromUnit: ConversionData.temperatureCategory.units.firstWhere(
            (unit) => unit.symbol == 'K',
          ),
          toUnit: ConversionData.temperatureCategory.units.firstWhere(
            (unit) => unit.symbol == '°C',
          ),
          inputValue: 273.15,
        );

        expect(calculation, contains('- 273.15'));
        expect(calculation, contains('0'));
      });
    });
  });
}