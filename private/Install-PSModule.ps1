function Install-PSModule {
    param (
        $ModuleName
    )

    Test-Installation -App "gsudo"

    try {
        # gsudo 
        Install-Module -Name $ModuleName -Force -Scope CurrentUser -AllowClobber
        Import-Module -Name $ModuleName -Force -Scope Local -ErrorAction Stop

        Write-Host "Module '$ModuleName' installed and imported successfully."
    } catch {
        Write-Error "Failed to install PowerShell module '$ModuleName': $_"
    }
}