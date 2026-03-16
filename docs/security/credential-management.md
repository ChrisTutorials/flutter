# Security Configuration Guide

## Documentation Navigation
- [Project Overview](readme.md)
- [Quick Start Guide](quickstart.md)
- [Architecture Documentation](ARCHITECTURE.md)
- [API Documentation](API.md)

This guide explains how to configure security settings for production deployment of the Unit Converter app.

## 1. App Signing Configuration

### Generate a Production Keystore

Generate a keystore for signing your release builds:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Important:
- Keep the keystore file secure and never commit it to version control
- Use a strong password for the keystore
- Remember the keystore password and key password - you'll need them for future updates

### Create key.properties File

Create a `key.properties` file in the `android/` directory with the following content:

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=<path-to-keystore-file>
```

Example:
```properties
storePassword=MyStrongPassword123!
keyPassword=MyStrongPassword123!
keyAlias=upload
storeFile=/Users/yourname/upload-keystore.jks
```

### Update build.gradle.kts

Update the `android/app/build.gradle.kts` file to read the signing configuration from `key.properties`:

1. Add this before the `android` block:

```kotlin
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

2. Update the signing configuration in the release build type:

```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug") // Remove this line
        
        // Add this block:
        signingConfig = signingConfigs.create("release") {
            storeFile = keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword = keystoreProperties['storePassword']
            keyAlias = keystoreProperties['keyAlias']
            keyPassword = keystoreProperties['keyPassword']
        }
        
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

## 2. AdMob Configuration

For comprehensive ad strategy details, including frequency capping, user experience considerations, and revenue optimization, see [ad-strategy.md](ad-strategy.md).

### Production App ID

The app is configured with the production AdMob App ID:
- **App ID**: `ca-app-pub-384330333412031~5666527399`
- **App Name**: unit-converter (Android)
- **Status**: Configured in `android/app/build.gradle.kts`

### Create Ad Units

Before configuring ad unit IDs, you need to create ad units in the AdMob Console:

1. Go to [AdMob Console](https://apps.admob.com)
2. Select your app: "unit-converter"
3. Navigate to the "Ad units" section
4. Create the following ad units:
   - **Banner Ad**: For displaying banner ads at the bottom of screens
   - **Interstitial Ad**: For full-screen ads between conversions

### Configure Ad Unit IDs

#### Option 1: Using Environment Variables (Recommended for Production)

When building for production, pass the AdMob ad unit IDs as environment variables:

```bash
flutter build apk --release \
  --dart-define=BANNER_AD_UNIT_ID=ca-app-pub-your-banner-ad-unit-id-here \
  --dart-define=INTERSTITIAL_AD_UNIT_ID=ca-app-pub-your-interstitial-ad-unit-id-here
```

IMPORTANT: Replace the above placeholder IDs with your actual ad unit IDs from the AdMob Console.

#### Option 2: Update in Code (For Development)

Update the default values in `lib/services/admob_service.dart`:

```dart
static String get _bannerAdUnitId => const String.fromEnvironment(
  'BANNER_AD_UNIT_ID',
  defaultValue: 'ca-app-pub-384330333412031/YYYYYYYYYY', // Your banner ad unit ID
);

static String get _interstitialAdUnitId => const String.fromEnvironment(
  'INTERSTITIAL_AD_UNIT_ID',
  defaultValue: 'ca-app-pub-384330333412031/ZZZZZZZZZZ', // Your interstitial ad unit ID
);
```

## 3. Network Security Configuration

The app now enforces HTTPS for all network traffic by default. This is configured in:

- `android/app/src/main/AndroidManifest.xml` - Sets `usesCleartextTraffic="false"`
- `android/app/src/main/res/xml/network_security_config.xml` - Defines security policy

### Allow Specific Domains (if needed)

If you need to allow cleartext traffic for specific domains (not recommended), add them to `network_security_config.xml`:

```xml
<domain-config cleartextTrafficPermitted="true">
    <domain includeSubdomains="true">your-domain.com</domain>
</domain-config>
```

## 4. Code Obfuscation and Shrinking

The app is configured to use ProGuard/R8 for code shrinking and obfuscation in release builds:

- `isMinifyEnabled = true` - Shrinks and obfuscates code
- `isShrinkResources = true` - Removes unused resources
- `proguard-rules.pro` - Contains ProGuard rules to keep necessary classes

### Test Your Release Build

Always test your release build before publishing:

```bash
flutter build apk --release
```

Install and test the APK on a physical device to ensure all functionality works correctly.

## 5. Security Best Practices

### Never Commit Sensitive Data

The following files are already in `.gitignore`:
- `*.jks` - Keystore files
- `*.keystore` - Keystore files
- `key.properties` - Signing configuration
- `android/key.properties` - Signing configuration

### Use Environment Variables for Secrets

Never hardcode API keys, secrets, or sensitive configuration in your code. Use:
- Environment variables (via `--dart-define`)
- Build configuration (via `build.gradle.kts`)
- Secure storage services (e.g., Firebase Remote Config)

### Regular Security Audits

- Keep dependencies updated: `flutter pub upgrade`
- Run security analysis: `flutter analyze`
- Review third-party libraries for vulnerabilities
- Monitor security advisories for Flutter and Android

### Enable Google Play App Signing

When publishing to Google Play Store:
1. Use Google Play App Signing (recommended)
2. Upload your keystore to Google Play Console
3. Google Play will manage the signing key for you
4. This provides better security and key recovery options

## 6. Additional Security Measures

### Add Crash Reporting

Implement crash reporting to monitor app stability:
- Firebase Crashlytics
- Sentry
- Bugsnag

### Add Analytics

Add analytics to understand user behavior (respect privacy):
- Firebase Analytics
- Google Analytics for Firebase

### Implement Certificate Pinning (Advanced)

For enhanced security, implement certificate pinning for API calls:
- Use the `certificate_pinning` package
- Pin certificates for trusted domains
- Prevent man-in-the-middle attacks

## 7. Pre-Launch Security Checklist

- [ ] Production keystore generated and secured
- [ ] key.properties file created (not committed to git)
- [ ] AdMob App ID configured (ca-app-pub-384330333412031~5666527399)
- [ ] AdMob ad units created in AdMob Console (Banner and Interstitial)
- [ ] AdMob ad unit IDs configured (via environment variables or code)
- [ ] Network security configured (HTTPS enforced)
- [ ] Code shrinking and obfuscation enabled
- [ ] Release build tested on physical device
- [ ] Crash reporting implemented
- [ ] Analytics implemented
- [ ] Privacy policy created and published
- [ ] App store listing prepared
- [ ] Security audit completed

## 8. Troubleshooting

### Build Fails with Signing Error

Ensure:
- `key.properties` file exists in `android/` directory
- Keystore file path is correct in `key.properties`
- Passwords are correct in `key.properties`
- Keystore file exists at the specified path

### AdMob Ads Not Showing

Ensure:
- AdMob app ID is correct in `build.gradle.kts` (ca-app-pub-384330333412031~5666527399)
- Ad units are created in AdMob Console (Banner and Interstitial)
- Ad unit IDs are configured correctly (via environment variables or in code)
- Test ads are working before switching to production IDs
- AdMob account is properly set up and app is verified
- App has been submitted for review in AdMob Console (required for production ads)
- AdMob approval status is "Approved" (not "Requires review")

### Network Requests Failing

Ensure:
- Network security configuration is correct
- HTTPS is enforced (no cleartext traffic)
- Domain is accessible and has valid SSL certificate
- Internet permission is granted in AndroidManifest.xml

## Resources

- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [Google Play App Signing](https://support.google.com/googleplay/android-developer/answer/7384423)
- [AdMob Getting Started](https://developers.google.com/admob/android/quick-start)
- [Network Security Configuration](https://developer.android.com/training/articles/security-config)
- [ProGuard/R8](https://developer.android.com/studio/build/shrink-code)

