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

    gsudo cache on
    
    try {
        Write-Host "Updating installed PowerShell modules."
        gsudo Update-Module

        gsudo winget upgrade --all --accept-package-agreements --accept-source-agreements --disable-interactivity --include-unknown --include-pinned --silent --force 
        # --uninstall-previous # ! unintalling old version can have negative consequences. e.g. when updating game launcher, installed games will be deleted.

        Remove-AppShortcuts -OldShortCuts $OldShortCuts

        Write-Host "Software update process completed successfully!" -ForegroundColor Green
    } catch {
        Write-Error "An error occurred during the update process: $_"
    }
}

function Remove-AppShortcuts {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $OldShortCuts
    )

    $UserDesktopPath = "$env:USERPROFILE\Desktop"
    $PublicDesktopPath = "C:\Users\Public\Desktop"

    $DesktopPaths = @($UserDesktopPath, $PublicDesktopPath)

    foreach ($FilePath in $DesktopPaths) {
        Write-Host "Removing unwanted shortcuts at '$FilePath'" -ForegroundColor Cyan

        if (-not (Test-Path $FilePath)) {
            Write-Warning "The path '$FilePath' does not exist. Skipping..."
            continue
        }

        $CurrentShortCuts = Get-ChildItem $FilePath -Filter "*.lnk"

        gsudo cache on

        foreach ($ShortCut in $CurrentShortCuts) {
            if ($OldShortCuts -notcontains $ShortCut.Name) {
                try {
                    gsudo Remove-Item $ShortCut.FullName -Force
                    Write-Warning "Removed newly added shortcut: $($ShortCut.Name)"
                } catch {
                    Write-Error "Failed to remove shortcut: $($ShortCut.Name). Error: $_"
                }
            } else {
                Write-Host "Keeping shortcut: $($ShortCut.Name)"
            }
        }
    }

    Write-Host "Successfully removed unwanted shortcuts." -ForegroundColor Green
}


# temporary test

# $OldShortCuts = Get-ChildItem "$env:USERPROFILE\Desktop" -Filter "*.lnk" | Select-Object -ExpandProperty Name

# Write-Host "Old Shortcuts: "
# Write-Host $OldShortCuts

# Copy-Item "C:\Users\Jax\Temp\Epic Games Launcher.lnk" -Destination "C:\Users\Public\Desktop"

# Remove-AppShortcuts -OldShortCuts $OldShortCuts