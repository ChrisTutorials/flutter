# Skill: Run Flutter App with Android Simulator

## Overview
This skill explains how to run the unit_converter Flutter app on an Android simulator/emulator.

## Prerequisites

### 1. Android Studio Installation
- Install Android Studio from https://developer.android.com/studio
- During installation, ensure you select:
  - Android SDK
  - Android SDK Platform-Tools
  - Android Virtual Device (AVD)

### 2. Flutter SDK Installation
- Install Flutter SDK from https://flutter.dev/docs/get-started/install
- Add Flutter to your PATH
- Run \lutter doctor\ to verify installation

### 3. Environment Setup
- Ensure JAVA_HOME is set correctly
- Ensure ANDROID_HOME or ANDROID_SDK_ROOT is set
- Accept Android SDK licenses: \lutter doctor --android-licenses\`n

## Methods to Run the App

### Method 1: Using Android Studio AVD Manager (Recommended)

#### Step 1: Create an Android Virtual Device
1. Open Android Studio
2. Go to Tools > Device Manager
3. Click the \+\ button to create a new device
4. Select a device model (e.g., Pixel 6 Pro)
5. Select a system image (API 33+ recommended)
6. If system image is not downloaded, click Download
7. Give the AVD a name and click Finish

#### Step 2: Start the Emulator
1. In Device Manager, click the Play button next to your AVD
2. Wait for the emulator to fully boot (Android home screen should appear)

#### Step 3: Run the Flutter App
`ash
# Navigate to the project directory
cd c:\dev\flutter\unit_converter

# Run the app on the connected emulator
flutter run

# Or specify the device if multiple are connected
flutter run -d <device-id>

# To see available devices
flutter devices
`


### Method 2: Using Command Line

#### Step 1: List Available Emulators
`ash
cd c:\dev\flutter\unit_converter
flutter emulators
`


#### Step 2: Launch an Emulator
`ash
# Launch a specific emulator by name
flutter emulators --launch <emulator-name>


# Or use the emulator command directly
emulator -avd <avd-name>
`


#### Step 3: Run the App
`ash
flutter run
`


### Method 3: Using VS Code

#### Step 1: Install Flutter Extension
1. Open VS Code
2. Install the Flutter extension from the Extensions marketplace
3. Reload VS Code

#### Step 2: Select Device
1. Click the device selector in the bottom status bar
2. Select an Android emulator from the list
3. If no emulator is running, click \Start Android Emulator\`n

#### Step 3: Run the App
1. Press \F5\ or click \Run > Start Debugging\`n2. Or press \Ctrl+F5\ to run without debugging
3. Or click the Play button in the top right corner


## Common Issues and Solutions

### Issue 1: No Devices Found
**Error**: \No devices found\`n
**Solution**:
1. Check if emulator is running: \db devices\`n2. Start an emulator: \lutter emulators --launch <name>\`n3. Verify Flutter recognizes devices: \lutter devices\`n
### Issue 2: Emulator Won't Start
**Error**: Emulator fails to boot or shows black screen

**Solution**:
1. Check if HAXM is installed and running (Intel Mac)
2. Enable virtualization in BIOS (Windows)
3. Try a different system image (x86_64 vs ARM64)
4. Increase RAM allocated to AVD in AVD settings

### Issue 3: Gradle Build Fails
**Error**: \Gradle build failed\`n
**Solution**:
1. Clean build: \lutter clean\`n2. Get dependencies: \lutter pub get\`n3. Try again: \lutter run\`n4. Check for Android SDK updates: \lutter doctor -v\`n
### Issue 4: License Not Accepted
**Error**: \License not accepted\`n
**Solution**:
`ash
flutter doctor --android-licenses
# Accept all licenses by typing 'y'
`


### Issue 5: Outdated Flutter Version
**Error**: \Your Flutter version is outdated\`n
**Solution**:
`ash
flutter upgrade
`


## Useful Commands

`ash
# Check Flutter installation status
flutter doctor

# List all available devices
flutter devices

# List all emulators
flutter emulators

# Launch specific emulator
flutter emulators --launch <name>

# Run app in debug mode
flutter run

# Run app in release mode
flutter run --release

# Run app in profile mode
flutter run --profile

# Hot reload (while app is running)
# Press 'r' in the terminal

# Hot restart (while app is running)
# Press 'R' in the terminal

# Stop the app
# Press 'q' in the terminal

# Clean build artifacts
flutter clean

# Get dependencies
flutter pub get

# Upgrade Flutter
flutter upgrade

`


## Performance Tips

1. **Use Profile Mode for Performance Testing**:
   - \lutter run --profile\`n   - More accurate performance metrics than debug mode

2. **Enable VM Service**:
   - \lutter run --profile --dart-define=dart.vm.product=false\`n   - Allows using DevTools in profile mode

3. **Reduce Emulator Resources**:
   - Lower RAM allocation in AVD settings
   - Use software rendering if GPU issues occur

4. **Use Cold Boot**:
   - \emulator -avd <name> -no-snapshot-load\`n   - Useful for testing app startup from scratch


## Testing the App

Once the app is running, you can:

1. Test unit conversions
2. Test currency conversion (requires internet)
3. Test custom units
4. Test theme switching
5. Test quick presets
6. Test recent conversions
7. Test search functionality
8. Test favorites

## Debugging

### Using Flutter DevTools
1. While app is running, open DevTools:
   \lutter pub global run devtools\`n2. Open browser to the URL shown
3. Inspect widgets, performance, and network requests

### Using Android Studio Debugger
1. Set breakpoints in code
2. Click the Debug button (bug icon)
3. Use the Debug panel to step through code

### Using VS Code Debugger
1. Set breakpoints by clicking in the gutter
2. Press F5 to start debugging
3. Use the Debug panel to inspect variables


## Related Skills

- Run Flutter app with iOS Simulator (macOS only)
- Run Flutter app on physical Android device
- Run Flutter app on web browser
- Run Flutter app on desktop (Windows, macOS, Linux)

## Additional Resources

- [Flutter Testing](https://flutter.dev/docs/testing)
- [Android Emulator Documentation](https://developer.android.com/studio/run/emulator)
- [Flutter Debugging](https://flutter.dev/docs/testing/debugging)
- [Flutter Performance](https://flutter.dev/docs/perf)

