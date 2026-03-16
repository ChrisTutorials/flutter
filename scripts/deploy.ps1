# Unified Multi-Platform Deployment Script
# Supports Android, Windows, and iOS deployment
# Usage: .\deploy.ps1 -Platform 'android' -Track 'production' -ReleaseNotes 'New features'

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('android', 'windows', 'ios')]
    [string]$Platform,

    [Parameter(Mandatory=$false)]
    [ValidateSet('internal', 'alpha', 'beta', 'production', 'retail')]
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
    [switch]$DoNotSendForReview,

    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = (Get-Location)
)

# Set error action preference
$ErrorActionPreference = 'Stop'

# Color output functions
function Write-ColorOutput {
    param(
        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet('Cyan', 'Green', 'Yellow', 'Red', 'White')]
        [string]$Color = 'White'
    )
    
    Write-Host $Message -ForegroundColor $Color
}

function Import-DotEnv {
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

function Test-FastlaneAvailable {
    $fastlaneAvailable = $null -ne (Get-Command fastlane -ErrorAction SilentlyContinue)

    if (-not $fastlaneAvailable) {
        Write-ColorOutput "[ERROR] Fastlane is not installed or not in PATH" -Color Red
        Write-ColorOutput "[INFO] Install Fastlane with: gem install fastlane" -Color Cyan
        return $false
    }

    return $true
}

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

function Test-PlatformPrerequisites {
    param([string]$Platform)
    
    Write-ColorOutput "[INFO] Checking $Platform prerequisites..." -Color Cyan
    
    switch ($Platform) {
        'android' {
            # Check if android directory exists
            $androidPath = Join-Path $ProjectPath 'android'
            if (-not (Test-Path $androidPath)) {
                Write-ColorOutput "[ERROR] Android directory not found at: $androidPath" -Color Red
                return $false
            }
            
            # Check if Fastfile exists
            $fastfilePath = Join-Path $androidPath 'fastlane\Fastfile'
            if (-not (Test-Path $fastfilePath)) {
                Write-ColorOutput "[ERROR] Fastfile not found at: $fastfilePath" -Color Red
                return $false
            }
            
            Write-ColorOutput "[SUCCESS] Android prerequisites verified" -Color Green
            return $true
        }
        
        'windows' {
            # Check if windows directory exists
            $windowsPath = Join-Path $ProjectPath 'windows'
            if (-not (Test-Path $windowsPath)) {
                Write-ColorOutput "[ERROR] Windows directory not found at: $windowsPath" -Color Red
                return $false
            }
            
            # Check if Fastfile exists
            $fastfilePath = Join-Path $windowsPath 'fastlane\Fastfile'
            if (-not (Test-Path $fastfilePath)) {
                Write-ColorOutput "[ERROR] Fastfile not found at: $fastfilePath" -Color Red
                Write-ColorOutput "[INFO] Windows Fastlane not configured. See docs/DEPLOYMENT.md for setup instructions." -Color Cyan
                return $false
            }
            
            # Check Flutter Windows support
            $flutterOutput = flutter config | Select-String "enable-windows-desktop"
            if ($flutterOutput -match "false") {
                Write-ColorOutput "[WARNING] Windows desktop is not enabled in Flutter" -Color Yellow
                Write-ColorOutput "[INFO] Run: flutter config --enable-windows-desktop" -Color Cyan
            }
            
            Write-ColorOutput "[SUCCESS] Windows prerequisites verified" -Color Green
            return $true
        }
        
        'ios' {
            # Check if running on macOS
            if ($IsWindows -or $null -eq $IsWindows) {
                Write-ColorOutput "[ERROR] iOS deployment requires macOS" -Color Red
                return $false
            }
            
            # Check if ios directory exists
            $iosPath = Join-Path $ProjectPath 'ios'
            if (-not (Test-Path $iosPath)) {
                Write-ColorOutput "[ERROR] iOS directory not found at: $iosPath" -Color Red
                return $false
            }
            
            # Check if Fastfile exists
            $fastfilePath = Join-Path $iosPath 'fastlane\Fastfile'
            if (-not (Test-Path $fastfilePath)) {
                Write-ColorOutput "[ERROR] Fastfile not found at: $fastfilePath" -Color Red
                Write-ColorOutput "[INFO] iOS Fastlane not configured. See docs/DEPLOYMENT.md for setup instructions." -Color Cyan
                return $false
            }
            
            Write-ColorOutput "[SUCCESS] iOS prerequisites verified" -Color Green
            return $true
        }
        
        default {
            Write-ColorOutput "[ERROR] Unknown platform: $Platform" -Color Red
            return $false
        }
    }
}

function Invoke-AndroidDeployment {
    param(
        [string]$Track,
        [string]$ReleaseNotes,
        [bool]$SkipScreenshots,
        [bool]$SkipMetadata,
        [bool]$SkipValidation,
        [bool]$SkipConfirmation,
        [bool]$DoNotSendForReview
    )
    
    Write-ColorOutput "[INFO] Starting Android deployment to $Track track..." -Color Cyan
    
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
    
    # Navigate to android directory
    $androidPath = Join-Path $ProjectPath 'android'
    Push-Location $androidPath
    
    try {
        Write-ColorOutput "[INFO] Running: bundle exec fastlane $($fastlaneParams -join ' ')" -Color Cyan
        bundle exec fastlane ($fastlaneParams -join ' ')
        $exitCode = $LASTEXITCODE
    } finally {
        Pop-Location
    }
    
    return $exitCode
}

function Invoke-WindowsDeployment {
    param(
        [string]$Track,
        [string]$ReleaseNotes,
        [bool]$SkipScreenshots,
        [bool]$SkipMetadata,
        [bool]$SkipValidation,
        [bool]$SkipConfirmation,
        [bool]$DoNotSendForReview
    )
    
    Write-ColorOutput "[INFO] Starting Windows deployment to $Track track..." -Color Cyan
    
    # Build Fastlane parameters
    $fastlaneParams = @("deploy_production")
    
    if ($SkipConfirmation) {
        $fastlaneParams += "skip_confirmation:true"
    }
    
    # Navigate to windows directory
    $windowsPath = Join-Path $ProjectPath 'windows'
    Push-Location $windowsPath
    
    try {
        Write-ColorOutput "[INFO] Running: bundle exec fastlane $($fastlaneParams -join ' ')" -Color Cyan
        bundle exec fastlane ($fastlaneParams -join ' ')
        $exitCode = $LASTEXITCODE
    } finally {
        Pop-Location
    }
    
    return $exitCode
}

function Invoke-iOSDeployment {
    param(
        [string]$Track,
        [string]$ReleaseNotes,
        [bool]$SkipScreenshots,
        [bool]$SkipMetadata,
        [bool]$SkipValidation,
        [bool]$SkipConfirmation,
        [bool]$DoNotSendForReview
    )
    
    Write-ColorOutput "[INFO] Starting iOS deployment to $Track track..." -Color Cyan
    
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
    
    # Navigate to ios directory
    $iosPath = Join-Path $ProjectPath 'ios'
    Push-Location $iosPath
    
    try {
        Write-ColorOutput "[INFO] Running: bundle exec fastlane $($fastlaneParams -join ' ')" -Color Cyan
        bundle exec fastlane ($fastlaneParams -join ' ')
        $exitCode = $LASTEXITCODE
    } finally {
        Pop-Location
    }
    
    return $exitCode
}

# Main execution
try {
    # Resolve project path
    $ProjectPath = Resolve-Path $ProjectPath

    # Load environment variables
    $envPath = Join-Path $ProjectPath '.env'
    Import-DotEnv -Path $envPath

    # Clean up any zombie processes before deployment
    Invoke-ProcessCleanup

    # Print deployment header
    Write-ColorOutput "=========================================" -Color Cyan
    Write-ColorOutput "Unified Multi-Platform Deployment" -Color Cyan
    Write-ColorOutput "=========================================" -Color Cyan
    Write-ColorOutput ""
    Write-ColorOutput "Platform: $Platform" -Color White
    Write-ColorOutput "Track: $Track" -Color White
    Write-ColorOutput "Release Notes: $ReleaseNotes" -Color White
    Write-ColorOutput "Skip Screenshots: $SkipScreenshots" -Color White
    Write-ColorOutput "Skip Metadata: $SkipMetadata" -Color White
    Write-ColorOutput "Skip Validation: $SkipValidation" -Color White
    Write-ColorOutput "Skip Confirmation: $SkipConfirmation" -Color White
    Write-ColorOutput "Submit For Review: $($DoNotSendForReview -eq $false)" -Color White
    Write-ColorOutput "Project Path: $ProjectPath" -Color White
    Write-ColorOutput ""
    
    # Check Fastlane availability
    if (-not (Test-FastlaneAvailable)) {
        exit 1
    }
    
    # Check platform prerequisites
    if (-not (Test-PlatformPrerequisites -Platform $Platform)) {
        exit 1
    }
    
    # Execute platform-specific deployment
    $exitCode = 0
    
    switch ($Platform) {
        'android' {
            $exitCode = Invoke-AndroidDeployment -Track $Track -ReleaseNotes $ReleaseNotes -SkipScreenshots $SkipScreenshots -SkipMetadata $SkipMetadata -SkipValidation $SkipValidation -SkipConfirmation $SkipConfirmation -DoNotSendForReview $DoNotSendForReview
        }
        
        'windows' {
            $exitCode = Invoke-WindowsDeployment -Track $Track -ReleaseNotes $ReleaseNotes -SkipScreenshots $SkipScreenshots -SkipMetadata $SkipMetadata -SkipValidation $SkipValidation -SkipConfirmation $SkipConfirmation -DoNotSendForReview $DoNotSendForReview
        }
        
        'ios' {
            $exitCode = Invoke-iOSDeployment -Track $Track -ReleaseNotes $ReleaseNotes -SkipScreenshots $SkipScreenshots -SkipMetadata $SkipMetadata -SkipValidation $SkipValidation -SkipConfirmation $SkipConfirmation -DoNotSendForReview $DoNotSendForReview
        }
    }
    
    # Check exit code
    if ($exitCode -ne 0) {
        Write-ColorOutput ""
        Write-ColorOutput "[ERROR] Deployment failed with exit code $exitCode" -Color Red
        exit $exitCode
    }
    
    Write-ColorOutput ""
    Write-ColorOutput "[SUCCESS] Deployment completed successfully!" -Color Green
    Write-ColorOutput ""
    Write-ColorOutput "Next steps:" -Color Cyan
    switch ($Platform) {
        'android' {
            Write-ColorOutput "  - Monitor deployment in Google Play Console" -Color White
            if (-not $DoNotSendForReview) {
                Write-ColorOutput "  - Wait for Google Play review to complete" -Color White
            }
        }
        'windows' {
            Write-ColorOutput "  - Monitor deployment in Microsoft Partner Center" -Color White
            Write-ColorOutput "  - Wait for Microsoft Store certification" -Color White
        }
        'ios' {
            Write-ColorOutput "  - Monitor deployment in App Store Connect" -Color White
            if (-not $DoNotSendForReview) {
                Write-ColorOutput "  - Wait for App Store review to complete" -Color White
            }
        }
    }

    # Clean up any zombie processes after deployment
    Invoke-ProcessCleanup

} catch {
    Write-ColorOutput ""
    Write-ColorOutput "[ERROR] An unexpected error occurred:" -Color Red
    Write-ColorOutput $_.Exception.Message -Color Red
    Write-ColorOutput $_.ScriptStackTrace -Color Red

    # Clean up processes even on error
    Invoke-ProcessCleanup

    exit 1
}

