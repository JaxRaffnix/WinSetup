New-ModuleManifest -Path .\WinSetup.psd1 `
    -RootModule 'WinSetup.psm1' `
    -ModuleVersion '1.0.0' `
    -Author 'Jan Hoegen' `
    -Description 'Simplifies Windows configuration.' `
    -ProjectUri 'https://github.com/JaxRaffnix/WinSetup' `
    -PowerShellVersion '5.1' `
    -ScriptsToProcess @('Install-Scoop.ps1') `
    -FunctionsToExport  @(
        'Copy-Repositories'
        'Install-Applications'
        'Install-MSOffice'
        'New-UserFolders'
        'Switch-ToQuickAccess'
        'Set-GitConfiguration'
        'Set-WindowsConfiguration'
        'Set-WallpaperAndLockScreen'
        'Update-Software'
    )
