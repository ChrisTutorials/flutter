# Pre-Deployment Test Suites

This directory contains comprehensive test suites to verify critical Play Store compliance requirements before deployment. These tests prevent common app rejection failures.

## Overview

The test suites verify:

1. **AndroidManifest.xml** - Critical permissions and configurations
2. **Build Configuration** - Gradle settings for release builds
3. **Pubspec.yaml** - Version format and dependencies
4. **Integration Tests** - End-to-end verification

## Test Files

### 1. AndroidManifestTest.java
**Location:** `android/app/src/test/java/com/unitconverter/unitconverter/AndroidManifestTest.java`

**Tests:**
- AdMob Application ID presence (not commented out)
- Advertising ID permission (Android 13+ compliance)
- Billing permission (in-app purchases)
- Internet permission (AdMob and currency API)
- MainActivity exported
- Network security config
- Cleartext traffic disabled
- Widget provider exported
- Application label and icon

**Run:**
```bash
cd android
./gradlew test
```

### 2. BuildConfigTest.java
**Location:** `android/app/src/test/java/com/unitconverter/unitconverter/BuildConfigTest.java`

**Tests:**
- AdMob app ID configured in build.gradle.kts
- Target SDK version (Android 13+ requirement)
- Min SDK version
- Code shrinking enabled
- Resource shrinking enabled
- ProGuard configured
- Release signing config present
- Namespace set
- Application ID set
- Version code and name configured

**Run:**
```bash
cd android
./gradlew test
```

### 3. Pubspec Release Checks
**Location:** `test/release_checks/pubspec_test.dart`

**Tests:**
- Version format (x.y.z+buildNumber)
- Build number greater than 0
- Version has build number specified
- Required dependencies present (google_mobile_ads, shared_preferences, intl, in_app_purchase, http)
- App name and description present
- publish_to set to none
- SDK version constraints specified
- Flutter SDK constraint at least 3.0.0
- Version incrementability
- Dependency version constraints

**Run:**
```bash
flutter test test/release_checks/pubspec_test.dart
```

### 4. Pre-Deployment Verification Script
**Location:** `scripts/pre-deployment-check.ps1` (Windows) or `scripts/pre-deployment-check.sh` (Linux/Mac)

**Comprehensive checks:**
- Flutter and Dart installation
- Project directory verification
- All AndroidManifest tests
- All build.gradle.kts tests
- Version format validation
- Required dependencies check
- Flutter test execution
- Release build configuration validation
- Common issue detection (test IDs, signing keys)

**Run (Windows):**
```powershell
powershell -ExecutionPolicy Bypass -File scripts\pre-deployment-check.ps1
```

**Run (Linux/Mac):**
```bash
bash scripts/pre-deployment-check.sh
```

## What These Tests Prevent

### 1. AdMob Application ID Missing
**Error:** "Missing application ID. AdMob publishers should follow the instructions here: https://goo.gl/admub-android-update-manifest to add a valid App ID inside the AndroidManifest."

**Cause:** AdMob Application ID meta-data is commented out in AndroidManifest.xml

**Test:** `AndroidManifestTest.testAdMobApplicationIdPresent()`

### 2. Advertising ID Declaration Missing
**Error:** "Incomplete advertising ID declaration - All developers targeting Android 13 or later are required to let us know if their app uses advertising ID"

**Cause:** Missing `com.google.android.gms.permission.AD_ID` permission

**Test:** `AndroidManifestTest.testAdvertisingIdPermissionPresent()`

### 3. Version Code Conflict
**Error:** "Version code X has already been used. Try another version code."

**Cause:** Trying to upload an app with a version code that's already been used

**Test:** `PubspecTest.testVersionMustBeIncrementable()` and pre-deployment script

### 4. App Size Too Large
**Error:** Google Play rejects apps over 150MB (or warns about size)

**Cause:** Code and resource shrinking not enabled

**Test:** `BuildConfigTest.testCodeShrinkingEnabled()` and `BuildConfigTest.testResourceShrinkingEnabled()`

### 5. Broken Functionality
**Error:** "App installs, but doesn't load"

**Cause:** Missing critical permissions or configurations

**Test:** All AndroidManifest and BuildConfig tests

## Integration with Deployment Workflow

### Before Every Release:

1. **Run pre-deployment verification:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts\pre-deployment-check.ps1
   ```

2. **Fix any failing tests**

3. **Build release AAB:**
   ```bash
   flutter build appbundle --release
   ```

4. **Upload to Google Play Console**

### Automated CI/CD Integration

You can integrate these tests into your CI/CD pipeline:

```yaml
# Example GitHub Actions workflow
- name: Run pre-deployment checks
  run: |
    flutter test test/release_checks/pubspec_test.dart
    cd android
    ./gradlew test
    cd ..
    powershell -ExecutionPolicy Bypass -File scripts\pre-deployment-check.ps1
```

## Adding New Tests

To add a new test for a Play Store requirement:

1. Identify the requirement (e.g., new permission, configuration)
2. Add a test method to the appropriate test file
3. Update the pre-deployment script if needed
4. Document the test in this README

## Troubleshooting

### Tests Fail But App Works

Some tests are more strict than Play Store requirements. If a test fails but you're confident the app is ready:

1. Review the test failure message
2. Check if the requirement is actually enforced by Play Store
3. If not, you can skip that specific test (but document why)
4. Consider updating the test to match actual Play Store requirements

### Pre-Deployment Script Fails

If the pre-deployment script fails:

1. Check which specific test failed
2. Review the error message
3. Fix the issue in the source code
4. Run the script again

### Version Code Conflicts

If you get version code conflicts:

1. Check your current version in pubspec.yaml
2. Increment the build number (the number after the +)
3. Run the tests again
4. Build a new release

## Best Practices

1. **Run tests before every release** - This catches issues early
2. **Keep tests updated** - Add new tests as Play Store requirements change
3. **Document test failures** - If you skip a test, document why
4. **Use version control** - Track test changes alongside code changes
5. **Automate in CI/CD** - Run tests automatically on every build

## Resources

- [Google Play Console](https://play.google.com/console)
- [Android App Bundle Requirements](https://developer.android.com/guide/app-bundle)
- [AdMob Integration Guide](https://developers.google.com/admob/android/quick-start)
- [Play Console Policy Center](https://play.google.com/about/developer-content-policy/)

## Support

If you encounter issues with these tests:

1. Check the error message carefully
2. Review the Play Store documentation
3. Check if the requirement is still current
4. Update the test if Play Store requirements have changed

---

**Last Updated:** March 11, 2026  
**Version:** 1.0.0

