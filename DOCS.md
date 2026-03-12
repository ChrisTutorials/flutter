# Flutter Workspace Documentation

This index provides quick access to all documentation in the Flutter workspace.

## 📚 Documentation Structure

### Rules (.windsurf/rules/)
Workspace rules and practices that should be followed across all projects.

- **[golden-screenshot-practice.md](.windsurf/rules/golden-screenshot-practice.md)** - Workspace standard for automated store screenshot generation
- **[project_rules.md](.windsurf/rules/project_rules.md)** - General project rules and guidelines
- **[use_common_folder.md](.windsurf/rules/use_common_folder.md)** - Guidelines for using the common folder

### Skills (.windsurf/skills/)
Specific skills and workflows for common tasks.

- **[take-screenshots.md](.windsurf/skills/take-screenshots.md)** - Screenshot workflows (golden_screenshot is primary method)
- **[fastlane-setup.md](.windsurf/skills/fastlane-setup.md)** - Fastlane setup and usage for automated deployment
- **[run-android-simulator](.windsurf/skills/run-android-simulator/)** - Android simulator setup and usage

### Project-Specific Documentation
Documentation specific to individual projects.

#### Unit Converter
- **[DEPLOYMENT_CHECKLIST.md](unit_converter/DEPLOYMENT_CHECKLIST.md)** - Play Store deployment checklist
- **[README.md](unit_converter/README.md)** - Unit converter app documentation

#### Common Package
- **[README.md](common/README.md)** - Common package documentation
- **[MIGRATION_GUIDE.md](common/MIGRATION_GUIDE.md)** - Migration guide for common package

#### Marketing
- **[README.md](marketing/README.md)** - Marketing documentation index

## 🚀 Quick Start Guides

### For New Developers

1. Read [project_rules.md](.windsurf/rules/project_rules.md) for general guidelines
2. Read [use_common_folder.md](.windsurf/rules/use_common_folder.md) for common package usage
3. Review the specific project's README.md

### For Store Deployment

1. Read [golden-screenshot-practice.md](.windsurf/rules/golden-screenshot-practice.md) for screenshot generation
2. Read [fastlane-setup.md](.windsurf/skills/fastlane-setup.md) for deployment automation
3. Follow the [DEPLOYMENT_CHECKLIST.md](unit_converter/DEPLOYMENT_CHECKLIST.md)

### For Screenshot Generation

1. Primary method: Use [golden_screenshot-practice.md](.windsurf/rules/golden-screenshot-practice.md)
2. Alternative methods: See [take-screenshots.md](.windsurf/skills/take-screenshots.md)

## 📋 Workspace Standards

### Code Standards
- Follow existing code style and conventions
- Keep files under 1000 lines maximum
- Avoid god classes
- Prefer composition over inheritance
- Ensure integration test coverage for cross-system integrations

### Deployment Standards
- Use Fastlane for all Play Store deployments
- Use golden_screenshot for store screenshot generation
- Run pre-deployment validation before every release
- Follow the deployment checklist for each release

### Testing Standards
- Write unit tests for all business logic
- Write integration tests for cross-system functionality
- Use golden_screenshot for visual regression testing
- Run tests before every commit

## 🔧 Common Workflows

### Deploy to Play Store
```bash
cd unit_converter/android
fastlane deploy_internal
```

### Generate Store Screenshots
```bash
cd unit_converter
flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens
```

### Run Pre-Deployment Checks
```bash
cd unit_converter/android
fastlane validate
```

### Complete Release Workflow
```bash
cd unit_converter/android
fastlane deploy_production
```

## 📖 Key Concepts

### golden_screenshot
Automated screenshot generation tool for Flutter apps. Provides:
- Automatic device frames
- Multi-device support
- Multi-language support
- Visual regression testing
- Fastlane integration

### Fastlane
Automation tool for mobile app deployment. Provides:
- Automated build processes
- Play Store integration
- Screenshot upload
- Metadata management
- Multi-track deployment

### Common Package
Shared utilities and services across all Flutter projects. Includes:
- Ad service
- Platform utilities
- Navigation helpers
- Theme controller
- Purchase service
- Number formatter

## 🎯 Best Practices

1. **Always use workspace standards** - Follow the rules and skills documented here
2. **Test before committing** - Run tests and validation before pushing
3. **Document changes** - Update documentation when you change workflows
4. **Use automation** - Leverage Fastlane and golden_screenshot
5. **Keep code clean** - Follow the project rules for code quality

## 🆘 Getting Help

If you need help:

1. Check the relevant skill or rule documentation
2. Review the project-specific README
3. Check the deployment checklist
4. Consult the additional resources in each document

## 📝 Updating Documentation

When updating documentation:

1. Keep it clear and concise
2. Include examples where helpful
3. Update the index if you add new documents
4. Use consistent formatting
5. Cross-reference related documents

---

**Last Updated:** March 12, 2026  
**Workspace Version:** 1.0.0
