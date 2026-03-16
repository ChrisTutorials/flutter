# Shared Flutter Release Tooling

This directory contains reusable tooling for building, validating, and deploying Flutter applications to app stores.

## Structure

```
release_tooling/
├── fastlane/
│   ├── Appfile.template          # Template for app-specific configuration
│   ├── Fastfile                  # Reusable Fastfile with parameterized paths
│   ├── metadata/
│   │   └── android/              # Store listing templates
│   └── scripts/                  # Shared utility scripts
├── ci/
│   ├── workflows/                # GitHub Actions workflows
│   └── scripts/                  # CI utility scripts
└── docs/
    └── usage.md                  # Documentation on how to use this tooling
```

## Usage

1. Copy the template files to your project:
   ```bash
   cp release_tooling/fastlane/Appfile.template your_project/android/fastlane/Appfile
   cp release_tooling/fastlane/Fastfile your_project/android/fastlane/Fastfile
   ```

2. Customize the Appfile with your app-specific values:
   - Package name
   - Service account configuration

3. Use the shared Fastfile which will automatically detect project structure

## Features

- **Project Structure Agnostic**: Automatically detects Flutter project root
- **Reusable Validation**: Comprehensive pre-deployment checks
- **Cross-platform Support**: Primarily Android focused but extensible
- **Well-tested**: Based on proven workflow from unit_converter app

## Customization

Each app can override specific behaviors by:
1. Creating local fastlane configurations that supplement the shared ones
2. Using environment variables to customize behavior
3. Creating app-specific lanes that call into the shared lanes

