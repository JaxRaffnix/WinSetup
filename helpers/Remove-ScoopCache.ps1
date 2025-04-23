function Remove-ScoopCache {
    <#
    .SYNOPSIS
    Removes Scoop cache, performs cleanup, and checks for issues.

    .DESCRIPTION
    This function removes all cached files, performs a cleanup using elevated privileges, 
    and runs a checkup to identify any potential issues with Scoop.

    .EXAMPLE
    Remove-ScoopCache
    #>

    Test-Installation -App 'scoop'
    Test-Installation -App 'gsudo'

    try {
        Write-Host "Removing Scoop cache and running cleanup ..." -ForegroundColor Cyan
        scoop cache rm *
        gsudo scoop cleanup *

        scoop checkup
        Write-Host "Scoop cache removed and cleanup completed." -ForegroundColor Green
    } catch {
        Write-Error "An error occurred while cleaning Scoop: $_"
    }
}