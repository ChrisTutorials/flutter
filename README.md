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

All Android projects in this workspace are configured with optimized build settings that provide 30-50% faster clean builds and 90%+ faster incremental builds. See [unit_converter/docs/android-build-optimization.md](unit_converter/docs/android-build-optimization.md) for details.

## Common Folder

The `common/` folder contains shared code used across multiple projects. See [common/readme.md](common/readme.md) for more details.

## Deployment

The workspace includes a **unified deployment workflow** that supports Android, Windows, and iOS platforms:

```powershell
# Deploy to Android
cd unit_converter
..\scripts\deploy.ps1 -Platform android -Track production -ReleaseNotes "New features" -SkipConfirmation

# Deploy to Windows
..\scripts\deploy.ps1 -Platform windows -Track retail -ReleaseNotes "Windows release" -SkipConfirmation

# Deploy to iOS (macOS only)
../scripts/deploy.ps1 -Platform ios -Track production -ReleaseNotes "App Store release" -SkipConfirmation
```

For complete deployment documentation, see:
- [docs/UNIFIED_DEPLOYMENT.md](docs/UNIFIED_DEPLOYMENT.md) - Unified multi-platform deployment guide
- [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) - Android deployment guide
- [scripts/readme.md](scripts/readme.md) - Deployment scripts documentation

## Documentation

- [Workspace Setup](WORKSPACE_SETUP_SUMMARY.md)
- [Project Rules](.windsurf/rules/project_rules.md)

## License

This project is not open source.

