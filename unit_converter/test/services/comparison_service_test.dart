import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/models/conversion.dart';
import 'package:unit_converter/services/comparison_service.dart';

void main() {
  group('ComparisonService', () {
    test('should return description for length - inches', () {
      final fromUnit = Unit(name: 'Inch', symbol: 'in', conversionFactor: 0.0254);
      final toUnit = Unit(name: 'Centimeter', symbol: 'cm', conversionFactor: 0.01);
      
      final result = ComparisonService.describe(
        categoryName: 'Length',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, '1 inch is about the width of an adult thumb.');
    });

    test('should return description for length - feet', () {
      final fromUnit = Unit(name: 'Foot', symbol: 'ft', conversionFactor: 0.3048);
      final toUnit = Unit(name: 'Meter', symbol: 'm', conversionFactor: 1.0);
      
      final result = ComparisonService.describe(
        categoryName: 'Length',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, '1 foot is roughly the length of a standard ruler.');
    });

    test('should return description for length - meters', () {
      final fromUnit = Unit(name: 'Meter', symbol: 'm', conversionFactor: 1.0);
      final toUnit = Unit(name: 'Foot', symbol: 'ft', conversionFactor: 0.3048);
      
      final result = ComparisonService.describe(
        categoryName: 'Length',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, '1 meter is a little taller than a kitchen counter.');
    });

    test('should return description for length - kilometers', () {
      final fromUnit = Unit(name: 'Kilometer', symbol: 'km', conversionFactor: 1000.0);
      final toUnit = Unit(name: 'Meter', symbol: 'm', conversionFactor: 1.0);
      
      final result = ComparisonService.describe(
        categoryName: 'Length',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, '1 kilometer is about a 10-minute walk.');
    });

    test('should return description for weight - pounds', () {
      final fromUnit = Unit(name: 'Pound', symbol: 'lb', conversionFactor: 0.453592);
      final toUnit = Unit(name: 'Kilogram', symbol: 'kg', conversionFactor: 1.0);
      
      final result = ComparisonService.describe(
        categoryName: 'Weight',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, '1 pound is close to a loaf of sandwich bread.');
    });

    test('should return description for weight - kilograms', () {
      final fromUnit = Unit(name: 'Kilogram', symbol: 'kg', conversionFactor: 1.0);
      final toUnit = Unit(name: 'Pound', symbol: 'lb', conversionFactor: 0.453592);
      
      final result = ComparisonService.describe(
        categoryName: 'Weight',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, '1 kilogram is about the mass of a liter of water.');
    });

    test('should return description for volume - liters', () {
      final fromUnit = Unit(name: 'Liter', symbol: 'L', conversionFactor: 1.0);
      final toUnit = Unit(name: 'Milliliter', symbol: 'mL', conversionFactor: 0.001);
      
      final result = ComparisonService.describe(
        categoryName: 'Volume',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, '1 liter is about a standard reusable water bottle.');
    });

    test('should return description for volume - gallons', () {
      final fromUnit = Unit(name: 'Gallon (US)', symbol: 'gal', conversionFactor: 3.785411784);
      final toUnit = Unit(name: 'Liter', symbol: 'L', conversionFactor: 1.0);
      
      final result = ComparisonService.describe(
        categoryName: 'Volume',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, '1 US gallon is roughly 3.8 one-liter bottles.');
    });

    test('should return description for volume - cups', () {
      final fromUnit = Unit(name: 'Cup (US)', symbol: 'cup', conversionFactor: 0.236588);
      final toUnit = Unit(name: 'Milliliter', symbol: 'mL', conversionFactor: 0.001);
      
      final result = ComparisonService.describe(
        categoryName: 'Volume',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, '1 US cup is close to a typical coffee mug serving.');
    });

    test('should return description for temperature - Fahrenheit', () {
      final fromUnit = Unit(name: 'Fahrenheit', symbol: '°F', conversionFactor: 1.0);
      final toUnit = Unit(name: 'Celsius', symbol: '°C', conversionFactor: 1.0);
      
      final result = ComparisonService.describe(
        categoryName: 'Temperature',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, '32°F is the freezing point of water and 212°F is boiling.');
    });

    test('should return description for temperature - Celsius', () {
      final fromUnit = Unit(name: 'Celsius', symbol: '°C', conversionFactor: 1.0);
      final toUnit = Unit(name: 'Fahrenheit', symbol: '°F', conversionFactor: 1.0);
      
      final result = ComparisonService.describe(
        categoryName: 'Temperature',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, '0°C is freezing and 100°C is boiling at sea level.');
    });

    test('should return description for area - acres', () {
      final fromUnit = Unit(name: 'Acre', symbol: 'ac', conversionFactor: 4046.8564224);
      final toUnit = Unit(name: 'Square Meter', symbol: 'm²', conversionFactor: 1.0);
      
      final result = ComparisonService.describe(
        categoryName: 'Area',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, '1 acre is a little smaller than a football field.');
    });

    test('should return description for area - square meters', () {
      final fromUnit = Unit(name: 'Square Meter', symbol: 'm²', conversionFactor: 1.0);
      final toUnit = Unit(name: 'Square Foot', symbol: 'ft²', conversionFactor: 0.092903);
      
      final result = ComparisonService.describe(
        categoryName: 'Area',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, '1 square meter is about the area of a small desk.');
    });

    test('should return null when fromUnit is null', () {
      final toUnit = Unit(name: 'Meter', symbol: 'm', conversionFactor: 1.0);
      
      final result = ComparisonService.describe(
        categoryName: 'Length',
        fromUnit: null,
        toUnit: toUnit,
      );
      
      expect(result, isNull);
    });

    test('should return null when toUnit is null', () {
      final fromUnit = Unit(name: 'Meter', symbol: 'm', conversionFactor: 1.0);
      
      final result = ComparisonService.describe(
        categoryName: 'Length',
        fromUnit: fromUnit,
        toUnit: null,
      );
      
      expect(result, isNull);
    });

    test('should return null for unsupported units in Length category', () {
      final fromUnit = Unit(name: 'Centimeter', symbol: 'cm', conversionFactor: 0.01);
      final toUnit = Unit(name: 'Millimeter', symbol: 'mm', conversionFactor: 0.001);
      
      final result = ComparisonService.describe(
        categoryName: 'Length',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, isNull);
    });

    test('should return null for unsupported category', () {
      final fromUnit = Unit(name: 'Meter', symbol: 'm', conversionFactor: 1.0);
      final toUnit = Unit(name: 'Foot', symbol: 'ft', conversionFactor: 0.3048);
      
      final result = ComparisonService.describe(
        categoryName: 'Speed',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, isNull);
    });

    test('should return null for Time category', () {
      final fromUnit = Unit(name: 'Hour', symbol: 'hr', conversionFactor: 3600.0);
      final toUnit = Unit(name: 'Minute', symbol: 'min', conversionFactor: 60.0);
      
      final result = ComparisonService.describe(
        categoryName: 'Time',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, isNull);
    });

    test('should return null for unsupported Weight units', () {
      final fromUnit = Unit(name: 'Gram', symbol: 'g', conversionFactor: 0.001);
      final toUnit = Unit(name: 'Milligram', symbol: 'mg', conversionFactor: 0.000001);
      
      final result = ComparisonService.describe(
        categoryName: 'Weight',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, isNull);
    });

    test('should return description for data - megabytes', () {
      final fromUnit = Unit(name: 'Megabyte', symbol: 'MB', conversionFactor: 1000000.0);
      final toUnit = Unit(name: 'Byte', symbol: 'B', conversionFactor: 1.0);
      
      final result = ComparisonService.describe(
        categoryName: 'Data',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, '1 megabyte is roughly a high-quality photo from a phone camera.');
    });

    test('should return description for data - gigabytes', () {
      final fromUnit = Unit(name: 'Gigabyte', symbol: 'GB', conversionFactor: 1000000000.0);
      final toUnit = Unit(name: 'Megabyte', symbol: 'MB', conversionFactor: 1000000.0);
      
      final result = ComparisonService.describe(
        categoryName: 'Data',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, '1 gigabyte can cover hours of music or a standard-definition movie.');
    });

    test('should return description for pressure - psi', () {
      final fromUnit = Unit(name: 'PSI', symbol: 'psi', conversionFactor: 6894.757293168);
      final toUnit = Unit(name: 'Pascal', symbol: 'Pa', conversionFactor: 1.0);
      
      final result = ComparisonService.describe(
        categoryName: 'Pressure',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, '32 psi is a common target for car tire pressure.');
    });

    test('should return description for pressure - bar', () {
      final fromUnit = Unit(name: 'Bar', symbol: 'bar', conversionFactor: 100000.0);
      final toUnit = Unit(name: 'Pascal', symbol: 'Pa', conversionFactor: 1.0);
      
      final result = ComparisonService.describe(
        categoryName: 'Pressure',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, '1 bar is close to the air pressure you feel at sea level.');
    });

    test('should return description for cooking - tablespoon', () {
      final fromUnit = Unit(name: 'Tablespoon', symbol: 'tbsp', conversionFactor: 0.01478676478125);
      final toUnit = Unit(name: 'Teaspoon', symbol: 'tsp', conversionFactor: 0.00492892159375);
      
      final result = ComparisonService.describe(
        categoryName: 'Cooking',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, '1 tablespoon is about the bowl of a large soup spoon.');
    });

    test('should return description for cooking - cup', () {
      final fromUnit = Unit(name: 'Cup', symbol: 'cup', conversionFactor: 0.2365882365);
      final toUnit = Unit(name: 'Milliliter', symbol: 'mL', conversionFactor: 0.001);
      
      final result = ComparisonService.describe(
        categoryName: 'Cooking',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, '1 cup is about the volume of a small breakfast mug.');
    });

    test('should return null for Speed category (no comparisons defined)', () {
      final fromUnit = Unit(name: 'Mile per Hour', symbol: 'mph', conversionFactor: 0.44704);
      final toUnit = Unit(name: 'Kilometer per Hour', symbol: 'km/h', conversionFactor: 0.2777777778);
      
      final result = ComparisonService.describe(
        categoryName: 'Speed',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, isNull);
    });

    test('should return null for Data category with Bit unit', () {
      final fromUnit = Unit(name: 'Bit', symbol: 'b', conversionFactor: 0.125);
      final toUnit = Unit(name: 'Byte', symbol: 'B', conversionFactor: 1.0);
      
      final result = ComparisonService.describe(
        categoryName: 'Data',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, isNull);
    });

    test('should return null for Pressure category with Pascal unit', () {
      final fromUnit = Unit(name: 'Pascal', symbol: 'Pa', conversionFactor: 1.0);
      final toUnit = Unit(name: 'Atmosphere', symbol: 'atm', conversionFactor: 101325.0);
      
      final result = ComparisonService.describe(
        categoryName: 'Pressure',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, isNull);
    });

    test('should return null for Kelvin temperature (no comparisons defined)', () {
      final fromUnit = Unit(name: 'Kelvin', symbol: 'K', conversionFactor: 1.0);
      final toUnit = Unit(name: 'Celsius', symbol: '°C', conversionFactor: 1.0);
      
      final result = ComparisonService.describe(
        categoryName: 'Temperature',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, isNull);
    });

    test('should return null for Volume category with unsupported units', () {
      final fromUnit = Unit(name: 'Milliliter', symbol: 'mL', conversionFactor: 0.001);
      final toUnit = Unit(name: 'Liter', symbol: 'L', conversionFactor: 1.0);
      
      final result = ComparisonService.describe(
        categoryName: 'Volume',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, isNull);
    });

    test('should return null for Area category with unsupported units', () {
      final fromUnit = Unit(name: 'Square Meter', symbol: 'm²', conversionFactor: 1.0);
      final toUnit = Unit(name: 'Hectare', symbol: 'ha', conversionFactor: 10000.0);
      
      final result = ComparisonService.describe(
        categoryName: 'Area',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
      
      expect(result, isNull);
    });
  });
}
