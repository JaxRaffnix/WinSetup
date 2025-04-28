# import necessary functions
. .$PSScriptRoot\helpers\Install-Category.ps1
. .$PSScriptRoot\helpers\Install-WithWinget.ps1
. .$PSScriptRoot\helpers\Install-PSModule.ps1

# Execute when the module is imported.
try {
    Install-Category -Category 'Initialize' -ConfigLocation "$ModulePath\config\apps.json" -ErrorAction Stop

    Write-Host "Module $ModuleName imported successfully." -ForegroundColor Green
} catch {
    Write-Error "Failed to import module $ModuleName : $_"
}