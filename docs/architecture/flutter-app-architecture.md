# Architecture Documentation

## Documentation Navigation
- [Project Overview](readme.md)
- [API Documentation](API.md)
- [Quick Start Guide](quickstart.md)
- [Security Configuration](SECURITY_CONFIG.md)

## Architecture Overview
The Unit Converter follows a clean architecture pattern with clear separation of concerns:

## Layers

### 1. Presentation Layer (UI)
- Located in `lib/main.dart`
- Handles user interface and user interactions
- Manages app state and UI updates
- Delegates business logic to services

### 2. Business Logic Layer (Services)
- Located in `lib/services/`
- **RecentConversionsService**: Manages conversion history persistence
- **AdMobService**: Handles ad integration
- Services are stateless and testable

### 3. Data Layer (Models)
- Located in `lib/models/`
- **Unit**: Represents a unit with conversion factor
- **ConversionCategory**: Groups related units
- **RecentConversion**: Represents a saved conversion
- **ConversionData**: Static data and conversion logic

## Design Patterns

### Singleton Pattern
Services use static methods and are stateless, making them easy to use throughout the app.

### Factory Pattern
`RecentConversion.fromJson()` and `Unit()` constructors use factory pattern for object creation.

### Strategy Pattern
Temperature conversion uses a different strategy (formula-based) compared to other conversions (factor-based).

## Data Flow

### Conversion Flow
1. User selects category, from unit, to unit, and enters value
2. UI calls `ConversionData.convert()`
3. Conversion logic calculates result
4. UI displays result
5. If user saves, `RecentConversionsService.saveConversion()` persists it

### Recent Conversions Flow
1. User performs a conversion
2. Service saves to SharedPreferences
3. Service maintains max 10 recent conversions
4. UI retrieves and displays recent conversions

## Key Design Decisions

### SharedPreferences for Persistence
- Chosen for simplicity and cross-platform support
- Suitable for small amounts of data (max 10 conversions)
- No need for complex database for this use case

### Static Conversion Data
- Conversion factors are hardcoded for performance
- No network calls required
- Easy to maintain and test

### Temperature Special Handling
- Temperature conversions require formulas, not simple multiplication
- Implemented as a special case in the conversion logic
- Converts to Celsius as intermediate step

## Testing Strategy
- Unit tests for models (conversion logic)
- Unit tests for services (with mocked SharedPreferences)
- Widget tests for UI components

