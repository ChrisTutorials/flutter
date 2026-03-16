# Skill: Production Deployment - Non-Interactive Mode

## 📋 Summary

Deploy Flutter apps to Google Play Store production track using **non-interactive modes** to prevent blocking on user input. This is essential for automated workflows, CI/CD pipelines, and hands-off deployment processes.

## ⚠️ Critical: Always Use Non-Interactive Flags

When deploying to production, **ALWAYS** use non-interactive flags to prevent the deployment from hanging on confirmation prompts:

- `skip_confirmation:true` - Skip all confirmation prompts
- `submit_for_review:true` - Automatically submit for Google Play review
- `skip_screenshots:true` - Skip screenshot generation (if already done)
- `skip_metadata:true` - Skip metadata updates (if already done)

## 🚀 Production Deployment Commands

### Method 1: Direct Fastlane (Recommended)

```bash
cd unit_converter/android
bundle exec fastlane deploy track:production skip_confirmation:true submit_for_review:true
```

### Method 2: PowerShell Wrapper

```powershell
cd unit_converter
.\scripts\release.ps1 -Track 'production' -SkipConfirmation -DoNotSendForReview:$false
```

### Method 3: With Custom Release Notes

```bash
cd unit_converter/android
bundle exec fastlane deploy track:production release_notes:"Your release notes here" skip_confirmation:true submit_for_review:true
```

## 📋 Complete Non-Interactive Deployment Workflow

### Step 1: Update Version

```bash
cd unit_converter/android
bundle exec fastlane bump_build_number
```

### Step 2: Generate Screenshots (if needed)

```bash
cd unit_converter
flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens
```

### Step 3: Deploy to Production (Non-Interactive)

```bash
cd unit_converter/android
bundle exec fastlane deploy track:production skip_confirmation:true submit_for_review:true
```

## 🔧 Available Non-Interactive Flags

| Flag | Description | When to Use |
|------|-------------|-------------|
| `skip_confirmation:true` | Skip all confirmation prompts | **ALWAYS use for production** |
| `submit_for_review:true` | Auto-submit for Google Play review | **ALWAYS use for production** |
| `skip_screenshots:true` | Skip screenshot generation | When screenshots are already up-to-date |
| `skip_metadata:true` | Skip metadata updates | When metadata is already up-to-date |
| `skip_validation:true` | Skip validation checks | ⚠️ Only use if you've already validated |
| `release_notes:"text"` | Custom release notes | When you want specific notes |

## 📝 Example: Full Production Deployment

```bash
# Navigate to project
cd c:\dev\flutter\unit_converter\android

# Deploy with all non-interactive flags
bundle exec fastlane deploy \
  track:production \
  release_notes:"Currency Name Helpers: Added full currency names next to codes" \
  skip_confirmation:true \
  submit_for_review:true
```

## 🎯 Best Practices

### 1. Always Use Non-Interactive Flags
```bash
# ✅ GOOD - Non-interactive
bundle exec fastlane deploy track:production skip_confirmation:true submit_for_review:true

# ❌ BAD - Will hang on confirmation
bundle exec fastlane deploy track:production
```

### 2. Validate Before Deploying
```bash
# Run validation first (non-interactive)
bundle exec fastlane validate

# Then deploy (non-interactive)
bundle exec fastlane deploy track:production skip_confirmation:true submit_for_review:true
```

### 3. Test on Internal Track First
```bash
# Deploy to internal (non-interactive)
bundle exec fastlane deploy_internal skip_confirmation:true

# Test the build
# Then deploy to production (non-interactive)
bundle exec fastlane deploy track:production skip_confirmation:true submit_for_review:true
```

### 4. Use Meaningful Release Notes
```bash
bundle exec fastlane deploy \
  track:production \
  release_notes:"Bug fixes and performance improvements" \
  skip_confirmation:true \
  submit_for_review:true
```

## 🔒 Security Considerations

### Service Account Setup
1. Create service account in Google Play Console
2. Grant appropriate permissions (Admin recommended)
3. Download JSON key
4. Place in `android/fastlane/google-play-service-account.json`
5. Add to `.gitignore`

### Environment Variables (Alternative)
```bash
# Set service account JSON as environment variable
$env:GOOGLE_PLAY_SERVICE_ACCOUNT_JSON = Get-Content -Raw path/to/key.json
```

## 🐛 Troubleshooting

### Issue: Deployment hangs on confirmation
**Solution:** Always use `skip_confirmation:true` flag

### Issue: Changes not submitted for review
**Solution:** Use `submit_for_review:true` flag

### Issue: Version code conflict
**Solution:** Run `bundle exec fastlane bump_build_number` before deploying

### Issue: Screenshots failing
**Solution:** Use `skip_screenshots:true` if screenshots are already current

## 📊 Deployment Tracks

| Track | Command | Use Case |
|-------|---------|----------|
| Internal | `deploy_internal skip_confirmation:true` | Internal testing team |
| Alpha | `deploy_alpha skip_confirmation:true` | Alpha testers |
| Beta | `deploy_beta skip_confirmation:true` | Beta testers |
| Production | `deploy track:production skip_confirmation:true submit_for_review:true` | Public release |

## 🔄 CI/CD Integration

### GitHub Actions Example
```yaml
- name: Deploy to Production
  run: |
    cd unit_converter/android
    bundle exec fastlane deploy \
      track:production \
      release_notes:"${{ github.event.head_commit.message }}" \
      skip_confirmation:true \
      submit_for_review:true
```

### Jenkins Example
```groovy
stage('Deploy Production') {
  steps {
    dir('unit_converter/android') {
      sh 'bundle exec fastlane deploy track:production skip_confirmation:true submit_for_review:true'
    }
  }
}
```

## 📚 Related Skills

- **[unified-deployment/](../unified-deployment/)** - **Unified multi-platform deployment (Android, Windows, iOS)**
- **[windows-store-deployment/](../windows-store-deployment/)** - Windows Store deployment
- **[ios-store-deployment/](../ios-store-deployment/)** - iOS App Store deployment
- **[fastlane-setup/](../fastlane-setup/)** - Complete Fastlane setup and configuration
- **[take-screenshots/](../take-screenshots/)** - Screenshot generation for store assets
- **[full-screen-screenshot-validation/](../full-screen-screenshot-validation/)** - Screenshot validation

## 🎉 Summary

Always use non-interactive flags when deploying to production:

```bash
bundle exec fastlane deploy track:production skip_confirmation:true submit_for_review:true
```

This ensures:
- ✅ No blocking on confirmation prompts
- ✅ Automatic submission for Google Play review
- ✅ Suitable for CI/CD pipelines
- ✅ Hands-off deployment workflow
- ✅ Consistent deployment process

---

**Key Rule:** When user requests "deploy to production" or "build for production", **ALWAYS** use non-interactive flags to prevent blocking.

