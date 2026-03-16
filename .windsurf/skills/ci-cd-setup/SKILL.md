# Skill: CI/CD Setup

## 📋 Summary

Set up continuous integration and continuous deployment (CI/CD) pipelines for Flutter apps using GitHub Actions. This skill provides reusable patterns for testing, building, and deploying Flutter apps across Android, Windows, and iOS platforms.

## 🎯 When to Use

Use this skill when:
- Setting up CI/CD for a new Flutter app
- Adding new deployment targets to existing CI/CD
- Troubleshooting CI/CD issues
- Optimizing CI/CD performance
- Setting up automated testing

## 🚀 Quick Start

### Basic CI/CD Setup

1. **Create GitHub Actions workflow directory**:
   ```bash
   mkdir -p .github/workflows
   ```

2. **Create test workflow** (`.github/workflows/test.yml`):
   ```yaml
   name: Test

   on:
     push:
       branches: [ main, develop ]
     pull_request:
       branches: [ main, develop ]

   jobs:
     test:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: subosito/flutter-action@v2
           with:
             flutter-version: 'stable'
         - run: flutter pub get
         - run: flutter analyze
         - run: flutter test
   ```

3. **Create deployment workflow** (`.github/workflows/deploy.yml`):
   ```yaml
   name: Deploy

   on:
     push:
       tags:
         - 'v*'

   jobs:
     deploy-android:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: subosito/flutter-action@v2
           with:
             flutter-version: 'stable'
         - uses: ruby/setup-ruby@v1
           with:
             ruby-version: '3.0'
             bundler-cache: true
         - run: |
             cd unit_converter
             ../scripts/deploy.ps1 -Platform android -Track production -SkipConfirmation
   ```

## 📋 CI/CD Components

### 1. Test Workflow

Runs on every push and pull request to ensure code quality.

**Key Features**:
- Flutter analyze
- Unit tests
- Integration tests
- Process cleanup verification

**Template**: See [ci-cd-patterns.md](../../docs/deployment/ci-cd-patterns.md#workflow-1-test-and-process-cleanup)

### 2. Build Workflow

Builds artifacts for all platforms on tag push.

**Key Features**:
- Parallel builds for all platforms
- Artifact upload
- Build caching
- Error handling

**Template**: See [ci-cd-patterns.md](../../docs/deployment/ci-cd-patterns.md#workflow-2-build-all-platforms)

### 3. Deploy Workflow

Deploys to all stores on tag push.

**Key Features**:
- Platform-specific deployment
- Secret management
- Non-interactive mode
- Process cleanup

**Template**: See [ci-cd-patterns.md](../../docs/deployment/ci-cd-patterns.md#workflow-3-deploy-to-all-platforms)

### 4. Process Cleanup Workflow

Verifies no zombie processes after operations.

**Key Features**:
- Process cleanup tests
- Clean state verification
- Detailed logging

**Template**: See [ci-cd-patterns.md](../../docs/deployment/ci-cd-patterns.md#process-cleanup-in-cicd)

## 🔐 Secrets Management

### Required Secrets

#### Android
```bash
# Set Google Play service account
gh secret set GOOGLE_PLAY_JSON_KEY_FILE < google-play-service-account.json
```

#### Windows
```bash
gh secret set PARTNER_CENTER_CLIENT_ID
gh secret set PARTNER_CENTER_CLIENT_SECRET
gh secret set PARTNER_CENTER_TENANT_ID
gh secret set WINDOWS_CERTIFICATE_PATH
gh secret set WINDOWS_CERTIFICATE_PASSWORD
```

#### iOS
```bash
gh secret set APP_STORE_CONNECT_API_KEY_ID
gh secret set APP_STORE_CONNECT_API_ISSUER_ID
gh secret set APP_STORE_CONNECT_API_KEY_PATH
```

### Managing Secrets

```bash
# List secrets
gh secret list

# Update secret
gh secret set SECRET_NAME < secret_value.txt

# Delete secret
gh secret delete SECRET_NAME
```

## 🧪 Testing Integration

### Unit Tests in CI/CD

```yaml
- name: Run unit tests
  run: flutter test
```

### Integration Tests in CI/CD

```yaml
- name: Run integration tests
  run: flutter test integration_test
```

### Golden Screenshots in CI/CD

```yaml
- name: Generate golden screenshots
  run: flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens
```

### Coverage Reports

```yaml
- name: Generate coverage
  run: flutter test --coverage

- name: Upload coverage
  uses: codecov/codecov-action@v3
  with:
    files: coverage/lcov.info
```

## 🚀 Deployment Strategies

### Strategy 1: Progressive Deployment

Deploy to tracks in order: Internal → Alpha → Beta → Production

```yaml
deploy-internal:
  run: ./scripts/deploy.ps1 -Platform android -Track internal

deploy-alpha:
  needs: deploy-internal
  run: ./scripts/deploy.ps1 -Platform android -Track alpha

deploy-beta:
  needs: deploy-alpha
  run: ./scripts/deploy.ps1 -Platform android -Track beta

deploy-production:
  needs: deploy-beta
  run: ./scripts/deploy.ps1 -Platform android -Track production
```

### Strategy 2: Automated on Tag

Deploy automatically when a version tag is pushed.

```yaml
on:
  push:
    tags:
      - 'v*' # Matches v1.0.0, v2.1.3, etc.
```

### Strategy 3: Manual Approval

Require manual approval before production deployment.

```yaml
deploy-production:
  environment:
    name: production
    url: https://play.google.com/store/apps/details?id=com.example.app
```

## ⚡ Performance Optimization

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

Run jobs in parallel to speed up CI/CD:

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

## 📊 Monitoring and Debugging

### Enable Verbose Logging

```yaml
- name: Enable verbose logging
  run: |
    flutter doctor -v
    flutter --version
```

### Upload Build Logs on Failure

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

### Notification on Failure

```yaml
- name: Notify on failure
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: failure
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## 🔧 Troubleshooting

### Issue: Workflow Fails on Secrets

**Symptoms**: Workflow fails with "secret not found" error

**Solutions**:
```bash
# Check if secret exists
gh secret list

# Set secret
gh secret set SECRET_NAME < value.txt

# Verify secret is set correctly
gh secret list
```

### Issue: Build Timeout

**Symptoms**: Workflow times out during build

**Solutions**:
1. Add caching to speed up builds
2. Split build into multiple steps
3. Increase timeout in workflow
4. Optimize build process

### Issue: Deployment Fails

**Symptoms**: Deployment step fails

**Solutions**:
1. Check deployment logs
2. Verify credentials are correct
3. Test deployment locally first
4. Check store console for errors

## 📚 Cross-References

### Documentation
- [CI/CD Patterns](../../docs/deployment/ci-cd-patterns.md) - Complete CI/CD patterns and templates
- [Multi-Platform Deployment](../../docs/deployment/multi-platform-guide.md) - Deployment guide
- [Fastlane Patterns](../../docs/deployment/fastlane-patterns.md) - Fastlane configuration

### Scripts
- [deploy.ps1](../../scripts/deploy.ps1) - Unified deployment script
- [test-process-cleanup.ps1](../../scripts/test-process-cleanup.ps1) - Process cleanup tests

### Workflows
- [Test Process Cleanup](../../test-app/.github/workflows/test-process-cleanup.yml) - Example workflow
- [Deploy All Platforms](../../test-app/.github/workflows/deploy-all.yml) - Example workflow

### Related Skills
- [unified-deployment/](./unified-deployment/) - Multi-platform deployment
- [process-cleanup/](./process-cleanup/) - Process cleanup
- [fastlane-setup/](./fastlane-setup/) - Fastlane setup

## 🎯 AI Assistant Instructions

When this skill is invoked, the AI should:

1. **Assess the situation**:
   - Check if CI/CD already exists
   - Identify which components need setup
   - Determine which platforms need deployment

2. **Set up CI/CD**:
   - Create workflow files
   - Configure secrets
   - Set up caching
   - Configure notifications

3. **Test CI/CD**:
   - Trigger test workflow
   - Verify it runs successfully
   - Check logs for errors
   - Fix any issues

4. **Provide feedback**:
   - Report what was set up
   - Report any issues or warnings
   - Provide next steps for manual configuration

5. **Document setup**:
   - Update documentation
   - Add notes about configuration
   - Record any customizations

## 📝 Checklist

Before setting up CI/CD:
- [ ] Identify required platforms
- [ ] Determine deployment strategy
- [ ] Gather required secrets
- [ ] Review CI/CD patterns documentation

After setting up CI/CD:
- [ ] Test workflows locally
- [ ] Push test workflow
- [ ] Verify test workflow runs
- [ ] Configure secrets
- [ ] Test deployment workflow
- [ ] Verify deployment succeeds
- [ ] Set up notifications
- [ ] Document configuration

## 🔗 Related Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD](https://docs.flutter.dev/deployment/cd)
- [Fastlane CI/CD](https://docs.fastlane.tools/best-practices/continuous-integration/)

---

*This skill is part of the AI assistant toolkit. See [skills/readme.md](./readme.md) for all available skills.*

