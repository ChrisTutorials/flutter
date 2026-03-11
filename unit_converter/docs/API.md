# API Documentation

## Documentation Navigation
- [Project Overview](README.md)
- [Architecture Documentation](ARCHITECTURE.md)
- [Quick Start Guide](QUICKSTART.md)
- [Security Configuration](SECURITY_CONFIG.md)

## Models

### Unit
Represents a unit of measurement with its conversion factor.

#### Properties
- `name` (String): Full name of the unit (e.g., "Meter")
- `symbol` (String): Symbol of the unit (e.g., "m")
- `conversionFactor` (double): Factor to convert to base unit

#### Example
```dart
Unit meter = Unit(
  name: 'Meter',
  symbol: 'm',
  conversionFactor: 1.0,
);
```

---

### ConversionCategory
Groups related units together.

#### Properties
- `name` (String): Category name (e.g., "Length")
- `icon` (String): Icon identifier
- `units` (List<Unit>): List of units in this category

#### Example
```dart
ConversionCategory lengthCategory = ConversionCategory(
  name: 'Length',
  icon: 'straighten',
  units: [meter, kilometer, ...],
);
```

---

### RecentConversion
Represents a saved conversion with timestamp.

#### Properties
- `category` (String): Category name
- `fromUnit` (String): Source unit symbol
- `toUnit` (String): Target unit symbol
- `inputValue` (double): Input value
- `outputValue` (double): Converted value
- `timestamp` (DateTime): When conversion was performed

#### Methods
- `toJson()`: Convert to JSON map
- `fromJson(Map<String, dynamic> json)`: Create from JSON map

#### Example
```dart
RecentConversion conversion = RecentConversion(
  category: 'Length',
  fromUnit: 'm',
  toUnit: 'km',
  inputValue: 1000.0,
  outputValue: 1.0,
  timestamp: DateTime.now(),
);
```

---

## Services

### RecentConversionsService
Manages recent conversions using SharedPreferences.

#### Methods

##### saveConversion(RecentConversion conversion)
Saves a conversion to recent history. Maintains max 10 items, removes duplicates.

```dart
await RecentConversionsService.saveConversion(conversion);
```

##### getRecentConversions()
Returns list of recent conversions, sorted by most recent first.

```dart
List<RecentConversion> conversions = await RecentConversionsService.getRecentConversions();
```

##### clearRecentConversions()
Clears all recent conversions.

```dart
await RecentConversionsService.clearRecentConversions();
```

##### deleteConversion(RecentConversion conversion)
Deletes a specific conversion from history.

```dart
await RecentConversionsService.deleteConversion(conversion);
```

---

## Conversion Logic

### ConversionData.convert()
Converts a value from one unit to another.

#### Parameters
- `value` (double): Value to convert
- `fromUnit` (Unit): Source unit
- `toUnit` (Unit): Target unit
- `categoryName` (String): Category name for special handling

#### Returns
- `double`: Converted value

#### Example
```dart
double result = ConversionData.convert(
  1000.0,
  ConversionData.lengthCategory.units[2], // Meter
  ConversionData.lengthCategory.units[3], // Kilometer
  'Length',
);
// Result: 1.0
```

#### Temperature Conversion
Temperature conversions use special formulas:
- Celsius to Fahrenheit: (C × 9/5) + 32
- Fahrenheit to Celsius: (F - 32) × 5/9
- Celsius to Kelvin: C + 273.15
- Kelvin to Celsius: K - 273.15

---

### ConversionData.categories
Static list of all available conversion categories.

```dart
List<ConversionCategory> categories = ConversionData.categories;
```

### Category Properties
- `lengthCategory`: Length conversions
- `weightCategory`: Weight conversions
- `temperatureCategory`: Temperature conversions
- `volumeCategory`: Volume conversions
- `areaCategory`: Area conversions
- `speedCategory`: Speed conversions
- `timeCategory`: Time conversions

---

## Testing

### Documentation Claims Validation
All promotional claims made in `APP_STORE_PROMO.md` are validated by comprehensive tests in `test/documentation_claims_validation_test.dart`. This ensures that every feature advertised to users is backed by tested, working functionality.

For detailed information about the documentation claims validation test suite, see [DOCUMENTATION_CLAIMS_VALIDATION.md](DOCUMENTATION_CLAIMS_VALIDATION.md).

### Test Coverage
The project includes comprehensive test coverage across:
- Conversion logic (`conversion_test.dart`)
- Custom units functionality (`custom_units_test.dart`)
- Recent conversions service (`recent_conversions_service_test.dart`)
- Platform-specific AdMob behavior (`platform_admob_test.dart`)
- Responsive layout (`responsive_layout_test.dart`)
- Widget functionality (`widget_test.dart`)
- Smoke tests (`smoke_test.dart`)
- Documentation claims validation (`documentation_claims_validation_test.dart`)
