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
        return -1
    }

    # Ensure required tools are installed
    Test-Installation -App 'winget'
    Test-Installation -App 'scoop'
    Test-Installation -App 'gsudo'

    Update-Applications -UseScoop

    # Install selected categories
    if ($Core) {
        Write-Host "Installing core applications..." -ForegroundColor Cyan

        $ScoopCoreApps = @('vscode', 'powertoys', 'keepassxc', 'restic', 'obsidian', 'googlechrome', 'mathpix')
        foreach ($app in $ScoopCoreApps) {
            Install-WithScoop $app
        }
        
        "$HOME\scoop\apps\powertoys\current\install-context.ps1"

        "$HOME\scoop\apps\vscode\current\install-context.reg"
        "$HOME\scoop\apps\vscode\current\install-associations.reg"  
        "$HOME\scoop\apps\vscode\current\install-github-integration.reg"

        $WingetCoreApps = @('Microsoft.WindowsTerminal', 'Spotify.Spotify', 'Google.GoogleDrive')
        foreach ($app in $WingetCoreApps) {
            Install-WithWinget $app
        }

        gsudo Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
        gsudo Install-Module PSScriptTools
    }

    if ($Messengers) {
        Write-Host "Installing messengers..." -ForegroundColor Cyan

        $ScoopMessengersApps = @('discord', 'signal', 'thunderbird')
        foreach ($app in $ScoopMessengersApps) {
            Install-WithScoop $app
        }

        $WingetMessengersApps = @('9NKSQGP7F2NH')   # this installs whatsapp.
        foreach ($app in $WingetMessengersApps) {
            Install-WithWinget $app
        }
    }

    if ($ProgrammingTools) {
        Write-Host "Installing programming tools..." -ForegroundColor Cyan

        $ProgrammingApps =  @('gcc', 'inkscape', 'miktex', 'perl', 'python', 'rufus', 'pdfcpu')
        foreach ($app in $ProgrammingApps) {
            Install-WithScoop $app
        }

        "$HOME\scoop\apps\python\current\install-pep-514.reg" 
        "python.exe -m pip install --upgrade pip"

        Start-Process "https://www.mathworks.com/products/matlab.html"
        Start-Process "https://www.analog.com/en/design-center/design-tools-and-calculators/ltspice-simulator.html"
    }

    if ($Games) {
        Write-Host "Installing games..." -ForegroundColor Cyan

        Install-ScoopBucket games

        $ScoopGamesApps = @('playnite', 'battlenet', 'steam', 'ubisoftconnect', 'nvidia-profile-inspector')
        foreach ($app in $ScoopGamesApps) {
            Install-WithScoop $app
        }

        gsudo scoop install epic-games-launcher

        $WingetGamesApps = @('ElectronicArts.EADesktop', 'Logitech.GHUB', 'Nvidia.GeForceExperience', 'RiotGames.Valorant.EU')
        foreach ($app in $WingetGamesApps) {
            Install-WithWinget $app
        }

        Start-Process "https://www.duckychannel.com.tw/en/support"
    }

    # Update software repositories
    Update-Applications -All

    Write-Host "Finished app install process." -ForegroundColor Green

    # Clean up Scoop cache
    Remove-ScoopCache

    Test-SystemIntegrity -All
}


function Install-MSOffice {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ConfigLocation
    )

    if (-not (Test-Path $ConfigLocation)) {
        Write-Error "Configuration file not found at $ConfigLocation."
        return -1
    }

    Test-Installation -App 'winget'

    Install-WithWinget Microsoft.OfficeDeploymentTool
    Set-Location "C:\Program Files\OfficeDeploymentTool";  .\setup.exe /configure "$ConfigLocation"
    
    Write-Host "MS Office installation completed." -ForegroundColor Green
}
