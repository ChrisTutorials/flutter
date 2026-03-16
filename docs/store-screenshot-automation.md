# Reusable Store Screenshot Automation

This document defines the reusable screenshot workflow for apps in this workspace.

## Goal

Produce repeatable store screenshots that are:

- deterministic
- sized to storefront requirements
- visually dense
- validated by automated tests and post-export checks

## Workflow Layers

1. App runtime support
   - Each app exposes deterministic screenshot states through deep links, route parameters, seeded data, or launch arguments.
2. Raw capture
   - Capture raw screenshots into an app-owned `raw_store_screenshots` folder.
   - Raw capture can come from browser automation, Playwright, or native device automation.
3. Post-processing
   - Run the reusable `marketing/tools/store_screenshots` tool to crop and resize the raw captures.
4. Validation
   - Validate dimensions, file size, and trailing whitespace before publishing.

## Reusable Tool Location

- Tool package: `marketing/tools/store_screenshots`
- Shared commands:
  - `dart run bin/store_screenshots.dart process <spec.json>`
  - `dart run bin/store_screenshots.dart validate <spec.json>`

## App Integration Contract

Each app should provide:

- a deterministic way to open the target screens
- a raw screenshot directory
- a per-app JSON spec describing target outputs

Recommended per-app layout:

- `marketing/<app>/screenshots/raw_store_screenshots/`
- `marketing/<app>/screenshots/store_screenshots/`
- `marketing/<app>/screenshots/store_screenshot_spec.json`

## Validation Contract

The current tool validates:

- exact output dimensions
- image file size limit
- excessive top whitespace
- excessive bottom whitespace

This is intentionally strict enough to catch sparse exports while remaining reusable across apps.

## Test Coverage Expectations

Each workflow change should keep these test layers green:

1. Tool unit tests for cropping and validation.
2. Spec parsing tests for each app spec that uses the tool.
3. App-level runtime tests for deterministic screenshot states where the app exposes them.

## Long-Term Capture Options

The tool is capture-source agnostic.

- Fast path: web build plus browser automation.
- Native Android path: Espresso or UI Automator, commonly through Fastlane Screengrab.
- Native iOS path: XCUITest-based scripted capture.

The important rule is determinism. AI can help set up the pipeline, but the exported assets must come from scripted, repeatable states.

