# Skill: Full-Screen Screenshot Validation Methodology

## Overview

This skill provides the methodology for ensuring all store screenshots are captured at full-screen size with no whitespace. This is the workspace standard for validating screenshot quality.

## When to Use This Skill

Use this methodology when:
- Generating new store screenshots for Play Store
- Validating that screenshots are full-screen with no whitespace
- Troubleshooting screenshot capture issues
- Reviewing screenshot quality before deployment

## Important: Avoid Common Anti-Patterns

**CRITICAL**: Before generating screenshots, review the [Workspace Anti-Patterns](../../rules/anti-patterns.md) document to avoid common mistakes, especially:
- Using `flutter test` for production screenshots (doesn't render fonts)
- Not validating text legibility
- Not checking for whitespace chunks throughout the entire image

For production screenshots, use `integration_test` instead of `flutter test` to ensure fonts render properly.

## Key Concepts

### Validation Layers

The validation uses 5 layers to ensure screenshot quality:

1. **Dimension Validation**: Exact dimensions (1080x1920, 1200x1920, 1600x2560)
2. **Edge Whitespace Detection**: No whitespace at top/bottom (5% check)
3. **Whitespace Chunk Detection**: No large contiguous whitespace bands
4. **Quadrant Content Validation**: Content in all 4 quadrants
5. **Overall Content Validation**: Not mostly blank

### Key Innovation: Consecutive Chunk Detection

The validation tracks **consecutive** whitespace chunks rather than total count, which allows legitimate white UI elements while still catching improper capture.

- **Scattered white UI elements**: ✅ Pass (not consecutive)
- **Large whitespace band**: ❌ Fail (consecutive chunks)

## Quick Start

### Generate and Validate Screenshots

```bash
# 1. Clean existing screenshots
Remove-Item -Path "..\marketing\unit_converter\screenshots\raw_store_screenshots\*.png" -Force

# 2. Generate new screenshots
flutter test test/integration/store_screenshots_generation_test.dart --update-goldens

# 3. Validate screenshots
flutter test test/integration/store_screenshots_validation_test.dart

# 4. Process for Play Store
.\scripts\generate-store-screenshots.ps1
```

### Validate Existing Screenshots

```bash
# Run validation only
flutter test test/integration/store_screenshots_validation_test.dart
```

## Detailed Documentation

For complete technical details, algorithms, troubleshooting, and threshold explanations, see:

- **[full-screen-screenshot-methodology.md](../../unit_converter/docs/full-screen-screenshot-methodology.md)** - Complete technical documentation
- **[screenshot-generation-workflow.md](../../unit_converter/docs/screenshot-generation-workflow.md)** - Step-by-step workflow
- **[FULL_SCREEN_SCREENSHOT_IMPLEMENTATION.md](../../unit_converter/FULL_SCREEN_SCREENSHOT_IMPLEMENTATION.md)** - Quick reference summary

## Validation Test

The validation test is located at:
- **File**: `unit_converter/test/integration/store_screenshots_validation_test.dart`
- **Run**: `flutter test test/integration/store_screenshots_validation_test.dart`

## Troubleshooting

### Validation Fails: "Consecutive whitespace chunks detected"

**Problem**: Large contiguous whitespace band detected.

**Solution**:
1. Check device size in `test/support/store_screenshot_test_harness.dart`
2. Verify `setSurfaceSize` is called with correct dimensions
3. Ensure screenshot captures full device, not just widget
4. Note: Scattered white UI elements are allowed; only contiguous bands cause failure

### Validation Fails: "Quadrant is mostly empty"

**Problem**: One or more quadrants have insufficient content.

**Solution**:
1. Verify `MediaQuery` is set with zero padding
2. Check app layout fills available space
3. Ensure screenshot capture includes full device

### Validation Fails: "Wrong dimensions"

**Problem**: Screenshot doesn't have expected dimensions.

**Solution**:
1. Check `resolution` parameter in `ScreenshotDevice` configurations
2. Verify `setSurfaceSize` is called with correct dimensions
3. Ensure device pixel ratio is set correctly (should be 1 for screenshots)

## Thresholds

- **Whitespace threshold**: 98% white pixels
- **Max consecutive whitespace chunks**: 3 (300 pixels)
- **Quadrant content**: 2% non-white pixels
- **Overall content**: 1% informative pixels

## Related Skills

- **[take-screenshots/](../take-screenshots/)** - General screenshot taking methods (golden_screenshot, browser, Playwright)
- **[fastlane-setup/](../fastlane-setup/)** - Automated Play Store deployment with screenshot upload

## Related Scripts

- **[generate-store-screenshots.ps1](../../unit_converter/scripts/generate-store-screenshots.ps1)** - Screenshot processing script
- **[fastlane-wrapper.ps1](../scripts/fastlane-wrapper.ps1)** - Fastlane automation wrapper

## Integration with Release Process

The validation tests are integrated into the release workflow:

1. `generate-store-screenshots.ps1` runs validation before processing
2. Validation failures prevent the script from continuing
3. This ensures only properly captured screenshots make it to the Play Store

## Best Practices

1. **Always run validation before deploying**: Never skip the validation step
2. **Commit raw screenshots**: Keep raw screenshots in version control for reproducibility
3. **Review visually**: Automated checks are good, but visual review is still important
4. **Test on all device sizes**: Ensure screenshots look good on phone, tablet 7", and tablet 10"
5. **Keep scenarios up to date**: Update screenshot scenarios when UI changes significantly

## When to Regenerate Screenshots

Regenerate screenshots when:
- UI changes significantly
- New features are added that should be showcased
- Theme or color scheme changes
- Layout changes
- Bug fixes affect visual appearance
- New device sizes are supported
- Validation tests are improved

