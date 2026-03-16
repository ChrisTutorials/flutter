# Play Store Release Runbook

This document is the current source of truth for preparing and publishing the Android release of the unit_converter app.

## 🚀 Quick Start (Recommended)

### Single Command Deployment

The easiest way to deploy is to use the all-in-one deployment command:

```powershell
# Deploy to internal testing (default)
.\scripts\release.ps1

# Deploy to production
.\scripts\release.ps1 -Track production -ReleaseNotes "New features and bug fixes"

# Deploy to beta
.\scripts\release.ps1 -Track beta -ReleaseNotes "Added dark mode support"

# Hotfix: deploy without updating screenshots
.\scripts\release.ps1 -Track beta -SkipScreenshots
```

Or using Fastlane directly:

```bash
cd android
fastlane deploy track:internal
fastlane deploy track:production release_notes:"New features and bug fixes"
fastlane deploy track:beta skip_screenshots:true
```

### Check Release Readiness

Before deploying, check your configuration:

```bash
cd android
fastlane release_status
```

This will show:
- Current version
- Credential configuration status
- Screenshot status
- Manual steps checklist
- Quick deployment commands

## What Is Automated

- Flutter validation and release build through Fastlane
- Automatic version bumping
- Deterministic store screenshot processing through `marketing/tools/store_screenshots`
- Synchronization of processed screenshots and graphics into Fastlane's Play Store metadata layout
- Upload of localized metadata text, screenshots, and graphics through Fastlane
- All-in-one deployment that combines all steps into a single command

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

## Release Sequence (Legacy - Still Supported)

If you prefer to run steps manually, the original sequence is still available:

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

## What Still Requires Manual Verification

- Physical-device checks for ads, purchase flow, and upgrade to premium.
- Final Play Console forms: audience, data safety, content rating, and release notes.
- Verification that the uploaded screenshots match the intended storefront order (run `fastlane verify_screenshots` before deploying).

## Credential Requirements

- `c:\dev\flutter\unit_converter\.env` is the source of truth for release configuration on local development machines.
- `android/key.properties` for release signing.
- `android/fastlane/google-play-service-account.json` or `GOOGLE_PLAY_JSON_KEY_FILE` for Play Console upload.
- `GOOGLE_APPLICATION_CREDENTIALS` for Google Cloud services (see [Google Cloud Credentials Configuration](GOOGLE_CLOUD_CREDENTIALS.md)).
- `UNIT_CONVERTER_ADMOB_APP_ID` for production AdMob configuration (see [Release Credentials Setup Guide](RELEASE_CREDENTIALS_SETUP.md)).
- `PACKAGE_NAME` only if overriding the default application ID.

Gradle, Fastlane, and the PowerShell release scripts load values from `.env` first. If a key is not present there, Fastlane and the PowerShell scripts then fall back to process, user, and machine environment scopes on Windows.

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

## Available Commands

### All-in-One Deployment
- `fastlane deploy track:internal` - Deploy to internal testing
- `fastlane deploy track:alpha` - Deploy to alpha testing
- `fastlane deploy track:beta` - Deploy to beta testing
- `fastlane deploy track:production` - Deploy to production
- `fastlane deploy track:beta skip_screenshots:true` - Hotfix without screenshots
- `fastlane deploy track:production skip_metadata:true` - Deploy without updating metadata

### Helper Commands
- `fastlane release_status` - Check release readiness and configuration
- `fastlane verify_screenshots` - Generate and verify screenshots before upload
- `fastlane show_version` - Show current version and build number

### Individual Steps (if needed)
- `fastlane validate` - Run all validation checks
- `fastlane bump_build_number` - Increment build number
- `fastlane generate_screenshots` - Prepare store screenshots
- `fastlane upload_metadata` - Upload metadata to Play Store
- `fastlane upload_screenshots` - Upload screenshots to Play Store
- `fastlane build_release` - Build release AAB

### Legacy Deployment Commands (still supported)
- `fastlane deploy_internal` - Validate, build, and upload to internal testing
- `fastlane deploy_alpha` - Validate, build, and upload to alpha testing
- `fastlane deploy_beta` - Validate, build, and upload to beta testing
- `fastlane deploy_production` - Validate, build, and upload to production

## Troubleshooting

### Screenshot Upload Failures

If screenshot uploads fail, it's likely because the screenshot naming doesn't match Play Store's expected format. The new deployment process automatically renames screenshots to the correct format (`phoneScreenshots-01.png`, `phoneScreenshots-02.png`, etc.).

If you still encounter issues:
1. Run `fastlane verify_screenshots` to check your screenshots
2. Manually review screenshots in `../marketing/unit_converter/screenshots/store_screenshots`
3. Ensure all screenshots are under 8 MB
4. Check that you have the correct Play Console permissions

### Credential Issues

If deployment fails due to credential issues:
1. Run `fastlane release_status` to check your configuration
2. Verify your `.env` file has the correct values
3. Check that service account files exist and are valid
4. Ensure you have the correct Play Console permissions

### Build Failures

If the build fails:
1. Run `flutter clean` and `flutter pub get`
2. Check that all dependencies are up to date
3. Verify your signing configuration
4. Run `fastlane validate` to check for configuration issues

## FAQ

### Q: Can I deploy without updating screenshots?
A: Yes, use the `-SkipScreenshots` flag: `.\scripts\release.ps1 -Track beta -SkipScreenshots`

### Q: How do I skip validation for a quick test?
A: Use `skip_validation:true`: `fastlane deploy track:internal skip_validation:true` (not recommended for production)

### Q: Can I deploy to multiple tracks at once?
A: No, deploy to each track separately. Start with internal, then alpha, then beta, then production.

### Q: How do I check what version will be deployed?
A: Run `fastlane show_version` or `fastlane release_status`

### Q: What if I need to rollback a release?
A: Use the Google Play Console to halt the rollout or create a new release with a higher version number.
