<#
.SYNOPSIS
Installs this module into the user's PowerShell module path.

.DESCRIPTION
Copies the current folder (the module folder) to the user's module path under
$env:USERPROFILE\Documents\PowerShell\Modules, overwriting if needed.
Then imports the module to make it available immediately.
#>

$ModuleName = Split-Path -Leaf $PSScriptRoot
$TargetPath = Join-Path -Path "$HOME\Documents\PowerShell\Modules" -ChildPath $ModuleName

Write-Host "Installing module '$ModuleName' to '$TargetPath'..."

# Create target path if it doesn't exist
if (-not (Test-Path $TargetPath)) {
    New-Item -ItemType Directory -Path $TargetPath -Force | Out-Null
}

# Copy all files from this folder to the user module path
Copy-Item -Path "$PSScriptRoot\*" -Destination $TargetPath -Recurse -Force

# Import the module
try {
    Import-Module $ModuleName -Force -ErrorAction Stop
    Write-Host "Module '$ModuleName' installed and imported successfully." -ForegroundColor Green
} catch {
    Write-Error "Failed to import module '$ModuleName': $_"
}
