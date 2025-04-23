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

    Test-CommandExists -App 'scoop'
    Test-CommandExists -App 'gsudo'

    try {
        Write-Host "Removing Scoop cache..." 
        scoop cache rm *

        Write-Host "Performing Scoop cleanup with elevated privileges..." 
        gsudo scoop cleanup *

        Write-Host "Running Scoop checkup..." 
        scoop checkup
    } catch {
        Write-Error "An error occurred while cleaning Scoop: $_"
    }
}