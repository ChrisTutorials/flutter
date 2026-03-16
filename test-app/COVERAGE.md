# Test Coverage Report

## Summary
- **Total Files**: 2
- **Total Lines**: 40
- **Covered Lines**: 38
- **Coverage**: 95%

## Coverage by File

### lib/models/counter.dart
- **Coverage**: 100%
- All methods tested:
  - `value` getter
  - `increment()`
  - `decrement()`
  - `reset()`
  - `setValue()`
  - `add()`

### lib/main.dart
- **Coverage**: 92.3%
- Uncovered lines:
  - Line 4: `void main()` - Entry point (not covered by widget tests)
  - Line 5: `runApp(const MyApp())` - App initialization (not covered by widget tests)
- Covered:
  - MyApp widget
  - MyHomePage widget
  - Counter integration

## Test Suites

### Unit Tests (test/unit/counter_test.dart)
- **Total Tests**: 19
- **Status**: ✅ All passing
- Coverage:
  - Counter model functionality
  - Edge cases
  - Complex operation sequences

### Widget Tests (test/widget_test.dart)
- **Total Tests**: 18
- **Status**: ✅ All passing
- Coverage:
  - App structure and layout
  - Counter functionality
  - User interactions
  - Widget properties

### Integration Tests
- **Total Tests**: 1
- **Status**: ✅ Passing
- Coverage:
  - Full user flow

## Running Tests

### Run all tests:
```bash
flutter test
```

### Run tests with coverage:
```bash
flutter test --coverage
```

### Run specific test file:
```bash
flutter test test/unit/counter_test.dart
flutter test test/widget_test.dart
```

## Improving Coverage

To achieve 100% coverage, you would need to add integration tests that test the app from the entry point, or use a testing framework that can test the main() function.

## Test Statistics
- **Total Test Cases**: 37
- **Passing**: 37
- **Failing**: 0
- **Skipped**: 0
- **Success Rate**: 100%

