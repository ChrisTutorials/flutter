# Flutter Workspace Documentation

Central index for all Flutter workspace documentation.

## 📚 Documentation Structure

### Rules (.windsurf/rules/)
Workspace rules and practices for all projects.

- **[golden-screenshot-practice.md](.windsurf/rules/golden-screenshot-practice.md)** - Store screenshot automation standard
- **[project_rules.md](.windsurf/rules/project_rules.md)** - General project guidelines
- **[use_common_folder.md](.windsurf/rules/use_common_folder.md)** - Common package usage

### Skills (.windsurf/skills/)
Specific workflows and how-to guides.

- **[fastlane-setup.md](.windsurf/skills/fastlane-setup.md)** - Play Store deployment automation
- **[take-screenshots.md](.windsurf/skills/take-screenshots.md)** - Screenshot generation workflows
- **[run-android-simulator](.windsurf/skills/run-android-simulator/)** - Android simulator setup

### API Documentation (docs/)
Detailed API references and technical documentation.

- **[GOLDEN_SCREENSHOT_API.md](docs/GOLDEN_SCREENSHOT_API.md)** - Complete Golden Screenshot API reference
- **[GOLDEN_SCREENSHOT_API_AUDIT.md](docs/GOLDEN_SCREENSHOT_API_AUDIT.md)** - Runtime code audit for API adherence

### Project Documentation
Project-specific documentation.

#### Unit Converter
- **[DEPLOYMENT_CHECKLIST.md](unit_converter/DEPLOYMENT_CHECKLIST.md)** - Play Store deployment checklist
- **[README.md](unit_converter/README.md)** - App documentation
- **[ANDROID_BUILD_OPTIMIZATION.md](unit_converter/docs/ANDROID_BUILD_OPTIMIZATION.md)** - Android build performance settings

#### Common Package
- **[README.md](common/README.md)** - Common package documentation
- **[MIGRATION_GUIDE.md](common/MIGRATION_GUIDE.md)** - Migration guide

#### Marketing
- **[README.md](marketing/README.md)** - Marketing documentation index

## 🚀 Quick Start

### New Developers
1. Read [project_rules.md](.windsurf/rules/project_rules.md)
2. Read [use_common_folder.md](.windsurf/rules/use_common_folder.md)
3. Review project-specific README

### Store Deployment
1. Read [golden-screenshot-practice.md](.windsurf/rules/golden-screenshot-practice.md)
2. Read [fastlane-setup.md](.windsurf/skills/fastlane-setup.md)
3. Follow [DEPLOYMENT_CHECKLIST.md](unit_converter/DEPLOYMENT_CHECKLIST.md)

### Screenshot Generation
1. API Reference: [GOLDEN_SCREENSHOT_API.md](docs/GOLDEN_SCREENSHOT_API.md)
2. Best Practices: [golden-screenshot-practice.md](.windsurf/rules/golden-screenshot-practice.md)
3. Alternative Methods: [take-screenshots.md](.windsurf/skills/take-screenshots.md)

## � Common Commands

### Fastlane (from project android directory)
```bash
cd unit_converter/android
fastlane validate              # Pre-deployment checks
fastlane generate_screenshots # Generate store screenshots
fastlane deploy_internal      # Deploy to internal testing
fastlane deploy_production    # Deploy to production
```

### golden_screenshot
```bash
cd unit_converter
flutter test test/golden_screenshots/store_screenshots_test.dart --update-goldens
```

### Using Wrapper Scripts (from anywhere)
```bash
# Windows
.\.windsurf\scripts\fastlane-wrapper.ps1 validate

# Linux/Mac
./.windsurf/scripts/fastlane-wrapper.sh validate
```

## 🎯 Workspace Standards

| Standard | Purpose | Documentation |
|----------|---------|---------------|
| golden_screenshot | Store screenshots | [GOLDEN_SCREENSHOT_API.md](docs/GOLDEN_SCREENSHOT_API.md), [golden-screenshot-practice.md](.windsurf/rules/golden-screenshot-practice.md) |
| Fastlane | Play Store deployment | [fastlane-setup.md](.windsurf/skills/fastlane-setup.md) |
| Pre-deployment testing | Validation | Built into Fastlane |
| Common package | Shared utilities | [use_common_folder.md](.windsurf/rules/use_common_folder.md) |

## 📝 Maintaining Documentation

- Keep documentation concise and focused
- Cross-reference related documents
- Update index when adding new docs
- Use consistent formatting
- Remove duplication

## 🆘 Getting Help

1. Check relevant skill or rule documentation
2. Review project-specific README
3. Check deployment checklist
4. Consult additional resources in each document

---

**Last Updated:** March 12, 2026
