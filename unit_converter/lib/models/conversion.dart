import '../services/custom_units_service.dart';
import '../services/unit_settings_service.dart';

/// Model representing a unit type with its conversion factor to base unit.
class Unit {
  final String name;
  final String symbol;
  final double conversionFactor;

  Unit({
    required this.name,
    required this.symbol,
    required this.conversionFactor,
  });

  /// Create a Unit from a CustomUnit
  factory Unit.fromCustomUnit(CustomUnit customUnit) {
    return Unit(
      name: customUnit.name,
      symbol: customUnit.symbol,
      conversionFactor: customUnit.conversionFactor,
    );
  }
}

/// Model representing a user-defined custom unit.
class CustomUnit {
  final String id;
  final String name;
  final String symbol;
  final double conversionFactor;
  final String categoryName;
  final DateTime createdAt;

  CustomUnit({
    required this.id,
    required this.name,
    required this.symbol,
    required this.conversionFactor,
    required this.categoryName,
    required this.createdAt,
  });

  CustomUnit copyWith({
    String? id,
    String? name,
    String? symbol,
    double? conversionFactor,
    String? categoryName,
    DateTime? createdAt,
  }) {
    return CustomUnit(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      conversionFactor: conversionFactor ?? this.conversionFactor,
      categoryName: categoryName ?? this.categoryName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'conversionFactor': conversionFactor,
      'categoryName': categoryName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustomUnit.fromJson(Map<String, dynamic> json) {
    return CustomUnit(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      conversionFactor: json['conversionFactor'],
      categoryName: json['categoryName'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// Model representing a conversion category.
class ConversionCategory {
  final String name;
  final String icon;
  final List<Unit> units;

  ConversionCategory({
    required this.name,
    required this.icon,
    required this.units,
  });
}

/// Model representing a recent conversion.
class RecentConversion {
  final String category;
  final String fromUnit;
  final String toUnit;
  final double inputValue;
  final double outputValue;
  final DateTime timestamp;

  RecentConversion({
    required this.category,
    required this.fromUnit,
    required this.toUnit,
    required this.inputValue,
    required this.outputValue,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'fromUnit': fromUnit,
      'toUnit': toUnit,
      'inputValue': inputValue,
      'outputValue': outputValue,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory RecentConversion.fromJson(Map<String, dynamic> json) {
    return RecentConversion(
      category: json['category'],
      fromUnit: json['fromUnit'],
      toUnit: json['toUnit'],
      inputValue: json['inputValue'],
      outputValue: json['outputValue'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// Conversion data for all categories.
class ConversionData {
  static List<ConversionCategory> get categories => [
    lengthCategory,
    weightCategory,
    temperatureCategory,
    volumeCategory,
    cookingCategory,
    areaCategory,
    speedCategory,
    dataCategory,
    pressureCategory,
    timeCategory,
  ];

  /// Get categories with custom units included and filtered by visibility settings
  static Future<List<ConversionCategory>> getCategoriesWithCustomUnits() async {
    final customUnitsService = CustomUnitsService.instance;
    final customUnits = await customUnitsService.getCustomUnits();

    // Group custom units by category
    final Map<String, List<CustomUnit>> customUnitsByCategory = {};
    for (final customUnit in customUnits) {
      customUnitsByCategory.putIfAbsent(customUnit.categoryName, () => []);
      customUnitsByCategory[customUnit.categoryName]!.add(customUnit);
    }

    // Merge custom units into existing categories and apply visibility filters
    final List<ConversionCategory> mergedCategories = [];
    for (final category in categories) {
      final categoryCustomUnits = customUnitsByCategory[category.name] ?? [];
      final mergedUnits = [...category.units];

      // Add custom units as Unit objects
      for (final customUnit in categoryCustomUnits) {
        mergedUnits.add(Unit.fromCustomUnit(customUnit));
      }

      // Filter units based on visibility settings
      final filteredUnits = await UnitSettingsService.filterUnits(mergedUnits);

      mergedCategories.add(
        ConversionCategory(
          name: category.name,
          icon: category.icon,
          units: filteredUnits,
        ),
      );
    }

    return mergedCategories;
  }

  /// Get a specific category with custom units and visibility filtering
  static Future<ConversionCategory?> getCategoryWithCustomUnits(
    String categoryName,
  ) async {
    final categoriesWithCustom = await getCategoriesWithCustomUnits();
    try {
      return categoriesWithCustom.firstWhere((cat) => cat.name == categoryName);
    } catch (e) {
      return null;
    }
  }

  static final ConversionCategory lengthCategory = ConversionCategory(
    name: 'Length',
    icon: 'straighten',
    units: [
      Unit(name: 'Micrometer', symbol: 'um', conversionFactor: 0.000001),
      Unit(name: 'Millimeter', symbol: 'mm', conversionFactor: 0.001),
      Unit(name: 'Centimeter', symbol: 'cm', conversionFactor: 0.01),
      Unit(name: 'Meter', symbol: 'm', conversionFactor: 1.0),
      Unit(name: 'Kilometer', symbol: 'km', conversionFactor: 1000.0),
      Unit(name: 'Inch', symbol: 'in', conversionFactor: 0.0254),
      Unit(name: 'Foot', symbol: 'ft', conversionFactor: 0.3048),
      Unit(name: 'Yard', symbol: 'yd', conversionFactor: 0.9144),
      Unit(name: 'Mile', symbol: 'mi', conversionFactor: 1609.344),
      Unit(name: 'Nautical Mile', symbol: 'nmi', conversionFactor: 1852.0),
    ],
  );

  static final ConversionCategory weightCategory = ConversionCategory(
    name: 'Weight',
    icon: 'scale',
    units: [
      Unit(name: 'Milligram', symbol: 'mg', conversionFactor: 0.000001),
      Unit(name: 'Gram', symbol: 'g', conversionFactor: 0.001),
      Unit(name: 'Kilogram', symbol: 'kg', conversionFactor: 1.0),
      Unit(name: 'Metric Ton', symbol: 't', conversionFactor: 1000.0),
      Unit(name: 'Ounce', symbol: 'oz', conversionFactor: 0.028349523125),
      Unit(name: 'Pound', symbol: 'lb', conversionFactor: 0.45359237),
      Unit(name: 'Stone', symbol: 'st', conversionFactor: 6.35029318),
      Unit(name: 'US Ton', symbol: 'ton', conversionFactor: 907.18474),
    ],
  );

  static final ConversionCategory temperatureCategory = ConversionCategory(
    name: 'Temperature',
    icon: 'thermostat',
    units: [
      Unit(name: 'Celsius', symbol: '°C', conversionFactor: 1.0),
      Unit(name: 'Fahrenheit', symbol: '°F', conversionFactor: 1.0),
      Unit(name: 'Kelvin', symbol: 'K', conversionFactor: 1.0),
    ],
  );

  static final ConversionCategory volumeCategory = ConversionCategory(
    name: 'Volume',
    icon: 'local_drink',
    units: [
      Unit(name: 'Milliliter', symbol: 'mL', conversionFactor: 0.001),
      Unit(name: 'Liter', symbol: 'L', conversionFactor: 1.0),
      Unit(name: 'Cubic Meter', symbol: 'm³', conversionFactor: 1000.0),
      Unit(
        name: 'Teaspoon (US)',
        symbol: 'tsp',
        conversionFactor: 0.00492892159375,
      ),
      Unit(
        name: 'Tablespoon (US)',
        symbol: 'tbsp',
        conversionFactor: 0.01478676478125,
      ),
      Unit(
        name: 'Fluid Ounce (US)',
        symbol: 'fl oz',
        conversionFactor: 0.0295735295625,
      ),
      Unit(name: 'Cup (US)', symbol: 'cup', conversionFactor: 0.2365882365),
      Unit(name: 'Pint (US)', symbol: 'pt', conversionFactor: 0.473176473),
      Unit(name: 'Quart (US)', symbol: 'qt', conversionFactor: 0.946352946),
      Unit(name: 'Gallon (US)', symbol: 'gal', conversionFactor: 3.785411784),
      Unit(
        name: 'Pint (Imperial)',
        symbol: 'imp pt',
        conversionFactor: 0.56826125,
      ),
      Unit(
        name: 'Gallon (Imperial)',
        symbol: 'imp gal',
        conversionFactor: 4.54609,
      ),
    ],
  );

  static final ConversionCategory areaCategory = ConversionCategory(
    name: 'Area',
    icon: 'crop_square',
    units: [
      Unit(
        name: 'Square Millimeter',
        symbol: 'mm²',
        conversionFactor: 0.000001,
      ),
      Unit(name: 'Square Centimeter', symbol: 'cm²', conversionFactor: 0.0001),
      Unit(name: 'Square Meter', symbol: 'm²', conversionFactor: 1.0),
      Unit(name: 'Hectare', symbol: 'ha', conversionFactor: 10000.0),
      Unit(
        name: 'Square Kilometer',
        symbol: 'km²',
        conversionFactor: 1000000.0,
      ),
      Unit(name: 'Square Inch', symbol: 'in²', conversionFactor: 0.00064516),
      Unit(name: 'Square Foot', symbol: 'ft²', conversionFactor: 0.09290304),
      Unit(name: 'Square Yard', symbol: 'yd²', conversionFactor: 0.83612736),
      Unit(name: 'Acre', symbol: 'ac', conversionFactor: 4046.8564224),
      Unit(
        name: 'Square Mile',
        symbol: 'mi²',
        conversionFactor: 2589988.110336,
      ),
    ],
  );

  static final ConversionCategory cookingCategory = ConversionCategory(
    name: 'Cooking',
    icon: 'restaurant',
    units: [
      Unit(name: 'Pinch', symbol: 'pinch', conversionFactor: 0.0003080576),
      Unit(name: 'Dash', symbol: 'dash', conversionFactor: 0.0006161152),
      Unit(
        name: 'Teaspoon',
        symbol: 'tsp',
        conversionFactor: 0.00492892159375,
      ),
      Unit(
        name: 'Tablespoon',
        symbol: 'tbsp',
        conversionFactor: 0.01478676478125,
      ),
      Unit(name: 'Cup', symbol: 'cup', conversionFactor: 0.2365882365),
      Unit(name: 'Pint', symbol: 'pt', conversionFactor: 0.473176473),
      Unit(name: 'Quart', symbol: 'qt', conversionFactor: 0.946352946),
      Unit(name: 'Liter', symbol: 'L', conversionFactor: 1.0),
    ],
  );

  static final ConversionCategory speedCategory = ConversionCategory(
    name: 'Speed',
    icon: 'speed',
    units: [
      Unit(name: 'Meter per Second', symbol: 'm/s', conversionFactor: 1.0),
      Unit(
        name: 'Kilometer per Hour',
        symbol: 'km/h',
        conversionFactor: 0.2777777778,
      ),
      Unit(name: 'Mile per Hour', symbol: 'mph', conversionFactor: 0.44704),
      Unit(name: 'Foot per Second', symbol: 'ft/s', conversionFactor: 0.3048),
      Unit(name: 'Knot', symbol: 'kn', conversionFactor: 0.5144444444),
    ],
  );

  static final ConversionCategory dataCategory = ConversionCategory(
    name: 'Data',
    icon: 'data',
    units: [
      Unit(name: 'Bit', symbol: 'b', conversionFactor: 0.125),
      Unit(name: 'Byte', symbol: 'B', conversionFactor: 1.0),
      Unit(name: 'Kilobyte', symbol: 'KB', conversionFactor: 1000.0),
      Unit(name: 'Megabyte', symbol: 'MB', conversionFactor: 1000000.0),
      Unit(name: 'Gigabyte', symbol: 'GB', conversionFactor: 1000000000.0),
      Unit(name: 'Terabyte', symbol: 'TB', conversionFactor: 1000000000000.0),
    ],
  );

  static final ConversionCategory pressureCategory = ConversionCategory(
    name: 'Pressure',
    icon: 'pressure',
    units: [
      Unit(name: 'Pascal', symbol: 'Pa', conversionFactor: 1.0),
      Unit(name: 'Kilopascal', symbol: 'kPa', conversionFactor: 1000.0),
      Unit(name: 'Bar', symbol: 'bar', conversionFactor: 100000.0),
      Unit(name: 'Atmosphere', symbol: 'atm', conversionFactor: 101325.0),
      Unit(name: 'PSI', symbol: 'psi', conversionFactor: 6894.757293168),
      Unit(name: 'mmHg', symbol: 'mmHg', conversionFactor: 133.3223684211),
    ],
  );

  static final ConversionCategory timeCategory = ConversionCategory(
    name: 'Time',
    icon: 'schedule',
    units: [
      Unit(name: 'Millisecond', symbol: 'ms', conversionFactor: 0.001),
      Unit(name: 'Second', symbol: 's', conversionFactor: 1.0),
      Unit(name: 'Minute', symbol: 'min', conversionFactor: 60.0),
      Unit(name: 'Hour', symbol: 'h', conversionFactor: 3600.0),
      Unit(name: 'Day', symbol: 'd', conversionFactor: 86400.0),
      Unit(name: 'Week', symbol: 'wk', conversionFactor: 604800.0),
      Unit(name: 'Month', symbol: 'mo', conversionFactor: 2629746.0),
      Unit(name: 'Year', symbol: 'yr', conversionFactor: 31556952.0),
    ],
  );

  /// Convert a value from one unit to another within a category.
  static double convert(
    double value,
    Unit fromUnit,
    Unit toUnit,
    String categoryName,
  ) {
    if (categoryName == 'Temperature') {
      return _convertTemperature(value, fromUnit, toUnit);
    }

    final baseValue = value * fromUnit.conversionFactor;
    return baseValue / toUnit.conversionFactor;
  }

  static double _convertTemperature(double value, Unit from, Unit to) {
    double celsius;

    if (from.symbol == '°C') {
      celsius = value;
    } else if (from.symbol == '°F') {
      celsius = (value - 32) * 5 / 9;
    } else if (from.symbol == 'K') {
      celsius = value - 273.15;
    } else {
      return value;
    }

    if (to.symbol == '°C') {
      return celsius;
    }
    if (to.symbol == '°F') {
      return (celsius * 9 / 5) + 32;
    }
    if (to.symbol == 'K') {
      return celsius + 273.15;
    }

    return celsius;
  }
}
