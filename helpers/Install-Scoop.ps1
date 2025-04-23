function Install-Scoop {
    <#
    .SYNOPSIS
        Installs Scoop and specified helper applications, along with additional Scoop buckets.

    .DESCRIPTION
        This script installs Scoop, a command-line installer for Windows, and optionally installs specified helper applications and additional Scoop buckets.
        It ensures the script is run with elevated privileges and sets the execution policy to *RemoteSigned* if necessary.

    .PARAMETER HelperApps
        An array of helper applications to install using Scoop. Defaults to 'git', '7zip', 'gsudo', and 'extras/vcredist2022' if not specified.

    .PARAMETER Buckets
        An array of additional Scoop buckets to add. Defaults to 'extras' and 'versions' if not specified.
        Buckets are repositories of software definitions that Scoop uses to install applications.

    .EXAMPLE
        Install-Scoop -HelperApps @('git', 'nodejs') -Buckets @('extras', 'games')

        Installs Scoop, the specified helper applications (git and nodejs), and adds the specified buckets (extras and games).
    #>

    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string[]]$HelperApps = @('git', '7zip', 'gsudo', 'extras/vcredist2022'),

        [ValidateNotNullOrEmpty()]
        [string[]]$Buckets = @('extras', 'versions')
    )

    Write-Host "Installing Scoop and helper applications..." -ForegroundColor Cyan

    # Elevate privileges
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "This script needs to be run as an administrator. Restarting with elevated privileges..."
        Start-Process powershell.exe "-File $PSCommandPath" -Verb RunAs
        exit
    }

    # Fix untrusted script execution
    if ((Get-ExecutionPolicy) -ne "RemoteSigned") {
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
        Write-Host "Execution Policy has been set to RemoteSigned."
    }

    # Install Scoop
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
        Write-Host "Scoop installed successfully."
    }

    # Install helper Scoop apps
    foreach ($bucket in $Buckets) {
        scoop bucket add $bucket
        # Write-Host "Installed Scoop bucket $bucket."
    }

    foreach ($app in $HelperApps) {
        scoop install $app
    }

    Update-Software -UseScoop

    Write-Host "Scoop and helper applications installed successfully." -ForegroundColor Green
}