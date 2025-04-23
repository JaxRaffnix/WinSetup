function Install-WithWinget {
    param (
        [Parameter(Mandatory = $true)]
        [string]$App
    )

    $alreadyInstalledMessages = @(
        "No newer package versions are available from the configured sources",
        "The specified application is already installed",
        "is already installed",
        "Installer failed with exit code: 29"
    )

    $Result = Invoke-CommandWithLogging -Command "winget install -e --id $App --silent --accept-source-agreements --accept-package-agreements --disable-interactivity --force" -SkipOnError

    if ($Result.Errors) {
        if ($alreadyInstalledMessages | Where-Object { $Result.Output -match $_ }) {
            Write-Warning "Already installed $App."
        } else {
            Write-Warning "Could not install $App."
        }
    } else {
        # Write-Host "Successfully installed $App."
    }
}