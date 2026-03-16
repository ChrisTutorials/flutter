# test_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Building for Different Platforms

### Windows
```bash
flutter build windows
```
The executable will be located at `build\windows\x64\runner\Debug\test_app.exe` (debug) or `build\windows\x64\runner\Release\test_app.exe` (release).

### Android
Requires Android SDK to be installed. Set the `ANDROID_HOME` environment variable to your Android SDK path.

```bash
flutter build apk          # Build APK
flutter build appbundle    # Build App Bundle (for Play Store)
```

### iOS
Requires macOS and Xcode to build.

```bash
flutter build ios
```

## Running the App

### Windows
```bash
flutter run -d windows
```

### Android
```bash
flutter run -d <device_id>    # Run on connected Android device
flutter devices                # List available devices
```

### iOS
```bash
flutter run -d <device_id>    # Run on connected iOS device/simulator (macOS only)
```

## Testing

### Run all tests:
```bash
flutter test
```

### Run tests with coverage:
```bash
flutter test --coverage
```

### Test Coverage:
- **Overall Coverage**: 95%
- **Unit Tests**: 19 tests (Counter model)
- **Widget Tests**: 18 tests (UI components)
- **Integration Tests**: 1 test (Full user flow)
- **Total Tests**: 37 tests

See [COVERAGE.md](COVERAGE.md) for detailed coverage report.

