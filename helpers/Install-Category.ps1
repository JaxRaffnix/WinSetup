function Install-Category {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Category,
        [string]$ConfigLocation = (Join-Path -Path $PSScriptRoot -ChildPath '..\config\apps.json')
    )

    if (-not (Test-Path $ConfigLocation)) {
        Throw "Configuration file not found at $ConfigLocation."
    }

    try {
        $Applications = Get-Content -Path $ConfigLocation -Raw | ConvertFrom-Json
    } catch {
        Throw "Failed to parse '$ConfigLocation'. Ensure it's properly formatted JSON."
    }

    if (-not $Applications.$Category) {
        Throw "No '$Category' found in '$ConfigLocation'."
    }

    Write-Host "Installing apps with category '$Category' from '$ConfigLocation'..." -ForegroundColor Cyan

    $SubCategories = $Applications.$Category.PSObject.Properties.Name

    foreach ($SubCategory in $SubCategories) {
        Write-Host "Processing subcategory '$SubCategory'..." 
        
        switch ($SubCategory) {
            "Winget" {
                foreach ($app in $Applications.$Category.Winget) {
                    Install-WithWinget $app
                }
            }
            "Scripts" {
                foreach ($script in $Applications.$Category.Scripts) {
                    try {
                        Write-Host "Invoking Expression: '$script'"
                        Invoke-Expression $script
                    } catch {
                        Write-Error "Failed to execute script: $_"
                    }
                }
            }
            "Modules" {
                Test-Installation -App "gsudo"
                foreach ($module in $Applications.$Category.Modules) {
                    try {
                        Write-Host "Installing PowerShell module: $module"
                        gsudo Install-Module -Name $module -Force -Scope CurrentUser -AllowClobber
                        Import-Module -Name $module -Force -Scope CurrentUser -ErrorAction Stop
                    } catch {
                        Write-Error "Failed to install PowerShell module '$module': $_"
                    }
                }
            }
            "ExternalLinks" {
                foreach ($link in $Applications.$Category.ExternalLinks) {
                    Write-Host "Opening external link: $link"
                    Start-Process $link
                }
            }
            default {
                Write-Error "Unknown subcategory '$SubCategory' found in '$Category'."
            }
        }
    }

    Write-Host "Installation for category '$Category' completed." -ForegroundColor Green
}