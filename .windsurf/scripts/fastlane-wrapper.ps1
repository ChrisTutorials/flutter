# Fastlane Wrapper Script
# This script ensures Fastlane is only run from project android directories

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Lane
)

# Check if we're in a project's android directory
$currentDir = Get-Location

# Check if we're in an android directory
if (-not ($currentDir.Name -eq 'android' -and (Test-Path "$currentDir\fastlane"))) {
    Write-Host "❌ Error: Fastlane must be run from a project's android directory" -ForegroundColor Red
    Write-Host ""
    Write-Host "Current directory: $currentDir" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please navigate to a project's android directory:" -ForegroundColor Cyan
    Write-Host "  cd unit_converter/android" -ForegroundColor White
    Write-Host "  fastlane [lane_name]" -ForegroundColor White
    Write-Host ""
    Write-Host "Or use this wrapper from the project root:" -ForegroundColor Cyan
    Write-Host "  cd unit_converter" -ForegroundColor White
    Write-Host "  ..\.windsurf\scripts\fastlane-wrapper.ps1 [lane_name]" -ForegroundColor White
    exit 1
}

# Run Fastlane with the specified lane
Write-Host "🚀 Running Fastlane lane: $Lane" -ForegroundColor Green
fastlane $Lane $args
