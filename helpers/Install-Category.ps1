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
                        Write-Host "Invoking Expression: $script"
                        Invoke-Expression $script
                    } catch {
                        Write-Error "Failed to execute script: $_"
                    }
                }
            }
            "Modules" {
                foreach ($module in $Applications.$Category.Modules) {
                    Install-PSModule -ModuleName $module
                }
            }
            "ExternalLinks" {
                foreach ($link in $Applications.$Category.ExternalLinks) {
                    Write-Host "Opening external link: $link"
                    Start-Process $link
                }
            }
            default {
                Throw "Unknown subcategory '$SubCategory' found in '$Category'."
            }
        }
    }

    Write-Host "Installation for category '$Category' completed." -ForegroundColor Green
}