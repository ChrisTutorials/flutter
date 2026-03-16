# Skill: Taking Screenshots - Fast Workflow

## ⭐ PRIMARY METHOD: golden_screenshot (Automated)

**Use golden_screenshot for automated store screenshot generation.** This is the workspace standard for generating Play Store and App Store screenshots.

## Important: Avoid Common Anti-Patterns

**CRITICAL**: Before generating screenshots, review the [Workspace Anti-Patterns](../../rules/anti-patterns.md) document to avoid common mistakes, especially:
- Using `flutter test` for production screenshots (doesn't render fonts - use `integration_test` instead)
- Not validating text legibility
- Not checking for whitespace chunks throughout the entire image

## Why golden_screenshot?

- **Industry Standard**: Purpose-built for app store screenshots
- **Automatic Device Frames**: No manual frame editing needed
- **Multi-Device Support**: Phones, tablets, desktops
- **Multi-Language Support**: Easy localization
- **CLI Integration**: Works with CI/CD pipelines
- **Fastlane Integration**: Automatic upload to stores
- **Visual Regression**: Detects UI changes automatically

### Quick Start

```bash
# 1. Generate all screenshots
cd unit_converter
flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens

# 2. Validate screenshots (NEW - ensures full-screen with no whitespace)
flutter test test/integration/store_screenshots_validation_test.dart

# 3. Or use the automation script
powershell -ExecutionPolicy Bypass -File scripts/generate-store-screenshots.ps1

# 4. Or use Fastlane
cd android
fastlane generate_screenshots
```

### Screenshot Validation

**NEW**: All store screenshots must pass full-screen validation to ensure they have no whitespace and fill the entire image area.

For details on the validation methodology, see:
- **[full-screen-screenshot-validation/](../full-screen-screenshot-validation/)** - Validation methodology and troubleshooting
- **[full-screen-screenshot-methodology.md](../../unit_converter/docs/full-screen-screenshot-methodology.md)** - Complete technical documentation

### Detailed Documentation

See [golden-screenshot-practice.md](../rules/golden-screenshot-practice.md) for complete documentation.

---

## 📋 ALTERNATIVE METHODS (Manual/Development)

**Use these methods only for development or when golden_screenshot is not suitable.**

### Option 1: Web Browser (Fastest for Manual Screenshots)

#### Step 1: Run App in Browser
`ash
cd c:\dev\flutter\unit_converter
flutter run -d chrome
`

#### Step 2: Take Screenshots Using Browser DevTools

**Chrome DevTools Method:**
1. Press F12 to open DevTools
2. Press Ctrl+Shift+P to open Command Menu
3. Type " screenshot\ and choose:
 - \Capture screenshot\ - captures visible area
 - \Capture full size screenshot\ - captures entire page
4. Save to appropriate location

**Browser Extensions:**
- GoFullPage - Full page screenshots
- Awesome Screenshot - Annotated screenshots
- Lightshot - Quick screenshots with editing

#### Step 3: Resize Browser for Store Screenshots

For Google Play Store screenshots (9:16 aspect ratio):
1. Press F12 to open DevTools
2. Click the device toolbar icon (Ctrl+Shift+M)
3. Select \Responsive\ or custom dimensions
4. Set dimensions to 1080x1920 for phone screenshots
5. Take screenshot

### Option 2: Playwright (Fastest for Automated Screenshots - Alternative to golden_screenshot)

**Note: This is an alternative method. Use golden_screenshot as the primary method for store screenshots.**

#### Step 1: Install Playwright
`ash
cd c:\dev\flutter\unit_converter
npm install -D @playwright/test
npx playwright install
`

#### Step 2: Create Screenshot Script

Create screenshots.spec.ts:
` ypescript
import { test, expect } from '@playwright/test';

test.describe('Unit Converter Screenshots', () => {
 test.beforeEach(async ({ page }) => {
 // Navigate to the app running in browser
 await page.goto('http://localhost:8080');
 await page.waitForLoadState('networkidle');
 });

 test('Home screen', async ({ page }) => {
 await page.setViewportSize({ width: 1080, height: 1920 });
 await page.screenshot({ path: 'screenshots/01_home.png' });
 });

 test('Length conversion', async ({ page }) => {
 await page.setViewportSize({ width: 1080, height: 1920 });
 // Navigate to length conversion
 await page.click('text=Length');
 await page.waitForLoadState('networkidle');
 await page.screenshot({ path: 'screenshots/02_length.png' });
 });

 test('Currency converter', async ({ page }) => {
 await page.setViewportSize({ width: 1080, height: 1920 });
 // Navigate to currency
 await page.click('text=Currency');
 await page.waitForLoadState('networkidle');
 await page.screenshot({ path: 'screenshots/03_currency.png' });
 });

 test('Theme settings', async ({ page }) => {
 await page.setViewportSize({ width: 1080, height: 1920 });
 // Navigate to settings
 await page.click('[aria-label=\Settings\]');
 await page.waitForLoadState('networkidle');
 await page.screenshot({ path: 'screenshots/04_settings.png' });
 });

 test('Custom units', async ({ page }) => {
 await page.setViewportSize({ width: 1080, height: 1920 });
 // Navigate to custom units
 await page.click('text=Custom Units');
 await page.waitForLoadState('networkidle');
 await page.screenshot({ path: 'screenshots/05_custom_units.png' });
 });
});
`

#### Step 3: Run Screenshot Script

First, run the Flutter app in web mode:
`ash
flutter run -d chrome --web-port 8080
`

Then, in another terminal:
`ash
npx playwright test screenshots.spec.ts
`

All screenshots will be captured automatically in one run!

### Option 3: Simple Browser Automation (Quick & Easy - Alternative to golden_screenshot)

**Note: This is an alternative method. Use golden_screenshot as the primary method for store screenshots.**

Create a simple PowerShell script:
`powershell
# Run Flutter app
Start-Process -FilePath \flutter\ -ArgumentList \run -d chrome --web-port 8080\ -NoNewWindow

# Wait for app to start
Start-Sleep -Seconds 10

# Open browser to localhost
Start-Process \chrome.exe\ \http://localhost:8080\

# Wait for user to navigate manually
Read-Host \Press Enter when you are ready to take screenshot\

# Take screenshot using browser automation
# (You can use browser extensions or manual screenshot tools here)
`

## Screenshots to Capture

### Required for Google Play Store:
1. Home screen with categories and presets
2. Length conversion screen
3. Currency converter screen
4. Theme settings screen
5. Custom units screen
6. Search functionality

### Optional but Recommended:
- Light theme screenshots
- Dark theme screenshots
- Different conversion examples

## Google Play Store Requirements

### Phone Screenshots:
- **Format**: PNG or JPEG
- **Size**: Up to 8 MB each
- **Dimensions**: 320-3840 pixels on each side
- **Aspect Ratio**: 9:16 (portrait) for this project
- **Quantity**: 2-8 screenshots
- **Promotion Eligibility**: At least 4 screenshots at minimum 1080px on each side

### Recommended Sizes:
- Phone: 1080 x 1920
- 7-inch tablet: 1200 x 1920
- 10-inch tablet: 1600 x 2560

## Quick Start Guide

### Primary Method (Store Screenshots - Automated):
```bash
# Use golden_screenshot (workspace standard)
cd unit_converter
flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens
```

### Alternative Method (Manual - Development Only):
```bash
# 1. Run app in browser
cd unit_converter
flutter run -d chrome

# 2. Use browser devtools to take screenshots
# F12 -> Ctrl+Shift+P -> 'screenshot'

# 3. Resize to 1080x1920 for store screenshots
# F12 -> Ctrl+Shift+M -> Set dimensions
```

## Best Practices

1. **Use golden_screenshot for store screenshots** - This is the workspace standard
2. **Use browser-based screenshots for development** - Much faster than emulator
3. **Test in multiple themes** - Capture both light and dark themes
4. **Verify dimensions** - Ensure screenshots meet store requirements
5. **Organize files** - Use descriptive filenames
6. **Check quality** - Verify screenshots are clear and readable
7. **Automate with golden_screenshot** - Use for repeatable store screenshots

## Troubleshooting

### Issue: App not loading in browser
**Solution:** Make sure web build is working:
`ash
flutter build web
flutter run -d chrome
`

### Issue: Screenshots are blurry
**Solution:** Use higher resolution viewport in Playwright or browser zoom

### Issue: Playwright cannot find elements
**Solution:** Use Playwright Inspector to test selectors:
`ash
npx playwright codegen http://localhost:8080
`

### Issue: Screenshots not capturing entire page
**Solution:** Use \fullPage\ option in Playwright:
` ypescript
await page.screenshot({ 
 path: 'screenshot.png', 
 fullPage: true 
});
`

## Related Skills

- **[full-screen-screenshot-validation/](../full-screen-screenshot-validation/)** - Full-screen screenshot validation methodology (NEW)
- [golden-screenshot-practice.md](../rules/golden-screenshot-practice.md) - Workspace standard for automated store screenshots
- [fastlane-setup/](../fastlane-setup/) - Automated Play Store deployment with screenshot upload
- [run-android-simulator/](../run-android-simulator/) - Only needed for testing, not screenshots

## Additional Resources

- [Playwright Documentation](https://playwright.dev)
- [Flutter Web Documentation](https://flutter.dev/web)
- [Google Play Store Asset Guidelines](https://support.google.com/googleplay/android-developer/answer/10788323)
- [Chrome DevTools Screenshots](https://developer.chrome.com/docs/devtools/screenshots/)

