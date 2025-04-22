New-ModuleManifest -Path .\WinSetup.psd1 `
    -RootModule 'WinSetup.psm1' `
    -Author 'Jan Hoegen' `
    -Description 'Simplifies Windows configuration...' `
    -FunctionsToExport 'New-UserFolders', 'Add-Shortcut', 'Add-ToQuickAccess'
