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

    Write-Host "Installing apps with category $Category from '$ConfigLocation'..." -ForegroundColor Cyan

    $SubCategories = $Applications.$Category.PSObject.Properties.Name


    switch ($SubCategories) {
        'Winget' {
            foreach ($app in $Applications.$SubCategories.Winget) {
                Install-WithWinget $app
            }
        }
        'Scripts' {
            foreach ($script in $Applications.$SubCategories.Scripts) {
                try {
                    & $script

                    Write-Host "Executed script: $script"
                } catch {
                    Write-Error "Failed to resolve script path: $_"
                }
            }
        }
        'Modules' {
            Test-Installation -App 'gsudo'
            foreach ($module in $Applications.$SubCategories.Modules) {
                try {
                    gsudo Install-Module -Name $module -Force -Scope CurrentUser -AllowClobber
                    Import-Module -Name $module -Force -Scope CurrentUser -ErrorAction Stop

                    Write-Host "Installed PowerShell module: $module"
                } catch {
                    Write-Error "Failed to install PowerShell module: $_"
                }                
            }
        }
        'ExternalLinks' {
            foreach ($link in $Applications.$SubCategories.ExternalLinks) {
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