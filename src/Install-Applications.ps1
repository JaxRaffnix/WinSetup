function Install-Applications {
    <#
    .SYNOPSIS
    Installs applications using Scoop and Winget.

    .DESCRIPTION
    Automatically installs a list of applications using Scoop and Winget.

    .PARAMETER Core
    Installs core applications using Scoop.

    .PARAMETER Games
    Installs games using Winget.

    .PARAMETER Messengers
    Installs messaging applications.

    .PARAMETER ProgrammingTools
    Installs programming-related applications.

    .PARAMETER All
    Installs all categories of applications.

    .EXAMPLE
    Install-Applications -All
    Installs all categories of applications.
    #>

    [CmdletBinding()]
    param (
        [switch]$Core,
        [switch]$Games,
        [switch]$Messengers,
        [switch]$ProgrammingTools,
        [switch]$All
    )

    # Enable all categories if -All is specified
    if ($All) {
        $Core = $true
        $Games = $true
        $Messengers = $true
        $ProgrammingTools = $true
    }

    if (-not ($Core -or $Games -or $Messengers -or $ProgrammingTools)) {
        Write-Error "Please specify at least one category to install."
        return 1
    }

    # Load applications from JSON file
    $AppsFile = "$PSScriptRoot\config\apps.json"
    if (-not (Test-Path $AppsFile)) {
        Write-Error "Applications file not found at $AppsFile."
        return 1
    }
    $Applications = Get-Content -Path $AppsFile | ConvertFrom-Json

    # Ensure required tools are installed
    Test-Installation -App 'winget'
    Test-Installation -App 'scoop'
    Test-Installation -App 'gsudo'

    Update-Applications -UseScoop

    # Install selected categories
    if ($Core) {
        Write-Host "Installing core applications..." -ForegroundColor Cyan

        foreach ($app in $Applications.Core.Scoop) {
            Install-WithScoop $app
        }

        foreach ($script in $Applications.Core.ContextScripts) {
            if (Test-Path $script) {
                & $script
            }
        }

        foreach ($app in $Applications.Core.Winget) {
            Install-WithWinget $app
        }

        gsudo Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
        gsudo Install-Module PSScriptTools
    }

    if ($Messengers) {
        Write-Host "Installing messengers..." -ForegroundColor Cyan

        foreach ($app in $Applications.Messengers.Scoop) {
            Install-WithScoop $app
        }

        foreach ($app in $Applications.Messengers.Winget) {
            Install-WithWinget $app
        }
    }

    if ($ProgrammingTools) {
        Write-Host "Installing programming tools..." -ForegroundColor Cyan

        foreach ($app in $Applications.ProgrammingTools.Scoop) {
            Install-WithScoop $app
        }

        foreach ($script in $Applications.ProgrammingTools.PythonScripts) {
            if (Test-Path $script -or $script -match 'python.exe') {
                & $script
            }
        }

        foreach ($link in $Applications.ProgrammingTools.ExternalLinks) {
            Start-Process $link
        }
    }

    if ($Games) {
        Write-Host "Installing games..." -ForegroundColor Cyan

        Install-ScoopBucket games

        foreach ($app in $Applications.Games.Scoop) {
            Install-WithScoop $app
        }

        foreach ($app in $Applications.Games.Extra) {
            gsudo scoop install $app
        }

        foreach ($app in $Applications.Games.Winget) {
            Install-WithWinget $app
        }

        foreach ($link in $Applications.Games.ExternalLinks) {
            Start-Process $link
        }
    }

    # Update software repositories
    Update-Applications -All

    Write-Host "Finished app install process." -ForegroundColor Green

    # Clean up Scoop cache
    Remove-ScoopCache
}


function Install-MSOffice {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$ConfigLocation
    )

    if (-not (Test-Path $ConfigLocation)) {
        Write-Error "Configuration file not found at $ConfigLocation."
        return 1
    }

    Test-Installation -App 'winget'

    Install-WithWinget Microsoft.OfficeDeploymentTool
    Set-Location "C:\Program Files\OfficeDeploymentTool";  .\setup.exe /configure "$ConfigLocation"
    
    Write-Host "MS Office installation completed." -ForegroundColor Green
}
