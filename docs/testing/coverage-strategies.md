# Test Coverage Documentation

## Documentation Navigation
- [Project Overview](readme.md)
- [API Documentation](API.md)
- [Documentation Claims Validation](DOCUMENTATION_CLAIMS_VALIDATION.md)

## Overview
This document provides an overview of the test coverage for the Unit Converter application.

## Test Summary
- **Total Tests**: 130+ (11 smoke tests + 49 conversion tests + 14 service tests + 35+ ad tests + widget tests)
- **Test Files**: 7
- **Coverage**: Models, Services, AdMob, Smoke Tests, Widget tests, and Integration tests

## Test Files

### 1. smoke_test.dart (NEW)
**Purpose**: Early build failure detection smoke tests

**Test Groups**:
- Data Model Validation (4 tests)
- Service Initialization Tests (3 tests)
- Conversion Logic Smoke Tests (3 tests)
- Integration Smoke Tests (1 test)

**Total**: 11 tests

**Coverage Details**:
- All conversion categories have valid data
- All required categories are present
- Temperature category has special units
- Units within categories have unique symbols
- RecentConversionsService initialization
- Save, retrieve, and clear operations
- Basic conversion works for all categories
- Temperature conversion works for all combinations
- Conversion handles edge values (zero, negative)
- Complete conversion flow without UI
- **Note**: Widget tests skipped due to layout overflow in CategoryCard (separate UI issue)

**Purpose**: These tests run fast and fail early if there are fundamental build or logic issues. They focus on detecting compilation errors, data model issues, service initialization problems, and core conversion logic failures.

### 2. conversion_test.dart
**Purpose**: Unit tests for conversion models and logic

**Test Groups**:
- Unit Model (3 tests)
- ConversionCategory Model (1 test)
- RecentConversion Model (3 tests)
- ConversionData Categories (7 tests)
- Length Conversions (6 tests)
- Weight Conversions (4 tests)
- Temperature Conversions (7 tests)
- Volume Conversions (3 tests)
- Area Conversions (3 tests)
- Speed Conversions (3 tests)
- Time Conversions (5 tests)
- Edge Cases (5 tests)

**Total**: 52 tests

**Coverage Details**:
- Unit model creation and properties
- ConversionCategory model creation
- RecentConversion model including JSON serialization/deserialization
- All conversion categories (8 categories including currency with correct unit counts)
- Length conversions (meters, kilometers, centimeters, inches, feet, miles)
- Weight conversions (kilograms, grams, pounds, ounces)
- Temperature conversions (Celsius, Fahrenheit, Kelvin with special formulas)
- Volume conversions (liters, milliliters, gallons, cups)
- Area conversions (square meters, square kilometers, acres, square feet)
- Speed conversions (km/h, m/s, mph, knots)
- Time conversions (seconds, minutes, hours, days, weeks, years)
- Edge cases (zero values, negative values, very large/small values, same unit conversion)

### 3. recent_conversions_service_test.dart
**Purpose**: Unit tests for the RecentConversionsService

**Test Groups**:
- Save and retrieve conversions
- Maintain order (most recent first)
- Remove duplicates
- Limit to 10 recent conversions
- Clear all conversions
- Delete specific conversion
- Handle empty storage
- Handle corrupted data
- Distinguish conversions with different values
- Distinguish conversions with different units
- Preserve timestamp correctly
- Handle multiple categories
- Handle deletion when conversion doesn't exist
- Handle floating point precision

**Total**: 14 tests

**Coverage Details**:
- CRUD operations for recent conversions
- Data persistence using SharedPreferences
- Duplicate detection and removal
- Maximum limit enforcement (10 conversions)
- Error handling (empty storage, corrupted data)
- Timestamp preservation
- Multi-category support
- Floating point precision handling

### 4. widget_test.dart
**Purpose**: Widget tests for the main application UI

**Test Groups**:
- App displays category selection screen
- All categories are present
- Category cards have icons

**Total**: 3 tests

**Coverage Details**:
- Main screen UI rendering
- All 8 categories displayed correctly (including currency)
- Category icons displayed correctly
- App title and section headers

### 5. admob_service_test.dart (NEW)
**Purpose**: Unit tests for AdMob service configuration and logic

**Test Groups**:
- Configuration Validation (4 tests)
- Banner Ads (2 tests)
- Interstitial Ads - Frequency Capping (4 tests)
- Interstitial Ads - Time-Based Capping (2 tests)
- Interstitial Ads - Session Limits (2 tests)
- Conversion Tracking (3 tests)
- App Open Ads (2 tests)
- Ad Unit IDs (3 tests)
- Persistent Tracking (3 tests)
- Ad Display Logic (4 tests)
- Integration (3 tests)
- Configuration Validation (3 tests)
- Debugging Support (4 tests)

**Total**: 39 tests

**Coverage Details**:
- AdMob configuration constants are correct
- Banner ads are created with correct unit IDs
- Interstitial frequency capping (20 conversions between ads)
- First-time user protection (10 conversions before first ad)
- Time-based capping (3 minutes between ads)
- Session limits (3 interstitials per session)
- Conversion tracking and counters
- App open ads (once per day)
- Persistent tracking across app restarts
- Ad display logic enforcement
- Configuration validation
- Debugging support

### 6. ad_rendering_test.dart (NEW)
**Purpose**: Widget and integration tests for ad rendering

**Test Groups**:
- Banner Ad Rendering Tests (2 tests)
- AdMobService Widget Integration (1 test)
- Ad Configuration Validation (3 tests)
- Ad Display Logic Integration (3 tests)

**Total**: 9 tests

**Coverage Details**:
- Banner ads render on CategorySelectionScreen
- Screen loads without errors with AdMob service
- Ad configuration is valid
- Ad display logic is accessible
- Conversion tracking works correctly
- Session counters are accessible

### 7. ad_integration_test.dart (NEW)
**Purpose**: Integration tests for complete ad flow based on configuration

**Test Groups**:
- User Journey: New User Experience (2 tests)
- User Journey: Regular User Experience (1 test)
- User Journey: Heavy User Experience (1 test)
- User Journey: Multi-Session Experience (2 tests)
- Ad Configuration Enforcement (3 tests)
- Edge Cases (4 tests)
- Configuration Values (2 tests)
- Ad Unit Configuration (3 tests)

**Total**: 18 tests

**Coverage Details**:
- New users don't see ads in first 9 conversions
- First interstitial after 10th conversion
- Regular users see interstitial every 20 conversions
- Heavy users limited to 3 interstitials per session
- Session counters reset between sessions
- Conversion count persists across sessions
- First-time user protection is strictly enforced
- Frequency cap is strictly enforced
- Session limit is strictly enforced
- Edge cases (zero conversions, single conversion, etc.)
- Configuration values match strategy document
- Configuration is review-friendly
- Ad units are properly configured

## Test Execution

### Run All Tests
```bash
flutter test
```

### Run Smoke Tests Only (Fast Build Failure Detection)
```bash
flutter test test/smoke_test.dart
```

### Run Specific Test File
```bash
flutter test test/conversion_test.dart
flutter test test/recent_conversions_service_test.dart
flutter test test/widget_test.dart
```

### Run Core Unit Tests (Smoke + Conversion + Service)
```bash
flutter test test/smoke_test.dart test/conversion_test.dart test/recent_conversions_service_test.dart
```

### Run with Coverage
```bash
flutter test --coverage
```

### View Coverage Report
After running with coverage, view the report:
```bash
genhtml coverage/lcov.info -o coverage/html
```

## Test Coverage Areas

### Covered
- ✅ All conversion logic (8 categories including currency, 47 units)
- ✅ Temperature conversion formulas
- ✅ Recent conversions service (CRUD operations)
- ✅ Data persistence (SharedPreferences)
- ✅ JSON serialization/deserialization
- ✅ Main screen UI
- ✅ Edge cases and error handling
- ✅ **Early build failure detection (smoke tests)**
- ✅ Data model validation
- ✅ Service initialization
- ✅ Integration flow testing
- ✅ **AdMob service configuration and logic**
- ✅ **Ad frequency capping (20 conversions between ads)**
- ✅ **First-time user protection (10 conversions before first ad)**
- ✅ **Time-based capping (3 minutes between ads)**
- ✅ **Session limits (3 interstitials per session)**
- ✅ **Ad display logic enforcement**
- ✅ **Banner ad rendering**
- ✅ **Ad integration testing**
- ✅ **Persistent tracking across app restarts**

### Not Covered (Future Enhancements)
- ⚠ Conversion screen UI (due to layout overflow in test environment)
- ⚠ User interaction flows (tap, scroll, etc.)
- ⚠ Performance tests
- ⚠ End-to-end UI automation tests

## Best Practices Followed
1. **Test Isolation**: Each test is independent and can run in any order
2. **Mocking**: SharedPreferences is mocked for service tests
3. **Descriptive Test Names**: Test names clearly describe what is being tested
4. **Arrange-Act-Assert Pattern**: Tests follow clear structure
5. **Edge Cases**: Comprehensive edge case testing
6. **Floating Point Comparison**: Using `closeTo` for floating point assertions
7. **Smoke Tests**: Fast-running tests that detect early build failures
8. **Separation of Concerns**: Smoke tests focus on build failures, not UI layout issues

## Continuous Integration
All tests should pass before merging any changes to the main branch.

### CI Pipeline Recommendations
1. **First**: Run smoke tests (fast, detect build failures early)
2. **Second**: Run unit tests (conversion and service tests)
3. **Third**: Run widget tests (UI testing)
4. **Finally**: Run integration tests (if any)

This staged approach ensures that fundamental issues are caught quickly before running slower UI tests.

## Adding New Tests
When adding new features:
1. Write unit tests for business logic
2. Write widget tests for UI components
3. Write integration tests if needed
4. Update this documentation

## Test Maintenance
- Keep tests updated when code changes
- Remove obsolete tests
- Add tests for new features
- Review and refactor tests periodically

