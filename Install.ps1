<#
.SYNOPSIS
Installs the current PowerShell module into the user's module path.

.DESCRIPTION
This script automates the installation of a PowerShell module by copying the current folder to the user's module path located at 
'$env:USERPROFILE\Documents\PowerShell\Modules'. If a module with the same name already exists, 
it will be overwritten. After copying, the module is imported to make it immediately available 
for use in the current session.

.NOTES
- Ensure this script is run from the module folder.

.EXAMPLE
.\Install.ps1
This command installs the module located in the current folder into the user's PowerShell 
module path and imports it into the current session.
#>

# Elevate privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script needs to be run as an administrator. Restarting with elevated privileges..."
    Start-Process powershell.exe "-NoExit -File $PSCommandPath" -Verb RunAs
    exit
}

# Fix untrusted script execution
if ((Get-ExecutionPolicy) -ne "RemoteSigned") {
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
    Write-Host "Execution Policy has been set to RemoteSigned."
}

# Define variables
$ModuleName = Split-Path -Leaf $PSScriptRoot
$UserModulesPath = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\PowerShell\Modules"
$TargetPath = Join-Path -Path $UserModulesPath -ChildPath $ModuleName

Write-Host "Installing module '$ModuleName' to '$TargetPath'..." -ForegroundColor Cyan

# Remove the existing module folder if it exists
if (Test-Path $TargetPath) {
    try {
        Remove-Item -Path $TargetPath -Recurse -Force -ErrorAction Stop
        
        Write-Host "Removed existing module at '$TargetPath'."
    } catch {
        Write-Error "Failed to remove existing module folder: $_"
        exit 1
    }
}

# Create target path if it doesn't exist
if (-not (Test-Path $TargetPath)) {
    try {
        New-Item -ItemType Directory -Path $TargetPath -Force | Out-Null

        Write-Host "Created target directory '$TargetPath'."
    } catch {
        Write-Error "Failed to create target directory: $_"
        exit 1
    }
}

# Copy all files from this folder to the user module path
try {
    Copy-Item -Path "$PSScriptRoot\*" -Destination $TargetPath -Recurse -Force -ErrorAction Stop

    Write-Host "Copied Module to '$TargetPath'."
} catch {
    Write-Error "Failed to copy module files: $_"
    exit 1
}

# Import the module
try {
    $env:PSModulePath += ";$UserModulesPath"  # Update the environment variable to include the new module path
    Import-Module $ModuleName -Force -ErrorAction Stop

    Write-Host "Module '$ModuleName' installed and imported successfully." -ForegroundColor Green
} catch {
    Write-Error "Failed to import module '$ModuleName': $_"
    exit 1
}
