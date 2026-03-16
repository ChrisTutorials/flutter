# Fastlane Patterns for Flutter Apps

## Overview

This document provides reusable Fastlane patterns for building, testing, and deploying Flutter apps across Android, Windows, and iOS platforms.

## 📋 Prerequisites

### Common Prerequisites
- Ruby 3.0+
- Fastlane (`gem install fastlane`)
- Flutter SDK
- Platform-specific SDKs (Android SDK, Xcode, Visual Studio)

### Installation
```bash
# Install Fastlane
gem install fastlane

# Initialize Fastlane in your project (run in platform directory)
cd android
fastlane init
```

## 🏗️ Project Structure

### Recommended Fastlane Structure

```
your_flutter_app/
├── android/
│   └── fastlane/
│       ├── Fastfile
│       ├── Appfile
│       └── google-play-service-account.json
├── windows/
│   └── fastlane/
│       ├── Fastfile
│       └── Appfile
└── ios/
    └── fastlane/
        ├── Fastfile
        └── Appfile
```

## 🔧 Common Fastlane Patterns

### Pattern 1: Build and Test

#### Android
```ruby
# android/fastlane/Fastfile
platform :android do
  desc "Build debug APK"
  lane :build_debug do
    gradle(
      task: "assembleDebug",
      project_dir: "android/"
    )
  end

  desc "Build release APK"
  lane :build_release do
    gradle(
      task: "assembleRelease",
      project_dir: "android/"
    )
  end

  desc "Run tests"
  lane :test do
    gradle(
      task: "test",
      project_dir: "android/"
    )
  end
end
```

#### Windows
```ruby
# windows/fastlane/Fastfile
platform :windows do
  desc "Build debug"
  lane :build_debug do
    build_windows(
      build_type: "debug"
    )
  end

  desc "Build release"
  lane :build_release do
    build_windows(
      build_type: "release"
    )
  end
end
```

#### iOS
```ruby
# ios/fastlane/Fastfile
platform :ios do
  desc "Build debug"
  lane :build_debug do
    build_ios(
      configuration: "Debug"
    )
  end

  desc "Build release"
  lane :build_release do
    build_ios(
      configuration: "Release"
    )
  end

  desc "Run tests"
  lane :test do
    run_tests(
      scheme: "Runner"
    )
  end
end
```

### Pattern 2: Increment Version

#### Android
```ruby
# android/fastlane/Fastfile
platform :android do
  desc "Increment version code"
  lane :increment_version do
    increment_version_code(
      gradle_file_path: "app/build.gradle.kts"
    )
  end

  desc "Increment version name"
  lane :increment_version_name do |options|
    increment_version_name(
      gradle_file_path: "app/build.gradle.kts",
      version_name: options[:version_name]
    )
  end
end
```

#### iOS
```ruby
# ios/fastlane/Fastfile
platform :ios do
  desc "Increment build number"
  lane :increment_build_number do
    increment_build_number(
      xcodeproj: "Runner.xcodeproj"
    )
  end

  desc "Increment version number"
  lane :increment_version_number do |options|
    increment_version_number(
      xcodeproj: "Runner.xcodeproj",
      version_number: options[:version_number]
    )
  end
end
```

### Pattern 3: Screenshot Generation

#### Android
```ruby
# android/fastlane/Fastfile
platform :android do
  desc "Capture screenshots"
  lane :screenshots do
    capture_android_screenshots(
      locales: ["en-US"],
      clear_previous_screenshots: true
    )
  end
end
```

#### iOS
```ruby
# ios/fastlane/Fastfile
platform :ios do
  desc "Capture screenshots"
  lane :screenshots do
    capture_screenshots(
      scheme: "Runner",
      languages: ["en-US"]
    )
  end
end
```

### Pattern 4: Deployment

#### Android Deployment
```ruby
# android/fastlane/Fastfile
platform :android do
  desc "Deploy to Google Play Store"
  lane :deploy do |options|
    track = options[:track] || "internal"
    release_notes = options[:release_notes] || "Bug fixes and improvements"

    # Upload screenshots
    upload_to_play_store(
      track: track,
      skip_upload_screenshots: options[:skip_screenshots] || false,
      skip_upload_metadata: options[:skip_metadata] || false,
      release_notes: release_notes,
      apk: "../build/app/outputs/flutter-apk/app-release.apk"
    )
  end

  desc "Deploy to internal testing"
  lane :deploy_internal do |options|
    deploy(
      track: "internal",
      release_notes: options[:release_notes]
    )
  end

  desc "Deploy to production"
  lane :deploy_production do |options|
    deploy(
      track: "production",
      release_notes: options[:release_notes]
    )
  end
end
```

#### Windows Deployment
```ruby
# windows/fastlane/Fastfile
platform :windows do
  desc "Deploy to Microsoft Store"
  lane :deploy_production do |options|
    release_notes = options[:release_notes] || "Bug fixes and improvements"

    # Build and package
    build_windows(
      build_type: "release"
    )

    # Upload to Microsoft Store
    # Note: This requires additional setup with Microsoft Store APIs
    upload_windows_store(
      skip_screenshots: options[:skip_screenshots] || false,
      release_notes: release_notes
    )
  end
end
```

#### iOS Deployment
```ruby
# ios/fastlane/Fastfile
platform :ios do
  desc "Deploy to TestFlight"
  lane :deploy_beta do |options|
    release_notes = options[:release_notes] || "Bug fixes and improvements"

    # Build and upload
    build_app(
      scheme: "Runner",
      export_method: "app-store"
    )

    upload_to_testflight(
      skip_waiting_for_build_processing: true,
      release_notes: release_notes
    )
  end

  desc "Deploy to App Store"
  lane :deploy_production do |options|
    release_notes = options[:release_notes] || "Bug fixes and improvements"

    # Build and upload
    build_app(
      scheme: "Runner",
      export_method: "app-store"
    )

    upload_to_app_store(
      submit_for_review: options[:submit_for_review] || false,
      release_notes: release_notes
    )
  end
end
```

### Pattern 5: Validation

#### Android Validation
```ruby
# android/fastlane/Fastfile
platform :android do
  desc "Validate deployment readiness"
  lane :validate do
    # Check version
    version = get_version_name(
      gradle_file_path: "app/build.gradle.kts"
    )
    UI.user_error!("Version not set!") unless version

    # Check credentials
    UI.user_error!("Service account not found!") unless File.exist?("google-play-service-account.json")

    # Check screenshots
    UI.user_error!("Screenshots not generated!") unless Dir.exist?("metadata/android/en-US/images/phoneScreenshots")

    UI.success("Validation passed!")
  end
end
```

#### iOS Validation
```ruby
# ios/fastlane/Fastfile
platform :ios do
  desc "Validate deployment readiness"
  lane :validate do
    # Check certificates
    cert
    sigh

    # Check screenshots
    UI.user_error!("Screenshots not generated!") unless Dir.exist?("fastlane/screenshots/en-US")

    UI.success("Validation passed!")
  end
end
```

### Pattern 6: Release Status

#### Android Release Status
```ruby
# android/fastlane/Fastfile
platform :android do
  desc "Check release status"
  lane :release_status do
    # Get current version
    version_code = get_version_code(
      gradle_file_path: "app/build.gradle.kts"
    )
    version_name = get_version_name(
      gradle_file_path: "app/build.gradle.kts"
    )

    UI.header("Current Release Status")
    UI.message("Version Code: #{version_code}")
    UI.message("Version Name: #{version_name}")

    # Check credentials
    if File.exist?("google-play-service-account.json")
      UI.success("✅ Service account configured")
    else
      UI.error("❌ Service account not configured")
    end

    # Check screenshots
    if Dir.exist?("metadata/android/en-US/images/phoneScreenshots")
      screenshot_count = Dir.glob("metadata/android/en-US/images/phoneScreenshots/*").count
      UI.success("✅ Screenshots generated (#{screenshot_count} images)")
    else
      UI.error("❌ Screenshots not generated")
    end

    # Quick deployment commands
    UI.header("Quick Deployment Commands")
    UI.message("Internal: fastlane deploy_internal")
    UI.message("Alpha: fastlane deploy track:alpha")
    UI.message("Beta: fastlane deploy track:beta")
    UI.message("Production: fastlane deploy_production")
  end
end
```

## 🔐 Credential Management

### Android Credentials
```ruby
# android/fastlane/Appfile
json_key_file("google-play-service-account.json") # Path to the json secret file
package_name("com.example.app") # e.g. com.yourcompany.yourapp
```

### iOS Credentials
```ruby
# ios/fastlane/Appfile
app_identifier("com.example.app")
apple_id("your-apple-id@example.com")
team_id("YOUR_TEAM_ID") # Developer Portal Team ID

# For more information about the Appfile, see:
#     https://docs.fastlane.tools/advanced/#appfile
```

### Windows Credentials
Windows credentials are typically managed through environment variables or the Microsoft Store CLI.

## 🧪 Testing Integration

### Flutter Test Integration
```ruby
# Run Flutter tests before deployment
platform :android do
  before_each do |lane|
    sh("flutter", "test")
    sh("flutter", "analyze")
  end
end

platform :ios do
  before_each do |lane|
    sh("flutter", "test")
    sh("flutter", "analyze")
  end
end
```

### Golden Screenshots
```ruby
# Generate golden screenshots
platform :android do
  desc "Generate golden screenshots"
  lane :golden_screenshots do
    sh("flutter", "test", "test/golden_screenshots/store_screenshots_test.dart", "--update-goldens")
  end
end
```

## 🚀 CI/CD Integration

### GitHub Actions Example
```yaml
name: Deploy to Android

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.0'
          bundler-cache: true
      - name: Deploy to Play Store
        env:
          GOOGLE_PLAY_JSON_KEY_FILE: ${{ secrets.GOOGLE_PLAY_JSON_KEY_FILE }}
        run: |
          cd android
          bundle exec fastlane deploy_production
```

## 📊 Best Practices

### 1. Use Lanes for Common Operations
Organize your Fastfile into logical lanes for common operations.

### 2. Parameterize Lanes
Make lanes flexible by accepting parameters.

### 3. Add Validation
Validate prerequisites before running deployment lanes.

### 4. Use Before/After Hooks
Use `before_each` and `after_each` for common setup/teardown.

### 5. Keep Credentials Secure
Never commit credentials. Use environment variables or encrypted secrets.

### 6. Document Lanes
Add `desc` comments to all lanes for documentation.

### 7. Test Locally First
Always test lanes locally before running in CI/CD.

### 8. Use Version Control
Commit your Fastfile and Appfile to version control.

## 🔧 Troubleshooting

### Common Issues

#### Issue: Fastlane not found
```bash
# Solution: Install Fastlane
gem install fastlane
```

#### Issue: Ruby version too old
```bash
# Solution: Update Ruby
rbenv install 3.0.0
rbenv global 3.0.0
```

#### Issue: Gradle build fails
```bash
# Solution: Clean and rebuild
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### Issue: iOS code signing issues
```bash
# Solution: Reset certificates
cd ios
fastlane match nuke development
fastlane match development
```

## 📚 Additional Resources

- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Fastlane for Android](https://docs.fastlane.tools/actions/upload_to_play_store/)
- [Fastlane for iOS](https://docs.fastlane.tools/actions/upload_to_app_store/)
- [Flutter Build Documentation](https://docs.flutter.dev/deployment/android)

## 🎯 Next Steps

1. Set up Fastlane for your platforms
2. Create custom lanes for your app
3. Integrate with CI/CD
4. Test deployment locally
5. Deploy to internal testing first

---

*This document is part of the reusable documentation. See [index.md](index.md) for more resources.*

