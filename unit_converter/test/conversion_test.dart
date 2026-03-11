import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/models/conversion.dart';

Unit _unitBySymbol(ConversionCategory category, String symbol) {
  return category.units.firstWhere((unit) => unit.symbol == symbol);
}

void main() {
  group('Unit Model', () {
    test('should create a Unit with correct properties', () {
      final unit = Unit(name: 'Meter', symbol: 'm', conversionFactor: 1.0);

      expect(unit.name, 'Meter');
      expect(unit.symbol, 'm');
      expect(unit.conversionFactor, 1.0);
    });
  });

  group('ConversionCategory Model', () {
    test('should create a ConversionCategory with correct properties', () {
      final category = ConversionCategory(
        name: 'Length',
        icon: 'straighten',
        units: [
          Unit(name: 'Meter', symbol: 'm', conversionFactor: 1.0),
          Unit(name: 'Kilometer', symbol: 'km', conversionFactor: 1000.0),
        ],
      );

      expect(category.name, 'Length');
      expect(category.icon, 'straighten');
      expect(category.units.length, 2);
      expect(category.units[0].name, 'Meter');
    });
  });

  group('RecentConversion Model', () {
    test('should serialize and deserialize correctly', () {
      final original = RecentConversion(
        category: 'Weight',
        fromUnit: 'kg',
        toUnit: 'lb',
        inputValue: 1.0,
        outputValue: 2.20462,
        timestamp: DateTime(2024, 1, 15, 10, 30),
      );

      final restored = RecentConversion.fromJson(original.toJson());

      expect(restored.category, original.category);
      expect(restored.fromUnit, original.fromUnit);
      expect(restored.toUnit, original.toUnit);
      expect(restored.inputValue, original.inputValue);
      expect(restored.outputValue, original.outputValue);
      expect(restored.timestamp, original.timestamp);
    });
  });

  group('ConversionData', () {
    test('should have all 10 categories', () {
      expect(ConversionData.categories.length, 10);
    });

    test('length category includes core metric and imperial units', () {
      expect(
        ConversionData.lengthCategory.units.length,
        greaterThanOrEqualTo(10),
      );
      expect(_unitBySymbol(ConversionData.lengthCategory, 'm').name, 'Meter');
      expect(_unitBySymbol(ConversionData.lengthCategory, 'ft').name, 'Foot');
      expect(_unitBySymbol(ConversionData.lengthCategory, 'mi').name, 'Mile');
    });

    test('weight category includes common imperial units', () {
      expect(
        ConversionData.weightCategory.units.length,
        greaterThanOrEqualTo(8),
      );
      expect(_unitBySymbol(ConversionData.weightCategory, 'oz').name, 'Ounce');
      expect(_unitBySymbol(ConversionData.weightCategory, 'lb').name, 'Pound');
      expect(
        _unitBySymbol(ConversionData.weightCategory, 'ton').name,
        'US Ton',
      );
    });

    test('volume category includes US and imperial variants', () {
      expect(
        ConversionData.volumeCategory.units.length,
        greaterThanOrEqualTo(12),
      );
      expect(
        _unitBySymbol(ConversionData.volumeCategory, 'gal').name,
        'Gallon (US)',
      );
      expect(
        _unitBySymbol(ConversionData.volumeCategory, 'imp gal').name,
        'Gallon (Imperial)',
      );
      expect(
        _unitBySymbol(ConversionData.volumeCategory, 'tsp').name,
        'Teaspoon (US)',
      );
    });

    test('area category includes square yard and square mile', () {
      expect(
        ConversionData.areaCategory.units.length,
        greaterThanOrEqualTo(10),
      );
      expect(
        _unitBySymbol(ConversionData.areaCategory, 'yd²').name,
        'Square Yard',
      );
      expect(
        _unitBySymbol(ConversionData.areaCategory, 'mi²').name,
        'Square Mile',
      );
    });

    test('data category includes common file-size units', () {
      expect(_unitBySymbol(ConversionData.dataCategory, 'B').name, 'Byte');
      expect(_unitBySymbol(ConversionData.dataCategory, 'MB').name, 'Megabyte');
      expect(_unitBySymbol(ConversionData.dataCategory, 'GB').name, 'Gigabyte');
    });

    test('pressure category includes engineering and everyday units', () {
      expect(_unitBySymbol(ConversionData.pressureCategory, 'Pa').name, 'Pascal');
      expect(_unitBySymbol(ConversionData.pressureCategory, 'psi').name, 'PSI');
      expect(_unitBySymbol(ConversionData.pressureCategory, 'bar').name, 'Bar');
    });

    test('cooking category includes kitchen-friendly measures', () {
      expect(_unitBySymbol(ConversionData.cookingCategory, 'tsp').name, 'Teaspoon');
      expect(_unitBySymbol(ConversionData.cookingCategory, 'tbsp').name, 'Tablespoon');
      expect(_unitBySymbol(ConversionData.cookingCategory, 'cup').name, 'Cup');
    });
  });

  group('Length Conversions', () {
    test('should convert meters to kilometers', () {
      final result = ConversionData.convert(
        1000.0,
        _unitBySymbol(ConversionData.lengthCategory, 'm'),
        _unitBySymbol(ConversionData.lengthCategory, 'km'),
        'Length',
      );
      expect(result, closeTo(1.0, 0.0001));
    });

    test('should convert inches to centimeters', () {
      final result = ConversionData.convert(
        1.0,
        _unitBySymbol(ConversionData.lengthCategory, 'in'),
        _unitBySymbol(ConversionData.lengthCategory, 'cm'),
        'Length',
      );
      expect(result, closeTo(2.54, 0.0001));
    });

    test('should convert miles to kilometers', () {
      final result = ConversionData.convert(
        1.0,
        _unitBySymbol(ConversionData.lengthCategory, 'mi'),
        _unitBySymbol(ConversionData.lengthCategory, 'km'),
        'Length',
      );
      expect(result, closeTo(1.609344, 0.0001));
    });
  });

  group('Weight Conversions', () {
    test('should convert kilograms to pounds', () {
      final result = ConversionData.convert(
        1.0,
        _unitBySymbol(ConversionData.weightCategory, 'kg'),
        _unitBySymbol(ConversionData.weightCategory, 'lb'),
        'Weight',
      );
      expect(result, closeTo(2.20462262, 0.0001));
    });

    test('should convert ounces to grams', () {
      final result = ConversionData.convert(
        1.0,
        _unitBySymbol(ConversionData.weightCategory, 'oz'),
        _unitBySymbol(ConversionData.weightCategory, 'g'),
        'Weight',
      );
      expect(result, closeTo(28.3495, 0.0001));
    });
  });

  group('Temperature Conversions', () {
    test('should convert Celsius to Fahrenheit', () {
      final result = ConversionData.convert(
        0.0,
        _unitBySymbol(ConversionData.temperatureCategory, '°C'),
        _unitBySymbol(ConversionData.temperatureCategory, '°F'),
        'Temperature',
      );
      expect(result, closeTo(32.0, 0.0001));
    });

    test('should convert Fahrenheit to Celsius', () {
      final result = ConversionData.convert(
        212.0,
        _unitBySymbol(ConversionData.temperatureCategory, '°F'),
        _unitBySymbol(ConversionData.temperatureCategory, '°C'),
        'Temperature',
      );
      expect(result, closeTo(100.0, 0.0001));
    });
  });

  group('Volume Conversions', () {
    test('should convert US gallons to liters', () {
      final result = ConversionData.convert(
        1.0,
        _unitBySymbol(ConversionData.volumeCategory, 'gal'),
        _unitBySymbol(ConversionData.volumeCategory, 'L'),
        'Volume',
      );
      expect(result, closeTo(3.785411784, 0.000001));
    });

    test('should convert cups to milliliters', () {
      final result = ConversionData.convert(
        1.0,
        _unitBySymbol(ConversionData.volumeCategory, 'cup'),
        _unitBySymbol(ConversionData.volumeCategory, 'mL'),
        'Volume',
      );
      expect(result, closeTo(236.5882365, 0.000001));
    });
  });

  group('Area Conversions', () {
    test('should convert square feet to square meters', () {
      final result = ConversionData.convert(
        1.0,
        _unitBySymbol(ConversionData.areaCategory, 'ft²'),
        _unitBySymbol(ConversionData.areaCategory, 'm²'),
        'Area',
      );
      expect(result, closeTo(0.09290304, 0.000001));
    });

    test('should convert acres to square meters', () {
      final result = ConversionData.convert(
        1.0,
        _unitBySymbol(ConversionData.areaCategory, 'ac'),
        _unitBySymbol(ConversionData.areaCategory, 'm²'),
        'Area',
      );
      expect(result, closeTo(4046.8564224, 0.000001));
    });
  });

  group('Speed Conversions', () {
    test('should convert mph to km/h', () {
      final result = ConversionData.convert(
        1.0,
        _unitBySymbol(ConversionData.speedCategory, 'mph'),
        _unitBySymbol(ConversionData.speedCategory, 'km/h'),
        'Speed',
      );
      expect(result, closeTo(1.609344, 0.0001));
    });
  });

  group('Time Conversions', () {
    test('should convert years to days', () {
      final result = ConversionData.convert(
        1.0,
        _unitBySymbol(ConversionData.timeCategory, 'yr'),
        _unitBySymbol(ConversionData.timeCategory, 'd'),
        'Time',
      );
      expect(result, closeTo(365.2425, 0.0001));
    });
  });

  group('Data Conversions', () {
    test('should convert bytes to kilobytes', () {
      final result = ConversionData.convert(
        2000,
        _unitBySymbol(ConversionData.dataCategory, 'B'),
        _unitBySymbol(ConversionData.dataCategory, 'KB'),
        'Data',
      );
      expect(result, closeTo(2.0, 0.000001));
    });
  });

  group('Pressure Conversions', () {
    test('should convert psi to kilopascals', () {
      final result = ConversionData.convert(
        1,
        _unitBySymbol(ConversionData.pressureCategory, 'psi'),
        _unitBySymbol(ConversionData.pressureCategory, 'kPa'),
        'Pressure',
      );
      expect(result, closeTo(6.894757293168, 0.000001));
    });
  });

  group('Cooking Conversions', () {
    test('should convert cups to tablespoons', () {
      final result = ConversionData.convert(
        1,
        _unitBySymbol(ConversionData.cookingCategory, 'cup'),
        _unitBySymbol(ConversionData.cookingCategory, 'tbsp'),
        'Cooking',
      );
      expect(result, closeTo(16, 0.000001));
    });
  });

  group('Edge Cases', () {
    test('should handle negative values', () {
      final result = ConversionData.convert(
        -100.0,
        _unitBySymbol(ConversionData.lengthCategory, 'm'),
        _unitBySymbol(ConversionData.lengthCategory, 'km'),
        'Length',
      );
      expect(result, closeTo(-0.1, 0.0001));
    });

    test('should handle very large values', () {
      final result = ConversionData.convert(
        1e10,
        _unitBySymbol(ConversionData.lengthCategory, 'm'),
        _unitBySymbol(ConversionData.lengthCategory, 'km'),
        'Length',
      );
      expect(result, closeTo(1e7, 0.0001));
    });

    test('should handle conversion to same unit', () {
      final result = ConversionData.convert(
        100.0,
        _unitBySymbol(ConversionData.lengthCategory, 'm'),
        _unitBySymbol(ConversionData.lengthCategory, 'm'),
        'Length',
      );
      expect(result, closeTo(100.0, 0.0001));
    });
  });
}
