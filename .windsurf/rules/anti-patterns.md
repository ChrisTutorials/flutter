# Workspace Anti-Patterns

This document describes common anti-patterns to avoid when working with screenshots and other workflows in this Flutter workspace.

## Screenshot Anti-Patterns

### 1. Using flutter test for Production Screenshots

**Anti-Pattern**: Using `flutter test` to generate production store screenshots.

**Problem**: `flutter test` uses a headless rendering engine that does not render fonts properly. Text appears as white rectangles instead of actual characters.

**Example**:
```bash
# BAD: This generates screenshots with no legible text
flutter test test/integration/store_screenshots_generation_test.dart --update-goldens
```

**Correct Approach**: Use `integration_test` which runs on a real device/emulator and renders fonts properly.

```bash
# GOOD: This generates screenshots with legible text
flutter test integration_test/store_screenshots_generation_integration_test.dart --device-id emulator-5554
```

**Why This Matters**: Store screenshots must have legible text to be useful for users. Screenshots with placeholder rectangles are unprofessional and don't showcase the app's functionality.

---

### 2. Not Validating Text Legibility

**Anti-Pattern**: Only validating dimensions and whitespace, but not checking if text is legible.

**Problem**: Screenshots can pass dimension and whitespace checks but still have no legible text (e.g., text rendering as white rectangles).

**Example**:
```dart
// BAD: Only checks dimensions and whitespace
test('Screenshots have correct dimensions', () {
  expect(image.width, equals(1080));
  expect(image.height, equals(1920));
});

test('Screenshots have no whitespace', () {
  // Check for whitespace at edges
});
```

**Correct Approach**: Add validation for text legibility using color variance analysis.

```dart
// GOOD: Also checks for legible text
test('Screenshots contain legible text characters', () {
  // Check for color variance to detect text rendering
  // Text has higher variance than solid blocks
  final textRegionRatio = calculateTextRegionRatio(image);
  expect(textRegionRatio, greaterThan(0.1));
});
```

**Why This Matters**: Ensures screenshots actually show the app's content, not just the layout structure.

---

### 3. Not Checking for Whitespace Chunks

**Anti-Pattern**: Only checking for whitespace at the top and bottom edges.

**Problem**: Screenshots can have whitespace bands in the middle (e.g., from improper cropping) that edge checks miss.

**Example**:
```dart
// BAD: Only checks edges
test('No whitespace at top', () {
  // Check first 5% of image
});

test('No whitespace at bottom', () {
  // Check last 5% of image
});
```

**Correct Approach**: Check for whitespace chunks throughout the entire image, tracking consecutive chunks.

```dart
// GOOD: Checks entire image for whitespace chunks
test('Screenshots have no large whitespace chunks', () {
  // Scan entire image in 100-pixel chunks
  // Track consecutive whitespace chunks
  // Reject if more than 3 consecutive chunks
});
```

**Why This Matters**: Catches improper capture and cropping issues that edge checks miss.

---

### 4. Not Verifying Full Image Coverage

**Anti-Pattern**: Not checking that the app content fills the entire screenshot area.

**Problem**: Screenshots can have the app centered with whitespace on all sides, passing edge checks.

**Example**:
```dart
// BAD: No quadrant validation
// Only checks edges and overall content
```

**Correct Approach**: Divide the image into quadrants and verify each has sufficient content.

```dart
// GOOD: Validates all quadrants have content
test('Screenshots fill the entire image area', () {
  for (final quadrant in quadrants) {
    final contentRatio = calculateContentRatio(quadrant);
    expect(contentRatio, greaterThan(0.02));
  }
});
```

**Why This Matters**: Ensures screenshots are truly full-screen and the app fills the entire device.

---

### 5. Using Low Pixel Ratio for Screenshots

**Anti-Pattern**: Using `pixelRatio: 1` for all screenshot generation.

**Problem**: Low pixel ratio can result in blurry text and poor quality screenshots.

**Example**:
```dart
// BAD: Always uses pixelRatio: 1
ScreenshotDevice(
  resolution: Size(1080, 1920),
  pixelRatio: 1,
);
```

**Correct Approach**: Use appropriate pixel ratio for the target device density.

```dart
// GOOD: Uses appropriate pixel ratio
ScreenshotDevice(
  resolution: Size(1080, 1920),
  pixelRatio: 2.0, // For higher density displays
);
```

**Why This Matters**: Ensures screenshots are crisp and readable on all devices.

---

## General Workflow Anti-Patterns

### 6. Not Using DRY Principles

**Anti-Pattern**: Duplicating code and documentation across multiple files.

**Problem**: Makes maintenance difficult and leads to inconsistencies.

**Example**:
```dart
// BAD: Same logic duplicated in multiple files
// file1.dart
void validateScreenshot(String path) {
  // 50 lines of validation logic
}

// file2.dart
void validateScreenshot(String path) {
  // Same 50 lines of validation logic
}
```

**Correct Approach**: Extract common logic into shared utilities.

```dart
// GOOD: Shared utility
// lib/utils/screenshot_validation.dart
void validateScreenshot(String path) {
  // 50 lines of validation logic
}

// file1.dart
import 'package:common_flutter_utilities/screenshot_validation.dart';

// file2.dart
import 'package:common_flutter_utilities/screenshot_validation.dart';
```

**Why This Matters**: Single source of truth, easier to maintain, consistent behavior.

---

### 7. Not Cross-Referencing Documentation

**Anti-Pattern**: Having multiple documentation files that don't reference each other.

**Problem**: Hard to find related information, leads to outdated docs.

**Example**:
```markdown
<!-- BAD: No cross-references -->
# Screenshot Generation

Generate screenshots with this command...

# Screenshot Validation

Validate screenshots with this command...
```

**Correct Approach**: Cross-reference related documentation and skills.

```markdown
<!-- GOOD: Cross-references -->
# Screenshot Generation

Generate screenshots with this command...

For validation methodology, see:
- [Screenshot Validation](./screenshot_validation.md)
- [full-screen-screenshot-validation/](../.windsurf/skills/full-screen-screenshot-validation/)
```

**Why This Matters**: Makes documentation easier to navigate and maintain.

---

### 8. Not Following Proper File Structure

**Anti-Pattern**: Creating skills or documentation files without proper structure.

**Problem**: Violates workspace conventions, makes files hard to find.

**Example**:
```
# BAD: Flat structure
.windsurf/
  skills/
    take-screenshots.md
    validate-screenshots.md
    fastlane-setup.md
```

**Correct Approach**: Follow the proper folder structure for skills.

```
# GOOD: Proper structure
.windsurf/
  skills/
    README.md
    take-screenshots/
      SKILL.md
    full-screen-screenshot-validation/
      SKILL.md
    fastlane-setup/
      SKILL.md
```

**Why This Matters**: Consistent structure makes the workspace easier to navigate and maintain.

---

### 9. Not Testing Validation Logic

**Anti-Pattern**: Creating validation tests but not testing the validation itself.

**Problem**: Validation logic can have bugs that go undetected.

**Example**:
```dart
// BAD: No tests for validation logic
void validateScreenshot(String path) {
  // Complex validation logic with no tests
}
```

**Correct Approach**: Write unit tests for validation logic.

```dart
// GOOD: Tests for validation logic
test('validateScreenshot detects whitespace', () {
  final testImage = createTestImageWithWhitespace();
  expect(() => validateScreenshot(testImage), throwsException);
});

test('validateScreenshot accepts valid screenshot', () {
  final testImage = createValidTestImage();
  validateScreenshot(testImage); // Should not throw
});
```

**Why This Matters**: Ensures validation logic works correctly and catches real issues.

---

### 10. Not Using Proper Error Messages

**Anti-Pattern**: Using generic error messages that don't help with debugging.

**Problem**: Makes it hard to understand what went wrong and how to fix it.

**Example**:
```dart
// BAD: Generic error message
expect(hasWhitespace, isFalse, reason: 'Screenshot has whitespace');
```

**Correct Approach**: Provide detailed error messages with context.

```dart
// GOOD: Detailed error message
expect(
  hasWhitespace,
  isFalse,
  reason: 'Screenshot ${screenshotPath} has whitespace at the bottom '
      '(whitespace pixels: $whitespacePixels, total pixels: $totalPixels, '
      'percentage: ${(whitespacePixels / totalPixels * 100).toStringAsFixed(2)}%). '
      'This indicates the screenshot was not captured at full screen size. '
      'Check the device size configuration in the screenshot generation test.'
);
```

**Why This Matters**: Saves debugging time and makes issues easier to fix.

---

## Deployment Anti-Patterns

### 11. Not Running Validation Before Deployment

**Anti-Pattern**: Deploying screenshots without running validation tests.

**Problem**: Invalid screenshots can make it to production.

**Example**:
```bash
# BAD: Deploy without validation
flutter test test/integration/store_screenshots_generation_test.dart --update-goldens
.\scripts\generate-store-screenshots.ps1
.\scripts\deploy-to-play-store.ps1
```

**Correct Approach**: Always run validation before deployment.

```bash
# GOOD: Validate before deploying
flutter test test/integration/store_screenshots_generation_test.dart --update-goldens
flutter test test/integration/store_screenshots_validation_test.dart
.\scripts\generate-store-screenshots.ps1
.\scripts\deploy-to-play-store.ps1
```

**Why This Matters**: Catches issues before they reach production.

---

### 12. Hardcoding Paths in Scripts

**Anti-Pattern**: Hardcoding absolute paths in scripts.

**Problem**: Scripts break when run from different locations or on different machines.

**Example**:
```powershell
# BAD: Hardcoded absolute path
$screenshotsDir = "C:\dev\flutter\marketing\unit_converter\screenshots"
```

**Correct Approach**: Use relative paths and resolve them at runtime.

```powershell
# GOOD: Relative path
$workspaceRoot = Resolve-Path ".."
$screenshotsDir = Join-Path $workspaceRoot "marketing\unit_converter\screenshots"
```

**Why This Matters**: Makes scripts more portable and maintainable.

---

## Testing Anti-Patterns

### 13. Not Using Test Isolation

**Anti-Pattern**: Tests that depend on each other or shared state.

**Problem**: Tests can fail intermittently or in different orders.

**Example**:
```dart
// BAD: Tests depend on shared state
late String sharedValue;

setUp(() {
  sharedValue = 'initial';
});

test('Test 1', () {
  sharedValue = 'modified';
});

test('Test 2', () {
  expect(sharedValue, equals('initial')); // Fails if Test 1 ran first
});
```

**Correct Approach**: Ensure each test is independent.

```dart
// GOOD: Each test is independent
test('Test 1', () {
  final value = 'initial';
  value = 'modified';
  expect(value, equals('modified'));
});

test('Test 2', () {
  final value = 'initial';
  expect(value, equals('initial'));
});
```

**Why This Matters**: Tests are reliable and can run in any order.

---

### 14. Not Cleaning Up Test Resources

**Anti-Pattern**: Tests that leave resources in an inconsistent state.

**Problem**: Subsequent tests may fail due to leftover state.

**Example**:
```dart
// BAD: No cleanup
test('Test with file creation', () {
  final file = File('test.txt');
  file.writeAsStringSync('test data');
  // File is not cleaned up
});
```

**Correct Approach**: Clean up resources in tearDown.

```dart
// GOOD: Cleanup in tearDown
late File testFile;

setUp(() {
  testFile = File('test.txt');
});

tearDown(() {
  if (testFile.existsSync()) {
    testFile.deleteSync();
  }
});

test('Test with file creation', () {
  testFile.writeAsStringSync('test data');
});
```

**Why This Matters**: Tests are isolated and don't interfere with each other.

---

## Summary

By avoiding these anti-patterns, you can:

1. **Generate high-quality screenshots** with legible text and proper full-screen rendering
2. **Maintain a DRY workspace** with shared utilities and cross-referenced documentation
3. **Follow proper file structure** for skills and documentation
4. **Write maintainable tests** that are isolated and reliable
5. **Deploy with confidence** knowing validation catches issues before production
6. **Debug efficiently** with clear error messages and proper logging

Remember: The best way to avoid anti-patterns is to review this document before starting new work and to get code reviews from team members.
