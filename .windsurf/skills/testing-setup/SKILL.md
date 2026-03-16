# Skill: Testing Setup

## 📋 Summary

Set up comprehensive testing infrastructure for Flutter apps, including unit tests, integration tests, end-to-end tests, and golden screenshot tests. This skill provides reusable patterns for achieving good test coverage and ensuring app quality.

## 🎯 When to Use

Use this skill when:
- Setting up testing for a new Flutter app
- Adding new types of tests to existing app
- Improving test coverage
- Setting up golden screenshot testing
- Configuring CI/CD for testing

## 🚀 Quick Start

### Basic Test Setup

1. **Create test directories**:
   ```bash
   mkdir -p test/unit
   mkdir -p test/integration
   mkdir -p test/e2e
   mkdir -p test/golden_screenshots
   ```

2. **Create a unit test** (`test/unit/example_test.dart`):
   ```dart
   import 'package:flutter_test/flutter_test.dart';

   void main() {
     test('example test', () {
       expect(1 + 1, equals(2));
     });
   }
   ```

3. **Run tests**:
   ```bash
   flutter test
   ```

### Golden Screenshot Setup

1. **Create golden screenshot test** (`test/golden_screenshots/home_screen_test.dart`):
   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_test/flutter_test.dart';
   import 'package:my_app/main.dart';

   void main() {
     testWidgets('home screen golden', (tester) async {
       await tester.pumpWidget(MyApp());
       await expectLater(
         find.byType(MaterialApp),
         matchesGoldenFile('goldens/home_screen.png'),
       );
     });
   }
   ```

2. **Generate golden screenshots**:
   ```bash
   flutter test test/golden_screenshots/home_screen_test.dart --update-goldens
   ```

## 📋 Test Types

### 1. Unit Tests

Test individual functions, classes, and methods in isolation.

**When to use**:
- Testing business logic
- Testing utility functions
- Testing service methods
- Testing model transformations

**Example**:
```dart
// test/unit/services/calculator_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/services/calculator_service.dart';

void main() {
  group('CalculatorService', () {
    test('should add two numbers', () {
      final service = CalculatorService();
      expect(service.add(2, 3), equals(5));
    });

    test('should subtract two numbers', () {
      final service = CalculatorService();
      expect(service.subtract(5, 3), equals(2));
    });
  });
}
```

### 2. Integration Tests

Test how multiple components work together.

**When to use**:
- Testing service interactions
- Testing screen navigation
- Testing data flow
- Testing API integrations

**Example**:
```dart
// test/integration/app_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:my_app/main.dart';

void main() {
  testWidgets('app should navigate from home to settings', (tester) async {
    await tester.pumpWidget(MyApp());

    // Tap settings button
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Verify settings screen is shown
    expect(find.text('Settings'), findsOneWidget);
  });
}
```

### 3. End-to-End Tests

Test complete user flows from start to finish.

**When to use**:
- Testing critical user journeys
- Testing complete workflows
- Testing cross-screen flows
- Regression testing

**Example**:
```dart
// test/e2e/purchase_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:my_app/main.dart';

void main() {
  testWidgets('complete purchase flow', (tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to premium screen
    await tester.tap(find.text('Upgrade'));
    await tester.pumpAndSettle();

    // Tap purchase button
    await tester.tap(find.text('Purchase'));
    await tester.pumpAndSettle();

    // Verify purchase completed
    expect(find.text('Premium Unlocked'), findsOneWidget);
  });
}
```

### 4. Golden Screenshot Tests

Test UI appearance by comparing screenshots.

**When to use**:
- Testing UI consistency
- Store screenshot generation
- Visual regression testing
- Testing responsive layouts

**Example**:
```dart
// test/golden_screenshots/screenshots_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';

void main() {
  testWidgets('home screen golden', (tester) async {
    await tester.pumpWidget(MyApp());
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/home_screen.png'),
    );
  });

  testWidgets('settings screen golden', (tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to settings
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(SettingsScreen),
      matchesGoldenFile('goldens/settings_screen.png'),
    );
  });
}
```

## 🧪 Test Organization

### Directory Structure

```
test/
├── unit/                      # Unit tests
│   ├── models/
│   │   └── user_model_test.dart
│   ├── services/
│   │   └── calculator_service_test.dart
│   └── utils/
│       └── formatter_test.dart
├── integration/               # Integration tests
│   ├── screens/
│   │   └── home_screen_test.dart
│   └── flows/
│       └── navigation_flow_test.dart
├── e2e/                       # End-to-end tests
│   └── purchase_flow_test.dart
├── golden_screenshots/        # Golden screenshots
│   └── store_screenshots_test.dart
└── widget/                    # Widget tests
    └── custom_button_test.dart
```

## 📊 Test Coverage

### Generate Coverage Report

```bash
# Run tests with coverage
flutter test --coverage

# View coverage report
# Linux/macOS: genhtml coverage/lcov.info -o coverage/html
# Windows: Use VS Code coverage extension
```

### Coverage Goals

- **Unit tests**: 80%+ coverage
- **Integration tests**: 60%+ coverage
- **Critical paths**: 100% coverage
- **Overall**: 70%+ coverage

### Coverage in CI/CD

```yaml
- name: Generate coverage
  run: flutter test --coverage

- name: Upload coverage
  uses: codecov/codecov-action@v3
  with:
    files: coverage/lcov.info
    fail_ci_if_error: false
```

## 🎨 Golden Screenshots

### Setup Golden Screenshots

1. **Create test file**:
   ```dart
   // test/golden_screenshots/store_screenshots_test.dart
   import 'package:flutter/material.dart';
   import 'package:flutter_test/flutter_test.dart';
   import 'package:my_app/main.dart';

   void main() {
     testWidgets('home screen screenshot', (tester) async {
       await tester.pumpWidget(MyApp());
       await expectLater(
         find.byType(MaterialApp),
         matchesGoldenFile('goldens/store/home.png'),
       );
     });
   }
   ```

2. **Generate golden files**:
   ```bash
   flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens
   ```

3. **Update golden files**:
   ```bash
   flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens
   ```

### Golden Screenshot Best Practices

1. **Use descriptive names**:
   ```dart
   matchesGoldenFile('goldens/home_screen_dark_theme.png')
   ```

2. **Test multiple configurations**:
   ```dart
   testWidgets('home screen in dark theme', (tester) async {
     await tester.pumpWidget(
       MaterialApp(
         theme: ThemeData.dark(),
         home: HomeScreen(),
       ),
     );
     await expectLater(
       find.byType(HomeScreen),
       matchesGoldenFile('goldens/home_dark.png'),
     );
   });
   ```

3. **Test responsive layouts**:
   ```dart
   testWidgets('home screen on tablet', (tester) async {
     await tester.pumpWidget(
       MaterialApp(
         home: HomeScreen(),
       ),
     );

     // Set tablet size
     await tester.binding.setSurfaceSize(Size(1024, 768));
     await tester.pumpAndSettle();

     await expectLater(
       find.byType(HomeScreen),
       matchesGoldenFile('goldens/home_tablet.png'),
     );
   });
   ```

## 🔧 Testing Configuration

### pubspec.yaml

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

  # Testing
  mockito: ^5.0.0
  integration_test:
    sdk: flutter
  build_runner: ^2.0.0
  golden_toolkit: ^0.15.0
```

### analysis_options.yaml

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

  errors:
    # Treat missing test coverage as a hint
    missing_required_param: error
    missing_return: error
```

## 🚀 Testing in CI/CD

### Test Workflow

```yaml
name: Test

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Analyze code
        run: flutter analyze

      - name: Run unit tests
        run: flutter test

      - name: Run integration tests
        run: flutter test integration_test

      - name: Generate coverage
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info
```

## 🔧 Troubleshooting

### Issue: Golden Screenshots Fail

**Symptoms**: Golden screenshot tests fail with pixel differences

**Solutions**:
1. Update golden files: `flutter test --update-goldens`
2. Check for platform differences (fonts, rendering)
3. Use device pixel ratio in tests
4. Check for animation timing issues

### Issue: Tests Timeout

**Symptoms**: Tests take too long and timeout

**Solutions**:
1. Use `pumpAndSettle()` instead of `pump()`
2. Add timeouts to async operations
3. Mock slow dependencies
4. Run tests in parallel

### Issue: Flaky Tests

**Symptoms**: Tests pass sometimes, fail sometimes

**Solutions**:
1. Add proper waiting with `pumpAndSettle()`
2. Use `tester.runAsync()` for async operations
3. Mock external dependencies
4. Add retry logic for flaky tests

## 📚 Cross-References

### Documentation
- [Test Coverage Strategies](../../docs/testing/coverage-strategies.md) - Coverage strategies and goals
- [Golden Screenshots](../../docs/testing/golden-screenshots.md) - Golden screenshot testing
- [Integration Tests](../../docs/testing/integration-tests.md) - Integration test patterns

### Related Skills
- [process-cleanup/](./process-cleanup/) - Process cleanup (important for tests)
- [ci-cd-setup/](./ci-cd-setup/) - CI/CD configuration for tests

## 🎯 AI Assistant Instructions

When this skill is invoked, the AI should:

1. **Assess the situation**:
   - Check if testing infrastructure exists
   - Identify which test types are needed
   - Determine coverage goals
   - Check if golden screenshots are needed

2. **Set up testing**:
   - Create test directory structure
   - Create test templates
   - Configure testing tools
   - Set up CI/CD for testing

3. **Create tests**:
   - Create unit tests for services
   - Create integration tests for screens
   - Create E2E tests for critical flows
   - Create golden screenshot tests if needed

4. **Configure CI/CD**:
   - Set up test workflows
   - Configure coverage reporting
   - Set up golden screenshot generation
   - Configure test notifications

5. **Provide guidance**:
   - Explain test organization
   - Provide testing best practices
   - Explain how to run tests
   - Provide troubleshooting tips

## 📝 Checklist

Before setting up tests:
- [ ] Determine test types needed
- [ ] Set coverage goals
- [ ] Decide if golden screenshots are needed
- [ ] Review testing documentation

After setting up tests:
- [ ] Verify all tests run
- [ ] Check coverage report
- [ ] Test CI/CD workflow
- [ ] Update documentation
- [ ] Train team on testing practices

## 🔗 Related Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/cookbook/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration Testing](https://docs.flutter.dev/cookbook/testing/integration/introduction)
- [Golden Toolkit](https://pub.dev/packages/golden_toolkit)

---

*This skill is part of the AI assistant toolkit. See [skills/readme.md](./readme.md) for all available skills.*

