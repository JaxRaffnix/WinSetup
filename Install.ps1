<#
.SYNOPSIS
Installs this module into the user's PowerShell module path.

.DESCRIPTION
Copies the current folder (the module folder) to the user's module path under
$env:USERPROFILE\Documents\PowerShell\Modules, overwriting if needed.
Then imports the module to make it available immediately.
#>

$ModuleName = Split-Path -Leaf $PSScriptRoot
$UserModulesPath = "$env:USERPROFILE\Documents\PowerShell\Modules"
$TargetPath = Join-Path -Path $UserModulesPath -ChildPath $ModuleName

# Remove the existing module folder if it exists
if (Test-Path $TargetPath) {
    Write-Host "Removing existing module at '$TargetPath'..."
    Remove-Item -Path $TargetPath -Recurse -Force
}

Write-Host "Installing module '$ModuleName' to '$TargetPath'..."
# Create target path if it doesn't exist
if (-not (Test-Path $TargetPath)) {
    New-Item -ItemType Directory -Path $TargetPath -Force | Out-Null
}

# Copy all files from this folder to the user module path
Copy-Item -Path "$PSScriptRoot\*" -Destination $TargetPath -Recurse -Force

# Import the module
try {
    $env:PSModulePath += ";$UserModulesPath"    #Update the Environment variable to include the new module path
    Import-Module $ModuleName -Force -ErrorAction Stop
    Write-Host "Module '$ModuleName' installed and imported successfully." -ForegroundColor Green
} catch {
    Write-Error "Failed to import module '$ModuleName': $_"
}
