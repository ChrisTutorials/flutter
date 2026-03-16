# Full-Screen Screenshot Methodology

## Overview

This methodology ensures all store screenshots are captured at full-screen size with no whitespace, providing a consistent and professional appearance across all devices.

## Quick Reference

For quick instructions on generating and validating screenshots, see:
- **[.windsurf/skills/full-screen-screenshot-validation/](../.windsurf/skills/full-screen-screenshot-validation/)** - Agent skill with quick start and troubleshooting

This document provides complete technical details.

## Problem Statement

Previous screenshot implementations had issues with:
1. White space at the bottom or top of screenshots
2. Inaccurate cropping that cut off app content
3. Screenshots not showing the full app screen
4. Inconsistent dimensions across different devices

## Solution: Comprehensive Validation

We've implemented a multi-layered validation approach that checks for whitespace throughout the entire image, not just at the edges.

### Validation Layers

#### 1. Dimension Validation
- Verifies each screenshot has the exact target dimensions:
  - Phone: 1080x1920 pixels
  - Tablet 7": 1200x1920 pixels
  - Tablet 10": 1600x2560 pixels

#### 2. Edge Whitespace Detection
- Checks the first 5% of the image for whitespace at the top
- Checks the last 5% of the image for whitespace at the bottom
- Ensures no white bars at the edges

#### 3. Whitespace Chunk Detection (NEW)
- Scans the entire image in 100-pixel chunks (both horizontal and vertical)
- Counts chunks that are >98% white
- **Key innovation**: Tracks consecutive whitespace chunks
- Allows at most 3 consecutive whitespace chunks (300 pixels)
- **This catches large whitespace bands while allowing legitimate white UI elements**

#### 4. Quadrant Content Validation (NEW)
- Divides the image into 4 quadrants
- Verifies each quadrant has sufficient non-white content (>2%)
- Ensures the screenshot fills the entire image area
- **Catches issues where the app only occupies part of the screen**

#### 5. Overall Content Validation
- Samples pixels throughout the image
- Ensures the screenshot is not mostly blank
- Minimum 1% informative pixels required

## How It Works

### Chunk Detection Algorithm

The whitespace chunk detection works by:

1. **Horizontal Chunks**: Scans each row of pixels in 100-pixel vertical strips
   - If a strip is >98% white, it's flagged as a whitespace chunk
   - Tracks consecutive whitespace chunks
   - This catches horizontal whitespace bands

2. **Vertical Chunks**: Scans each column of pixels in 100-pixel horizontal strips
   - If a strip is >98% white, it's flagged as a whitespace chunk
   - Tracks consecutive whitespace chunks
   - This catches vertical whitespace bands

3. **Threshold**: Maximum of 3 consecutive whitespace chunks allowed (300 pixels)
   - This tolerance allows for legitimate white UI elements (e.g., input fields, cards) that may be scattered
   - But prevents large contiguous whitespace areas that indicate improper capture
   - **Key insight**: Consecutive chunks indicate a band, scattered chunks indicate legitimate UI

### Quadrant Validation Algorithm

The quadrant validation ensures the screenshot fills the entire image:

1. Divides the image into 4 equal quadrants (top-left, top-right, bottom-left, bottom-right)
2. Samples pixels in each quadrant
3. Requires each quadrant to have >2% non-white content
4. If any quadrant fails, the screenshot is rejected

This catches issues where:
- The app is centered with whitespace on edges
- The screenshot was cropped incorrectly
- The device size was not set properly during capture

## Screenshot Generation Workflow

### Step 1: Generate Raw Screenshots

```bash
flutter test test/integration/store_screenshots_generation_test.dart --update-goldens
```

This test:
- Sets the device surface size to the exact target dimensions
- Navigates to each required screen
- Captures the full device screen (not just the widget tree)
- Saves screenshots to `marketing/unit_converter/screenshots/raw_store_screenshots/`

**Critical**: The device size must be set correctly in the test. The `setSurfaceSize` call ensures the screenshot captures the full device at the exact dimensions.

### Step 2: Validate Screenshots

```bash
flutter test test/integration/store_screenshots_validation_test.dart
```

This runs all validation layers:
1. ✅ Correct dimensions
2. ✅ No whitespace at top (5% check)
3. ✅ No whitespace at bottom (5% check)
4. ✅ No large whitespace chunks (NEW)
5. ✅ Content in all quadrants (NEW)
6. ✅ Overall content not blank

If any validation fails, the test will tell you exactly which screenshot failed and why.

### Step 3: Process for Play Store

```bash
.\scripts\generate-store-screenshots.ps1
```

This script:
1. Validates the raw screenshots (runs the validation test)
2. Processes screenshots with the shared tooling
3. Copies processed screenshots to the Play Store metadata folders
4. Optionally uploads to Play Store

### Step 4: Deploy

```bash
.\scripts\release.ps1 -Track production
```

## Troubleshooting

### Validation Fails: "Whitespace chunks detected"

**Problem**: The screenshot has large contiguous whitespace bands, indicating it wasn't captured at full screen size.

**Solution**:
1. Check the device size in `test/integration/store_screenshots_generation_test.dart`
2. Ensure `setSurfaceSize` is called with the correct dimensions
3. Verify the screenshot is capturing the full device, not just a widget
4. Note: Scattered white UI elements are allowed; only contiguous bands cause failure

### Validation Fails: "Quadrant is mostly empty"

**Problem**: One or more quadrants of the screenshot are mostly white, indicating the app doesn't fill the screen.

**Solution**:
1. Check that the app is being rendered at full screen size
2. Verify `MediaQuery` is set with zero padding in the test harness
3. Ensure the app's layout is responsive and fills the available space

### Validation Fails: "Wrong dimensions"

**Problem**: The screenshot doesn't have the expected dimensions.

**Solution**:
1. Check the device size configuration in `test/support/store_screenshot_test_harness.dart`
2. Verify the `resolution` parameter in `ScreenshotDevice` matches the target
3. Ensure `setSurfaceSize` is called with the same dimensions

### Validation Fails: "Whitespace at top/bottom"

**Problem**: The screenshot has whitespace at the edges.

**Solution**:
1. This usually means the screenshot capture is not including the full device
2. Check that `setSurfaceSize` is called before `takeScreenshot`
3. Verify the surface size is reset after capture

## Technical Details

### Why Chunk Detection?

Traditional screenshot validation only checks the edges (top 5%, bottom 5%). This misses several issues:

1. **Centered Layouts**: If the app is centered with whitespace on all sides, edge checks pass
2. **Horizontal Bands**: A horizontal whitespace band in the middle won't be caught
3. **Vertical Bands**: A vertical whitespace band won't be caught
4. **Partial Screen Capture**: If only part of the screen is captured, edge checks might still pass

Chunk detection scans the entire image, catching all these issues.

### Why Quadrant Validation?

Quadrant validation ensures the screenshot fills the entire image area:

1. **Full Coverage**: All four quadrants must have content
2. **No Edge Gaps**: Prevents whitespace on any edge
3. **Responsive Layouts**: Ensures the app layout fills the available space
4. **Cropping Detection**: Catches improper cropping that removes content

### Thresholds Explained

- **Whitespace threshold**: 98% white pixels
  - Allows for legitimate white UI elements (cards, input fields, backgrounds)
  - Still catches large whitespace areas that indicate problems
  - Stricter than 95% to reduce false positives

- **Max consecutive whitespace chunks**: 3 (300 pixels)
  - Allows for small legitimate white areas
  - Prevents large contiguous whitespace bands
  - **Key innovation**: Consecutive check distinguishes between scattered UI elements and improper capture

- **Quadrant content**: 2% non-white pixels
  - Very low threshold, ensures at least some content in each quadrant
  - Prevents completely empty quadrants

- **Overall content**: 1% informative pixels
  - Ensures the screenshot is not mostly blank
  - Catches completely empty or corrupted screenshots

## Integration with Release Process

The validation tests are integrated into the release workflow:

1. `generate-store-screenshots.ps1` runs validation before processing
2. Validation failures prevent the script from continuing
3. This ensures only properly captured screenshots make it to the Play Store

## Next Steps for New Screenshots

When preparing screenshots for a new release:

1. **Update screenshot scenarios** (if needed):
   - Edit `test/support/store_screenshot_test_harness.dart`
   - Modify `StoreScreenshotSurface` enum for new screens or data

2. **Generate new raw screenshots**:
   ```bash
   flutter test test/integration/store_screenshots_generation_test.dart --update-goldens
   ```

3. **Validate the new screenshots**:
   ```bash
   flutter test test/integration/store_screenshots_validation_test.dart
   ```

4. **Review the screenshots manually**:
   - Open screenshots in an image viewer
   - Verify they look correct visually
   - Check that all UI elements are visible

5. **Process for Play Store**:
   ```bash
   .\scripts\generate-store-screenshots.ps1
   ```

6. **Commit the screenshots**:
   - Commit both raw and processed screenshots
   - This ensures reproducibility

## Best Practices

1. **Always run validation before deploying**: Never skip the validation step
2. **Commit raw screenshots**: Keep raw screenshots in version control for reproducibility
3. **Review visually**: Automated checks are good, but visual review is still important
4. **Test on all device sizes**: Ensure screenshots look good on phone, tablet 7", and tablet 10"
5. **Keep scenarios up to date**: Update screenshot scenarios when UI changes significantly

## Summary

This methodology provides:
- ✅ Comprehensive validation of full-screen screenshots
- ✅ Detection of whitespace chunks throughout the entire image
- ✅ Consecutive chunk tracking to distinguish legitimate UI from improper capture
- ✅ Verification that screenshots fill the entire image area (quadrant validation)
- ✅ Automated integration with the release process
- ✅ Clear error messages for troubleshooting
- ✅ Reproducible screenshot generation

By following this methodology, we ensure all store screenshots are professional, consistent, and properly captured at full screen size.
