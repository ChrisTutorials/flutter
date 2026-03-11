import 'package:flutter_test/flutter_test.dart';

import 'package:unit_converter/models/conversion.dart';
import 'package:unit_converter/services/formula_service.dart';

void main() {
  test('buildFormula uses factor math for non-temperature categories', () {
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

  test('buildCalculation uses temperature-specific math', () {
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
}