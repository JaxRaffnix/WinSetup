# $ModuleName = "WinSetup"
$ModulePath = $PSScriptRoot

# Write-Host "Importing Module $ModuleName at '$ModulePath' ..." -ForegroundColor Cyan

# load helper functions
$HelperFolder = "$ModulePath\helpers"
foreach ($file in (Get-ChildItem -Path $HelperFolder -Filter '*.ps1')) {
    . $file.FullName
}

# Load all function scripts
$SourceFolder = "$ModulePath\src"
foreach ($file in (Get-ChildItem -Path $SourceFolder -Filter '*.ps1')) {
    . $file.FullName
}

# TODO: This should not be necessary. There is a strange error when importing this module.
# TODO: The initialize script has been temporarily disabled.
Export-ModuleMember -Function `
    Copy-Repositories,
    Install-Applications,
    Install-MSOffice,
    Set-Posh,
    New-UserFolders,
    Set-GitConfiguration,
    Git-Amend,
    Set-WindowsConfiguration,
    Set-WallpaperAndLockScreen,
    Test-SystemIntegrity,
    Update-Applications