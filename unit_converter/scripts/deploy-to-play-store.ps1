# Deploy to Google Play Store - PowerShell Script
# Usage: .\deploy-to-play-store.ps1 -Track 'internal' -ReleaseNotes 'Initial release'
# Increments the Android build number and uses Fastlane when available.

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('internal', 'alpha', 'beta', 'production')]
    [string]$Track,
    
    [Parameter(Mandatory=$false)]
    [string]$ReleaseNotes = 'Bug fixes and improvements',
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipVersionBump,

    [Parameter(Mandatory=$false)]
    [switch]$PrepareStoreAssets
)

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Set-Location $projectRoot

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

Load-DotEnv -Path (Join-Path $projectRoot '.env')

function Resolve-EnvironmentValue {
    param([Parameter(Mandatory=$true)][string]$Name)

    $processValue = [Environment]::GetEnvironmentVariable($Name, 'Process')
    if (-not [string]::IsNullOrWhiteSpace($processValue)) {
        return $processValue
    }

    $userValue = [Environment]::GetEnvironmentVariable($Name, 'User')
    if (-not [string]::IsNullOrWhiteSpace($userValue)) {
        Set-Item -Path "Env:$Name" -Value $userValue
        return $userValue
    }

    $machineValue = [Environment]::GetEnvironmentVariable($Name, 'Machine')
    if (-not [string]::IsNullOrWhiteSpace($machineValue)) {
        Set-Item -Path "Env:$Name" -Value $machineValue
        return $machineValue
    }

    return $null
}

function Get-BumpedBuildVersion {
    param([string]$PubspecContent)

    $versionMatch = [regex]::Match($PubspecContent, 'version:\s*(\d+\.\d+\.\d+)\+(\d+)')
    if (-not $versionMatch.Success) {
        throw 'Could not parse version line in pubspec.yaml. Expected format x.y.z+buildNumber.'
    }

    $semanticVersion = $versionMatch.Groups[1].Value
    $buildNumber = [int]$versionMatch.Groups[2].Value
    $newBuildNumber = $buildNumber + 1

    return @{
        Current = "$semanticVersion+$buildNumber"
        Next = "$semanticVersion+$newBuildNumber"
        UpdatedContent = [regex]::Replace(
            $PubspecContent,
            'version:\s*\d+\.\d+\.\d+\+\d+',
            "version: $semanticVersion+$newBuildNumber",
            1
        )
    }
}

if (-not $SkipVersionBump) {
    Write-Host '[INFO] Checking current version...' -ForegroundColor Cyan

    $pubspecContent = Get-Content 'pubspec.yaml' -Raw
    $versionInfo = Get-BumpedBuildVersion -PubspecContent $pubspecContent
    Write-Host "[INFO] Bumping build number from $($versionInfo.Current) to $($versionInfo.Next)" -ForegroundColor Yellow
    Set-Content -Path 'pubspec.yaml' -Value $versionInfo.UpdatedContent -NoNewline
    Write-Host "[PASS] Version updated to $($versionInfo.Next)" -ForegroundColor Green
}

if ($PrepareStoreAssets) {
    Write-Host '[INFO] Preparing Play Store screenshots and metadata...' -ForegroundColor Cyan
    powershell -ExecutionPolicy Bypass -File scripts\generate-store-screenshots.ps1

    if ($LASTEXITCODE -ne 0) {
        Write-Host '[FAIL] Screenshot preparation failed!' -ForegroundColor Red
        exit 1
    }
}

$fastlaneAvailable = $null -ne (Get-Command fastlane -ErrorAction SilentlyContinue)
$googlePlayJsonKeyFile = Resolve-EnvironmentValue -Name 'GOOGLE_PLAY_JSON_KEY_FILE'
$googleApplicationCredentials = Resolve-EnvironmentValue -Name 'GOOGLE_APPLICATION_CREDENTIALS'
$adMobAppId = Resolve-EnvironmentValue -Name 'UNIT_CONVERTER_ADMOB_APP_ID'
$serviceAccountConfigured = (Test-Path 'android\fastlane\google-play-service-account.json') -or $googlePlayJsonKeyFile
$googleCloudCredentialsConfigured = $googleApplicationCredentials -and (Test-Path $googleApplicationCredentials)
$adMobAppIdConfigured = $adMobAppId -and $adMobAppId -notmatch 'ca-app-pub-3940256099942544'

# Check if Google Cloud credentials are configured (optional for current deployment)
if (-not $googleCloudCredentialsConfigured) {
    Write-Host '[WARN] GOOGLE_APPLICATION_CREDENTIALS not configured. Google Cloud services will not be available.' -ForegroundColor Yellow
    Write-Host '[INFO] See ../../../docs/GOOGLE_CLOUD_CREDENTIALS.md for setup instructions.' -ForegroundColor Cyan
} else {
    Write-Host "[PASS] Google Cloud credentials configured: $googleApplicationCredentials" -ForegroundColor Green
}

# Check if AdMob App ID is configured for release
if (-not $adMobAppIdConfigured) {
    Write-Host '[WARN] UNIT_CONVERTER_ADMOB_APP_ID not configured or using test ID. Release builds will use test AdMob configuration.' -ForegroundColor Yellow
    Write-Host '[INFO] See ../../../docs/RELEASE_CREDENTIALS_SETUP.md for setup instructions.' -ForegroundColor Cyan
} else {
    Write-Host "[PASS] AdMob App ID configured for release: $adMobAppId" -ForegroundColor Green
}

if ($fastlaneAvailable -and $serviceAccountConfigured) {
    Write-Host "[INFO] Deploying with Fastlane to the $Track track..." -ForegroundColor Cyan
    Push-Location android
    try {
        fastlane "deploy_$Track"
        if ($LASTEXITCODE -ne 0) {
            throw "Fastlane deploy_$Track failed with exit code $LASTEXITCODE"
        }
    } finally {
        Pop-Location
    }
} else {
    Write-Host '[INFO] Running release validation checks before manual deployment...' -ForegroundColor Cyan

    if ($fastlaneAvailable) {
        Push-Location android
        try {
            fastlane validate
        } finally {
            Pop-Location
        }
    } else {
        powershell -ExecutionPolicy Bypass -File scripts\pre-deployment-check.ps1
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Host '[FAIL] Release validation failed!' -ForegroundColor Red
        exit 1
    }

    Write-Host '[INFO] Building app bundle for manual upload...' -ForegroundColor Cyan
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        Write-Host '[FAIL] Dependency resolution failed!' -ForegroundColor Red
        exit 1
    }

    flutter build appbundle --release
    if ($LASTEXITCODE -ne 0) {
        Write-Host '[FAIL] Build failed!' -ForegroundColor Red
        exit 1
    }

    Write-Host '[PASS] Build successful!' -ForegroundColor Green
    Write-Host "[INFO] AAB file location: build\app\outputs\bundle\release\app-release.aab" -ForegroundColor Yellow
    Write-Host ''
    Write-Host '[INFO] Next steps for manual upload:' -ForegroundColor Cyan
    Write-Host '1. Go to Google Play Console: https://play.google.com/console' -ForegroundColor White
    Write-Host '2. Navigate to your app and create a release on the selected track' -ForegroundColor White
    Write-Host '3. Upload build\app\outputs\bundle\release\app-release.aab' -ForegroundColor White
    Write-Host "4. Add release notes: $ReleaseNotes" -ForegroundColor White
    Write-Host '5. Upload metadata and screenshots with fastlane once service account access is configured' -ForegroundColor White
}
