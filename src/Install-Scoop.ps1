function Install-Scoop {
    <#
    .SYNOPSIS
        Installs Scoop and specified helper applications.

    .DESCRIPTION
        This script installs Scoop, a command-line installer for Windows, and optionally installs specified helper applications.

    .PARAMETER HelperApps
        An array of helper applications to install using Scoop. Defaults to 'git', '7zip', and 'curl' if not specified.

    .EXAMPLE
        Install-Scoop -HelperApps @('git', 'nodejs', 'python')

        Installs Scoop and the specified helper applications: git, nodejs, and python.

    .NOTES
        This script requires administrative privileges to run.
    #>

    [CmdletBinding()]
    param (
        [string[]]$HelperApps = @('git', '7zip', 'gsudo', 'extras/vcredist2022'),
        [string[]]$Buckets = @('extras', 'versions')
    )

    # Elevate privileges
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "This script needs to be run as an administrator. Restarting with elevated privileges..."
        Start-Process powershell.exe "-File $PSCommandPath" -Verb RunAs
        exit
    }

    # Fix untrusted script execution
    if ((Get-ExecutionPolicy) -ne "RemoteSigned") {
        Write-Host "Setting execution policy to RemoteSigned..."
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
    }

    # Install Scoop
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Scoop..."
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
    }

    foreach ($bucket in $Buckets) {
        Write-Host "Adding Scoop bucket: $bucket..."
        scoop bucket add $bucket
    }
    # Install helper Scoop apps
    foreach ($app in $HelperApps) {
        Write-Host "Installing $app..."
        scoop install $app
    }

    Update-Software -Mode 'Scoop'
}