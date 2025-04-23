function Install-Software {
    <#
    .SYNOPSIS
    Installs software using Scoop and Winget.

    .DESCRIPTION
    Automatically installs a list of applications using Scoop and Winget.

    .PARAMETER ScoopApps
    An array of app names to install using Scoop.

    .PARAMETER WingetApps
    An array of app IDs to install using Winget.

    .EXAMPLE
    Install-Software -ScoopApps @("git") -WingetApps @("Mozilla.Firefox")
    #>

    [CmdletBinding()]
    param (
        [string[]]$ScoopApps,
        [string[]]$WingetApps 
    )

    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Scoop..."
        Invoke-Expression (New-Object Net.WebClient).DownloadString('https://get.scoop.sh')
    }

    foreach ($app in $ScoopApps) {
        scoop install $app
    }

    foreach ($app in $WingetApps) {
        winget install --id $app --silent --accept-source-agreements --accept-package-agreements
    }

    update-Software
    Remove-ScoopCache
}

function Install-MSOffice {
    param(
        [string]$ConfigLocation
    )
    if (-not (Test-Path $ConfigLocation)) {
        Write-LogWarning "Configuration file not found at $ConfigLocation. Skipping Office installation."
        return
    }

    Test-Installation -App 'winget'

    Install-WithWinget Microsoft.OfficeDeploymentTool
    Set-Location "C:\Program Files\OfficeDeploymentTool";  .\setup.exe /configure "$ConfigLocation"
}
