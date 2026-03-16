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
  - Cross-references: [take-screenshots/](./take-screenshots/), [FULL_SCREEN_SCREENSHOT_METHODOLOGY.md](../../unit_converter/docs/FULL_SCREEN_SCREENSHOT_METHODOLOGY.md)

### Deployment & Release

- **[fastlane-setup/](./fastlane-setup/)** - Fastlane setup for automated deployment
  - Play Store deployment
  - Screenshot upload
  - Cross-references: [take-screenshots/](./take-screenshots/), [run-android-simulator/](./run-android-simulator/)

### Testing & Development

- **[run-android-simulator/](./run-android-simulator/)** - Running Android simulator for testing
  - Simulator setup
  - Troubleshooting
  - Cross-references: [fastlane-setup/](./fastlane-setup/)

## Related Scripts

Reusable scripts are located in [../scripts/](../scripts/):

- **fastlane-wrapper.ps1** - Fastlane automation wrapper
- **fastlane-wrapper.sh** - Fastlane automation wrapper (Linux/Mac)

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

### For Store Screenshots
1. Generate: [take-screenshots/](./take-screenshots/) (golden_screenshot method)
2. Validate: [full-screen-screenshot-validation/](./full-screen-screenshot-validation/)
3. Deploy: [fastlane-setup/](./fastlane-setup/)

### For Development Screenshots
1. Take screenshots: [take-screenshots/](./take-screenshots/) (browser or Playwright method)
2. No validation needed for development screenshots

### For Testing
1. Run simulator: [run-android-simulator/](./run-android-simulator/)
2. Run tests: Use Flutter test commands

### For Deployment
1. Prepare: [fastlane-setup/](./fastlane-setup/)
2. Deploy: Use Fastlane commands
