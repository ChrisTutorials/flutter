# Screenshot Generation Workflow for Next Release

## Overview

This workflow provides a step-by-step process for generating new full-screen screenshots for the next release of the Unit Converter plugin.

## Quick Reference

For quick instructions and troubleshooting, see:
- **[.windsurf/skills/full-screen-screenshot-validation/](../.windsurf/skills/full-screen-screenshot-validation/)** - Agent skill with quick start guide
- **[.windsurf/skills/take-screenshots/](../.windsurf/skills/take-screenshots/)** - General screenshot taking methods

This document provides a detailed step-by-step workflow.

## Prerequisites

- Flutter SDK installed
- All dependencies installed: `flutter pub get`
- Access to the marketing tools repository
- Git repository in clean state (no uncommitted changes)

## Step-by-Step Workflow

### Step 1: Clean Existing Screenshots

Before generating new screenshots, clean the existing raw screenshots:

```bash
# Navigate to the unit_converter directory
cd c:\dev\flutter\unit_converter

# Remove existing raw screenshots
Remove-Item -Path "..\marketing\unit_converter\screenshots\raw_store_screenshots\*.png" -Force
```

### Step 2: Generate New Raw Screenshots

Run the screenshot generation test with the `--update-goldens` flag:

```bash
flutter test test/integration/store_screenshots_generation_test.dart --update-goldens
```

This will:
- Generate all 12 screenshots (4 screens × 3 device types)
- Save them to `marketing/unit_converter/screenshots/raw_store_screenshots/`
- Use exact device dimensions (1080x1920, 1200x1920, 1600x2560)
- Capture the full device screen at the correct size

**Expected output**: 12 PNG files in the raw_screenshots directory

### Step 3: Validate Screenshots

Run the comprehensive validation test:

```bash
flutter test test/integration/store_screenshots_validation_test.dart
```

This will run all validation checks:
1. ✅ Correct dimensions
2. ✅ No whitespace at top (5% check)
3. ✅ No whitespace at bottom (5% check)
4. ✅ No large contiguous whitespace chunks (NEW - consecutive chunk detection)
5. ✅ Content in all quadrants (NEW - quadrant validation)
6. ✅ Overall content not blank

**If validation passes**: Continue to Step 4

**If validation fails**:
1. Note which screenshot(s) failed and why
2. Review the failure message carefully
3. Check the troubleshooting section below
4. Fix the issue and re-run Step 2

### Step 4: Visual Review

Open the generated screenshots in an image viewer and verify:

1. **All screenshots are present**:
   - phone_01_home_history_light_portrait_1080x1920.png
   - phone_02_conversion_light_portrait_1080x1920.png
   - phone_03_currency_dark_portrait_1080x1920.png
   - phone_04_custom_units_dark_portrait_1080x1920.png
   - tablet7_01_home_history_light_portrait_1200x1920.png
   - tablet7_02_conversion_light_portrait_1200x1920.png
   - tablet7_03_currency_dark_portrait_1200x1920.png
   - tablet7_04_custom_units_dark_portrait_1200x1920.png
   - tablet10_01_home_history_light_portrait_1600x2560.png
   - tablet10_02_conversion_light_portrait_1600x2560.png
   - tablet10_03_currency_dark_portrait_1600x2560.png
   - tablet10_04_custom_units_dark_portrait_1600x2560.png

2. **No whitespace at edges**: Check top, bottom, left, and right edges
3. **Full screen content**: Ensure the app fills the entire screenshot
4. **UI elements visible**: All buttons, text, and UI elements should be visible
5. **Correct themes**: Light theme for screenshots 1-2, dark theme for screenshots 3-4
6. **Correct content**: Verify the data preset (store data) is visible

### Step 5: Process Screenshots for Play Store

Run the screenshot processing script:

```bash
.\scripts\generate-store-screenshots.ps1
```

This will:
1. Validate raw screenshots (runs the validation test again)
2. Process screenshots with the shared tooling
3. Copy processed screenshots to Play Store metadata folders
4. Sync with Android fastlane metadata

**Expected output**: Processed screenshots in `marketing/unit_converter/screenshots/store_screenshots/` and `android/fastlane/metadata/android/en-US/images/`

### Step 6: Commit Screenshots

Commit the new screenshots to version control:

```bash
# Stage the raw screenshots
git add ../marketing/unit_converter/screenshots/raw_store_screenshots/*.png

# Stage the processed screenshots
git add ../marketing/unit_converter/screenshots/store_screenshots/*.png

# Stage the Play Store metadata
git add android/fastlane/metadata/android/en-US/images/phoneScreenshots/*.png
git add android/fastlane/metadata/android/en-US/images/sevenInchScreenshots/*.png
git add android/fastlane/metadata/android/en-US/images/tenInchScreenshots/*.png

# Commit with a descriptive message
git commit -m "Update store screenshots for next release

- Generated new full-screen screenshots using comprehensive validation
- Verified no whitespace chunks or empty quadrants
- All screenshots pass validation tests
- Screenshots captured at exact device dimensions"
```

### Step 7: Upload to Play Store (Optional)

If you want to upload directly to the Play Store:

```bash
.\scripts\generate-store-screenshots.ps1 -UploadToPlayStore
```

Or manually:

```bash
cd android
fastlane upload_screenshots
```

## Troubleshooting

### Issue: Validation fails with "Whitespace chunks detected"

**Cause**: The screenshot has large contiguous horizontal or vertical bands of whitespace.

**Solutions**:
1. Check the device size in `test/support/store_screenshot_test_harness.dart`
2. Verify the `resolution` parameter matches the target dimensions
3. Ensure `setSurfaceSize` is called correctly in the generation test
4. Check that the app is being rendered at full screen size
5. Note: Scattered white UI elements are allowed; only contiguous bands cause failure

### Issue: Validation fails with "Quadrant is mostly empty"

**Cause**: One or more quadrants of the screenshot are mostly white.

**Solutions**:
1. Verify `MediaQuery` is set with zero padding in the test harness
2. Check that the app's layout is responsive and fills the available space
3. Ensure the screenshot capture includes the full device, not just a widget
4. Review the app's layout code for issues with empty space

### Issue: Validation fails with "Wrong dimensions"

**Cause**: The screenshot doesn't have the expected dimensions.

**Solutions**:
1. Check the `resolution` parameter in `ScreenshotDevice` configurations
2. Verify `setSurfaceSize` is called with the correct dimensions
3. Ensure the device pixel ratio is set correctly (should be 1 for screenshots)

### Issue: Screenshots look correct visually but validation fails

**Cause**: The validation thresholds might be too strict for legitimate UI elements.

**Solutions**:
1. Review the failed screenshot in an image editor
2. Check if there are large white areas that are part of the UI design
3. Consider adjusting the validation thresholds in `test/integration/store_screenshots_validation_test.dart`
4. Document any threshold changes with a clear explanation

### Issue: Generation test fails or produces no screenshots

**Cause**: The test harness or screenshot generation logic has an issue.

**Solutions**:
1. Check that `golden_screenshot` package is properly installed
2. Verify the test can access the screenshot directory
3. Check for errors in the test output
4. Ensure the app can be rendered in test mode

## Verification Checklist

Before considering the screenshot generation complete, verify:

- [ ] All 12 raw screenshots are generated
- [ ] All screenshots pass validation tests
- [ ] No whitespace chunks detected in any screenshot
- [ ] All quadrants have sufficient content
- [ ] Screenshots have correct dimensions
- [ ] Visual review confirms screenshots look correct
- [ ] Screenshots are processed for Play Store
- [ ] Screenshots are committed to version control
- [ ] (Optional) Screenshots are uploaded to Play Store

## When to Regenerate Screenshots

Regenerate screenshots when:

1. **UI changes**: Any significant change to the app's UI
2. **New features**: Adding new features that should be showcased
3. **Theme changes**: Changes to color schemes or theming
4. **Layout changes**: Changes to the app's layout or responsive behavior
5. **Bug fixes**: Fixes that affect the visual appearance
6. **New device sizes**: Adding support for new device sizes
7. **Validation improvements**: When validation tests are improved

## Automation

This workflow can be partially automated:

```bash
# One-command generation and validation
flutter test test/integration/store_screenshots_generation_test.dart --update-goldens; flutter test test/integration/store_screenshots_validation_test.dart
```

However, visual review (Step 4) should always be done manually to ensure screenshots look correct.

## Related Documentation

- [FULL_SCREEN_SCREENSHOT_METHODOLOGY.md](FULL_SCREEN_SCREENSHOT_METHODOLOGY.md) - Detailed explanation of the validation algorithms
- [SCREENSHOT_FIX_SUMMARY.md](SCREENSHOT_FIX_SUMMARY.md) - Summary of the screenshot fix implementation
- [take-screenshots.md](../../.windsurf/skills/take-screenshots.md) - General screenshot skills

## Support

If you encounter issues not covered in this workflow:

1. Check the validation test output for detailed error messages
2. Review the methodology documentation for technical details
3. Examine the failed screenshots in an image editor
4. Consult the troubleshooting section above
5. Check the git history for previous screenshot generation commits
