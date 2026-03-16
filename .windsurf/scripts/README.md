# Scripts Directory

This directory contains reusable scripts that can be used across the Flutter workspace.

## Available Scripts

### Fastlane Wrapper

- **fastlane-wrapper.ps1** - PowerShell wrapper for Fastlane commands (Windows)
- **fastlane-wrapper.sh** - Bash wrapper for Fastlane commands (Linux/Mac)

These scripts provide a consistent interface for running Fastlane commands across different platforms and apps.

## How to Use Scripts

### Fastlane Wrapper

```powershell
# Windows
.\.windsurf\scripts\fastlane-wrapper.ps1 [fastlane-command]

# Example
.\.windsurf\scripts\fastlane-wrapper.ps1 upload_screenshots
```

```bash
# Linux/Mac
./.windsurf/scripts/fastlane-wrapper.sh [fastlane-command]

# Example
./.windsurf/scripts/fastlane-wrapper.sh upload_screenshots
```

## App-Specific Scripts

App-specific scripts are located in each app's `scripts/` directory:

- **unit_converter/scripts/** - Unit Converter app scripts
  - generate-store-screenshots.ps1 - Process and validate store screenshots
  - deploy-to-play-store.ps1 - Deploy to Play Store
  - pre-deployment-check.ps1 - Run pre-deployment checks

## Adding New Scripts

When adding a new reusable script:

1. Determine if the script is reusable across apps or app-specific
2. If reusable, add it to this directory (`.windsurf/scripts/`)
3. If app-specific, add it to the app's `scripts/` directory
4. Include usage instructions in this README
5. Make scripts executable on Linux/Mac: `chmod +x scriptname.sh`
6. Test scripts on all platforms (Windows, Linux, Mac) if cross-platform

## Script Conventions

1. **Use descriptive names**: Script names should clearly indicate what they do
2. **Include help text**: Scripts should have `-Help` or `-h` parameter that shows usage
3. **Handle errors**: Scripts should exit with appropriate error codes
4. **Be idempotent**: Scripts should be safe to run multiple times
5. **Log output**: Scripts should provide clear output about what they're doing
6. **Validate prerequisites**: Scripts should check for required tools and dependencies

## Related Skills

- **[../skills/fastlane-setup.md](../skills/fastlane-setup.md)** - Fastlane setup and usage
- **[../skills/take-screenshots.md](../skills/take-screenshots.md)** - Screenshot generation and validation

## Related Documentation

- **[../../unit_converter/docs/DEPLOYMENT.md](../../unit_converter/docs/DEPLOYMENT.md)** - Deployment documentation
- **[../../unit_converter/docs/play-store-release-runbook.md](../../unit_converter/docs/play-store-release-runbook.md)** - Play Store release process

