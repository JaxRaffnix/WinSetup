function Update-Applications {
    <#
    .SYNOPSIS
        Automates the process of updating software using Winget and Scoop package managers.

    .DESCRIPTION
        This script updates installed applications with winget and Scoop. 
        
    .PARAMETER UseWinget
        Updates apps from winget.

    .PARAMETER UseScoop
        Updates apps from Scop.

    .PARAMETER All
        Updates all installed software using both Winget and Scoop package manager.
    .EXAMPLE
        Update-Applications -All
        Updates all installed software using both Winget and Scoop package managers.

    .NOTES
        Ensure that both Winget and Scoop are installed and properly configured on your system before running this script.
        Administrator privileges are called with 'gsudo'.
    #>

    [CmdletBinding()]
    param (
    [switch]$UseWinget,
    [switch]$UseScoop,
    [switch]$All
    )

    if ($All) {
        $UseWinget = $true
        $UseScoop = $true
    }

    if (-not ($UseWinget -or $UseScoop)) {
        Write-Error "At least one switch parameter (-UseWinget, -UseScoop, or -All) must be specified."
        return 1
    }

    Test-Installation -App 'winget'
    Test-Installation -App 'scoop'
    Test-Installation -App 'gsudo'

    Write-Host "Starting software update process..." -ForegroundColor Cyan
    Write-Warning "Please make sure common apps are closed before running this script. This includes browsers, IDE, terminals, startup apps, etc."
    
    try {
        if ($UseScoop) {
            scoop update
            gsudo scoop update *

            Remove-ScoopCache
        }

        if ($UseWinget) {
            winget upgrade --all --accept-package-agreements --accept-source-agreements --disable-interactivity --include-unknown --include-pinned --silent --force
        }

        Write-Host "Software update process completed successfully!" -ForegroundColor Green
    } catch {
        Write-Error "An error occurred during the update process: $_"
    }
}