# Process Cleanup Test Script
# Tests that compiler builds and deployments clean up processes automatically

param(
    [Parameter(Mandatory=$false)]
    [switch]$ShowDetails = $false
)

# Set error action preference
$ErrorActionPreference = 'Stop'

# Color output functions
function Write-ColorOutput {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet('Cyan', 'Green', 'Yellow', 'Red', 'White')]
        [string]$Color = 'White'
    )
    
    Write-Host $Message -ForegroundColor $Color
}

function Get-DartProcesses {
    return Get-Process | Where-Object {$_.ProcessName -like "*dart*" -or $_.ProcessName -like "*flutter*"} | Select-Object Id, ProcessName, CPU, WorkingSet, StartTime
}

function Get-FastlaneProcesses {
    return Get-Process | Where-Object {$_.ProcessName -like "*ruby*" -or $_.ProcessName -like "*fastlane*"} | Select-Object Id, ProcessName, CPU, WorkingSet, StartTime
}

function Test-ProcessCleanup {
    param(
        [string]$TestName,
        [scriptblock]$TestScript,
        [bool]$ShowDetails = $false
    )
    
    Write-ColorOutput "`n========================================" -Color Cyan
    Write-ColorOutput "Test: $TestName" -Color Cyan
    Write-ColorOutput "========================================" -Color Cyan
    
    # Get initial processes
    $initialDartProcesses = Get-DartProcesses
    $initialFastlaneProcesses = Get-FastlaneProcesses
    
    if ($ShowDetails) {
        Write-ColorOutput "[INFO] Initial Dart processes:" -Color White
        $initialDartProcesses | Format-Table -AutoSize
        Write-ColorOutput "[INFO] Initial Fastlane processes:" -Color White
        $initialFastlaneProcesses | Format-Table -AutoSize
    } else {
        Write-ColorOutput "[INFO] Initial Dart processes: $($initialDartProcesses.Count)" -Color White
        Write-ColorOutput "[INFO] Initial Fastlane processes: $($initialFastlaneProcesses.Count)" -Color White
    }
    
    # Run the test script
    Write-ColorOutput "[INFO] Running test..." -Color Cyan
    try {
        & $TestScript
    } catch {
        Write-ColorOutput "[ERROR] Test failed with exception: $_" -Color Red
    }
    
    # Wait a moment for processes to clean up
    Start-Sleep -Seconds 2
    
    # Get final processes
    $finalDartProcesses = Get-DartProcesses
    $finalFastlaneProcesses = Get-FastlaneProcesses
    
    if ($ShowDetails) {
        Write-ColorOutput "[INFO] Final Dart processes:" -Color White
        $finalDartProcesses | Format-Table -AutoSize
        Write-ColorOutput "[INFO] Final Fastlane processes:" -Color White
        $finalFastlaneProcesses | Format-Table -AutoSize
    } else {
        Write-ColorOutput "[INFO] Final Dart processes: $($finalDartProcesses.Count)" -Color White
        Write-ColorOutput "[INFO] Final Fastlane processes: $($finalFastlaneProcesses.Count)" -Color White
    }
    
    # Check if processes were cleaned up
    # Allow some processes to remain if they were present before
    $newDartProcesses = @()
    foreach ($process in $finalDartProcesses) {
        $wasPresentBefore = $initialDartProcesses | Where-Object {$_.Id -eq $process.Id}
        if (-not $wasPresentBefore) {
            $newDartProcesses += $process
        }
    }
    
    $newFastlaneProcesses = @()
    foreach ($process in $finalFastlaneProcesses) {
        $wasPresentBefore = $initialFastlaneProcesses | Where-Object {$_.Id -eq $process.Id}
        if (-not $wasPresentBefore) {
            $newFastlaneProcesses += $process
        }
    }
    
    $success = ($newDartProcesses.Count -eq 0) -and ($newFastlaneProcesses.Count -eq 0)
    
    if ($success) {
        Write-ColorOutput "[SUCCESS] All processes cleaned up properly" -Color Green
        return $true
    } else {
        Write-ColorOutput "[FAILURE] Processes not cleaned up:" -Color Red
        if ($newDartProcesses.Count -gt 0) {
            Write-ColorOutput "  New Dart processes:" -Color Red
            $newDartProcesses | Format-Table -AutoSize
        }
        if ($newFastlaneProcesses.Count -gt 0) {
            Write-ColorOutput "  New Fastlane processes:" -Color Red
            $newFastlaneProcesses | Format-Table -AutoSize
        }
        return $false
    }
}

# Main execution
Write-ColorOutput "========================================" -Color Cyan
Write-ColorOutput "Process Cleanup Test Suite" -Color Cyan
Write-ColorOutput "========================================" -Color Cyan

$allTestsPassed = $true

# Test 1: Flutter clean
$test1Passed = Test-ProcessCleanup -TestName "Flutter Clean" -TestScript {
    Push-Location "c:\dev\flutter\unit_converter"
    try {
        flutter clean
    } finally {
        Pop-Location
    }
} -ShowDetails $ShowDetails
$allTestsPassed = $allTestsPassed -and $test1Passed

# Test 2: Flutter pub get
$test2Passed = Test-ProcessCleanup -TestName "Flutter Pub Get" -TestScript {
    Push-Location "c:\dev\flutter\unit_converter"
    try {
        flutter pub get
    } finally {
        Pop-Location
    }
} -ShowDetails $ShowDetails
$allTestsPassed = $allTestsPassed -and $test2Passed

# Test 3: Flutter build apk (debug - faster)
$test3Passed = Test-ProcessCleanup -TestName "Flutter Build APK (Debug)" -TestScript {
    Push-Location "c:\dev\flutter\unit_converter"
    try {
        flutter build apk --debug
    } finally {
        Pop-Location
    }
} -ShowDetails $ShowDetails
$allTestsPassed = $allTestsPassed -and $test3Passed

# Test 4: Flutter analyze
$test4Passed = Test-ProcessCleanup -TestName "Flutter Analyze" -TestScript {
    Push-Location "c:\dev\flutter\unit_converter"
    try {
        flutter analyze
    } finally {
        Pop-Location
    }
} -ShowDetails $ShowDetails
$allTestsPassed = $allTestsPassed -and $test4Passed

# Summary
Write-ColorOutput "`n========================================" -Color Cyan
Write-ColorOutput "Test Summary" -Color Cyan
Write-ColorOutput "========================================" -Color Cyan

if ($allTestsPassed) {
    Write-ColorOutput "[SUCCESS] All process cleanup tests passed!" -Color Green
    exit 0
} else {
    Write-ColorOutput "[FAILURE] Some process cleanup tests failed" -Color Red
    exit 1
}

