. $PSScriptRoot\Install-WithWinget.ps1

function Initialize-Module {
    <#
    .SYNOPSIS
        Installs applications listed in the init.json file using Winget.

    .DESCRIPTION

    .EXAMPLE
        Initialize-Module

        Reads the init.json file and installs the applications listed in it using Winget.
    #>

    [CmdletBinding()]
    param (
        [string]$initFilePath = (Join-Path -Path $PSScriptRoot -ChildPath 'config\init.json')
    )

   

    if (-not (Test-Path $initFilePath)) {
        Write-Error "init.json file not found at $initFilePath. Please ensure the file exists."
        return
    }

    Write-Host "Reading init.json file..." -ForegroundColor Cyan
    $initData = Get-Content -Path $initFilePath -Raw | ConvertFrom-Json

    foreach ($app in $initData.apps) {
        Install-WithWinget $app
    }

    Write-Host "All applications installed successfully." -ForegroundColor Green
}

Initialize-Module
