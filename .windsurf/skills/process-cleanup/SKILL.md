# Skill: Process Cleanup

## 📋 Summary

Clean up zombie processes (dangling dart, flutter, ruby, and fastlane processes) that accumulate during Flutter builds and deployments. This skill ensures system resources are freed and prevents build failures caused by process conflicts.

## 🎯 When to Use

Use this skill when:
- Flutter builds fail with process conflicts
- System is slow due to accumulated processes
- Before starting a new build
- After a build completes
- Before deployment
- As part of CI/CD pipeline

## 🚀 Quick Start

### Manual Process Cleanup

```powershell
# Check for zombie processes
Get-Process | Where-Object {$_.ProcessName -like "*dart*" -or $_.ProcessName -like "*flutter*"}

# Kill all zombie processes
Get-Process | Where-Object {$_.ProcessName -like "*dart*" -or $_.ProcessName -like "*flutter*"} | Stop-Process -Force

# Kill Ruby/Fastlane processes
Get-Process | Where-Object {$_.ProcessName -like "*ruby*" -or $_.ProcessName -like "*fastlane*"} | Stop-Process -Force
```

### Automated Process Cleanup

```powershell
# Run process cleanup tests
cd c:\dev\flutter
.\scripts\test-process-cleanup.ps1

# Run with detailed output
.\scripts\test-process-cleanup.ps1 -ShowDetails
```

### Cleanup in Deployment Script

The deployment script automatically cleans up processes before and after deployment:

```powershell
# Deployment script includes automatic cleanup
.\scripts\deploy.ps1 -Platform android -Track production -SkipConfirmation
```

## 🔍 Identifying Zombie Processes

### Check Process Age and Activity

```powershell
$currentTime = Get-Date
Get-Process | Where-Object {$_.ProcessName -like "*dart*"} | ForEach-Object {
    $age = ($currentTime - $_.StartTime).TotalMinutes
    [PSCustomObject]@{
        Id=$_.Id
        ProcessName=$_.ProcessName
        CPU=$_.CPU
        AgeMinutes=[math]::Round($age,2)
        CPUPerMinute=[math]::Round($_.CPU/$age,4)
    }
} | Where-Object {$_.AgeMinutes -gt 30} | Sort-Object AgeMinutes -Descending
```

### Identify Inactive Processes

Processes that are likely inactive:
- Running longer than 30 minutes
- CPU usage < 0.1 per minute
- Not responding to user input

## 🧪 Testing Process Cleanup

### Run Full Test Suite

```powershell
# Run all process cleanup tests
.\scripts\test-process-cleanup.ps1

# Run with detailed output
.\scripts\test-process-cleanup.ps1 -ShowDetails
```

### What the Tests Verify

The test suite verifies that:
- Flutter clean cleans up processes
- Flutter pub get cleans up processes
- Flutter build cleans up processes
- Flutter analyze cleans up processes

### Test Output Interpretation

```
✅ SUCCESS: All processes cleaned up properly
```
- No zombie processes were created by the operation

```
❌ FAILURE: Processes not cleaned up
```
- Zombie processes were found
- Check the output for process details
- Investigate why processes weren't cleaned up

## 🔧 Automatic Cleanup in Deployment

### Deployment Script Cleanup

The `deploy.ps1` script includes automatic cleanup at three points:

1. **Pre-deployment cleanup**: Before deployment starts
2. **Post-deployment cleanup**: After deployment completes
3. **Error cleanup**: Even if deployment fails

### Cleanup Function

```powershell
function Invoke-ProcessCleanup {
    Write-ColorOutput "[INFO] Cleaning up any zombie processes..." -Color Cyan

    # Clean up Dart processes
    $dartProcesses = Get-Process | Where-Object {$_.ProcessName -like "*dart*" -or $_.ProcessName -like "*flutter*"}
    if ($dartProcesses) {
        Write-ColorOutput "[INFO] Found $($dartProcesses.Count) Dart/Flutter processes to clean up" -Color Yellow
        $dartProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
        Write-ColorOutput "[SUCCESS] Cleaned up Dart/Flutter processes" -Color Green
    }

    # Clean up Ruby/Fastlane processes
    $rubyProcesses = Get-Process | Where-Object {$_.ProcessName -like "*ruby*" -or $_.ProcessName -like "*fastlane*"}
    if ($rubyProcesses) {
        Write-ColorOutput "[INFO] Found $($rubyProcesses.Count) Ruby/Fastlane processes to clean up" -Color Yellow
        $rubyProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
        Write-ColorOutput "[SUCCESS] Cleaned up Ruby/Fastlane processes" -Color Green
    }

    Write-ColorOutput "[SUCCESS] Process cleanup completed" -Color Green
}
```

## 🔄 CI/CD Integration

### GitHub Actions Workflow

```yaml
name: Test Process Cleanup

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test-process-cleanup:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Process Cleanup Tests
        shell: pwsh
        run: |
          cd c:\dev\flutter
          .\scripts\test-process-cleanup.ps1 -ShowDetails

      - name: Verify Clean State
        shell: pwsh
        run: |
          $processes = Get-Process | Where-Object {$_.ProcessName -like "*dart*"}
          if ($processes) {
            Write-Host "ERROR: Zombie processes found!"
            exit 1
          }
```

## 📊 Best Practices

### 1. Clean Up Regularly
- Run cleanup before starting builds
- Run cleanup after builds complete
- Run cleanup before deployment

### 2. Monitor Process Accumulation
- Check for zombie processes regularly
- Monitor system performance
- Set up automated cleanup in CI/CD

### 3. Test Cleanup
- Run process cleanup tests regularly
- Verify cleanup works for all operations
- Monitor CI/CD test results

### 4. Document Issues
- If cleanup fails, document why
- Report Flutter processes that don't clean up
- Track patterns in zombie processes

## 🔧 Troubleshooting

### Issue: Processes Won't Terminate

**Symptoms**: `Stop-Process` command fails or processes restart

**Solutions**:
```powershell
# Try with -Force flag
Stop-Process -Id <PID> -Force

# Try killing parent process
Get-Process -Id <PID> | Stop-Process -Force

# Use taskkill as fallback
taskkill /F /PID <PID>

# Reboot as last resort
Restart-Computer
```

### Issue: Tests Report Zombie Processes

**Symptoms**: Test suite reports zombie processes after operations

**Solutions**:
1. Check which processes are reported
2. Investigate why the command didn't clean up
3. Check if processes were present before the operation
4. Report issue to Flutter team if processes don't clean up

### Issue: Deployment Leaves Processes

**Symptoms**: Deployment completes but processes remain

**Solutions**:
1. Verify cleanup function is being called
2. Check for exceptions that bypass cleanup
3. Ensure cleanup runs in finally block
4. Check deployment script logs

## 📚 Cross-References

### Documentation
- [Process Cleanup Implementation](../../docs/deployment/process-cleanup.md) - Complete implementation details
- [Process Cleanup Tests](../../scripts/PROCESS_CLEANUP_TESTS.md) - Test suite documentation
- [Unified Deployment](./unified-deployment/) - Deployment with automatic cleanup

### Scripts
- [test-process-cleanup.ps1](../../scripts/test-process-cleanup.ps1) - Process cleanup test suite
- [deploy.ps1](../../scripts/deploy.ps1) - Deployment script with cleanup

### Workflows
- [Test Process Cleanup](../../test-app/.github/workflows/test-process-cleanup.yml) - CI/CD workflow

### Related Skills
- [unified-deployment/](./unified-deployment/) - Multi-platform deployment (includes cleanup)
- [fastlane-setup/](./fastlane-setup/) - Fastlane setup (may need cleanup)

## 🎯 AI Assistant Instructions

When this skill is invoked, the AI should:

1. **Assess the situation**:
   - Check if zombie processes exist
   - Identify which processes need cleanup
   - Determine if manual or automated cleanup is appropriate

2. **Execute cleanup**:
   - Use appropriate cleanup method
   - Verify cleanup completed successfully
   - Report any issues

3. **Provide feedback**:
   - Report how many processes were cleaned up
   - Report any errors or warnings
   - Suggest next steps if issues occurred

4. **Document findings**:
   - Log which processes were cleaned up
   - Note any patterns or issues
   - Update documentation if new patterns emerge

## 📝 Checklist

Before starting a build or deployment:
- [ ] Check for zombie processes
- [ ] Run cleanup if needed
- [ ] Verify system is clean
- [ ] Proceed with build/deployment

After a build or deployment:
- [ ] Run process cleanup tests
- [ ] Verify no zombie processes remain
- [ ] Document any issues
- [ ] Report failures

## 🔗 Related Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)
- [Process Management](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-process)

---

*This skill is part of the AI assistant toolkit. See [skills/readme.md](./readme.md) for all available skills.*

