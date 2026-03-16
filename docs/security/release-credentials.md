# Release Credentials Setup Guide

This guide walks you through setting up the two required credentials for Play Store releases: AdMob App ID and Play Console service account access.

## Blocker 1: AdMob App ID

### What You Need
- **Publisher ID**: `pub-5684393858412931` (you already have this)
- **App ID**: Format `ca-app-pub-5684393858412931~XXXXXXXXXX` (you need to get this from AdMob console)

### Step-by-Step Instructions

1. **Go to AdMob Console**
   - Navigate to [apps.admob.com](https://apps.admob.com)
   - Sign in with your Google account

2. **Find or Create Your App**
   - Click on "Apps" in the left sidebar
   - If your app already exists, click on it
   - If not, click "Add app" → "Android" → Enter your app name (can use placeholder like "Unit Converter") → Click "Add"

3. **Get the App ID**
   - On the app's overview page, look at the top right or under the app name
   - You'll see an App ID in the format: `ca-app-pub-5684393858412931~XXXXXXXXXX`
   - Copy this entire App ID

4. **Populate the Project `.env` File**

   Copy [unit_converter/.env.example](unit_converter/.env.example) to `c:\dev\flutter\unit_converter\.env` and set the values there.

   Recommended contents:
   ```powershell
   GOOGLE_APPLICATION_CREDENTIALS=C:/Users/chris/.keys/your-google-cloud-key.json
   GOOGLE_PLAY_JSON_KEY_FILE=C:/dev/flutter/unit_converter/android/fastlane/google-play-service-account.json
   UNIT_CONVERTER_ADMOB_APP_ID=ca-app-pub-5684393858412931~XXXXXXXXXX
   ```

5. **Optional Environment Variable Setup**

   **Windows PowerShell (User Level - Persistent):**
   ```powershell
   [Environment]::SetEnvironmentVariable('UNIT_CONVERTER_ADMOB_APP_ID', 'ca-app-pub-5684393858412931~XXXXXXXXXX', 'User')
   ```

   **Windows PowerShell (Current Session):**
   ```powershell
   $env:UNIT_CONVERTER_ADMOB_APP_ID = "ca-app-pub-5684393858412931~XXXXXXXXXX"
   ```

   **WSL Ubuntu (Add to ~/.bashrc):**
   ```bash
   echo 'export UNIT_CONVERTER_ADMOB_APP_ID=ca-app-pub-5684393858412931~XXXXXXXXXX' >> ~/.bashrc
   ```

6. **Verify the Configuration**
   ```powershell
   echo $env:UNIT_CONVERTER_ADMOB_APP_ID
   ```

   Should output: `ca-app-pub-5684393858412931~XXXXXXXXXX`

7. **How the Release Workflow Resolves It**
   - The project `.env` file is now the source of truth for release credentials.
   - Gradle, Fastlane, and the PowerShell deployment scripts load values from `c:\dev\flutter\unit_converter\.env` first.
   - If a value is missing from `.env`, Fastlane and the PowerShell scripts fall back to process, Windows user, then Windows machine environment scopes.
   - Direct manual commands like `flutter build appbundle --release` now also pick up `UNIT_CONVERTER_ADMOB_APP_ID` from `.env` through Gradle.

## Blocker 2: Play Console Service Account

### What You Need
- A service account with Release Manager or Publisher role in Google Play Console
- The service account JSON key file

### Step-by-Step Instructions

1. **Go to Google Play Console**
   - Navigate to [play.google.com/console](https://play.google.com/console)
   - Select your app

2. **Configure API Access**
   - Click "Settings" (gear icon) in the left sidebar
   - Click "Developer account" → "API access"
   - Under "Service accounts", click "Link service account"

3. **Create or Link Service Account**
   - Choose your Google Cloud project: `poetic-axle-490013-m9`
   - Click "Link service account"
   - If prompted, create a new service account or select an existing one

4. **Grant Access**
   - After linking, click "Grant access"
   - Select the role: **Release Manager** (recommended) or **Publisher** (full access)
   - Click "Invite user"

5. **Create Service Account Key**
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - Select project: `poetic-axle-490013-m9`
   - Navigate to "IAM & Admin" → "Service accounts"
   - Find the service account you just linked
   - Click on it → Click "Keys" tab → "Add key" → "Create new key"
   - Select "JSON" → Click "Create"
   - Download the JSON key file

6. **Store the Key Securely**
   - Move the downloaded JSON key to your `.keys` folder
   - Recommended path: `C:\Users\chris\.keys\google-play-service-account.json`
   - **Never commit this file to version control**

7. **Configure Fastlane to Use the Key**

   **Option A: Place key in Fastlane directory (Recommended for local development)**
   ```powershell
   Copy-Item "C:\Users\chris\.keys\google-play-service-account.json" "c:\dev\flutter\unit_converter\android\fastlane\google-play-service-account.json"
   ```

   **Option B: Use environment variable (Recommended for CI/CD)**
   ```powershell
   [Environment]::SetEnvironmentVariable('GOOGLE_PLAY_JSON_KEY_FILE', 'C:\Users\chris\.keys\google-play-service-account.json', 'User')
   ```

8. **Verify Fastlane Configuration**
   ```powershell
   cd c:\dev\flutter\unit_converter\android
   fastlane validate
   ```

## Testing Your Configuration

### Test AdMob Configuration
```powershell
cd c:\dev\flutter\unit_converter
flutter build appbundle --release
```

Check the build output to ensure the release AdMob App ID is used (not the test ID).

### Test Play Console Access
```powershell
cd c:\dev\flutter\unit_converter\android
fastlane validate
```

This should successfully validate your Play Console access.

## Release Pipeline Integration

Once both credentials are configured, the release pipeline will automatically:

1. Use the production AdMob App ID for release builds
2. Upload metadata and screenshots via Fastlane
3. Deploy to the internal, alpha, beta, or production track

### Run a Full Release
```powershell
cd c:\dev\flutter\unit_converter
powershell -ExecutionPolicy Bypass -File scripts\deploy-to-play-store.ps1 -Track internal -PrepareStoreAssets
```

## Security Best Practices

1. **Never commit service account keys to version control**
2. **Add `.keys` and `*.json` key files to `.gitignore`**
3. **Use minimal permissions** - Release Manager role is sufficient for deployments
4. **Rotate keys regularly** - Delete old keys and create new ones periodically
5. **Monitor usage** - Check Google Cloud Console for service account activity
6. **Restrict key usage** - Set IP restrictions on service account keys if possible

## Troubleshooting

### AdMob App ID Issues

**Symptom**: Build uses test AdMob ID (`ca-app-pub-3940256099942544`)

**Solution**:
- Verify `UNIT_CONVERTER_ADMOB_APP_ID` environment variable is set
- Check the value format: `ca-app-pub-5684393858412931~XXXXXXXXXX`
- Fastlane and the PowerShell deployment scripts now also check Windows user and machine environment scopes automatically
- Restart your terminal or export `$env:UNIT_CONVERTER_ADMOB_APP_ID` only if you are running `flutter build` directly in the current shell

### Play Console Access Issues

**Symptom**: Fastlane fails with authentication error

**Solution**:
- Verify the service account is linked in Play Console
- Check the service account has Release Manager or Publisher role
- Ensure the JSON key file exists at the expected path
- Verify `GOOGLE_PLAY_JSON_KEY_FILE` environment variable if using that method

**Symptom**: Service account linked but no permissions

**Solution**:
- Go to Play Console → Settings → API access
- Click "Grant access" next to the service account
- Select the appropriate role
- Click "Invite user"

## Related Documentation

- [Google Cloud Credentials Configuration](GOOGLE_CLOUD_CREDENTIALS.md) - Google Cloud service account setup
- [Play Store Release Runbook](play-store-release-runbook.md) - Complete release process
- [AdMob Production Setup](ADMOB_PRODUCTION_SETUP.md) - AdMob configuration details

## Support

For issues with:
- **AdMob**: Check [AdMob Help Center](https://support.google.com/admob)
- **Play Console**: Check [Play Console Help](https://support.google.com/googleplay/android-developer)
- **Fastlane**: Check [Fastlane Documentation](https://docs.fastlane.tools/)

