function Test-Installation {
    <#
    .SYNOPSIS
    Checks if a specific command-line application is installed and accessible.

    .DESCRIPTION
    Uses Get-Command to determine if an executable like 'git',  etc., is available in the system's PATH.

    .PARAMETER App
    The name of the application or command to check (e.g., 'git', 'gsudo').

    .EXAMPLE
    Test-Installation -App 'git'
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