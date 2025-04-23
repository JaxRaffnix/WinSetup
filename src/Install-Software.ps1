function Install-Software {
    <#
    .SYNOPSIS
    Installs software using Scoop and Winget.

    .DESCRIPTION
    Automatically installs a list of applications using Scoop and Winget.

    .PARAMETER CoreApps
    Installs core applications using Scoop.

    .PARAMETER Games
    Installs games using Winget.

    .PARAMETER Messengers
    Installs messaging applications.

    .PARAMETER ProgrammingApps
    Installs programming-related applications.

    .PARAMETER All
    Installs all categories of applications.

    .EXAMPLE
    Install-Software -All
    Installs all categories of applications.
    #>

    [CmdletBinding()]
    param (
        [switch]$CoreApps,
        [switch]$Games,
        [switch]$Messengers,
        [switch]$ProgrammingApps,
        [switch]$All
    )

    # Enable all categories if -All is specified
    if ($All) {
        $CoreApps = $true
        $Games = $true
        $Messengers = $true
        $ProgrammingApps = $true
    }

    # Ensure required tools are installed
    Test-Installation -App 'winget'
    Test-Installation -App 'scoop'
    Test-Installation -App 'gsudo'

    # Install selected categories
    if ($CoreApps) {
        Write-Host "Installing core applications..."
        Install-CoreApps
    }

    if ($Games) {
        Write-Host "Installing games..."
        Install-Games
    }

    if ($Messengers) {
        Write-Host "Installing messengers..."
        Install-Messengers
    }

    if ($ProgrammingApps) {
        Write-Host "Installing programming applications..."
        Install-ProgrammingApps
    }

    
    # Update software repositories
    Update-Software -Mode 'All'

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
}
