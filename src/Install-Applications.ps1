function Install-Applications {
    <#
    .SYNOPSIS
    Installs applications using Scoop and Winget.

    .DESCRIPTION
    Automatically installs a list of applications using Scoop and Winget.

    .PARAMETER Core
    Installs core applications using Scoop.

    .PARAMETER Games
    Installs games using Winget.

    .PARAMETER Messengers
    Installs messaging applications.

    .PARAMETER ProgrammingTools
    Installs programming-related applications.

    .PARAMETER All
    Installs all categories of applications.

    .EXAMPLE
    Install-Applications -All
    Installs all categories of applications.
    #>

    [CmdletBinding()]
    param (
        [switch]$Core,
        [switch]$Games,
        [switch]$Messengers,
        [switch]$ProgrammingTools,
        [switch]$All
    )

    # Enable all categories if -All is specified
    if ($All) {
        $Core = $true
        $Games = $true
        $Messengers = $true
        $ProgrammingTools = $true
    }

    # Ensure required tools are installed
    Test-Installation -App 'winget'
    Test-Installation -App 'scoop'
    Test-Installation -App 'gsudo'

    # Install selected categories
    if ($Core) {
        Write-Host "Installing core applications..." -ForegroundColor Cyan
    }

    if ($Games) {
        Write-Host "Installing games..." -ForegroundColor Cyan
    }

    if ($Messengers) {
        Write-Host "Installing messengers..." -ForegroundColor Cyan
    }

    if ($ProgrammingTools) {
        Write-Host "Installing programming tools..." -ForegroundColor Cyan
    }

    # Update software repositories
    Update-Software -Mode 'All'

    Write-Host "Finished app install process." -ForegroundColor Green

    # Clean up Scoop cache
    Remove-ScoopCache

    Test-SystemIntegrity -All
}


function Install-MSOffice {
    param(
        [string]$ConfigLocation
    )

    if (-not (Test-Path $ConfigLocation)) {
        Write-Warning "Configuration file not found at $ConfigLocation. Skipping Office installation."
        return
    }

    Test-Installation -App 'winget'

    Install-WithWinget Microsoft.OfficeDeploymentTool
    Set-Location "C:\Program Files\OfficeDeploymentTool";  .\setup.exe /configure "$ConfigLocation"
    
    Write-Host "MS Office installation completed." -ForegroundColor Green
}
