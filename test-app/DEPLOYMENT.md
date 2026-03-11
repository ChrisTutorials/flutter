# Automated Deployment Guide

This guide explains how to set up automated deployments for your Flutter app to Android, iOS, and Windows app stores using GitHub Actions.

## Overview

The project includes three separate deployment workflows:
- `deploy-android.yml` - Deploys to Google Play Store
- `deploy-ios.yml` - Deploys to Apple App Store
- `deploy-windows.yml` - Creates Windows installer and MSIX package
- `deploy-all.yml` - Deploys to all platforms simultaneously

## Prerequisites

1. **GitHub Repository** with Actions enabled
2. **App Store Accounts** for each platform:
   - Google Play Console (Android)
   - App Store Connect (iOS)
   - Microsoft Partner Center (Windows)

## Setup Instructions

### 1. Android Deployment Setup

#### Step 1: Create a Keystore
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

#### Step 2: Configure GitHub Secrets
Add the following secrets to your GitHub repository (Settings → Secrets and variables → Actions):

- `ANDROID_KEYSTORE_BASE64`: Base64 encoded keystore file
  ```bash
  base64 -i upload-keystore.jks | pbcopy  # macOS
  base64 -w 0 upload-keystore.jks | clip  # Linux/Windows
  ```
- `ANDROID_KEYSTORE_PASSWORD`: Keystore password
- `ANDROID_KEY_PASSWORD`: Key password
- `ANDROID_KEY_ALIAS`: Key alias (e.g., "upload")
- `PLAY_STORE_CONFIG_JSON`: Base64 encoded Google Play service account JSON

#### Step 3: Create Google Play Service Account
1. Go to [Google Play Console](https://play.google.com/console)
2. Navigate to Setup → API Access
3. Create a new service account
4. Download the JSON key file
5. Encode it to base64 and add as `PLAY_STORE_CONFIG_JSON`

#### Step 4: Update Package Name
Update the package name in `android/app/build.gradle` and the workflow files to match your app's package name.

### 2. iOS Deployment Setup

#### Step 1: Create Certificates and Provisioning Profiles
1. Go to [Apple Developer Portal](https://developer.apple.com/account)
2. Create a Distribution Certificate
3. Create an App Store Provisioning Profile
4. Download both files

#### Step 2: Configure GitHub Secrets
Add the following secrets:

- `IOS_CERTIFICATE_BASE64`: Base64 encoded .p12 certificate
  ```bash
  base64 -i YourCertificate.p12 | pbcopy
  ```
- `IOS_CERTIFICATE_PASSWORD`: Certificate password
- `IOS_PROVISIONING_PROFILE_BASE64`: Base64 encoded provisioning profile
  ```bash
  base64 -i YourProfile.mobileprovision | pbcopy
  ```

#### Step 3: Create App Store Connect API Key
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to Users and Access → Keys
3. Create a new API key with "App Manager" role
4. Download the .p8 key file
5. Note the Key ID and Issuer ID

#### Step 4: Add API Key Secrets
Add these secrets to GitHub:

- `APP_STORE_CONNECT_API_KEY_ID`: Your API key ID
- `APP_STORE_CONNECT_API_ISSUER_ID`: Your issuer ID
- `APP_STORE_CONNECT_API_KEY_BASE64`: Base64 encoded .p8 key file

#### Step 5: Update ExportOptions.plist
Update `ios/ExportOptions.plist` with your Team ID and provisioning profile name:
```xml
<key>teamID</key>
<string>YOUR_TEAM_ID</string>
<key>provisioningProfiles</key>
<dict>
    <key>com.yourcompany.yourapp</key>
    <string>YOUR_PROVISIONING_PROFILE_NAME</string>
</dict>
```

### 3. Windows Deployment Setup

#### Step 1: Configure GitHub Secrets
Add these secrets for Microsoft Store deployment:

- `MICROSOFT_STORE_TENANT_ID`: Your Azure AD tenant ID
- `MICROSOFT_STORE_CLIENT_ID`: Your application client ID
- `MICROSOFT_STORE_CLIENT_SECRET`: Your application client secret

#### Step 2: Set Up Microsoft Store Submission API
1. Go to [Microsoft Partner Center](https://partner.microsoft.com/dashboard)
2. Navigate to Account settings → Developer settings → Management API
3. Create a new Azure AD application
4. Configure the necessary permissions
5. Note the tenant ID, client ID, and create a client secret

#### Step 3: Alternative: Use AppCenter
If you prefer not to use the Microsoft Store API, you can use AppCenter:
1. Create an AppCenter account
2. Add `APPCENTER_TOKEN` as a GitHub secret
3. Uncomment the AppCenter commands in the workflow

## Deployment Process

### Deploying to a Single Platform

To deploy to a specific platform, create and push a tag:

```bash
# Android
git tag android-v1.0.0
git push origin android-v1.0.0

# iOS
git tag ios-v1.0.0
git push origin ios-v1.0.0

# Windows
git tag windows-v1.0.0
git push origin windows-v1.0.0
```

### Deploying to All Platforms

To deploy to all platforms simultaneously:

```bash
git tag v1.0.0
git push origin v1.0.0
```

### Manual Deployment

You can also trigger deployments manually from the GitHub Actions tab:
1. Go to Actions tab in your repository
2. Select the workflow you want to run
3. Click "Run workflow"
4. Select the branch and click "Run workflow"

## Workflow Details

### Android Workflow
- Builds both APK and App Bundle (AAB)
- Signs the app with your keystore
- Uploads artifacts for 30 days
- Deploys to Google Play Store internal testing track

### iOS Workflow
- Builds and signs the iOS app
- Creates an IPA file
- Uploads to App Store Connect
- Can be configured for TestFlight or App Store

### Windows Workflow
- Builds the Windows executable
- Creates an installer using Inno Setup
- Creates MSIX package if configured
- Can deploy to Microsoft Store or AppCenter

## Version Management

The workflows automatically increment the build number based on the GitHub run number. The version is managed in `pubspec.yaml`:

```yaml
version: 1.0.0+1  # 1.0.0 is the version, +1 is the build number
```

When you create a tag like `v1.0.0`, the workflow will use that version and append the build number.

## Troubleshooting

### Android Build Fails
- Check that all keystore secrets are correctly set
- Verify the package name matches your Google Play Console app
- Ensure the service account has proper permissions

### iOS Build Fails
- Verify certificates and provisioning profiles are valid
- Check that the Team ID is correct in ExportOptions.plist
- Ensure the API key has the "App Manager" role

### Windows Build Fails
- Check that the Inno Setup installation succeeds
- Verify Microsoft Store API credentials are correct
- Ensure the app is properly configured in Partner Center

## Best Practices

1. **Test in internal tracks first**: Always deploy to internal testing tracks before production
2. **Use semantic versioning**: Follow semantic versioning (MAJOR.MINOR.PATCH)
3. **Keep secrets secure**: Never commit secrets to the repository
4. **Monitor builds**: Check GitHub Actions logs for errors
5. **Update documentation**: Keep this guide updated as you make changes

## Additional Resources

- [Flutter Build Documentation](https://docs.flutter.dev/deployment)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Microsoft Partner Center Documentation](https://learn.microsoft.com/en-us/windows/apps/publish/)