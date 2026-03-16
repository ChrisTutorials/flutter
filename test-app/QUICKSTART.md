# Quick Start Guide - Automated Deployments

This is a quick reference for setting up automated deployments. For detailed instructions, see [DEPLOYMENT.md](DEPLOYMENT.md).

## 🚀 Quick Setup Checklist

### 1. Android (Google Play Store)
- [ ] Create keystore: `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
- [ ] Add secrets to GitHub:
  - `ANDROID_KEYSTORE_BASE64`
  - `ANDROID_KEYSTORE_PASSWORD`
  - `ANDROID_KEY_PASSWORD`
  - `ANDROID_KEY_ALIAS`
  - `PLAY_STORE_CONFIG_JSON`
- [ ] Create service account in Google Play Console
- [ ] Update package name in `android/app/build.gradle`

### 2. iOS (Apple App Store)
- [ ] Create Distribution Certificate in Apple Developer Portal
- [ ] Create App Store Provisioning Profile
- [ ] Add secrets to GitHub:
  - `IOS_CERTIFICATE_BASE64`
  - `IOS_CERTIFICATE_PASSWORD`
  - `IOS_PROVISIONING_PROFILE_BASE64`
  - `APP_STORE_CONNECT_API_KEY_ID`
  - `APP_STORE_CONNECT_API_ISSUER_ID`
  - `APP_STORE_CONNECT_API_KEY_BASE64`
- [ ] Update `ios/ExportOptions.plist` with Team ID

### 3. Windows (Microsoft Store)
- [ ] Add secrets to GitHub:
  - `MICROSOFT_STORE_TENANT_ID`
  - `MICROSOFT_STORE_CLIENT_ID`
  - `MICROSOFT_STORE_CLIENT_SECRET`
- [ ] Set up Microsoft Store Submission API in Partner Center

## 📦 How to Deploy

### Deploy to All Platforms
```bash
git tag v1.0.0
git push origin v1.0.0
```

### Deploy to Single Platform
```bash
# Android only
git tag android-v1.0.0
git push origin android-v1.0.0

# iOS only
git tag ios-v1.0.0
git push origin ios-v1.0.0

# Windows only
git tag windows-v1.0.0
git push origin windows-v1.0.0
```

### Manual Deployment
1. Go to GitHub Actions tab
2. Select workflow
3. Click "Run workflow"

## 🔑 Encoding Secrets to Base64

### Windows (PowerShell)
```powershell
# For keystore
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Set-Clipboard

# For iOS certificate
[Convert]::ToBase64String([IO.File]::ReadAllBytes("certificate.p12")) | Set-Clipboard

# For provisioning profile
[Convert]::ToBase64String([IO.File]::ReadAllBytes("profile.mobileprovision")) | Set-Clipboard

# For API keys
[Convert]::ToBase64String([IO.File]::ReadAllBytes("AuthKey_ABC123.p8")) | Set-Clipboard
```

### macOS/Linux
```bash
# For keystore
base64 -i upload-keystore.jks | pbcopy

# For iOS certificate
base64 -i certificate.p12 | pbcopy

# For provisioning profile
base64 -i profile.mobileprovision | pbcopy

# For API keys
base64 -i AuthKey_ABC123.p8 | pbcopy
```

## 📝 Version Management

Update version in `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Format: MAJOR.MINOR.PATCH+BUILD_NUMBER
```

When you push a tag, the workflow automatically uses the tag version and increments the build number.

## ⚠️ Important Notes

1. **Never commit secrets** - Always use GitHub Secrets
2. **Test locally first** - Test builds locally before deploying
3. **Use semantic versioning** - Follow MAJOR.MINOR.PATCH format
4. **Start with internal tracks** - Deploy to internal testing first
5. **Monitor builds** - Check GitHub Actions logs for errors

## 🐛 Common Issues

### Android build fails
- Check keystore secrets are correct
- Verify package name matches Google Play Console
- Ensure service account has proper permissions

### iOS build fails
- Verify certificates are valid
- Check Team ID in ExportOptions.plist
- Ensure API key has "App Manager" role

### Windows build fails
- Check Inno Setup installation
- Verify Microsoft Store API credentials
- Ensure app is configured in Partner Center

## 📚 Additional Resources

- [Full Deployment Guide](DEPLOYMENT.md)
- [Flutter Deployment Docs](https://docs.flutter.dev/deployment)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 🆘 Need Help?

1. Check the [DEPLOYMENT.md](DEPLOYMENT.md) for detailed instructions
2. Review GitHub Actions logs for error messages
3. Verify all secrets are correctly set
4. Ensure your app is properly configured in each store console

