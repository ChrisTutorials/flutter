# Deterministic Store Screenshot Preparation Script
# This script processes the committed raw screenshots, validates the shared
# screenshot tooling, and synchronizes the Play Store metadata image folders.

param(
    [Parameter(Mandatory=$false)]
    [switch]$ValidateOnly = $false,

    [Parameter(Mandatory=$false)]
    [switch]$UploadToPlayStore = $false,

    [Parameter(Mandatory=$false)]
    [string]$DeviceId = "emulator-5554"
)

$ErrorActionPreference = "Stop"
$TestTimeout = "3s"

function Load-DotEnv {
    param([Parameter(Mandatory=$true)][string]$Path)

    if (-not (Test-Path $Path)) {
        return
    }

    foreach ($line in Get-Content $Path) {
        $trimmed = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith('#')) {
            continue
        }

        $separatorIndex = $trimmed.IndexOf('=')
        if ($separatorIndex -lt 1) {
            continue
        }

        $name = $trimmed.Substring(0, $separatorIndex).Trim()
        $value = $trimmed.Substring($separatorIndex + 1).Trim()

        if (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'"))) {
            $value = $value.Substring(1, $value.Length - 2)
        }

        Set-Item -Path "Env:$name" -Value $value
    }
}

# Colors
$Green = [ConsoleColor]::Green
$Red = [ConsoleColor]::Red
$Yellow = [ConsoleColor]::Yellow
$Cyan = [ConsoleColor]::Cyan

function Write-Success {
    param([string]$Message)
    Write-Host "[PASS] $Message" -ForegroundColor $Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "[FAIL] $Message" -ForegroundColor $Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor $Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Cyan
}

function Invoke-Step {
    param(
        [string]$Command,
        [string]$WorkingDirectory
    )

    Push-Location $WorkingDirectory
    try {
        Write-Info "Running: $Command"
        Invoke-Expression $Command
        if ($LASTEXITCODE -ne 0) {
            throw "Command failed with exit code $LASTEXITCODE"
        }
    } finally {
        Pop-Location
    }
}

function Sync-PlayStoreMetadataImages {
    param(
        [string]$StoreScreenshotDir,
        [string]$GraphicsDir,
        [string]$MetadataRoot
    )

    $localeImagesDir = Join-Path $MetadataRoot "en-US\images"
    $sharedImagesDir = Join-Path $MetadataRoot "images"
    $phoneDir = Join-Path $localeImagesDir "phoneScreenshots"
    $sevenInchDir = Join-Path $localeImagesDir "sevenInchScreenshots"
    $tenInchDir = Join-Path $localeImagesDir "tenInchScreenshots"

    foreach ($directory in @($phoneDir, $sevenInchDir, $tenInchDir, $sharedImagesDir)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
        Get-ChildItem -Path $directory -File -ErrorAction SilentlyContinue | Remove-Item -Force
    }

    $screenshots = Get-ChildItem -Path $StoreScreenshotDir -Filter "*.png" | Sort-Object Name
    if ($screenshots.Count -eq 0) {
        throw "No processed screenshots found in $StoreScreenshotDir"
    }

    foreach ($screenshot in $screenshots) {
        $destinationDir = if ($screenshot.Name.StartsWith("phone_")) {
            $phoneDir
        } elseif ($screenshot.Name.StartsWith("tablet7_")) {
            $sevenInchDir
        } elseif ($screenshot.Name.StartsWith("tablet10_")) {
            $tenInchDir
        } else {
            throw "Unrecognized screenshot naming pattern: $($screenshot.Name)"
        }

        Copy-Item -Path $screenshot.FullName -Destination (Join-Path $destinationDir $screenshot.Name) -Force
    }

    Copy-Item -Path (Join-Path $GraphicsDir "unit-converter-logo.png") -Destination (Join-Path $sharedImagesDir "icon.png") -Force
    Copy-Item -Path (Join-Path $GraphicsDir "feature-graphic-unit-converter.png") -Destination (Join-Path $sharedImagesDir "featureGraphic.png") -Force
}

# Check if we're in the correct directory
if (-not (Test-Path "pubspec.yaml")) {
    Write-Error "Must be run from Flutter project root (pubspec.yaml not found)"
    exit 1
}

Load-DotEnv -Path (Join-Path (Resolve-Path '.') '.env')

Write-Info "Starting deterministic store screenshot preparation..."
Write-Host ""

$workspaceRoot = Resolve-Path ".."
$toolRoot = Join-Path $workspaceRoot "marketing\tools\store_screenshots"
$marketingRoot = Join-Path $workspaceRoot "marketing\unit_converter"
$specPath = Join-Path $marketingRoot "screenshots\store_screenshot_spec.json"
$processedScreenshotDir = Join-Path $marketingRoot "screenshots\store_screenshots"
$rawScreenshotDir = Join-Path $marketingRoot "screenshots\raw_store_screenshots"
$graphicsDir = Join-Path $marketingRoot "graphics"
$metadataRoot = Join-Path $PWD "android\fastlane\metadata\android"
$generationTargetPath = "integration_test/store_screenshots_generation_integration_test.dart"
$generationDriverPath = "test_driver/store_screenshots_generation_integration_test.dart"
$validationTestPath = "test/integration/store_screenshots_validation_test.dart"

foreach ($requiredPath in @($toolRoot, $specPath, $processedScreenshotDir, $rawScreenshotDir, $graphicsDir)) {
    if (-not (Test-Path $requiredPath)) {
        Write-Error "Required path not found: $requiredPath"
        exit 1
    }
}

$relativeSpecPath = "../../unit_converter/screenshots/store_screenshot_spec.json"

if (-not $ValidateOnly) {
    Write-Info "Generating deterministic raw screenshots..."
    Get-ChildItem -Path $rawScreenshotDir -Filter "*.png" -ErrorAction SilentlyContinue | Remove-Item -Force
    Invoke-Step -Command "flutter drive --driver=$generationDriverPath --target=$generationTargetPath -d $DeviceId" -WorkingDirectory $PWD
    Write-Success "Generated raw store screenshots"
    Write-Host ""

    Write-Info "Processing raw screenshots with the shared tooling..."
    Invoke-Step -Command "dart run bin/store_screenshots.dart process $relativeSpecPath" -WorkingDirectory $toolRoot
    Write-Success "Processed store screenshots"
    Write-Host ""
}

if ((Get-ChildItem -Path $rawScreenshotDir -Filter "*.png" | Measure-Object).Count -eq 0) {
    Write-Error "No raw screenshots found in $rawScreenshotDir"
    exit 1
}

Write-Info "Validating screenshot workflow outputs..."
Invoke-Step -Command "flutter test $validationTestPath --timeout $TestTimeout" -WorkingDirectory $PWD
Invoke-Step -Command "dart run bin/store_screenshots.dart validate $relativeSpecPath" -WorkingDirectory $toolRoot
Invoke-Step -Command "dart test --timeout $TestTimeout" -WorkingDirectory $toolRoot
Write-Success "Screenshot tooling validation passed"
Write-Host ""

Write-Info "Synchronizing Play Store metadata images..."
Sync-PlayStoreMetadataImages -StoreScreenshotDir $processedScreenshotDir -GraphicsDir $graphicsDir -MetadataRoot $metadataRoot
Write-Success "Synchronized Play Store metadata assets"
Write-Host ""

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
        if ($LASTEXITCODE -ne 0) {
            throw "Fastlane upload_screenshots failed with exit code $LASTEXITCODE"
        }
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
Write-Success "Screenshot preparation completed!"
Write-Host "=========================================" -ForegroundColor $Cyan
Write-Host ""

Write-Info "Processed screenshots: ..\marketing\unit_converter\screenshots\store_screenshots"
Write-Info "Fastlane metadata images: android\fastlane\metadata\android"

Write-Info "Next steps:"
Write-Host "1. Review the processed screenshots and metadata assets" -ForegroundColor White
Write-Host "2. Run cd android; fastlane upload_metadata to push text metadata" -ForegroundColor White

if ($UploadToPlayStore) {
    Write-Host "3. Screenshots are already uploaded to Play Store" -ForegroundColor White
} else {
    Write-Host "3. Upload to Play Store: cd android; fastlane upload_screenshots" -ForegroundColor White
}

Write-Host ""

