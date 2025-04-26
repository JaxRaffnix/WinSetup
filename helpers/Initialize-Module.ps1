# load required modules
. $PSScriptRoot\Install-Category.ps1
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
        [string]$ConfigLocation = (Join-Path -Path $PSScriptRoot -ChildPath '..\config\init.json')
    )


    if (-not (Test-Path $ConfigLocation)) {
        Throw "init.json file not found at $ConfigLocation. Please ensure the file exists."
    }

    Write-Host "Initializing module with config location '$ConfigLocation' ..." -ForegroundColor Cyan

    try {  
        Install-Category -Category 'Initialize' -ConfigLocation $ConfigLocation

        Write-Host "All applications installed successfully." -ForegroundColor Green
    } catch {
        Write-Error "Failed to install applications: $_"
    }
}
