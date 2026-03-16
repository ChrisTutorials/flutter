# Skill: Windows Store Deployment - Non-Interactive Mode

## 📋 Summary

Deploy Flutter Windows apps to Microsoft Store using **non-interactive modes** to prevent blocking on user input. This is essential for automated workflows, CI/CD pipelines, and hands-off deployment processes.

## ⚠️ Critical: Always Use Non-Interactive Flags

When deploying to Windows Store, **ALWAYS** use non-interactive flags to prevent the deployment from hanging on confirmation prompts:

- `skip_confirmation:true` - Skip all confirmation prompts
- `track:retail` - Specify the deployment track explicitly

## 🚀 Windows Store Deployment Commands

### Method 1: Direct Fastlane (Recommended)

```bash
cd unit_converter/windows
bundle exec fastlane deploy_production skip_confirmation:true
```

### Method 2: With Custom Track

```bash
cd unit_converter/windows
bundle exec fastlane deploy_store track:retail skip_confirmation:true
```

### Method 3: Internal Testing

```bash
cd unit_converter/windows
bundle exec fastlane deploy_internal
```

## 📋 Complete Non-Interactive Deployment Workflow

### Step 1: Update Version

```bash
cd unit_converter/windows
bundle exec fastlane bump_build_number
```

### Step 2: Run Deployment Tests

```bash
cd unit_converter/windows
bundle exec fastlane test_deployment
```

### Step 3: Deploy to Production (Non-Interactive)

```bash
cd unit_converter/windows
bundle exec fastlane deploy_production skip_confirmation:true
```

## 🔧 Available Non-Interactive Flags

| Flag | Description | When to Use |
|------|-------------|-------------|
| `skip_confirmation:true` | Skip all confirmation prompts | **ALWAYS use for production** |
| `track:retail` | Deploy to retail track | **ALWAYS use for production** |
| `track:internal` | Deploy to internal testing | For testing deployments |

## 📝 Example: Full Production Deployment

```bash
# Navigate to Windows directory
cd c:\dev\flutter\unit_converter\windows

# Deploy with non-interactive flags
bundle exec fastlane deploy_production skip_confirmation:true
```

## 🧪 Test Cases

### Running All Deployment Tests

```bash
cd unit_converter/windows
bundle exec fastlane test_deployment
```

This runs comprehensive tests:
1. ✅ Configuration Validation
2. ✅ Manifest Validation
3. ✅ Version Format Validation
4. ✅ Signing Configuration
5. ✅ Test ID Check
6. ✅ EXE Build
7. ✅ Flutter Tests

### Running Prerequisites Check

```bash
cd unit_converter/windows
bundle exec fastlane test_prerequisites
```

This checks:
1. ✅ Flutter Installation
2. ✅ Windows Build Configuration
3. ✅ Visual Studio Installation
4. ✅ Windows SDK Installation
5. ✅ Partner Center Credentials
6. ✅ Windows Certificate

## 🎯 Best Practices

### 1. Always Use Non-Interactive Flags
```bash
# ✅ GOOD - Non-interactive
bundle exec fastlane deploy_production skip_confirmation:true

# ❌ BAD - Will hang on confirmation
bundle exec fastlane deploy_production
```

### 2. Validate Before Deploying
```bash
# Run validation first (non-interactive)
bundle exec fastlane validate

# Then run tests (non-interactive)
bundle exec fastlane test_deployment

# Then deploy (non-interactive)
bundle exec fastlane deploy_production skip_confirmation:true
```

### 3. Test on Internal Track First
```bash
# Deploy to internal (non-interactive)
bundle exec fastlane deploy_internal

# Test the build
# Then deploy to production (non-interactive)
bundle exec fastlane deploy_production skip_confirmation:true
```

### 4. Use Environment Variables for Credentials
```bash
# Set credentials as environment variables
$env:PARTNER_CENTER_CLIENT_ID = "your-client-id"
$env:PARTNER_CENTER_CLIENT_SECRET = "your-client-secret"
$env:PARTNER_CENTER_TENANT_ID = "your-tenant-id"
$env:WINDOWS_CERTIFICATE_PATH = "path/to/certificate.pfx"
$env:WINDOWS_CERTIFICATE_PASSWORD = "your-password"

# Then deploy (non-interactive)
bundle exec fastlane deploy_production skip_confirmation:true
```

## 🔒 Security Considerations

### Partner Center Setup
1. Create app registration in Microsoft Partner Center
2. Generate API credentials (Client ID, Client Secret, Tenant ID)
3. Configure in Appfile or as environment variables

### Windows Certificate Setup
1. Obtain code signing certificate from a certificate authority
2. Store certificate securely
3. Set certificate path and password as environment variables
4. Never commit certificates to version control

### Environment Variables (Recommended)
```bash
# Set Partner Center credentials
$env:PARTNER_CENTER_CLIENT_ID = "your-client-id"
$env:PARTNER_CENTER_CLIENT_SECRET = "your-client-secret"
$env:PARTNER_CENTER_TENANT_ID = "your-tenant-id"

# Set Windows certificate
$env:WINDOWS_CERTIFICATE_PATH = "C:\path\to\certificate.pfx"
$env:WINDOWS_CERTIFICATE_PASSWORD = "your-password"
```

## 🐛 Troubleshooting

### Issue: Deployment hangs on confirmation
**Solution:** Always use `skip_confirmation:true` flag

### Issue: Partner Center credentials invalid
**Solution:** Verify Client ID, Client Secret, and Tenant ID in Partner Center

### Issue: Certificate not found
**Solution:** Check certificate path and password in environment variables

### Issue: Visual Studio not found
**Solution:** Install Visual Studio 2022 with "Desktop development with C++" workload

### Issue: Windows SDK not found
**Solution:** Install Windows 10/11 SDK through Visual Studio Installer

## 📊 Deployment Tracks

| Track | Command | Use Case |
|-------|---------|----------|
| Internal | `deploy_internal` | Internal testing team |
| Retail | `deploy_production skip_confirmation:true` | Public release |

## 🔄 CI/CD Integration

### GitHub Actions Example
```yaml
- name: Deploy to Windows Store
  run: |
    cd unit_converter/windows
    $env:PARTNER_CENTER_CLIENT_ID = "${{ secrets.PARTNER_CENTER_CLIENT_ID }}"
    $env:PARTNER_CENTER_CLIENT_SECRET = "${{ secrets.PARTNER_CENTER_CLIENT_SECRET }}"
    $env:PARTNER_CENTER_TENANT_ID = "${{ secrets.PARTNER_CENTER_TENANT_ID }}"
    $env:WINDOWS_CERTIFICATE_PATH = "${{ secrets.WINDOWS_CERTIFICATE_PATH }}"
    $env:WINDOWS_CERTIFICATE_PASSWORD = "${{ secrets.WINDOWS_CERTIFICATE_PASSWORD }}"
    bundle exec fastlane deploy_production skip_confirmation:true
```

### Jenkins Example
```groovy
stage('Deploy Windows Production') {
  steps {
    dir('unit_converter/windows') {
      withCredentials([
        string(credentialsId: 'PARTNER_CENTER_CLIENT_ID', variable: 'PARTNER_CENTER_CLIENT_ID'),
        string(credentialsId: 'PARTNER_CENTER_CLIENT_SECRET', variable: 'PARTNER_CENTER_CLIENT_SECRET'),
        string(credentialsId: 'PARTNER_CENTER_TENANT_ID', variable: 'PARTNER_CENTER_TENANT_ID'),
        string(credentialsId: 'WINDOWS_CERTIFICATE_PATH', variable: 'WINDOWS_CERTIFICATE_PATH'),
        string(credentialsId: 'WINDOWS_CERTIFICATE_PASSWORD', variable: 'WINDOWS_CERTIFICATE_PASSWORD')
      ]) {
        sh 'bundle exec fastlane deploy_production skip_confirmation:true'
      }
    }
  }
}
```

## 📚 Related Skills

- **[unified-deployment/](../unified-deployment/)** - **Unified multi-platform deployment (Android, Windows, iOS)**
- **[production-deployment/](../production-deployment/)** - Production deployment for Android (Google Play Store)
- **[ios-store-deployment/](../ios-store-deployment/)** - iOS App Store deployment
- **[fastlane-setup/](../fastlane-setup/)** - Complete Fastlane setup and configuration

## 🎉 Summary

Always use non-interactive flags when deploying to Windows Store:

```bash
bundle exec fastlane deploy_production skip_confirmation:true
```

This ensures:
- ✅ No blocking on confirmation prompts
- ✅ Suitable for CI/CD pipelines
- ✅ Hands-off deployment workflow
- ✅ Consistent deployment process

## 🔧 Prerequisites Checklist

Before deploying to Windows Store, ensure:

1. ✅ Flutter SDK installed with Windows support
2. ✅ Visual Studio 2022 with "Desktop development with C++" workload
3. ✅ Windows 10/11 SDK installed
4. ✅ Ruby and Fastlane installed
5. ✅ Windows code signing certificate obtained
6. ✅ Microsoft Partner Center account set up
7. ✅ Partner Center API credentials configured
8. ✅ App registered in Partner Center (9P8DMW35JXQ5)

## 📋 Quick Reference

### Validate Configuration
```bash
bundle exec fastlane validate
```

### Run Deployment Tests
```bash
bundle exec fastlane test_deployment
```

### Check Prerequisites
```bash
bundle exec fastlane test_prerequisites
```

### Bump Version
```bash
bundle exec fastlane bump_build_number
```

### Deploy to Production
```bash
bundle exec fastlane deploy_production skip_confirmation:true
```

---

**Key Rule:** When user requests "deploy to Windows Store" or "build for Windows Store", **ALWAYS** use non-interactive flags to prevent blocking.

