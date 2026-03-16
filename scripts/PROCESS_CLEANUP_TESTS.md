# Process Cleanup Tests

This directory contains scripts and tests to ensure that Flutter builds and deployments clean up processes automatically, preventing zombie processes from accumulating.

## Overview

Zombie processes (dangling dart, flutter, ruby, or fastlane processes) can:
- Consume system resources
- Cause build failures
- Interfere with subsequent builds
- Lead to unpredictable behavior

This test suite ensures that all build and deployment operations properly clean up after themselves.

## Scripts

### test-process-cleanup.ps1

Comprehensive test suite that verifies process cleanup for common Flutter operations.

#### Usage

```powershell
# Run all tests
.\scripts\test-process-cleanup.ps1

# Run with detailed output
.\scripts\test-process-cleanup.ps1 -ShowDetails
```

#### What It Tests

The test suite verifies that the following operations clean up processes properly:

1. **Flutter Clean** - Ensures `flutter clean` doesn't leave zombie processes
2. **Flutter Pub Get** - Ensures `flutter pub get` doesn't leave zombie processes
3. **Flutter Build APK (Debug)** - Ensures `flutter build apk --debug` doesn't leave zombie processes
4. **Flutter Analyze** - Ensures `flutter analyze` doesn't leave zombie processes

#### How It Works

For each test:
1. Captures the current state of dart/flutter and ruby/fastlane processes
2. Runs the Flutter command
3. Waits 2 seconds for processes to clean up
4. Compares before/after process states
5. Reports success if no new processes remain

### deploy.ps1

The unified deployment script has been enhanced with automatic process cleanup:

- **Pre-deployment cleanup**: Cleans up any zombie processes before starting deployment
- **Post-deployment cleanup**: Ensures all processes are cleaned up after deployment
- **Error cleanup**: Cleans up processes even if deployment fails

## CI/CD Integration

The GitHub Actions workflow `.github/workflows/test-process-cleanup.yml` automatically runs process cleanup tests on every push and pull request.

### Workflow Steps

1. Checkout code
2. Setup Flutter
3. Run process cleanup tests
4. Test deployment script cleanup
5. Verify clean state
6. Report results

## Running Tests Locally

### Quick Test

```powershell
# Run the full test suite
cd c:\dev\flutter
.\scripts\test-process-cleanup.ps1
```

### Detailed Test

```powershell
# See detailed process information
.\scripts\test-process-cleanup.ps1 -ShowDetails
```

### Manual Process Check

```powershell
# Check for zombie dart/flutter processes
Get-Process | Where-Object {$_.ProcessName -like "*dart*" -or $_.ProcessName -like "*flutter*"}

# Check for zombie ruby/fastlane processes
Get-Process | Where-Object {$_.ProcessName -like "*ruby*" -or $_.ProcessName -like "*fastlane*"}

# Kill all zombie processes
Get-Process | Where-Object {$_.ProcessName -like "*dart*" -or $_.ProcessName -like "*flutter*"} | Stop-Process -Force
Get-Process | Where-Object {$_.ProcessName -like "*ruby*" -or $_.ProcessName -like "*fastlane*"} | Stop-Process -Force
```

## Adding New Tests

To add a new test to the test suite, edit `test-process-cleanup.ps1` and add a new test:

```powershell
# Test 5: Your New Test
$test5Passed = Test-ProcessCleanup -TestName "Your Test Name" -TestScript {
    Push-Location "c:\dev\flutter\unit_converter"
    try {
        # Your command here
        flutter your-command
    } finally {
        Pop-Location
    }
}
$allTestsPassed = $allTestsPassed -and $test5Passed
```

## Troubleshooting

### Tests Fail with Zombie Processes

If tests report zombie processes:

1. Check which processes are reported
2. Manually kill them:
   ```powershell
   Get-Process | Where-Object {$_.ProcessName -like "*dart*"} | Stop-Process -Force
   ```
3. Investigate why the command didn't clean up properly
4. Fix the underlying issue or report it to Flutter team

### Deployment Script Leaves Processes

If the deployment script leaves zombie processes:

1. Check if the cleanup function is being called (search for `Invoke-ProcessCleanup`)
2. Verify the cleanup logic in `deploy.ps1`
3. Check for exceptions that might bypass cleanup
4. Ensure cleanup runs in the `finally` block

### CI/CD Tests Fail

If CI/CD tests fail:

1. Check the GitHub Actions logs
2. Look for specific processes that weren't cleaned up
3. Reproduce locally with verbose mode
4. Check if the CI environment has different process behavior

## Best Practices

1. **Always run tests after changes** - Ensure new commands don't leave zombie processes
2. **Use the deployment script** - It has built-in cleanup
3. **Monitor for zombie processes** - Regularly check for dangling processes
4. **Report issues** - If Flutter commands leave processes, report to Flutter team
5. **Keep tests updated** - Add new commands to the test suite as they're introduced

## Related Documentation

- [Unified Deployment Workflow](../.windsurf/workflows/unified-deployment.md)
- [Deployment Scripts](../scripts/readme.md)
- [Deployment Documentation](../docs/DEPLOYMENT.md)

