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
        [switch]$All,
        [string]$ConfigLocation = (Join-Path -Path $PSScriptRoot -ChildPath '..\config\apps.json')
    )

    # Enable all categories if -All is specified
    if ($All) {
        $Core = $true
        $Games = $true
        $Messengers = $true
        $ProgrammingTools = $true
    }

    if (-not ($Core -or $Games -or $Messengers -or $ProgrammingTools)) {
        Throw "No categories specified. Use -Core, -Games, -Messengers, or -ProgrammingTools to specify categories."
    }

    # Update-Applications

    if ($Core) {
        Install-Category -Category 'Core' -ConfigLocation $ConfigLocation
    }
    if ($Games) {
        Install-Category -Category 'Games' -ConfigLocation $ConfigLocation
    }
    if ($Messengers) {
        Install-Category -Category 'Messengers' -ConfigLocation $ConfigLocation
    }
    if ($ProgrammingTools) {
        Install-Category -Category 'ProgrammingTools' -ConfigLocation $ConfigLocation
    }

    # Update software repositories
    Update-Applications 

    Write-Host "Finished app install process." -ForegroundColor Green
}


function Install-MSOffice {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$ConfigLocation
    )

    if (-not (Test-Path $ConfigLocation)) {
        Throw "Configuration file not found at $ConfigLocation."
    }

    Install-WithWinget Microsoft.OfficeDeploymentTool
    Set-Location "C:\Program Files\OfficeDeploymentTool";  .\setup.exe /configure "$ConfigLocation"
    
    Write-Host "MS Office installation completed." -ForegroundColor Green
}
