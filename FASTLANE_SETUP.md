# Fastlane Setup for Flutter Workspace

## 📋 Summary

Fastlane has been successfully installed and configured for automated Play Store deployment across your Flutter workspace. This is the **industry standard** for mobile app deployment automation.

## ✅ What Was Done

### 1. Installation
- ✅ Installed Ruby 3.4 with MSYS2 (includes development tools)
- ✅ Installed Fastlane gem (version 2.232.2)
- ✅ Configured Fastlane for unit_converter app

### 2. Configuration Files Created
- ✅ `android/fastlane/Fastfile` - Comprehensive automation lanes
- ✅ `android/fastlane/Appfile` - Play Store service account configuration
- ✅ `android/fastlane/README.md` - Complete usage guide

### 3. Validation Lanes (7 checks)
- ✅ AndroidManifest.xml validation
- ✅ Build configuration validation
- ✅ Version format validation
- ✅ Required permissions validation
- ✅ AdMob configuration validation
- ✅ Test ID detection
- ✅ Signing configuration validation

### 4. Build Lanes
- ✅ Build release AAB
- ✅ Build release APK

### 5. Deployment Lanes
- ✅ Deploy to internal testing
- ✅ Deploy to alpha testing
- ✅ Deploy to beta testing
- ✅ Deploy to production
- ✅ Upload screenshots
- ✅ Upload metadata

### 6. Utility Lanes
- ✅ Run Flutter tests
- ✅ Complete CI pipeline
- ✅ Bump build number
- ✅ Show current version

## 🚀 How to Use Fastlane

### Quick Start

```bash
# Navigate to android directory
cd android

# Run validation checks
fastlane validate

# Deploy to internal testing
fastlane deploy_internal

# Deploy to production
fastlane deploy_production
```

### Common Workflows

#### 1. Development Workflow
```bash
cd android
fastlane validate          # Check configuration
fastlane test              # Run tests
fastlane build_release     # Build AAB
```

#### 2. Internal Testing Workflow
```bash
cd android
fastlane deploy_internal   # Validates, builds, and uploads
```

#### 3. Production Deployment Workflow
```bash
cd android
fastlane bump_build_number  # Increment version
fastlane deploy_production   # Validates, builds, and uploads
```

#### 4. Complete CI/CD Pipeline
```bash
cd android
fastlane ci                 # Test + validate + build
```

## 📦 Available Lanes

### Validation
| Lane | Description |
|------|-------------|
| `validate` | Run all validation checks |
| `validate_android_manifest` | Check AndroidManifest.xml |
| `validate_build_config` | Check build.gradle.kts |
| `validate_version_format` | Check version format |
| `validate_permissions` | Check required permissions |
| `validate_admob_config` | Check AdMob configuration |
| `check_for_test_ids` | Check for test IDs |
| `validate_signing_config` | Check signing configuration |

### Build
| Lane | Description |
|------|-------------|
| `build_release` | Build release AAB |
| `build_apk` | Build release APK |

### Deployment
| Lane | Description |
|------|-------------|
| `deploy_internal` | Deploy to internal testing |
| `deploy_alpha` | Deploy to alpha testing |
| `deploy_beta` | Deploy to beta testing |
| `deploy_production` | Deploy to production |
| `upload_screenshots` | Upload screenshots |
| `upload_metadata` | Upload metadata |

### Utility
| Lane | Description |
|------|-------------|
| `test` | Run Flutter tests |
| `ci` | Complete CI pipeline |
| `bump_build_number` | Increment build number |
| `show_version` | Show current version |

## 🔧 Play Store Service Account Setup

To enable Play Store deployment, you need to set up a service account:

### Step-by-Step Guide

1. **Create Service Account**
   - Go to [Google Play Console](https://play.google.com/console)
   - Navigate to **Settings** > **API access**
   - Click **Create Service Account**
   - Follow the prompts to create in Google Cloud Console

2. **Grant Permissions**
   - In Google Play Console, find your new service account
   - Click **Grant Access**
   - Select appropriate permissions (Admin recommended)

3. **Download JSON Key**
   - In Google Cloud Console, click on your service account
   - Go to **Keys** tab
   - Click **Add Key** > **Create New Key**
   - Select **JSON** format
   - Download the file

4. **Configure Fastlane**
   - Copy the JSON key to `android/fastlane/google-play-service-account.json`
   - Add to `.gitignore`: `android/fastlane/google-play-service-account.json`
   - Uncomment the `json_key_file` line in `android/fastlane/Appfile`

### Alternative: Use Environment Variable

```bash
# Set environment variable
export GOOGLE_PLAY_SERVICE_ACCOUNT_JSON='{"type": "service_account", ...}'

# Or in PowerShell:
$env:GOOGLE_PLAY_SERVICE_ACCOUNT_JSON = Get-Content -Raw path/to/your-key.json
```

## 🔄 Applying Fastlane to Other Projects

To use Fastlane in other Flutter projects in your workspace:

### Method 1: Copy Configuration
```bash
# Copy fastlane directory
cp -r unit_converter/android/fastlane other_project/android/fastlane

# Update package name in Appfile
# Edit other_project/android/fastlane/Appfile
# Change: package_name("com.ChrisTutorials.unit-converter")
# To: package_name("com.yourpackage.name")
```

### Method 2: Initialize New Fastlane
```bash
cd other_project/android
fastlane init
# Follow the prompts
```

### Method 3: Shared Fastlane Configuration
Create a shared Fastlane configuration in a common location and symlink to it:

```bash
# Create shared fastlane directory
mkdir -p common/fastlane

# Copy your Fastfile there
cp unit_converter/android/fastlane/Fastfile common/fastlane/

# Create symlinks in each project
cd other_project/android
ln -s ../../../common/fastlane fastlane
```

## 🎯 Best Practices

### Before Every Release
1. ✅ Run `fastlane validate` to check configuration
2. ✅ Run `fastlane test` to run tests
3. ✅ Run `fastlane ci` for complete validation
4. ✅ Fix any issues found
5. ✅ Run deployment lane

### Version Management
1. ✅ Always bump version before production deployment
2. ✅ Use `fastlane bump_build_number` to increment
3. ✅ Use `fastlane show_version` to check current version
4. ✅ Never reuse version codes

### Security
1. ✅ Never commit service account JSON keys
2. ✅ Use environment variables for CI/CD
3. ✅ Limit service account permissions
4. ✅ Rotate keys regularly

## 🔒 Security Notes

- Service account JSON keys are sensitive credentials
- Never commit them to version control
- Use `.gitignore` to exclude them
- Use environment variables in CI/CD pipelines
- Rotate keys periodically
- Use separate service accounts for different environments

## 📚 Documentation

- **Fastlane Documentation**: https://docs.fastlane.tools
- **Fastlane Android Actions**: https://docs.fastlane.tools/actions/
- **Google Play Console API**: https://developers.google.com/android-publisher
- **Project README**: `android/fastlane/README.md`

## 🐛 Troubleshooting

### Issue: "fastlane: command not found"
```bash
# Refresh PATH on Windows
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

### Issue: "Google Play Service Account not configured"
- Set up service account as described above
- Configure Appfile or set environment variable

### Issue: "Permission denied when uploading"
- Check service account permissions in Google Play Console
- Ensure service account has appropriate access

### Issue: "Version code already used"
- Run `fastlane bump_build_number` to increment
- Never reuse version codes

## 📊 Comparison: Fastlane vs. Manual Scripts

| Feature | Fastlane | Manual Scripts |
|---------|----------|----------------|
| Industry Standard | ✅ Yes | ❌ No |
| Play Store Integration | ✅ Native | ❌ Manual |
| Automated Validation | ✅ Built-in | ✅ Custom |
| Version Management | ✅ Built-in | ⚠️ Manual |
| Multi-Track Deployment | ✅ Built-in | ❌ No |
| Screenshot Upload | ✅ Built-in | ❌ No |
| Metadata Upload | ✅ Built-in | ❌ No |
| CI/CD Integration | ✅ Excellent | ⚠️ Basic |
| Community Support | ✅ Huge | ❌ None |
| Maintenance | ✅ Active | ❌ Manual |

## 🎉 Summary

Fastlane is now ready to use for automated Play Store deployment across your Flutter workspace. It provides:

- ✅ Industry-standard deployment automation
- ✅ Comprehensive validation checks
- ✅ Automated build and upload
- ✅ Multi-track deployment support
- ✅ Version management
- ✅ CI/CD integration
- ✅ Screenshot and metadata management

**Next Steps:**
1. Set up Play Store service account
2. Test `fastlane validate` on your app
3. Try `fastlane deploy_internal` for testing
4. Integrate into your CI/CD pipeline

---

**Installed:** March 12, 2026  
**Fastlane Version:** 2.232.2  
**Ruby Version:** 3.4.8  
**Status:** ✅ Ready for use
