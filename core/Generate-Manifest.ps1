New-ModuleManifest -Path .\WinSetup.psd1 `
    -RootModule 'WinSetup.psm1' `
    -ModuleVersion '1.0.0' `
    -Author 'Jan Hoegen' `
    -Description 'Simplifies Windows configuration. Installs apps with winget and allow configuration of Windows settings. Additionally, GitHub Projects can be cloned, the local git account can be configured and the system can be checked for errors.' `
    -ProjectUri 'https://github.com/JaxRaffnix/WinSetup' `
    -PowerShellVersion '5.1' `
    -ScriptsToProcess "core/Initialize-Module.ps1" `
    -FunctionsToExport  @(
        'Copy-Repositories'
        'Install-Applications'
        'Install-MSOffice'
        'Set-Posh'
        'New-UserFolders'
        'Set-GitConfiguration'
        'Invoke-GitAmend'
        'Set-WindowsConfiguration'
        'Set-WallpaperAndLockScreen'
        'Test-SystemIntegrity'
        'Update-Applications'
    ) `
    -AliasesToExport @('ga')
