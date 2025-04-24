function Update-Applications {
    <#
    .SYNOPSIS
        Updates software using Winget and Scoop package managers.

    .DESCRIPTION
        This script automates the process of updating software on a Windows system. 
        It uses Winget to update all installed packages and Scoop to update its apps and clear its cache.

    .PARAMETER UseWinget
        Updates software using the Winget package manager.

    .PARAMETER UseScoop
        Updates software using the Scoop package manager.

    .PARAMETER All
        Updates software using both Winget and Scoop.

    .EXAMPLE
        Update-Applications -UseWinget -UseScoop
        Runs the software update process using both Winget and Scoop. Identical to 'Update-Applications -All'.
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
        return -1
    }

    Test-Installation -App 'winget'
    Test-Installation -App 'scoop'
    Test-Installation -App 'gsudo'

    Write-Host "Starting software update process..." -ForegroundColor Cyan
    Write-Warning "Please make sure common apps are closed before running this script. This includes browsers, IDE, terminals, powertoys, etc."
    
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