# Flutter Workspace

This is a monorepo containing multiple Flutter projects and shared code.

## Projects

### [common/](common/)
Shared library containing reusable components and utilities used across multiple Flutter apps.

### [unit_converter/](unit_converter/)
A Flutter application for converting between different units of measurement.

### [test-app/](test-app/)
A test application used for integration testing across the workspace.

### [marketing/](marketing/)
Marketing materials and assets for the applications.

## Development

### Prerequisites
- Flutter SDK
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

### Running Projects
Navigate to a project directory and run:
```bash
flutter run
```

### Build Performance

All Android projects in this workspace are configured with optimized build settings that provide 30-50% faster clean builds and 90%+ faster incremental builds. See [unit_converter/docs/ANDROID_BUILD_OPTIMIZATION.md](unit_converter/docs/ANDROID_BUILD_OPTIMIZATION.md) for details.

## Common Folder

The `common/` folder contains shared code used across multiple projects. See [common/README.md](common/README.md) for more details.

## Documentation

- [Workspace Setup](WORKSPACE_SETUP_SUMMARY.md)
- [Project Rules](.windsurf/rules/project_rules.md)

## License

This project is not open source.
