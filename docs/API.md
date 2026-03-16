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

### CurrencyQuote
Represents a currency conversion result with rate information.

#### Properties
- `from` (String): Source currency code (e.g., 'USD')
- `to` (String): Target currency code (e.g., 'EUR')
- `amount` (double): Original amount
- `convertedAmount` (double): Converted amount
- `rate` (double): Exchange rate used (1 from = rate to)
- `effectiveDate` (DateTime): Date the rate was published

#### Example
```dart
CurrencyQuote quote = CurrencyQuote(
  from: 'USD',
  to: 'EUR',
  amount: 100.0,
  convertedAmount: 92.5,
  rate: 0.925,
  effectiveDate: DateTime.parse('2024-03-12'),
);
```

---

### CurrenciesResult
Represents the result of fetching currencies with metadata.

#### Properties
- `currencies` (Map<String, String>): Currency code to name mapping
- `isFromCache` (bool): Whether data came from cache
- `isFromDefaults` (bool): Whether data came from defaults
- `errorMessage` (String?): Error message if offline

#### Example
```dart
CurrenciesResult result = CurrenciesResult(
  currencies: {'USD': 'US Dollar', 'EUR': 'Euro'},
  isFromCache: false,
  isFromDefaults: false,
  errorMessage: null,
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

### CurrencyService
Manages currency conversion using the Frankfurter API.

#### Methods

##### getCurrenciesWithMetadata()
Returns available currencies with metadata about data source.

```dart
CurrenciesResult result = await currencyService.getCurrenciesWithMetadata();
```

**Returns**: `CurrenciesResult` containing:
- `currencies` (Map<String, String>): Currency code to name mapping
- `isFromCache` (bool): Whether data came from cache
- `isFromDefaults` (bool): Whether data came from defaults
- `errorMessage` (String?): Error message if offline

##### getCurrencies()
Returns list of available currencies.

```dart
Map<String, String> currencies = await currencyService.getCurrencies();
```

**Returns**: `Map<String, String>` mapping currency codes to names

##### convert({required String from, required String to, required double amount})
Converts an amount from one currency to another.

```dart
CurrencyQuote quote = await currencyService.convert(
  from: 'USD',
  to: 'EUR',
  amount: 100.0,
);
```

**Parameters**:
- `from` (String): Source currency code (e.g., 'USD')
- `to` (String): Target currency code (e.g., 'EUR')
- `amount` (double): Amount to convert

**Returns**: `CurrencyQuote` containing:
- `from` (String): Source currency code
- `to` (String): Target currency code
- `amount` (double): Original amount
- `convertedAmount` (double): Converted amount
- `rate` (double): Exchange rate used
- `effectiveDate` (DateTime): Date the rate was published

**Note**: For detailed architecture information, see [CURRENCY_ARCHITECTURE.md](CURRENCY_ARCHITECTURE.md).

---

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
