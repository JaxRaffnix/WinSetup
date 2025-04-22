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
        [string[]]$ScoopApps = @("git", "neovim"),
        [string[]]$WingetApps = @("Mozilla.Firefox", "Microsoft.PowerToys")
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
}

Export-ModuleMember -Function Install-Software
