# PowerShell test suite for deployment script functions
# Run with: powershell -ExecutionPolicy Bypass -File test\deployment_scripts_test.ps1

$ErrorActionPreference = "Stop"
$TestPassed = 0
$TestFailed = 0

function Test-LoadDotEnv {
    param([string]$TestName, [string]$Content, [hashtable]$ExpectedValues)

    Write-Host "Testing: $TestName" -ForegroundColor Cyan

    # Create a temporary .env file
    $tempEnvPath = Join-Path $env:TEMP "test_env_$([Guid]::NewGuid()).txt"
    $Content | Out-File -FilePath $tempEnvPath -Encoding utf8

    try {
        # Load the Load-DotEnv function from the deployment script
        $scriptPath = Join-Path $PSScriptRoot "..\scripts\deploy-to-play-store.ps1"
        if (-not (Test-Path $scriptPath)) {
            $scriptPath = Join-Path $PSScriptRoot "..\..\unit_converter\scripts\deploy-to-play-store.ps1"
        }

        if (-not (Test-Path $scriptPath)) {
            Write-Host "  [SKIP] Could not find deploy-to-play-store.ps1" -ForegroundColor Yellow
            return
        }

        # Extract and execute the Load-DotEnv function
        $scriptContent = Get-Content $scriptPath -Raw
        $functionMatch = [regex]::Match($scriptContent, "function Load-DotEnv \{[\s\S]*?\n\}")

        if (-not $functionMatch.Success) {
            Write-Host "  [FAIL] Could not extract Load-DotEnv function" -ForegroundColor Red
            $script:TestFailed++
            return
        }

        # Execute the function
        . ([scriptblock]::Create($functionMatch.Value))

        # Clear any existing environment variables
        foreach ($key in $ExpectedValues.Keys) {
            Remove-Item -Path "Env:$key" -ErrorAction SilentlyContinue
        }

        # Call the function
        Load-DotEnv -Path $tempEnvPath

        # Verify the values
        $allPassed = $true
        foreach ($key in $ExpectedValues.Keys) {
            $expectedValue = $ExpectedValues[$key]
            $actualValue = [Environment]::GetEnvironmentVariable($key, "Process")

            if ($actualValue -ne $expectedValue) {
                Write-Host "  [FAIL] ${key}: expected '$expectedValue', got '$actualValue'" -ForegroundColor Red
                $allPassed = $false
            }
        }

        if ($allPassed) {
            Write-Host "  [PASS] All values loaded correctly" -ForegroundColor Green
            $script:TestPassed++
        } else {
            $script:TestFailed++
        }
    } finally {
        # Cleanup
        Remove-Item -Path $tempEnvPath -ErrorAction SilentlyContinue
        foreach ($key in $ExpectedValues.Keys) {
            Remove-Item -Path "Env:$key" -ErrorAction SilentlyContinue
        }
    }
}

function Test-ResolveEnvironmentValue {
    param([string]$TestName, [string]$VarName, [string]$UserValue, [string]$MachineValue, [string]$ExpectedValue)

    Write-Host "Testing: $TestName" -ForegroundColor Cyan

    try {
        # Load the Resolve-EnvironmentValue function from the deployment script
        $scriptPath = Join-Path $PSScriptRoot "..\scripts\deploy-to-play-store.ps1"
        if (-not (Test-Path $scriptPath)) {
            $scriptPath = Join-Path $PSScriptRoot "..\..\unit_converter\scripts\deploy-to-play-store.ps1"
        }

        if (-not (Test-Path $scriptPath)) {
            Write-Host "  [SKIP] Could not find deploy-to-play-store.ps1" -ForegroundColor Yellow
            return
        }

        # Extract and execute the Resolve-EnvironmentValue function
        $scriptContent = Get-Content $scriptPath -Raw
        $functionMatch = [regex]::Match($scriptContent, "function Resolve-EnvironmentValue \{[\s\S]*?\n\}")

        if (-not $functionMatch.Success) {
            Write-Host "  [FAIL] Could not extract Resolve-EnvironmentValue function" -ForegroundColor Red
            $script:TestFailed++
            return
        }

        # Execute the function
        . ([scriptblock]::Create($functionMatch.Value))

        # Set up test environment
        Remove-Item -Path "Env:$VarName" -ErrorAction SilentlyContinue

        # Note: We can't easily test User and Machine scope without admin privileges,
        # so we'll just test Process scope for now
        [Environment]::SetEnvironmentVariable($VarName, $ExpectedValue, "Process")

        # Call the function
        $result = Resolve-EnvironmentValue -Name $VarName

        if ($result -eq $ExpectedValue) {
            Write-Host "  [PASS] Resolved to '$ExpectedValue'" -ForegroundColor Green
            $script:TestPassed++
        } else {
            Write-Host "  [FAIL] Expected '$ExpectedValue', got '$result'" -ForegroundColor Red
            $script:TestFailed++
        }
    } finally {
        # Cleanup
        Remove-Item -Path "Env:$VarName" -ErrorAction SilentlyContinue
    }
}

# Run tests
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment Script Function Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Load-DotEnv with simple key=value pairs
Test-LoadDotEnv -TestName "Load-DotEnv - Simple key=value pairs" -Content @"
KEY1=value1
KEY2=value2
"@ -ExpectedValues @{ KEY1 = "value1"; KEY2 = "value2" }

# Test 2: Load-DotEnv with quoted values
Test-LoadDotEnv -TestName "Load-DotEnv - Quoted values" -Content @"
KEY1="value with spaces"
KEY2='single quotes'
"@ -ExpectedValues @{ KEY1 = "value with spaces"; KEY2 = "single quotes" }

# Test 3: Load-DotEnv with comments
Test-LoadDotEnv -TestName "Load-DotEnv - Comments and empty lines" -Content @"
# This is a comment
KEY1=value1

# Another comment
KEY2=value2
"@ -ExpectedValues @{ KEY1 = "value1"; KEY2 = "value2" }

# Test 4: Load-DotEnv with whitespace
Test-LoadDotEnv -TestName "Load-DotEnv - Whitespace handling" -Content @"
KEY1  =  value1  
KEY2=value2
"@ -ExpectedValues @{ KEY1 = "value1"; KEY2 = "value2" }

# Test 5: Load-DotEnv with AdMob App ID
Test-LoadDotEnv -TestName "Load-DotEnv - AdMob App ID format" -Content @"
UNIT_CONVERTER_ADMOB_APP_ID=ca-app-pub-5684393858412931~5666527390
"@ -ExpectedValues @{ UNIT_CONVERTER_ADMOB_APP_ID = "ca-app-pub-5684393858412931~5666527390" }

# Test 6: Load-DotEnv with file paths
Test-LoadDotEnv -TestName "Load-DotEnv - File paths" -Content @"
GOOGLE_APPLICATION_CREDENTIALS=C:/Users/chris/.keys/key.json
GOOGLE_PLAY_JSON_KEY_FILE=C:/dev/flutter/unit_converter/android/fastlane/google-play-service-account.json
"@ -ExpectedValues @{
    GOOGLE_APPLICATION_CREDENTIALS = "C:/Users/chris/.keys/key.json"
    GOOGLE_PLAY_JSON_KEY_FILE = "C:/dev/flutter/unit_converter/android/fastlane/google-play-service-account.json"
}

# Test 7: Resolve-EnvironmentValue with process scope
Test-ResolveEnvironmentValue -TestName "Resolve-EnvironmentValue - Process scope" -VarName "TEST_VAR" -UserValue $null -MachineValue $null -ExpectedValue "test_value"

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Passed: $TestPassed" -ForegroundColor Green
Write-Host "Failed: $TestFailed" -ForegroundColor Red
Write-Host ""

if ($TestFailed -gt 0) {
    exit 1
} else {
    exit 0
}

