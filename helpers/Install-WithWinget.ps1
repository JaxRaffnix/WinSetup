$alreadyInstalledMessages = @(
    "No newer package versions are available from the configured sources",
    "The specified application is already installed",
    "is already installed",
    "Installer failed with exit code: 29"
)

function Install-WithWinget {
    <#
    .SYNOPSIS
    Installs an application using Winget.

    .DESCRIPTION
    The `Install-WithWinget` function installs an application using the Winget package manager. 
    It supports silent installation and automatically accepts source and package agreements. 
    The function also handles cases where the application is already installed or if the installation fails.

    .PARAMETER App
    The ID of the application to be installed. This parameter is mandatory.

    .EXAMPLE
    Install-WithWinget -App "Microsoft.VisualStudioCode"

    This example installs Visual Studio Code using Winget.

    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$App
    )

    Test-Installation -App "Winget"

    # Write-Host "Installing '$App' using Winget..."

    try {
        $Result = winget install -e --id $App --silent --accept-source-agreements --accept-package-agreements --disable-interactivity --force 

        if ($alreadyInstalledMessages | Where-Object { $Result -match $_ }) {
            Write-Warning "The application '$App' is already installed."
        } elseif ($Result -match "Successfully installed") {
            Write-Host "Successfully installed '$App'."
        } else {
            Write-Error "Failed to install '$App'. Output: $Result"
        }
    } catch {
        Write-Error "An unexpected error occurred while installing '$App'. Error: $_"
    }
}