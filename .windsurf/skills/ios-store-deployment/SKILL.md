# Skill: iOS Store Deployment - Non-Interactive Mode

## 📋 Summary

Deploy Flutter iOS apps to Apple App Store using **non-interactive modes** to prevent blocking on user input. This is essential for automated workflows, CI/CD pipelines, and hands-off deployment processes.

## ⚠️ Critical Requirements

1. **macOS Required** - iOS deployment requires macOS (cannot be done on Windows)
2. **Apple Developer Program** - Enroll at https://developer.apple.com/programs/ ($99/year)
3. **Xcode 14+** - Install latest Xcode from Mac App Store
4. **Non-Interactive Flags** - Always use `-SkipConfirmation` to prevent blocking

## ⚠️ Critical: Always Use Non-Interactive Flags

When deploying to iOS, **ALWAYS** use non-interactive flags to prevent the deployment from hanging on confirmation prompts:

- `-SkipConfirmation` - Skip all confirmation prompts
- `-Track production` - Specify the deployment track explicitly

## 🚀 iOS Store Deployment Commands

### Method 1: Unified Deployment Script (Recommended)

```bash
cd unit_converter
../scripts/deploy.ps1 -Platform ios -Track beta -ReleaseNotes "TestFlight release" -SkipConfirmation
```

### Method 2: Direct Fastlane

```bash
cd unit_converter/ios
bundle exec fastlane deploy track:beta release_notes:"TestFlight release" skip_confirmation:true
```

### Method 3: Production Deployment

```bash
cd unit_converter
../scripts/deploy.ps1 -Platform ios -Track production -ReleaseNotes "App Store release" -SkipConfirmation
```

## 📋 Complete Non-Interactive Deployment Workflow

### Step 1: Update Version

```bash
cd unit_converter/ios
bundle exec fastlane bump_build_number
```

### Step 2: Generate Screenshots (if needed)

```bash
cd unit_converter/ios
bundle exec fastlane capture_screenshots
```

### Step 3: Deploy to TestFlight (Non-Interactive)

```bash
cd unit_converter
../scripts/deploy.ps1 -Platform ios -Track beta -ReleaseNotes "TestFlight release" -SkipConfirmation
```

### Step 4: Deploy to Production (Non-Interactive)

```bash
cd unit_converter
../scripts/deploy.ps1 -Platform ios -Track production -ReleaseNotes "App Store release" -SkipConfirmation
```

## 🔧 Available Non-Interactive Flags

| Flag | Description | When to Use |
|------|-------------|-------------|
| `-SkipConfirmation` | Skip all confirmation prompts | **ALWAYS use for production** |
| `-Track beta` | Deploy to TestFlight | For beta testing |
| `-Track production` | Deploy to App Store | For public release |
| `-SkipScreenshots` | Skip screenshot generation | When screenshots are already up-to-date |
| `-SkipMetadata` | Skip metadata updates | When metadata is already up-to-date |
| `-SkipValidation` | Skip validation checks | ⚠️ Only use if you've already validated |
| `-ReleaseNotes "text"` | Custom release notes | When you want specific notes |

## 📝 Example: Full Production Deployment

```bash
# Navigate to project
cd c:\dev\flutter\unit_converter

# Deploy with non-interactive flags
../scripts/deploy.ps1 -Platform ios -Track production -ReleaseNotes "New features and improvements" -SkipConfirmation
```

## 🔧 Prerequisites Setup

### 1. Apple Developer Account

1. Enroll in Apple Developer Program: https://developer.apple.com/programs/
2. Complete enrollment and payment ($99/year)
3. Access App Store Connect: https://appstoreconnect.apple.com/

### 2. App Store Connect Setup

1. Create app in App Store Connect
2. Configure app information (bundle ID, name, SKU)
3. Set up pricing and availability
4. Configure app privacy details

### 3. API Access Setup

1. Go to App Store Connect > Users and Access > Keys
2. Create a new API key
3. Select the "App Manager" role
4. Download the `.p8` key file (only available once!)
5. Note the Key ID and Issuer ID

### 4. Xcode Setup

1. Install Xcode 14 or later from Mac App Store
2. Install command line tools: `xcode-select --install`
3. Accept Xcode license: `sudo xcodebuild -license accept`

### 5. Certificates and Provisioning Profiles

1. Create iOS Distribution Certificate in Apple Developer Portal
2. Create Provisioning Profile for your app
3. Download and install in Xcode

### 6. Fastlane Setup

```bash
cd unit_converter/ios
bundle init
bundle add fastlane
bundle exec fastlane init
```

### 7. Configure Environment Variables

Create a `.env` file in your project root:

```bash
# App Store Connect API
APP_STORE_CONNECT_API_KEY_ID=your-api-key-id
APP_STORE_CONNECT_API_ISSUER_ID=your-issuer-id
APP_STORE_CONNECT_API_KEY_PATH=path/to/AuthKey.p8

# Optional: Team ID
FASTLANE_ITC_TEAM_ID=your-team-id
FASTLANE_TEAM_ID=your-team-id
```

## 🎯 Best Practices

### 1. Always Use Non-Interactive Flags

```bash
# ✅ GOOD - Non-interactive
../scripts/deploy.ps1 -Platform ios -Track production -SkipConfirmation

# ❌ BAD - Will hang on confirmation
../scripts/deploy.ps1 -Platform ios -Track production
```

### 2. Validate Before Deploying

```bash
# Run validation first (non-interactive)
cd unit_converter/ios
bundle exec fastlane validate

# Then deploy (non-interactive)
cd ..
../scripts/deploy.ps1 -Platform ios -Track production -SkipConfirmation
```

### 3. Test on TestFlight First

```bash
# Deploy to TestFlight (non-interactive)
../scripts/deploy.ps1 -Platform ios -Track beta -SkipConfirmation

# Test with TestFlight users
# Collect feedback
# Fix issues

# Then deploy to production (non-interactive)
../scripts/deploy.ps1 -Platform ios -Track production -SkipConfirmation
```

### 4. Use Meaningful Release Notes

```bash
../scripts/deploy.ps1 -Platform ios -Track production -ReleaseNotes "Added dark mode support and improved currency conversion accuracy" -SkipConfirmation
```

## 🔒 Security Considerations

### API Key Security
1. Store API key file securely (never commit to git)
2. Use environment variables for API credentials
3. Rotate API keys regularly
4. Use secret management services in CI/CD

### Certificate Security
1. Keep distribution certificates secure
2. Use keychain access for certificate storage
3. Never share private keys
4. Use separate certificates for development and production

## 🐛 Troubleshooting

### Issue: Deployment hangs on confirmation

**Solution:** Always use `-SkipConfirmation` flag

### Issue: API key not found

**Solution:**
1. Check API key file path in `.env`
2. Verify API key ID and Issuer ID are correct
3. Ensure API key has "App Manager" role
4. Check API key hasn't expired

### Issue: Certificate errors

**Solution:**
1. Verify distribution certificate is valid
2. Check provisioning profile matches bundle ID
3. Ensure certificate is installed in keychain
4. Run `security find-identity -v -p codesigning` to check certificates

### Issue: Build fails

**Solution:**
```bash
cd unit_converter
flutter clean
flutter pub get
flutter build ios --release --no-codesign
# Then use Fastlane for signing and deployment
```

### Issue: Screenshots failing

**Solution:**
1. Use `-SkipScreenshots` if screenshots are already current
2. Check screenshot dimensions meet App Store requirements
3. Verify screenshot naming convention
4. Run `bundle exec fastlane capture_screenshots` manually

### Issue: App Store review rejection

**Solution:**
1. Review App Store Review Guidelines
2. Check app privacy details are complete
3. Ensure all metadata is accurate
4. Test on real devices before submission
5. Respond to review feedback promptly

## 📊 Deployment Tracks

| Track | Command | Use Case |
|-------|---------|----------|
| TestFlight (Beta) | `-Track beta` | Beta testing with TestFlight users |
| Production | `-Track production` | Public App Store release |

## 📱 Screenshot Requirements

### iPhone Screenshots
- 6.7" display: 1290 x 2796
- 6.5" display: 1242 x 2688
- 5.5" display: 1242 x 2208

### iPad Screenshots
- 12.9" display: 2048 x 2732
- 11" display: 1668 x 2388
- 10.5" display: 1668 x 2224

### Screenshot Naming
- iPhone: `iPhone_6.7_Pro_Max-01.png`, `iPhone_6.7_Pro_Max-02.png`, etc.
- iPad: `iPad_Pro_12.9-01.png`, `iPad_Pro_12.9-02.png`, etc.

## 🔄 CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy to iOS

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'
          
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.0'
          bundler-cache: true
          
      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: 'latest-stable'
          
      - name: Deploy to App Store
        env:
          APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
          APP_STORE_CONNECT_API_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_API_ISSUER_ID }}
          APP_STORE_CONNECT_API_KEY_PATH: ${{ secrets.APP_STORE_CONNECT_API_KEY_PATH }}
        run: |
          cd unit_converter
          ../scripts/deploy.ps1 -Platform ios -Track production -SkipConfirmation -ReleaseNotes "Release ${{ github.ref_name }}"
```

### Jenkins Example

```groovy
pipeline {
    agent { label 'macos' }
    stages {
        stage('Deploy iOS') {
            steps {
                script {
                    dir('unit_converter') {
                        withCredentials([
                            string(credentialsId: 'APP_STORE_CONNECT_API_KEY_ID', variable: 'APP_STORE_CONNECT_API_KEY_ID'),
                            string(credentialsId: 'APP_STORE_CONNECT_API_ISSUER_ID', variable: 'APP_STORE_CONNECT_API_ISSUER_ID'),
                            string(credentialsId: 'APP_STORE_CONNECT_API_KEY_PATH', variable: 'APP_STORE_CONNECT_API_KEY_PATH')
                        ]) {
                            sh """
                                ../scripts/deploy.ps1 -Platform ios -Track production -SkipConfirmation -ReleaseNotes 'Release ${BUILD_NUMBER}'
                            """
                        }
                    }
                }
            }
        }
    }
}
```

## 📚 Related Skills

- **[unified-deployment/](../unified-deployment/)** - Unified multi-platform deployment
- **[production-deployment/](../production-deployment/)** - Production deployment for Android
- **[windows-store-deployment/](../windows-store-deployment/)** - Windows Store deployment
- **[fastlane-setup/](../fastlane-setup/)** - Fastlane setup and configuration
- **[take-screenshots/](../take-screenshots/)** - Screenshot generation

## 📖 Documentation

- **[UNIFIED_DEPLOYMENT.md](../../../docs/UNIFIED_DEPLOYMENT.md)** - Complete unified deployment guide
- **[App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)** - Apple's review guidelines
- **[App Store Connect Help](https://help.apple.com/app-store-connect/)** - Official documentation

## 🎉 Summary

Always use non-interactive flags when deploying to iOS:

```bash
../scripts/deploy.ps1 -Platform ios -Track production -SkipConfirmation
```

This ensures:
- ✅ No blocking on confirmation prompts
- ✅ Suitable for CI/CD pipelines
- ✅ Hands-off deployment workflow
- ✅ Consistent deployment process

---

## Quick Reference

### Deploy to TestFlight
```bash
../scripts/deploy.ps1 -Platform ios -Track beta -SkipConfirmation
```

### Deploy to Production
```bash
../scripts/deploy.ps1 -Platform ios -Track production -SkipConfirmation
```

### Deploy with Custom Release Notes
```bash
../scripts/deploy.ps1 -Platform ios -Track production -ReleaseNotes "New features" -SkipConfirmation
```

### Hotfix Deployment (Skip Screenshots)
```bash
../scripts/deploy.ps1 -Platform ios -Track beta -ReleaseNotes "Critical bug fix" -SkipScreenshots -SkipConfirmation
```

---

**Key Rule:** When user requests "deploy to iOS" or "build for iOS", **ALWAYS** use `-SkipConfirmation` flag to prevent blocking. Note that iOS deployment requires macOS.

