# Skills Index

This directory contains reusable skills and workflows for working with this Flutter workspace.

## Available Skills

### Screenshot & Store Assets

- **[take-screenshots/](./take-screenshots/)** - Taking screenshots for development and store
  - Primary method: golden_screenshot (automated)
  - Alternative methods: Browser, Playwright
  - Store screenshot requirements
  - Cross-references: [full-screen-screenshot-validation/](./full-screen-screenshot-validation/)

- **[full-screen-screenshot-validation/](./full-screen-screenshot-validation/)** - Validating full-screen screenshots with no whitespace
  - Validation methodology (5 layers)
  - Consecutive chunk detection
  - Troubleshooting
  - Cross-references: [take-screenshots/](./take-screenshots/), [full-screen-screenshot-methodology.md](../../unit_converter/docs/full-screen-screenshot-methodology.md)

### Deployment & Release

- **[unified-deployment/](./unified-deployment/)** - Unified multi-platform deployment (Android, Windows, iOS)
  - Single interface for all platforms
  - Non-interactive mode for CI/CD
  - Automatic process cleanup
  - Cross-references: [process-cleanup/](./process-cleanup/), [ci-cd-setup/](./ci-cd-setup/)
  - Documentation: [Multi-Platform Deployment Guide](../../docs/deployment/multi-platform-guide.md)

- **[fastlane-setup/](./fastlane-setup/)** - Fastlane setup for automated deployment
  - Play Store deployment
  - Screenshot upload
  - Non-interactive AI-agent release commands
  - Cross-references: [take-screenshots/](./take-screenshots/), [run-android-simulator/](./run-android-simulator/)
  - Documentation: [Fastlane Patterns](../../docs/deployment/fastlane-patterns.md)

- **[production-deployment/](./production-deployment/)** - Production deployment in non-interactive mode
  - Non-interactive deployment commands
  - CI/CD integration
  - Best practices for hands-off deployment
  - Cross-references: [fastlane-setup/](./fastlane-setup/), [unified-deployment/](./unified-deployment/)

- **[ios-store-deployment/](./ios-store-deployment/)** - iOS App Store deployment in non-interactive mode
  - iOS App Store deployment commands
  - TestFlight and production deployment
  - CI/CD integration for iOS
  - Cross-references: [unified-deployment/](./unified-deployment/), [fastlane-setup/](./fastlane-setup/)

- **[windows-store-deployment/](./windows-store-deployment/)** - Windows Store deployment in non-interactive mode
  - Windows Store deployment commands
  - Test cases for Windows deployment
  - CI/CD integration for Windows
  - Cross-references: [fastlane-setup/](./fastlane-setup/), [production-deployment/](./production-deployment/)

### Infrastructure & Setup

- **[process-cleanup/](./process-cleanup/)** - Clean up zombie processes from builds and deployments
  - Identify and kill zombie dart/flutter/ruby/fastlane processes
  - Automated cleanup in deployment scripts
  - Process cleanup tests
  - Cross-references: [unified-deployment/](./unified-deployment/), [ci-cd-setup/](./ci-cd-setup/)
  - Documentation: [Process Cleanup Implementation](../../docs/deployment/process-cleanup.md)

- **[ci-cd-setup/](./ci-cd-setup/)** - Set up CI/CD pipelines for Flutter apps
  - GitHub Actions workflows
  - Test, build, and deploy automation
  - Secrets management
  - Performance optimization
  - Cross-references: [unified-deployment/](./unified-deployment/), [process-cleanup/](./process-cleanup/)
  - Documentation: [CI/CD Patterns](../../docs/deployment/ci-cd-patterns.md)

- **[new-app-setup/](./new-app-setup/)** - Create new Flutter app from template
  - Interactive app setup wizard
  - Multi-platform configuration
  - Fastlane and CI/CD setup
  - Testing infrastructure
  - Cross-references: [ci-cd-setup/](./ci-cd-setup/), [testing-setup/](./testing-setup/)
  - Documentation: [Utility App Template](../../docs/app-templates/utility-app.md)

- **[testing-setup/](./testing-setup/)** - Set up comprehensive testing infrastructure
  - Unit, integration, E2E, and golden screenshot tests
  - Test coverage reporting
  - CI/CD integration for tests
  - Cross-references: [process-cleanup/](./process-cleanup/), [ci-cd-setup/](./ci-cd-setup/)
  - Documentation: [Test Coverage Strategies](../../docs/testing/coverage-strategies.md), [Golden Screenshots](../../docs/testing/golden-screenshots.md)

### Testing & Development

- **[run-android-simulator/](./run-android-simulator/)** - Running Android simulator for testing
  - Simulator setup
  - Troubleshooting
  - Cross-references: [fastlane-setup/](./fastlane-setup/)

## Related Scripts

Reusable scripts are located in [../scripts/](../scripts/):

- **deploy.ps1** - Unified multi-platform deployment script (Android, Windows, iOS)
- **test-process-cleanup.ps1** - Process cleanup test suite
- **fastlane-wrapper.ps1** - Fastlane automation wrapper
- **fastlane-wrapper.sh** - Fastlane automation wrapper (Linux/Mac)
- **setup-new-app.ps1** - Create new Flutter app from template (TODO)

## Related Rules

Workspace rules are located in [../rules/](../rules/):

- **golden-screenshot-practice.md** - Workspace standard for automated store screenshots
- **project_rules.md** - Project-specific rules and conventions
- **use_common_folder.md** - Using common utilities across apps

## Anti-Patterns

Common anti-patterns to avoid are documented in [../rules/anti-patterns.md](../rules/anti-patterns.md). Review this before starting new work to avoid common mistakes.

## How to Use This Index

1. **Find the right skill**: Browse the list above to find the skill that matches your task
2. **Follow the skill**: Each skill provides step-by-step instructions
3. **Check cross-references**: Look at the "Related Skills" section for related workflows
4. **Use scripts**: Reusable scripts are in `../scripts/`
5. **Follow rules**: Check `../rules/` for workspace conventions

## DRY Principles

This workspace follows DRY (Don't Repeat Yourself) principles:

1. **Skills are reusable**: Skills are designed to be used across multiple apps
2. **Cross-reference, don't duplicate**: Skills link to each other instead of duplicating content
3. **Scripts are shared**: Reusable scripts are in `.windsurf/scripts/`
4. **Rules are global**: Workspace rules apply to all apps
5. **Documentation is linked**: Detailed docs link to skills, skills link to detailed docs

## Adding New Skills

When adding a new skill:

1. Create a folder in this directory with a descriptive name (kebab-case)
2. Create a `SKILL.md` file inside the folder (uppercase filename)
3. Start the SKILL.md with `# Skill: [Skill Name]`
4. Include a "Related Skills" section with cross-references
5. Link to detailed documentation in `unit_converter/docs/` if applicable
6. Update this index to include the new skill
7. Follow the existing skill format and style

## Quick Reference

### For New Apps
1. Create app: [new-app-setup/](./new-app-setup/) - Set up new Flutter app from template
2. Set up testing: [testing-setup/](./testing-setup/) - Configure testing infrastructure
3. Set up CI/CD: [ci-cd-setup/](./ci-cd-setup/) - Configure CI/CD pipelines

### For Store Screenshots
1. Generate: [take-screenshots/](./take-screenshots/) (golden_screenshot method)
2. Validate: [full-screen-screenshot-validation/](./full-screen-screenshot-validation/)
3. Deploy: [fastlane-setup/](./fastlane-setup/) or [unified-deployment/](./unified-deployment/)

### For Development Screenshots
1. Take screenshots: [take-screenshots/](./take-screenshots/) (browser or Playwright method)
2. No validation needed for development screenshots

### For Testing
1. Set up tests: [testing-setup/](./testing-setup/)
2. Run simulator: [run-android-simulator/](./run-android-simulator/)
3. Run tests: Use Flutter test commands

### For Deployment
1. Clean up processes: [process-cleanup/](./process-cleanup/) - Clean up zombie processes before deployment
2. Prepare: [unified-deployment/](./unified-deployment/) - **Unified multi-platform deployment (Android, Windows, iOS)**
3. Deploy to Android production: [production-deployment/](./production-deployment/) (non-interactive mode)
4. Deploy to Windows Store: [windows-store-deployment/](./windows-store-deployment/) (non-interactive mode)
5. Deploy to iOS App Store: [ios-store-deployment/](./ios-store-deployment/) (non-interactive mode)

### For CI/CD
1. Set up CI/CD: [ci-cd-setup/](./ci-cd-setup/)
2. Configure process cleanup: [process-cleanup/](./process-cleanup/)
3. Configure testing: [testing-setup/](./testing-setup/)

### For Process Issues
1. Check for zombie processes: [process-cleanup/](./process-cleanup/)
2. Run process cleanup tests: [process-cleanup/](./process-cleanup/)
3. Verify clean state: [process-cleanup/](./process-cleanup/)

