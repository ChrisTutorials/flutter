# Release to Google Play Store - PowerShell Wrapper
# Usage: .\scripts\release.ps1 -Track 'production' -ReleaseNotes 'New features'
# This is a convenience wrapper for the Fastlane deploy lane

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('internal', 'alpha', 'beta', 'production')]
    [string]$Track = 'internal',

    [Parameter(Mandatory=$false)]
    [string]$ReleaseNotes = 'Bug fixes and improvements',

    [Parameter(Mandatory=$false)]
    [switch]$SkipScreenshots,

    [Parameter(Mandatory=$false)]
    [switch]$SkipMetadata,

    [Parameter(Mandatory=$false)]
    [switch]$SkipValidation,

    [Parameter(Mandatory=$false)]
    [switch]$SkipConfirmation,

    [Parameter(Mandatory=$false)]
    [switch]$DoNotSendForReview
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

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Unit Converter Release Deployment" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Track: $Track" -ForegroundColor White
Write-Host "Release Notes: $ReleaseNotes" -ForegroundColor White
Write-Host "Skip Screenshots: $($SkipScreenshots)" -ForegroundColor White
Write-Host "Skip Metadata: $($SkipMetadata)" -ForegroundColor White
Write-Host "Skip Validation: $($SkipValidation)" -ForegroundColor White
Write-Host "Skip Confirmation: $($SkipConfirmation)" -ForegroundColor White
Write-Host "Submit For Review: $($DoNotSendForReview -eq $false)" -ForegroundColor White
Write-Host ""

# Check if Fastlane is available
$fastlaneAvailable = $null -ne (Get-Command fastlane -ErrorAction SilentlyContinue)

if (-not $fastlaneAvailable) {
    Write-Host "[ERROR] Fastlane is not installed or not in PATH" -ForegroundColor Red
    Write-Host "[INFO] Install Fastlane with: gem install fastlane" -ForegroundColor Cyan
    exit 1
}

# Build Fastlane parameters
$fastlaneParams = @("deploy", "track:$Track", "release_notes:$ReleaseNotes")

if ($SkipScreenshots) {
    $fastlaneParams += "skip_screenshots:true"
}

if ($SkipMetadata) {
    $fastlaneParams += "skip_metadata:true"
}

if ($SkipValidation) {
    $fastlaneParams += "skip_validation:true"
}

if ($SkipConfirmation) {
    $fastlaneParams += "skip_confirmation:true"
}

if ($DoNotSendForReview) {
    $fastlaneParams += "submit_for_review:false"
}

Write-Host "[INFO] Running Fastlane deploy..." -ForegroundColor Cyan
Write-Host ""

# Navigate to android directory and run Fastlane
Push-Location android
try {
    bundle exec fastlane ($fastlaneParams -join ' ')
    $exitCode = $LASTEXITCODE
} finally {
    Pop-Location
}

if ($exitCode -ne 0) {
    Write-Host ""
    Write-Host "[ERROR] Deployment failed with exit code $exitCode" -ForegroundColor Red
    exit $exitCode
}

Write-Host ""
Write-Host "[SUCCESS] Deployment completed successfully!" -ForegroundColor Green

