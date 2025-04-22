<#
.SYNOPSIS
    Updates software using Winget and Scoop package managers.

.DESCRIPTION
    This script automates the process of updating software on a Windows system. 
    It uses Winget to update all installed packages and Scoop to update its apps and cache.

.PARAMETER UseWinget
    Updates software using the Winget package manager.

.PARAMETER UseScoop
    Updates software using the Scoop package manager.

.PARAMETER All
    Updates software using both Winget and Scoop.

.EXAMPLE
    Update-Software -UseWinget -UseScoop
    Runs the software update process using both Winget and Scoop. Identical to Update-Software -All.

.NOTES
    Ensure that Winget, Scoop, and gsudo are installed and properly configured on your system.
#>
function Update-Software {
    param (
        [switch]$UseWinget,
        [switch]$UseScoop,
        [switch]$All 
    )

    if ($All) {
        $UseWinget = $true
        $UseScoop = $true
    }

    Test-CommandExists -App 'winget'
    Test-CommandExists -App 'scoop'
    Test-CommandExists -App 'gsudo'

    try {
        Write-Host "Starting software update process..."

        if ($UseWinget) {
            Write-Host "Running winget updates..."
            winget upgrade --all --accept-package-agreements --accept-source-agreements --disable-interactivity --include-unknown --include-pinned --silent --force
        }

        if ($UseScoop) {
            Write-Host "Updating Scoop..."
            scoop update

            Write-Host "Updating all Scoop apps with elevated privileges..."
            gsudo scoop update *
            
            Remove-ScoopCache
        }

        Write-Host "Software update process completed successfully!"
    } catch {
        Write-Error "An error occurred during the update process: $_"
    }
}