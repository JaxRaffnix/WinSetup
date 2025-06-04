function Update-Applications {
    <#
    .DESCRIPTION
        This script updates all appliications installed with winget. 
        
    .EXAMPLE
        Update-Applications

    .NOTES
        Ensure that Winget is installed and properly configured on your system before running this script.
        Administrator privileges are called with 'gsudo'.
    #>
    
    Test-Installation -App "gsudo"

    Write-Host "Starting software update process..." -ForegroundColor Cyan
    Write-Warning "Please make sure common apps are closed before running this script. This includes browsers, IDE, terminals, startup apps, etc."

    $OldShortCuts = Get-ChildItem "$env:USERPROFILE\Desktop" -Filter "*.lnk" | Select-Object -ExpandProperty Name
    
    try {
        gsudo winget upgrade --all --accept-package-agreements --accept-source-agreements --disable-interactivity --include-unknown --include-pinned --silent --force

        Remove-AppShortcuts -OldShortCuts $OldShortCuts

        Write-Host "Software update process completed successfully!" -ForegroundColor Green
    } catch {
        Write-Error "An error occurred during the update process: $_"
    }
}

function Remove-AppShortcuts {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $OldShortCuts
    )

    Write-Host "Removing unwanted shortcuts at '$FilePath'" -ForegroundColor Cyan

    $FilePath = "$env:USERPROFILE\Desktop"
    
    if (-not (Test-Path $FilePath)) {
        Throw "The path '$FilePath' does not exist."
    }

    $CurrentShortCuts = Get-ChildItem $FilePath -Filter "*.lnk"

    foreach ($ShortCut in $CurrentShortCuts) {
        if ($OldShortCuts -notcontains $ShortCut.Name) {
            try {
                Remove-Item $ShortCut.FullName -Force
                Write-Warning "Removed newly added shortcut: $($ShortCut.Name)"
            } catch {
                Throw "Failed to remove shortcut: $($ShortCut.Name). Error: $_"
            }
        } else {
            Write-Host "Keeping shortcut: $($ShortCut.Name)"
        }
    }

    Write-Host "Successfully removed unwanted shortcuts." -ForegroundColor Green
}