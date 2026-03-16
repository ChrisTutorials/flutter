# Deployment Guide - Unit Converter App

## ?? Quick Start

### Unified Multi-Platform Deployment

The recommended way to deploy is to use the **unified deployment script** that supports Android, Windows, and iOS:

```powershell
# Deploy to Android
cd unit_converter
..\scripts\deploy.ps1 -Platform android -Track internal -ReleaseNotes "Initial release"

# Deploy to Windows (Manual upload required)
# Build MSIX package: flutter pub run msix:create
# Then manually upload to Microsoft Partner Center
# ..\scripts\deploy.ps1 -Platform windows -Track retail -ReleaseNotes "Windows release"

# Deploy to iOS (macOS only)
../scripts/deploy.ps1 -Platform ios -Track beta -ReleaseNotes "TestFlight release"
```

For complete multi-platform deployment documentation, see [UNIFIED_DEPLOYMENT.md](UNIFIED_DEPLOYMENT.md).

### Android-Only Deployment (Legacy)

If you only need to deploy to Android, you can use the Android-specific script:

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

### Check Deployment Readiness

Before deploying, check your configuration:

`powershell
cd android
fastlane release_status
`

This will show:
- Current version
- Credential configuration status
- Screenshot status
- Manual steps checklist
- Quick deployment commands

## ?? Deployment Tracks

The app supports four deployment tracks in Google Play Store:

1. **Internal Testing** - For your own testing (up to 100 testers)
2. **Alpha Testing** - For a small group of trusted testers
3. **Beta Testing** - For wider testing before production
4. **Production** - For all users

### Recommended Deployment Flow

`
Internal ? Alpha ? Beta ? Production
`

Start with internal testing, then move to alpha, then beta, and finally production.

## ?? First-Time Setup

Before your first deployment, complete these setup steps:

### 1. AdMob Configuration

See [RELEASE_CREDENTIALS_SETUP.md](RELEASE_CREDENTIALS_SETUP.md#blocker-1-admob-app-id) for detailed instructions.

Quick steps:
1. Go to https://admob.google.com
2. Create an app and get your AdMob App ID
3. Set the UNIT_CONVERTER_ADMOB_APP_ID environment variable
4. Update ndroid/app/src/main/AndroidManifest.xml with your App ID

### 2. Play Console Service Account

See [RELEASE_CREDENTIALS_SETUP.md](RELEASE_CREDENTIALS_SETUP.md#blocker-2-play-console-service-account) for detailed instructions.

Quick steps:
1. Go to Google Play Console
2. Create a service account with API access
3. Download the JSON key file
4. Place it at ndroid/fastlane/google-play-service-account.json or set GOOGLE_PLAY_JSON_KEY_FILE

### 3. App Signing

See [SECURITY_CONFIG.md](SECURITY_CONFIG.md#1-app-signing-configuration) for detailed instructions.

Quick steps:
1. Generate a production keystore
2. Create a key.properties file (not committed to git)
3. Configure signing in ndroid/app/build.gradle.kts

### 4. Install Fastlane

`ash
gem install fastlane
`

### 5. Verify Configuration

`powershell
cd android
fastlane release_status
`

Ensure all checks pass before deploying.

## ?? Screenshot Management

### Automated Screenshot Handling

The deployment process automatically handles screenshots:

1. Screenshots are generated from raw captures
2. Screenshots are renamed to Play Store format
3. Screenshots are uploaded to Play Store

### Screenshot Naming Convention

Play Store expects screenshots to be named as:
- phoneScreenshots-01.png, phoneScreenshots-02.png, etc.
- sevenInchScreenshots-01.png, sevenInchScreenshots-02.png, etc.
- 	enInchScreenshots-01.png, 	enInchScreenshots-02.png, etc.

The deployment process automatically renames screenshots to this format.

### Verify Screenshots Before Deployment

`powershell
cd android
fastlane verify_screenshots
`

This will:
1. Generate screenshots
2. Display all screenshots with counts
3. Show screenshot location
4. Provide verification checklist
5. Ask you to confirm

### Screenshot Requirements

- **Phone**: 1080 x 1920 recommended, each side between 320 px and 3840 px
- **7-inch tablet**: 1200 x 1920 recommended, each side between 320 px and 3840 px
- **10-inch tablet**: 1600 x 2560 recommended, each side between 1080 px and 7680 px
- **File size**: Under 8 MB total
- **Format**: PNG

## ?? Deployment Commands

### All-in-One Deployment

`powershell
# Basic usage
.\scripts\release.ps1

# With parameters
.\scripts\release.ps1 -Track production -ReleaseNotes "New features"

# Skip screenshots (hotfix)
.\scripts\release.ps1 -Track beta -SkipScreenshots

# Skip metadata
.\scripts\release.ps1 -Track production -SkipMetadata

# Skip validation (not recommended for production)
.\scripts\release.ps1 -Track internal -SkipValidation
`

### Using Fastlane Directly

`ash
cd android

# Deploy to internal testing
fastlane deploy track:internal

# Deploy to production with release notes
fastlane deploy track:production release_notes:"New features and bug fixes"

# Hotfix without screenshots
fastlane deploy track:beta skip_screenshots:true

# Deploy without metadata
fastlane deploy track:production skip_metadata:true
`

### Helper Commands

`ash
cd android

# Check release readiness
fastlane release_status

# Verify screenshots
fastlane verify_screenshots

# Show current version
fastlane show_version

# Run validation checks
fastlane validate

# Bump build number
fastlane bump_build_number

# Prepare screenshots
fastlane generate_screenshots

# Upload metadata
fastlane upload_metadata

# Upload screenshots
fastlane upload_screenshots

# Build release AAB
fastlane build_release
`

## ?? Release Notes

Release notes describe what's new in your release. Good release notes:

1. **Be specific**: Describe actual changes, not generic statements
2. **Be concise**: Keep it brief and to the point
3. **Highlight improvements**: Focus on user-facing changes
4. **List bug fixes**: Mention important bug fixes

Examples:
- ? "Added dark mode support and improved currency conversion accuracy"
- ? "Fixed crash when searching for units and added 5 new conversion categories"
- ? "Bug fixes and improvements" (too generic)

## ?? Validation Checks

The deployment process automatically runs these validation checks:

1. ? AndroidManifest.xml validation
2. ? Build configuration validation
3. ? Version format validation
4. ? Required permissions validation
5. ? AdMob configuration validation
6. ? Purchase release configuration validation
7. ? Test ID check
8. ? Signing configuration validation

You can run these checks manually:

`ash
cd android
fastlane validate
`

## ?? Version Management

### Version Format

The version in pubspec.yaml follows the format: ersion: x.y.z+buildNumber

- x.y.z - Semantic version (what users see)
- uildNumber - Internal build number (must increase with each release)

Example: ersion: 1.0.4+10

### Automatic Version Bumping

The deployment process automatically bumps the build number by 1.

### Manual Version Bumping

`ash
cd android
fastlane bump_build_number
`

### Check Current Version

`ash
cd android
fastlane show_version
`

## ?? Common Issues

### Screenshot Upload Failures

**Problem**: Screenshots fail to upload to Play Store

**Solution**: The deployment process now automatically renames screenshots to the correct format. If you still encounter issues:

1. Run astlane verify_screenshots to check your screenshots
2. Ensure all screenshots are under 8 MB
3. Check that you have the correct Play Console permissions
4. Verify screenshot naming convention

### Credential Issues

**Problem**: Deployment fails due to credential issues

**Solution**:

1. Run astlane release_status to check your configuration
2. Verify your .env file has the correct values
3. Check that service account files exist and are valid
4. Ensure you have the correct Play Console permissions

### Build Failures

**Problem**: Build fails during deployment

**Solution**:

1. Run lutter clean and lutter pub get
2. Check that all dependencies are up to date
3. Verify your signing configuration
4. Run astlane validate to check for configuration issues

### Version Conflicts

**Problem**: Play Store rejects the build due to version conflict

**Solution**:

1. Check the current version: astlane show_version
2. Ensure the build number is higher than the previous release
3. The deployment process automatically bumps the build number
4. If you need to manually bump it: astlane bump_build_number

## ?? Additional Resources

- [play-store-release-runbook.md](play-store-release-runbook.md) - Complete production release workflow
- [RELEASE_CREDENTIALS_SETUP.md](RELEASE_CREDENTIALS_SETUP.md) - Credential setup instructions
- [SECURITY_CONFIG.md](SECURITY_CONFIG.md) - Security and signing configuration
- [quickstart.md](quickstart.md) - Quick start guide for testing and deployment

## ?? Best Practices

1. **Always test on internal track first** - Deploy to internal testing before alpha/beta/production
2. **Verify screenshots** - Run astlane verify_screenshots before production deployment
3. **Check release status** - Run astlane release_status before deploying
4. **Write good release notes** - Be specific about what changed
5. **Monitor after deployment** - Check Play Console for crashes and issues
6. **Keep credentials secure** - Never commit .env or key.properties to git
7. **Use semantic versioning** - Follow semantic versioning (MAJOR.MINOR.PATCH)
8. **Test on real devices** - Always test ads and purchases on a real device before production

## ?? Deployment Workflow Summary

### Typical Release Workflow

1. **Prepare release**
   `powershell
   cd android
   fastlane release_status
   `

2. **Verify screenshots**
   `powershell
   fastlane verify_screenshots
   `

3. **Deploy to internal testing**
   `powershell
   cd ..
   .\scripts\release.ps1 -Track internal
   `

4. **Test on internal track**
   - Install from Play Store internal testing link
   - Test all features
   - Verify ads work
   - Test purchase flow

5. **Deploy to alpha/beta**
   `powershell
   .\scripts\release.ps1 -Track alpha
   .\scripts\release.ps1 -Track beta
   `

6. **Deploy to production**
   `powershell
   .\scripts\release.ps1 -Track production -ReleaseNotes "Your release notes"
   `

7. **Monitor**
   - Check Play Console for crashes
   - Monitor user feedback
   - Track downloads and revenue

### Hotfix Workflow

For urgent bug fixes:

`powershell
# Deploy to beta without updating screenshots
.\scripts\release.ps1 -Track beta -SkipScreenshots -ReleaseNotes "Critical bug fix"
`

Then follow the normal deployment flow for production.

