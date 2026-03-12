# Store Screenshot Requirements

This document is the source of truth for Google Play screenshot assets for this project.

The reusable cross-app workflow lives in `marketing/docs/STORE_SCREENSHOT_AUTOMATION.md`. This file only describes the unit_converter-specific spec, asset set, and capture expectations.

## Default Export Rule

- Use portrait screenshots for the default exported store set across phone, 7-inch tablet, and 10-inch tablet.
- Keep orientation consistent across the delivered set.
- The default exported set must cover the main user-facing surfaces only: home with history, conversion, currency, and custom units.
- Settings and other minor utility pages are excluded from the default exported set.

## File Format Rules

- Allowed formats: PNG or JPEG
- Maximum file size: 8 MB per image

## Required Sizes

| Device family | Portrait size |
| ------------ | ------------- |
| Phone | 1080 x 1920 |
| 7-inch tablet | 1200 x 1920 |
| 10-inch tablet | 1600 x 2560 |

## Required Coverage

- Every device family must include the main surfaces of the app.
- Every device family must contain at least 1 light mode screenshot and at least 1 dark mode screenshot.
- Home screenshots must show the history section so the frame is content-dense.
- Screenshots must avoid large empty regions and should visually fill the frame with meaningful content.
- Every exported image must stay below the 8 MB Play Console limit.

## Current Exported Set

The current exported files in marketing/unit_converter/screenshots/store_screenshots are generated from:

- raw captures: `marketing/unit_converter/screenshots/raw_store_screenshots`
- app spec: `marketing/unit_converter/screenshots/store_screenshot_spec.json`
- shared tool: `marketing/tools/store_screenshots`

The processed exported files are:

- Phone:
  phone_01_home_history_light_portrait_1080x1920.png
  phone_02_conversion_light_portrait_1080x1920.png
  phone_03_currency_dark_portrait_1080x1920.png
  phone_04_custom_units_dark_portrait_1080x1920.png
- 7-inch tablet:
  tablet7_01_home_history_light_portrait_1200x1920.png
  tablet7_02_conversion_light_portrait_1200x1920.png
  tablet7_03_currency_dark_portrait_1200x1920.png
  tablet7_04_custom_units_dark_portrait_1200x1920.png
- 10-inch tablet:
  tablet10_01_home_history_light_portrait_1600x2560.png
  tablet10_02_conversion_light_portrait_1600x2560.png
  tablet10_03_currency_dark_portrait_1600x2560.png
  tablet10_04_custom_units_dark_portrait_1600x2560.png

All current PNG exports are below the 8 MB Play Console limit.

## Content Matrix

Use this matrix for the default export set:

| Surface | Phone | Tablet 7" | Tablet 10" | Theme |
| ------- | ----- | ---------- | ----------- | ----- |
| Home with history | 1080 x 1920 | 1200 x 1920 | 1600 x 2560 | Light |
| Conversion | 1080 x 1920 | 1200 x 1920 | 1600 x 2560 | Light |
| Currency | 1080 x 1920 | 1200 x 1920 | 1600 x 2560 | Dark |
| Custom units | 1080 x 1920 | 1200 x 1920 | 1600 x 2560 | Dark |

## No-Whitespace Composition Rules

Use these capture rules so screenshots fill the frame with useful content:

1. Home screenshots must deep-link into seeded recent conversion data and scroll to the history section.
2. Custom units screenshots must use seeded demo units so the list view is populated instead of showing an empty state.
3. Prefer content-dense pages that naturally fill the viewport: conversion, currency, populated custom units, and home-with-history.
4. Do not export screenshots with large empty regions below the primary content.
5. When needed, use deterministic initial scroll targets rather than manual cropping.

## Industry Standard Automation Pattern

Industry-standard mobile screenshot automation is deterministic, not AI-improvised. The common pattern is:

1. Fixed device presets for each storefront size.
2. Seeded fixture data so every run has the same content.
3. Deep links or launch arguments to open the exact screen needed.
4. Scripted capture through UI automation.
5. Post-capture validation of image dimensions and file sizes.

For Android specifically, the mainstream production approach is Espresso or UI Automator driven capture, commonly wrapped by Fastlane Screengrab. That is the long-term standard if this workflow moves from browser-driven generation to device or emulator-native generation.

Our current workflow now follows the same core principles:

1. Fixed portrait device presets.
2. URL-driven screen selection.
3. Deterministic seeded store demo data.
4. Theme selection from query parameters.
5. Automated size verification after export.

## Repeatable Capture Workflow

The web build supports deterministic screenshot scenarios through query parameters.

Supported parameters:

- `screen=home|conversion|currency|custom-units`
- `theme=light|dark`
- `data=store`
- `scroll=history`
- `category`, `from`, `to`, `value`, `label`, `subtitle` for conversion and currency scenarios

Example patterns:

- Home with seeded history: `/?screen=home&data=store&theme=light&scroll=history`
- Conversion: `/?screen=conversion&category=Weight&from=g&to=lb&value=60&label=60%20g%20to%20lb&data=store&theme=light`
- Currency: `/?screen=currency&from=USD&to=EUR&value=250&label=USD%20to%20EUR&subtitle=Travel%20rates&data=store&theme=dark`
- Custom units: `/?screen=custom-units&data=store&theme=dark`

## Recommended Workflow For Next Time

1. Build web before capture so the running app matches the latest code.
2. Capture deterministic raw screenshots into `marketing/unit_converter/screenshots/raw_store_screenshots`.
3. Run `dart run bin/store_screenshots.dart process ../../unit_converter/screenshots/store_screenshot_spec.json` from `marketing/tools/store_screenshots`.
4. Keep the export portrait-only unless there is a specific store requirement to do otherwise.
5. Run `dart test` in `marketing/tools/store_screenshots` to verify the shared crop and validation logic.
6. Treat `unit_converter_workflow_validation_test.dart` as the regression guard for the committed unit_converter screenshot outputs.

## App Icon Source

- Source logo asset: unit_converter/assets/unit-converter-logo.png
- Source dimensions: 1024 x 1024
- Launcher icons are generated from this asset via the flutter_launcher_icons configuration in unit_converter/pubspec.yaml
