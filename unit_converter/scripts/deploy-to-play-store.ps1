# Deploy to Google Play Store - PowerShell Script
# Usage: .\deploy-to-play-store.ps1 -Track 'internal' -ReleaseNotes 'Initial release'

param(
    [Parameter(Mandatory=$true)]
    [string]$Track,
    
    [Parameter(Mandatory=$false)]
    [string]$ReleaseNotes = 'Bug fixes and improvements'
)

# Navigate to project
Set-Location 'C:\dev\flutter\unit_converter'

# Build the app bundle
Write-Host '🔨 Building app bundle...' -ForegroundColor Cyan
flutter build appbundle --release

if ($LASTEXITCODE -ne 0) {
    Write-Host '❌ Build failed!' -ForegroundColor Red
    exit 1
}

Write-Host '✅ Build successful!' -ForegroundColor Green
Write-Host '📦 AAB file location: build\app\outputs\bundle\release\app-release.aab' -ForegroundColor Yellow

# Note: Manual upload until API is configured
Write-Host ''
Write-Host '📤 Next steps for manual upload:' -ForegroundColor Cyan
Write-Host '1. Go to Google Play Console: https://play.google.com/console' -ForegroundColor White
Write-Host '2. Navigate to your app' -ForegroundColor White
Write-Host '3. Go to Production or Internal Testing' -ForegroundColor White
Write-Host '4. Click Create new release' -ForegroundColor White
Write-Host '5. Upload the AAB file from: build\app\outputs\bundle\release\app-release.aab' -ForegroundColor White
Write-Host '6. Add release notes: $ReleaseNotes' -ForegroundColor White
Write-Host '7. Submit for review' -ForegroundColor White

