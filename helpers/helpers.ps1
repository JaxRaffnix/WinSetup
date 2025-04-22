function Test-CommandExists {
    <#
    .SYNOPSIS
    Checks if a specific command-line application is installed and accessible.

    .DESCRIPTION
    Uses Get-Command to determine if an executable like 'git',  etc., is available in the system's PATH.

    .PARAMETER App
    The name of the application or command to check (e.g., 'git', 'gsudo').

    .EXAMPLE
    Test-CommandExists -App 'git'
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$App
    )


    if (-not (Get-Command $App -ErrorAction SilentlyContinue)) {
        Write-Error "$App is not installed or not available in the PATH. Please install $App and try again."
    }
}

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