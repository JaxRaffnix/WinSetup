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
    
    try {
        gsudo winget upgrade --all --accept-package-agreements --accept-source-agreements --disable-interactivity --include-unknown --include-pinned --silent --force

        Write-Host "Software update process completed successfully!" -ForegroundColor Green
    } catch {
        Write-Error "An error occurred during the update process: $_"
    }
}