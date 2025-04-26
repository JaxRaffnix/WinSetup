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

    Write-Host "Installing $Category applications from '$ConfigLocation'..." -ForegroundColor Cyan

    $SubCategories = $Applications.$Category.PSObject.Properties.Name

    switch ($SubCategories) {
        'Winget' {
            foreach ($app in $Applications.Core.Winget) {
                Install-WithWinget $app
            }
        }
        'Scripts' {
            foreach ($script in $Applications.Core.Scripts) {
                try {
                    & $script

                    Write-Host "Executed script: $script"
                } catch {
                    Write-Error "Failed to resolve script path: $_"
                }
            }
        }
        'Modules' {
            foreach ($module in $Applications.Core.Modules) {
                try {
                    gsudo Install-Module -Name $module -Force -Scope CurrentUser -AllowClobber

                    Write-Host "Installed PowerShell module: $module"
                } catch {
                    Write-Error "Failed to install PowerShell module: $_"
                }                
            }
        }
        'ExternalLinks' {
            foreach ($link in $Applications.Core.ExternalLinks) {
                Write-Host "Opening external link: $link"
                Start-Process $link
            }
        }
        default {
            Write-Error "Unknown subcategory '$SubCategories' in '$Category'."
        }
    }

    Write-Host "Installation for '$Category' completed!" -ForegroundColor Green
}