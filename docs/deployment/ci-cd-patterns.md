# CI/CD Patterns for Flutter Apps

## Overview

This document provides reusable CI/CD patterns for building, testing, and deploying Flutter apps across Android, Windows, and iOS platforms.

## 🎯 CI/CD Strategy

### Principles
1. **Automated Testing**: Run tests on every commit
2. **Automated Deployment**: Deploy on tag push
3. **Process Cleanup**: Ensure no zombie processes
4. **Fast Feedback**: Quick build and test cycles
5. **Security**: Use secrets for credentials
6. **Rollback Capability**: Easy rollback if needed

## 🏗️ CI/CD Architecture

```
GitHub Actions
├── Test Workflow (runs on every push/PR)
│   ├── Flutter analyze
│   ├── Flutter test
│   ├── Integration tests
│   └── Process cleanup verification
├── Build Workflow (runs on tag push)
│   ├── Build Android APK
│   ├── Build Windows EXE
│   ├── Build iOS IPA (macOS only)
│   └── Upload artifacts
└── Deploy Workflow (runs on tag push)
    ├── Deploy to Android
    ├── Deploy to Windows
    ├── Deploy to iOS
    └── Process cleanup verification
```

## 📋 GitHub Actions Workflows

### Workflow 1: Test and Process Cleanup

```yaml
name: Test and Process Cleanup

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]
  workflow_dispatch:

jobs:
  test-flutter:
    name: Test Flutter App
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Analyze code
        run: flutter analyze

      - name: Run unit tests
        run: flutter test

      - name: Run integration tests
        run: flutter test integration_test

  test-process-cleanup:
    name: Test Process Cleanup
    runs-on: windows-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'

      - name: Run process cleanup tests
        shell: pwsh
        run: |
          cd ..
          .\scripts\test-process-cleanup.ps1 -ShowDetails

      - name: Verify clean state
        shell: pwsh
        run: |
          # Check for zombie processes
          $processes = Get-Process | Where-Object {$_.ProcessName -like "*dart*" -or $_.ProcessName -like "*flutter*"}
          if ($processes) {
            Write-Host "ERROR: Zombie processes found!"
            $processes | Format-Table
            exit 1
          }
```

### Workflow 2: Build All Platforms

```yaml
name: Build All Platforms

on:
  push:
    tags:
      - 'v*'
  workflow_dispatch:

jobs:
  build-android:
    name: Build Android APK
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Get dependencies
        run: flutter pub get

      - name: Build APK
        run: flutter build apk --release

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: app-release
          path: build/app/outputs/flutter-apk/app-release.apk

  build-windows:
    name: Build Windows EXE
    runs-on: windows-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Build Windows
        run: flutter build windows --release

      - name: Upload EXE
        uses: actions/upload-artifact@v4
        with:
          name: windows-installer
          path: build/windows/x64/runner/Release/*.exe

  build-ios:
    name: Build iOS IPA
    runs-on: macos-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Build iOS
        run: flutter build ios --release

      - name: Upload IPA
        uses: actions/upload-artifact@v4
        with:
          name: app-ipa
          path: build/ios/ipa/*.ipa
```

### Workflow 3: Deploy to All Platforms

```yaml
name: Deploy All Platforms

on:
  push:
    tags:
      - 'v*'
  workflow_dispatch:

jobs:
  deploy-android:
    name: Deploy to Android
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

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
          cd unit_converter
          ../scripts/deploy.ps1 -Platform android -Track production -SkipConfirmation

  deploy-windows:
    name: Deploy to Windows
    runs-on: windows-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.0'
          bundler-cache: true

      - name: Deploy to Microsoft Store
        env:
          PARTNER_CENTER_CLIENT_ID: ${{ secrets.PARTNER_CENTER_CLIENT_ID }}
          PARTNER_CENTER_CLIENT_SECRET: ${{ secrets.PARTNER_CENTER_CLIENT_SECRET }}
          PARTNER_CENTER_TENANT_ID: ${{ secrets.PARTNER_CENTER_TENANT_ID }}
          WINDOWS_CERTIFICATE_PATH: ${{ secrets.WINDOWS_CERTIFICATE_PATH }}
          WINDOWS_CERTIFICATE_PASSWORD: ${{ secrets.WINDOWS_CERTIFICATE_PASSWORD }}
        run: |
          cd unit_converter
          ..\scripts\deploy.ps1 -Platform windows -Track retail -SkipConfirmation

  deploy-ios:
    name: Deploy to iOS
    runs-on: macos-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.0'
          bundler-cache: true

      - name: Deploy to App Store
        env:
          APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
          APP_STORE_CONNECT_API_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_API_ISSUER_ID }}
          APP_STORE_CONNECT_API_KEY_PATH: ${{ secrets.APP_STORE_CONNECT_API_KEY_PATH }}
        run: |
          cd unit_converter
          ../scripts/deploy.ps1 -Platform ios -Track production -SkipConfirmation
```

## 🔐 Secrets Management

### Required Secrets

#### Android
- `GOOGLE_PLAY_JSON_KEY_FILE`: Base64-encoded Google Play service account JSON

#### Windows
- `PARTNER_CENTER_CLIENT_ID`: Microsoft Partner Center client ID
- `PARTNER_CENTER_CLIENT_SECRET`: Microsoft Partner Center client secret
- `PARTNER_CENTER_TENANT_ID`: Microsoft tenant ID
- `WINDOWS_CERTIFICATE_PATH`: Path to code signing certificate
- `WINDOWS_CERTIFICATE_PASSWORD`: Certificate password

Use `docs/deployment/windows-export-signing.md` as the canonical reference for Windows signing inputs and MSIX export expectations.

#### iOS
- `APP_STORE_CONNECT_API_KEY_ID`: App Store Connect API key ID
- `APP_STORE_CONNECT_API_ISSUER_ID`: App Store Connect issuer ID
- `APP_STORE_CONNECT_API_KEY_PATH`: Path to API key file

### Setting Secrets in GitHub

```bash
# Using GitHub CLI
gh secret set GOOGLE_PLAY_JSON_KEY_FILE < google-play-service-account.json

# Or via GitHub web interface
# Settings → Secrets and variables → Actions → New repository secret
```

## 🧪 Testing in CI/CD

### Unit Tests
```yaml
- name: Run unit tests
  run: flutter test
```

### Integration Tests
```yaml
- name: Run integration tests
  run: flutter test integration_test
```

### Golden Screenshots
```yaml
- name: Generate golden screenshots
  run: flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens
```

### Coverage
```yaml
- name: Generate coverage
  run: flutter test --coverage

- name: Upload coverage
  uses: codecov/codecov-action@v3
  with:
    files: coverage/lcov.info
```

## 🔄 Process Cleanup in CI/CD

### Automatic Cleanup
The deployment script automatically cleans up processes, but we also verify cleanup:

```yaml
- name: Verify process cleanup
  shell: pwsh
  run: |
    $processes = Get-Process | Where-Object {$_.ProcessName -like "*dart*"}
    if ($processes) {
      Write-Host "ERROR: Zombie processes found!"
      exit 1
    }
```

### Dedicated Cleanup Workflow
```yaml
- name: Run process cleanup tests
  shell: pwsh
  run: |
    ..\scripts\test-process-cleanup.ps1 -ShowDetails
```

## 📊 Deployment Strategies

### Strategy 1: Internal → Alpha → Beta → Production

```yaml
# Internal testing
deploy-android:
  run: |
    ./scripts/deploy.ps1 -Platform android -Track internal

# Alpha testing
deploy-android-alpha:
  run: |
    ./scripts/deploy.ps1 -Platform android -Track alpha

# Beta testing
deploy-android-beta:
  run: |
    ./scripts/deploy.ps1 -Platform android -Track beta

# Production
deploy-android-production:
  run: |
    ./scripts/deploy.ps1 -Platform android -Track production
```

### Strategy 2: Automated on Tag

```yaml
on:
  push:
    tags:
      - 'v*' # Matches v1.0.0, v2.1.3, etc.
```

### Strategy 3: Manual Approval

```yaml
deploy-android:
  environment:
    name: production
    url: https://play.google.com/store/apps/details?id=com.example.app
```

## 🚀 Performance Optimization

### Caching Dependencies
```yaml
- name: Cache Flutter dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/.pub-cache
      .flutter_tool_state
    key: ${{ runner.os }}-flutter-${{ hashFiles('pubspec.lock') }}
```

### Caching Gradle
```yaml
- name: Cache Gradle
  uses: actions/cache@v3
  with:
    path: |
      ~/.gradle/caches
      ~/.gradle/wrapper
    key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*') }}
```

### Parallel Jobs
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps: [...]

  build-android:
    runs-on: ubuntu-latest
    needs: test
    steps: [...]

  build-windows:
    runs-on: windows-latest
    needs: test
    steps: [...]

  build-ios:
    runs-on: macos-latest
    needs: test
    steps: [...]
```

## 📝 Notification Patterns

### Slack Notification
```yaml
- name: Notify Slack
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Email Notification
```yaml
- name: Send email
  if: failure()
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: smtp.gmail.com
    server_port: 465
    username: ${{ secrets.EMAIL_USERNAME }}
    password: ${{ secrets.EMAIL_PASSWORD }}
    subject: Deployment failed
    body: Deployment failed for ${{ github.repository }}
```

## 🔍 Monitoring and Debugging

### Logging
```yaml
- name: Enable verbose logging
  run: |
    flutter doctor -v
    flutter --version
```

### Artifact Retention
```yaml
- name: Upload build logs
  if: failure()
  uses: actions/upload-artifact@v4
  with:
    name: build-logs
    path: |
      **/*.log
      flutter_*.log
```

## 🎯 Best Practices

1. **Test Locally First**: Always test workflows locally
2. **Use Environments**: Separate environments for staging/production
3. **Secret Management**: Never hardcode credentials
4. **Process Cleanup**: Always verify no zombie processes
5. **Fail Fast**: Fail early on errors
6. **Clear Logs**: Provide clear error messages
7. **Artifact Retention**: Keep artifacts for debugging
8. **Notification**: Notify on failures
9. **Documentation**: Document workflow changes
10. **Review Regularly**: Review and update workflows

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD](https://docs.flutter.dev/deployment/cd)
- [Fastlane CI/CD](https://docs.fastlane.tools/best-practices/continuous-integration/)

---

*This document is part of the reusable documentation. See [index.md](index.md) for more resources.*

