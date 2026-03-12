# Pre-Deployment Verification Script (PowerShell)
# This script runs all critical tests to ensure the app is ready for Play Store deployment

$ErrorActionPreference = "Stop"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Pre-Deployment Verification Script" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Function to print colored output
function Print-Success {
    param([string]$Message)
    Write-Host "[PASS] $Message" -ForegroundColor Green
}

function Print-Error {
    param([string]$Message)
    Write-Host "[FAIL] $Message" -ForegroundColor Red
}

function Print-Warning {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

# 1. Check Flutter installation
Write-Host "1. Checking Flutter installation..." -ForegroundColor Cyan
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Print-Success "Flutter installed: $flutterVersion"
} catch {
    Print-Error "Flutter is not installed or not in PATH"
    exit 1
}

# 2. Check Dart installation
Write-Host ""
Write-Host "2. Checking Dart installation..." -ForegroundColor Cyan
try {
    $dartVersion = dart --version 2>&1
    Print-Success "Dart installed: $dartVersion"
} catch {
    Print-Error "Dart is not installed or not in PATH"
    exit 1
}

# 3. Check if we're in the correct directory
Write-Host ""
Write-Host "3. Checking project directory..." -ForegroundColor Cyan
if (Test-Path "pubspec.yaml") {
    Print-Success "In correct Flutter project directory"
} else {
    Print-Error "Not in a Flutter project directory (pubspec.yaml not found)"
    exit 1
}

# 4. Run pubspec tests
Write-Host ""
Write-Host "4. Running pubspec configuration tests..." -ForegroundColor Cyan
try {
    Push-Location test/release_checks
    flutter test pubspec_test.dart
    Pop-Location
    Print-Success "Pubspec configuration tests passed"
} catch {
    Print-Error "Pubspec configuration tests failed"
    Pop-Location
    exit 1
}

# 5. Check AndroidManifest.xml
Write-Host ""
Write-Host "5. Checking AndroidManifest.xml..." -ForegroundColor Cyan
$manifestPath = "android/app/src/main/AndroidManifest.xml"
if (Test-Path $manifestPath) {
    $manifestContent = Get-Content $manifestPath -Raw
    
    # Check AdMob app ID
    if ($manifestContent -match "com\.google\.android\.gms\.ads\.APPLICATION_ID") {
        # Check if it's commented out
        if ($manifestContent -match "<!--.*com\.google\.android\.gms\.ads\.APPLICATION_ID") {
            Print-Error "AdMob Application ID is commented out in AndroidManifest.xml"
            exit 1
        } else {
            Print-Success "AdMob Application ID is present in AndroidManifest.xml"
        }
    } else {
        Print-Error "AdMob Application ID is missing from AndroidManifest.xml"
        exit 1
    }
    
    # Check advertising ID permission
    if ($manifestContent -match "com\.google\.android\.gms\.permission\.AD_ID") {
        Print-Success "Advertising ID permission is present"
    } else {
        Print-Error "Advertising ID permission is missing (required for Android 13+)"
        exit 1
    }
    
    # Check billing permission
    if ($manifestContent -match "com\.android\.vending\.BILLING") {
        Print-Success "Billing permission is present"
    } else {
        Print-Error "Billing permission is missing (required for in-app purchases)"
        exit 1
    }
    
    # Check internet permission
    if ($manifestContent -match "android\.permission\.INTERNET") {
        Print-Success "Internet permission is present"
    } else {
        Print-Error "Internet permission is missing (required for AdMob and currency API)"
        exit 1
    }
} else {
    Print-Error "AndroidManifest.xml not found"
    exit 1
}

# 6. Check build.gradle.kts
Write-Host ""
Write-Host "6. Checking build.gradle.kts..." -ForegroundColor Cyan
$buildGradlePath = "android/app/build.gradle.kts"
if (Test-Path $buildGradlePath) {
    $buildGradleContent = Get-Content $buildGradlePath -Raw
    
    # Check code shrinking
    if ($buildGradleContent -match "isMinifyEnabled\s*=\s*true") {
        Print-Success "Code shrinking is enabled"
    } else {
        Print-Error "Code shrinking is not enabled (required for release builds)"
        exit 1
    }
    
    # Check resource shrinking
    if ($buildGradleContent -match "isShrinkResources\s*=\s*true") {
        Print-Success "Resource shrinking is enabled"
    } else {
        Print-Error "Resource shrinking is not enabled (required for release builds)"
        exit 1
    }
    
    # Check ProGuard
    if ($buildGradleContent -match "proguardFiles") {
        Print-Success "ProGuard is configured"
    } else {
        Print-Error "ProGuard is not configured (required for code obfuscation)"
        exit 1
    }
} else {
    Print-Error "build.gradle.kts not found"
    exit 1
}

# 7. Check version format
Write-Host ""
Write-Host "7. Checking version format..." -ForegroundColor Cyan
$versionLine = Select-String -Path "pubspec.yaml" -Pattern "^version:" | Select-Object -First 1
if ($versionLine) {
    $version = $versionLine.Line -replace "version:\s*", ""
    if ($version -match "^\d+\.\d+\.\d+\+\d+$") {
        Print-Success "Version format is correct: $version"
        $buildNumber = $version -split '\+' | Select-Object -Last 1
        if ([int]$buildNumber -gt 0) {
            Print-Success "Build number is valid: $buildNumber"
        } else {
            Print-Error "Build number must be greater than 0"
            exit 1
        }
    } else {
        Print-Error "Version format is incorrect. Expected: x.y.z+buildNumber, Got: $version"
        exit 1
    }
} else {
    Print-Error "Version not found in pubspec.yaml"
    exit 1
}

# 8. Check for required dependencies
Write-Host ""
Write-Host "8. Checking required dependencies..." -ForegroundColor Cyan
$requiredDeps = @("google_mobile_ads", "shared_preferences", "intl", "in_app_purchase", "http")
$pubspecContent = Get-Content "pubspec.yaml" -Raw
foreach ($dep in $requiredDeps) {
    if ($pubspecContent -match $dep) {
        Print-Success "Dependency $dep is present"
    } else {
        Print-Error "Dependency $dep is missing"
        exit 1
    }
}

# 9. Check purchase flow is production-safe
Write-Host ""
Write-Host "9. Checking purchase flow configuration..." -ForegroundColor Cyan
$settingsScreenPath = "lib/screens/settings_screen.dart"
$purchaseServicePath = "lib/services/purchase_service.dart"

if (-not (Test-Path $settingsScreenPath)) {
    Print-Error "Settings screen not found"
    exit 1
}

if (-not (Test-Path $purchaseServicePath)) {
    Print-Error "Purchase service not found"
    exit 1
}

$settingsContent = Get-Content $settingsScreenPath -Raw
$purchaseServiceContent = Get-Content $purchaseServicePath -Raw

if (
    $settingsContent -match [regex]::Escape('Ad-free mode (Development)') -or
    $settingsContent -match [regex]::Escape('Use the purchase button above for real purchases.') -or
    $settingsContent -match 'kDebugMode' -or
    $settingsContent -match 'PremiumService\.setPremium' -or
    $settingsContent -match 'AdMobService\.setPremiumStatus'
) {
    Print-Error "Production settings still expose a development-only premium entitlement path"
    exit 1
}

if ($purchaseServiceContent -match '\btestPurchase\b|\btestRefund\b') {
    Print-Error "PurchaseService still contains development-only entitlement helpers"
    exit 1
}

Print-Success "Purchase flow is limited to the production IAP path"

# 10. Run Flutter tests
Write-Host ""
Write-Host "10. Running Flutter tests..." -ForegroundColor Cyan
try {
    flutter test
    Print-Success "Flutter tests passed"
} catch {
    Print-Error "Flutter tests failed"
    exit 1
}

# 11. Check if release build is possible
Write-Host ""
Write-Host "11. Checking if release build is possible..." -ForegroundColor Cyan
flutter clean | Out-Null
flutter pub get | Out-Null
try {
    # Just check if the build configuration is valid
    flutter build apk --release --dry-run 2>&1 | Out-Null
    Print-Success "Release build configuration is valid"
} catch {
    Print-Error "Release build would fail"
    exit 1
}

# 12. Check for common issues
Write-Host ""
Write-Host "12. Checking for common issues..." -ForegroundColor Cyan

# Check if AdMob app ID is set to test ID
$buildGradleContent = Get-Content "android/app/build.gradle.kts" -Raw
if ($buildGradleContent -match "ca-app-pub-3940256099942544") {
    Print-Warning "AdMob app ID is set to test ID - this should be changed to production ID"
}

# Check if key.properties exists
if (-not (Test-Path "android/key.properties")) {
    Print-Warning "key.properties not found - app will be signed with debug keys (not secure for production)"
} else {
    Print-Success "Production signing configuration found"
}

# Check if Google Cloud credentials are configured
Write-Host ""
Write-Host "13. Checking Google Cloud credentials..." -ForegroundColor Cyan
if ($env:GOOGLE_APPLICATION_CREDENTIALS -and (Test-Path $env:GOOGLE_APPLICATION_CREDENTIALS)) {
    Print-Success "Google Cloud credentials configured: $env:GOOGLE_APPLICATION_CREDENTIALS"
} else {
    Print-Warning "GOOGLE_APPLICATION_CREDENTIALS not configured - Google Cloud services will not be available"
    Write-Host "       See docs/GOOGLE_CLOUD_CREDENTIALS.md for setup instructions" -ForegroundColor Gray
}

# Check if AdMob App ID is configured for release
Write-Host ""
Write-Host "14. Checking AdMob App ID for release..." -ForegroundColor Cyan
if ($env:UNIT_CONVERTER_ADMOB_APP_ID) {
    if ($env:UNIT_CONVERTER_ADMOB_APP_ID -match 'ca-app-pub-3940256099942544') {
        Print-Error "UNIT_CONVERTER_ADMOB_APP_ID is set to test ID - must use production AdMob App ID"
    } else {
        Print-Success "AdMob App ID configured for release: $env:UNIT_CONVERTER_ADMOB_APP_ID"
    }
} else {
    Print-Warning "UNIT_CONVERTER_ADMOB_APP_ID not configured - release builds will use test AdMob configuration"
}    Write-Host "       See docs/RELEASE_CREDENTIALS_SETUP.md for setup instructions" -ForegroundColor Gray
}

# Summary
Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "[SUCCESS] All pre-deployment checks passed!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "App is ready for Play Store deployment." -ForegroundColor Cyan
Write-Host "Version: $version" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Build release AAB: flutter build appbundle --release" -ForegroundColor White
Write-Host "2. Upload to Google Play Console" -ForegroundColor White
Write-Host "3. Complete store listing" -ForegroundColor White
Write-Host "4. Submit for review" -ForegroundColor White
Write-Host ""
