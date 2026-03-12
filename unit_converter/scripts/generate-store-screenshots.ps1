# Automated Store Screenshot Generation Script
# This script generates store screenshots using golden_screenshot and copies them to the marketing directory

param(
    [Parameter(Mandatory=$false)]
    [switch]$UpdateGolden = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$CopyToMarketing = $true,
    
    [Parameter(Mandatory=$false)]
    [switch]$UploadToPlayStore = $false
)

$ErrorActionPreference = "Stop"

# Colors
$Green = [ConsoleColor]::Green
$Red = [ConsoleColor]::Red
$Yellow = [ConsoleColor]::Yellow
$Cyan = [ConsoleColor]::Cyan

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor $Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor $Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor $Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor $Cyan
}

# Check if we're in the correct directory
if (-not (Test-Path "pubspec.yaml")) {
    Write-Error "Must be run from Flutter project root (pubspec.yaml not found)"
    exit 1
}

Write-Info "Starting automated store screenshot generation..."
Write-Host ""

# Step 1: Check if golden_screenshot is installed
Write-Info "Checking for golden_screenshot..."
$pubspec = Get-Content "pubspec.yaml" -Raw
if (-not ($pubspec -match "golden_screenshot")) {
    Write-Error "golden_screenshot not found in pubspec.yaml"
    Write-Info "Add it to dev_dependencies: golden_screenshot: ^2.0.0"
    exit 1
}
Write-Success "golden_screenshot is installed"
Write-Host ""

# Step 2: Run screenshot tests
Write-Info "Generating screenshots..."
$testFile = "test/golden_screenshots/store_screenshots_test.dart"
if (-not (Test-Path $testFile)) {
    Write-Error "Screenshot test file not found: $testFile"
    exit 1
}

$testCommand = "flutter test $testFile"
if ($UpdateGolden) {
    $testCommand += " --update-goldens"
}

Write-Info "Running: $testCommand"
$result = Invoke-Expression $testCommand

if ($LASTEXITCODE -ne 0) {
    Write-Error "Screenshot generation failed"
    exit 1
}

Write-Success "Screenshots generated successfully"
Write-Host ""

# Step 3: Copy screenshots to marketing directory
if ($CopyToMarketing) {
    Write-Info "Copying screenshots to marketing directory..."
    
    $goldenDir = "test/golden_screenshots/golden"
    $marketingDir = "marketing/unit_converter/screenshots/store_screenshots"
    
    # Create marketing directory if it doesn't exist
    if (-not (Test-Path $marketingDir)) {
        New-Item -ItemType Directory -Path $marketingDir -Force | Out-Null
        Write-Info "Created marketing directory: $marketingDir"
    }
    
    # Copy screenshots
    $screenshots = Get-ChildItem -Path $goldenDir -Filter "*.png"
    $copiedCount = 0
    
    foreach ($screenshot in $screenshots) {
        $destination = Join-Path $marketingDir $screenshot.Name
        Copy-Item -Path $screenshot.FullName -Destination $destination -Force
        $copiedCount++
    }
    
    Write-Success "Copied $copiedCount screenshots to $marketingDir"
    Write-Host ""
}

# Step 4: Upload to Play Store (optional)
if ($UploadToPlayStore) {
    Write-Info "Uploading screenshots to Play Store..."
    
    # Check if Fastlane is available
    try {
        $fastlaneVersion = fastlane --version 2>&1 | Select-Object -First 1
        Write-Info "Fastlane found: $fastlaneVersion"
    } catch {
        Write-Error "Fastlane not found. Install it with: gem install fastlane"
        exit 1
    }
    
    # Run Fastlane upload
    Push-Location android
    try {
        fastlane upload_screenshots
        Write-Success "Screenshots uploaded to Play Store"
    } catch {
        Write-Error "Failed to upload screenshots to Play Store"
        exit 1
    } finally {
        Pop-Location
    }
    Write-Host ""
}

# Summary
Write-Host "=========================================" -ForegroundColor $Cyan
Write-Success "Screenshot generation completed!"
Write-Host "=========================================" -ForegroundColor $Cyan
Write-Host ""

if ($CopyToMarketing) {
    Write-Info "Screenshots location: marketing/unit_converter/screenshots/store_screenshots"
}

Write-Info "Next steps:"
Write-Host "1. Review the generated screenshots" -ForegroundColor White
Write-Host "2. Make any necessary adjustments" -ForegroundColor White
Write-Host "3. Commit the screenshots to version control" -ForegroundColor White

if ($UploadToPlayStore) {
    Write-Host "4. Screenshots are already uploaded to Play Store" -ForegroundColor White
} else {
    Write-Host "4. Upload to Play Store: cd android && fastlane upload_screenshots" -ForegroundColor White
}

Write-Host ""
