. $PSScriptRoot\Install-ScoopBucket.ps1
. $PSScriptRoot\Install-WithScoop.ps1
. $PSScriptRoot\Install-WithWinget.ps1

function Install-Scoop {
    <#
    .SYNOPSIS
        Installs Scoop and specified helper applications, along with additional Scoop buckets.

    .DESCRIPTION
        This script installs Scoop, a command-line installer for Windows, and optionally installs specified helper applications and additional Scoop buckets.
        It ensures the script is run with elevated privileges and sets the execution policy to *RemoteSigned* if necessary.

    .PARAMETER ScoopHelperApps
        An array of helper applications to install using Scoop. Defaults to 'git', '7zip', 'gsudo', and 'extras/vcredist2022' if not specified.

    .PARAMETER Buckets
        An array of additional Scoop buckets to add. Defaults to 'extras' and 'versions' if not specified.
        Buckets are repositories of software definitions that Scoop uses to install applications.

    .EXAMPLE
        Install-Scoop -ScoopHelperApps @('git', 'nodejs') -Buckets @('extras', 'games')

        Installs Scoop, the specified helper applications (git and nodejs), and adds the specified buckets (extras and games).
    #>

    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string[]]$ScoopHelperApps = @('git', '7zip', 'gsudo', 'extras/vcredist2022'),

        [ValidateNotNullOrEmpty()]
        [string[]]$WingetHelperApps = @('Microsoft.NuGet'),

        [ValidateNotNullOrEmpty()]
        [string[]]$Buckets = @('extras', 'versions')
    )

    Write-Host "Installing Scoop and helper applications..." -ForegroundColor Cyan

    # Install Scoop
    if ((Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Warning "Scoop is already installed."
        # return 
    } else {
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
        Write-Host "Scoop installed successfully."
    }

    # Install helper Scoop apps
    foreach ($bucket in $Buckets) {
        Install-ScoopBucket -Bucket $bucket
    }

    foreach ($app in $ScoopHelperApps) {
        Install-WithScoop -App $app
    }

    foreach ($app in $WingetHelperApps) {
        Install-WithWinget -App $app
    }

    # Update-Applications -All

    Write-Host "Scoop and helper applications installed successfully." -ForegroundColor Green
}

# Write-Host "You are here!"

Install-Scoop