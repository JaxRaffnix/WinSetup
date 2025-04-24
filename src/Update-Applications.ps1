function Update-Applications {
    <#
    .SYNOPSIS
        Automates the process of updating software using Winget and Scoop package managers.

    .DESCRIPTION
        This script updates installed applications with winget and Scoop. 
        
    .EXAMPLE
        Update-Applications
        Updates all installed software using both Winget and Scoop package managers.

    .NOTES
        Ensure that both Winget and Scoop are installed and properly configured on your system before running this script.
        Administrator privileges are called with 'gsudo'.
    #>

    [CmdletBinding()]
    param (
    )

    Write-Host "Starting software update process..." -ForegroundColor Cyan
    Write-Warning "Please make sure common apps are closed before running this script. This includes browsers, IDE, terminals, startup apps, etc."
    
    try {
        winget upgrade --all --accept-package-agreements --accept-source-agreements --disable-interactivity --include-unknown --include-pinned --silent --force

        Write-Host "Software update process completed successfully!" -ForegroundColor Green
    } catch {
        Write-Error "An error occurred during the update process: $_"
    }
}