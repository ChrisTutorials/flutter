# Play Store Release Runbook

This document is the current source of truth for preparing and publishing the Android release of the unit_converter app.

## What Is Automated

- Flutter validation and release build through Fastlane.
- Deterministic store screenshot processing through `marketing/tools/store_screenshots`.
- Synchronization of processed screenshots and graphics into Fastlane's Play Store metadata layout.
- Upload of localized metadata text, screenshots, and graphics through Fastlane.

## Current Asset Sources

- Store screenshot spec: `../marketing/unit_converter/screenshots/store_screenshot_spec.json`
- Raw screenshot captures: `../marketing/unit_converter/screenshots/raw_store_screenshots`
- Processed screenshot exports: `../marketing/unit_converter/screenshots/store_screenshots`
- Source graphics: `../marketing/unit_converter/graphics`
- Fastlane metadata root: `android/fastlane/metadata/android`

## Metadata Files In Repo

Committed metadata text files live here:

- `android/fastlane/metadata/android/en-US/title.txt`
- `android/fastlane/metadata/android/en-US/short_description.txt`
- `android/fastlane/metadata/android/en-US/full_description.txt`

Generated image folders under `android/fastlane/metadata/android/**/images` are derived artifacts and are ignored by git.

## Release Sequence

1. Run app and screenshot validation:
   - `powershell -ExecutionPolicy Bypass -File scripts/pre-deployment-check.ps1`
2. Prepare store screenshots and synced metadata images:
   - `powershell -ExecutionPolicy Bypass -File scripts/generate-store-screenshots.ps1`
3. Review the processed exports in `../marketing/unit_converter/screenshots/store_screenshots`.
4. Upload listing text and image metadata:
   - `cd android`
   - `fastlane upload_metadata`
   - `fastlane upload_screenshots`
5. Build and ship the selected track:
   - `fastlane deploy_internal`
   - `fastlane deploy_alpha`
   - `fastlane deploy_beta`
   - `fastlane deploy_production`

For a single command flow, run:

- `powershell -ExecutionPolicy Bypass -File scripts/deploy-to-play-store.ps1 -Track internal -PrepareStoreAssets`

## What Still Requires Manual Verification

- Physical-device checks for ads, purchase flow, and upgrade to premium.
- Final Play Console forms: audience, data safety, content rating, and release notes.
- Verification that the uploaded screenshots match the intended storefront order.

## Credential Requirements

- `android/key.properties` for release signing.
- `android/fastlane/google-play-service-account.json` or `GOOGLE_PLAY_JSON_KEY_FILE` for Play Console upload.
- `GOOGLE_APPLICATION_CREDENTIALS` for Google Cloud services (see [Google Cloud Credentials Configuration](GOOGLE_CLOUD_CREDENTIALS.md)).
- `UNIT_CONVERTER_ADMOB_APP_ID` for production AdMob configuration (see [Release Credentials Setup Guide](RELEASE_CREDENTIALS_SETUP.md)).
- `PACKAGE_NAME` only if overriding the default application ID.

## First-Time Setup

Before your first release, complete the credential setup:

1. **AdMob App ID**: Follow the instructions in [Release Credentials Setup Guide](RELEASE_CREDENTIALS_SETUP.md#blocker-1-admob-app-id) to get and configure your production AdMob App ID.
2. **Play Console Service Account**: Follow the instructions in [Release Credentials Setup Guide](RELEASE_CREDENTIALS_SETUP.md#blocker-2-play-console-service-account) to set up Play Console API access.
3. **Google Cloud Credentials**: Follow the instructions in [Google Cloud Credentials Configuration](GOOGLE_CLOUD_CREDENTIALS.md) if using Google Cloud services.

## Release Gates

Do not push a production release until all of these are true:

- `flutter test` passes.
- `dart test` passes in `../marketing/tools/store_screenshots`.
- Release validation lanes pass in `android/fastlane/Fastfile`.
- Processed screenshots remain under the Play Console 8 MB limit.
- The AAB is signed with the production keystore.
- Ads and the `no_ads_premium` purchase are tested on a real device with Play billing.
