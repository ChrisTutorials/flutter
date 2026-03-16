# Marketing Materials

This folder contains marketing materials for Flutter applications in this monorepo.

## Structure

Marketing materials are organized by app:

- `unit_converter/` - Marketing materials for the Unit Converter app
  - `graphics/` - App logos and feature graphics
  - `screenshots/` - Store and UI screenshots
  - `docs/` - Marketing documentation and copy
- `tools/` - Reusable marketing automation tools shared across apps
- `docs/` - Reusable marketing workflow documentation shared across apps

## Unit Converter Marketing

### Graphics
- `feature-graphic-unit-converter-v2.jpg` - Featured graphic for app stores (v2)
- `feature-graphic-unit-converter.png` - Featured graphic for app stores
- `unit-converter-logo.png` - Unit converter app logo

### Screenshots
- `screenshots/store_screenshots/` - Screenshots for app store listings
  - Phone screenshots (1080x1920)
  - Tablet 7" screenshots (1200x1920)
  - Tablet 10" screenshots (1600x2560)
- `screenshots/ui_screenshots/` - UI screenshots for documentation and marketing

### Documentation
- `docs/APP_STORE_PROMO.md` - App store promotional text
- `docs/FEATURE_GRAPHIC_PROMPT.md` - Prompt used to generate feature graphics
- `docs/MARKETING_COPY_AUDIT.md` - Audit of marketing copy
- `docs/STORE_SCREENSHOT_REQUIREMENTS.md` - Requirements for store screenshots
- `docs/STORE_LISTING_CONTENT.md` - Content for store listings
- `docs/COMPETITIVE_ANALYSIS.md` - Competitive analysis of unit converter apps

## Shared Screenshot Workflow

- `docs/STORE_SCREENSHOT_AUTOMATION.md` - Reusable screenshot workflow for apps in this workspace
- `tools/store_screenshots/` - Shared crop, resize, and validation tooling for store screenshots

Apps that use the shared screenshot workflow should keep:

- raw captures in an app-owned `raw_store_screenshots/` folder
- processed assets in an app-owned `store_screenshots/` folder
- a per-app `store_screenshot_spec.json` beside those folders

## Usage

These materials are used for:
- App store submissions (Google Play, Apple App Store)
- Website and social media marketing
- Documentation and presentations
- Promotional materials

