# Flutter Workspace Documentation Index

Welcome to the Flutter workspace documentation. This index provides a comprehensive overview of all available documentation organized by topic.

## 📚 Documentation Structure

### 🚀 Getting Started
- [Quick Start Guide](getting-started/quickstart.md) - Get up and running quickly
- [Workspace Overview](getting-started/readme.md) - Overview of the workspace structure

### 📦 Deployment
- [Multi-Platform Deployment Guide](deployment/multi-platform-guide.md) - Unified deployment for Android, Windows, and iOS
- [Process Cleanup](deployment/process-cleanup.md) - Automatic process cleanup for builds and deployments
- [CI/CD Patterns](deployment/ci-cd-patterns.md) - CI/CD integration patterns (TODO)
- [Fastlane Patterns](deployment/fastlane-patterns.md) - Reusable Fastlane patterns (TODO)

### 🧪 Testing
- [Test Coverage Strategies](testing/coverage-strategies.md) - How to achieve good test coverage
- [Smoke Testing](testing/smoke-testing.md) - Smoke test patterns
- [Golden Screenshots](testing/golden-screenshots.md) - Golden screenshot testing
- [Golden Screenshot Audit](testing/golden-screenshot-audit.md) - Audit of golden screenshot implementation
- [Integration Tests](testing/integration-tests.md) - Integration test patterns (TODO)
- [E2E Tests](testing/e2e-tests.md) - End-to-end test patterns (TODO)

### 🔒 Security
- [Credential Management](security/credential-management.md) - Managing credentials securely
- [Release Credentials](security/release-credentials.md) - Setting up release credentials
- [Common Vulnerabilities](security/common-vulnerabilities.md) - Common security vulnerabilities and fixes
- [Signing Certificates](security/signing-certificates.md) - Code signing certificate management (TODO)

### 🏗️ Architecture
- [Flutter App Architecture](architecture/flutter-app-architecture.md) - Architecture patterns for Flutter apps
- [Service Layer Patterns](architecture/service-layer-patterns.md) - Service layer design patterns (TODO)
- [State Management Patterns](architecture/state-management-patterns.md) - State management patterns (TODO)

### 🏪 Store Deployment
- [AdMob Setup](store/admob-setup.md) - AdMob configuration and setup
- [Android Release Runbook](store/android-release-runbook.md) - Google Play Store release process
- [Google Cloud Credentials](store/google-cloud-credentials.md) - Google Cloud credential setup
- [Windows Deployment](store/windows-deployment.md) - Microsoft Store deployment (TODO)
- [iOS Deployment](store/ios-deployment.md) - App Store deployment (TODO)

### 🎨 App Templates
- [Utility App Template](app-templates/utility-app.md) - Template for utility apps (TODO)
- [Game App Template](app-templates/game-app.md) - Template for game apps (TODO)

## 📖 App-Specific Documentation

### Unit Converter
- [App Overview](../unit_converter/docs/readme.md) - Unit Converter app overview
- [Implementation Notes](../unit_converter/docs/IMPLEMENTATION_NOTES.md) - App-specific implementation notes
- [Feature Roadmap](../unit_converter/docs/FEATURE_ROADMAP.md) - Planned features (TODO)
- [Release Notes](../unit_converter/docs/RELEASE_NOTES.md) - Release history (TODO)

## 🔧 Scripts

### Deployment Scripts
- [deploy.ps1](../scripts/deploy.ps1) - Unified multi-platform deployment script
- [test-process-cleanup.ps1](../scripts/test-process-cleanup.ps1) - Process cleanup test suite

### Setup Scripts
- [setup-new-app.ps1](../scripts/setup-new-app.ps1) - Create new Flutter app from template (TODO)

## 📚 Common Code

The [common](../common/) folder contains reusable Flutter utilities and components.

- [Common Code README](../common/readme.md) - Overview of common utilities
- [Ad Service](../common/lib/ad_service.dart) - Ad integration service
- [Navigation Utils](../common/lib/navigation_utils.dart) - Navigation utilities
- [Platform Utils](../common/lib/platform_utils.dart) - Platform detection utilities

## 🤖 AI Skills

The [.windsurf/skills](../.windsurf/skills/) folder contains AI assistant skills for common tasks.

### Deployment Skills
- [Unified Deployment](../.windsurf/skills/unified-deployment/SKILL.md) - Multi-platform deployment
- [Fastlane Setup](../.windsurf/skills/fastlane-setup/SKILL.md) - Fastlane configuration
- [Production Deployment](../.windsurf/skills/production-deployment/SKILL.md) - Production deployment
- [iOS Store Deployment](../.windsurf/skills/ios-store-deployment/SKILL.md) - iOS deployment
- [Windows Store Deployment](../.windsurf/skills/windows-store-deployment/SKILL.md) - Windows deployment

### Infrastructure Skills
- [Process Cleanup](../.windsurf/skills/process-cleanup/SKILL.md) - Clean up zombie processes
- [CI/CD Setup](../.windsurf/skills/ci-cd-setup/SKILL.md) - Set up CI/CD pipelines
- [New App Setup](../.windsurf/skills/new-app-setup/SKILL.md) - Create new Flutter app
- [Testing Setup](../.windsurf/skills/testing-setup/SKILL.md) - Set up testing infrastructure

### Testing Skills
- [Run Android Simulator](../.windsurf/skills/run-android-simulator/SKILL.md) - Android simulator management
- [Take Screenshots](../.windsurf/skills/take-screenshots/SKILL.md) - Screenshot generation
- [Full Screen Screenshot Validation](../.windsurf/skills/full-screen-screenshot-validation/SKILL.md) - Screenshot validation

### Skills Documentation
- [Skills README](../.windsurf/skills/readme.md) - Complete skills index
- [AI Skills Refactoring Summary](ai-skills-refactoring-summary.md) - Skills refactoring details

## 📋 Workflows

The [.windsurf/workflows](../.windsurf/workflows/) folder contains workflow documentation.

- [Unified Deployment Workflow](../.windsurf/workflows/unified-deployment.md) - Multi-platform deployment workflow

## 🔄 Refactoring

- [DRY Refactoring Roadmap](DRY_REFACTORING.md) - Plan for DRYing up documentation and code

## 📝 Documentation Guidelines

### Principles
1. **DRY** - Don't Repeat Yourself
2. **Separation of Concerns** - Reusable vs App-Specific
3. **Clear Navigation** - Easy to find information
4. **Cross-References** - Link to related docs
5. **Up-to-Date** - Keep documentation current

### Writing Guidelines
1. Use clear, concise language
2. Include code examples
3. Provide step-by-step instructions
4. Add troubleshooting sections
5. Include diagrams where helpful
6. Cross-reference related documentation

### Maintenance
1. Review documentation quarterly
2. Update when processes change
3. Remove outdated information
4. Fix broken links
5. Add new patterns as they emerge

## 🚀 Quick Links

### For New Developers
1. Start with [Quick Start Guide](getting-started/quickstart.md)
2. Read [Workspace Overview](getting-started/readme.md)
3. Review [Flutter App Architecture](architecture/flutter-app-architecture.md)
4. Check [Deployment Guide](deployment/multi-platform-guide.md)

### For Deployment
1. Read [Multi-Platform Deployment Guide](deployment/multi-platform-guide.md)
2. Check [Process Cleanup](deployment/process-cleanup.md)
3. Review [Store Deployment](store/) for your platform
4. Run [Process Cleanup Tests](../scripts/test-process-cleanup.ps1)

### For Testing
1. Review [Test Coverage Strategies](testing/coverage-strategies.md)
2. Check [Golden Screenshots](testing/golden-screenshots.md)
3. Implement [Integration Tests](testing/integration-tests.md)
4. Run [Smoke Tests](testing/smoke-testing.md)

### For New Apps
1. Read [Utility App Template](app-templates/utility-app.md)
2. Use [setup-new-app.ps1](../scripts/setup-new-app.ps1)
3. Follow [Deployment Guide](deployment/multi-platform-guide.md)
4. Set up [CI/CD](deployment/ci-cd-patterns.md)

## 📞 Getting Help

If you need help:
1. Check the relevant documentation section
2. Review troubleshooting sections
3. Check the [FAQ](FAQ.md) (TODO)
4. Ask in team chat or create an issue

## 📈 Documentation Metrics

- **Total Documentation Files**: XX
- **Reusable Documentation**: XX
- **App-Specific Documentation**: XX
- **Last Updated**: [Date]
- **Next Review**: [Date]

---

*This index is maintained as part of the DRY refactoring effort. See [DRY_REFACTORING.md](DRY_REFACTORING.md) for more details.*

