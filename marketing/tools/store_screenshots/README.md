# Store Screenshots Tooling

This package provides a reusable, deterministic workflow for store screenshot processing.

It is intended for apps in this workspace that can already produce deterministic raw screenshots through deep links, seeded data, or scripted navigation.

## What It Does

- Reads a per-app JSON workflow spec.
- Crops raw screenshots to the densest content bounds.
- Resizes the final images to store-required dimensions.
- Validates dimensions, file size, and trailing whitespace.

## Commands

```bash
dart run bin/store_screenshots.dart process ../../unit_converter/screenshots/store_screenshot_spec.json
dart run bin/store_screenshots.dart validate ../../unit_converter/screenshots/store_screenshot_spec.json
```

## Expected App Workflow

1. Generate deterministic raw screenshots into an app-owned raw screenshot folder.
2. Run `process` with that app's spec.
3. Commit the processed outputs and keep the raw captures only when they are needed for regeneration.

## Spec Shape

```json
{
  "name": "sample_app_store_listing",
  "rawDir": "../sample_app/screenshots/raw_store_screenshots",
  "outputDir": "../sample_app/screenshots/store_screenshots",
  "sizeLimitBytes": 8388608,
  "defaults": {
    "backgroundTolerance": 18,
    "contentPadding": 24,
    "maxBottomWhitespaceFraction": 0.04,
    "maxTopWhitespaceFraction": 0.10
  },
  "images": [
    {
      "id": "phone_home",
      "input": "phone_home_raw.png",
      "output": "phone_home.png",
      "targetWidth": 1080,
      "targetHeight": 1920
    }
  ]
}
```
