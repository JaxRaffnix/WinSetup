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