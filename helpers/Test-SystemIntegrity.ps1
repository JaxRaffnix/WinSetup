function Test-SystemIntegrity {
    <#
    .SYNOPSIS
    Performs a comprehensive set of system integrity, storage health, and cleanup checks.

    .DESCRIPTION
    This function allows you to run grouped checks for system health, storage health, and cleanup tasks. 
    You can select specific checks using the provided switches or run all checks at once using the -All switch.
    Results are logged to a timestamped file in the TEMP directory for review.

    .PARAMETER SystemHealth
    Runs checks related to system health, including Windows Defender status, system reliability issues, 
    startup programs, DISM health scan, System File Checker (SFC), and CHKDSK.

    .PARAMETER StorageHealth
    Checks the health status of physical disks, including media type, health status, and operational status.

    .PARAMETER Cleanup
    Performs cleanup tasks such as identifying broken shortcuts on the desktop and running Disk Cleanup.

    .PARAMETER All
    Runs all available checks: system health, storage health, and cleanup tasks.

    .EXAMPLE
    Test-SystemIntegrity -All
    Runs all system integrity, storage health, and cleanup tasks.
    #>

    [CmdletBinding()]
    param (
        [switch]$SystemHealth,
        [switch]$StorageHealth,
        [switch]$Cleanup,
        [switch]$All = $true
    )

    # Expand group switches
    if ($All) {
        $SystemHealth = $true
        $StorageHealth = $true
        $Cleanup = $true
    }

    if (-not ($SystemHealth -or $StorageHealth -or $Cleanup)) {
        Write-Warning "No checks selected. Use -SystemHealth, -StorageHealth, -Cleanup, or -All."
        return
    }

    Test-Installation -App 'gsudo'

    $timestamp = Get-Date -Format 'yyyy-MM-dd-HHmmss'
    $logFile = Join-Path $env:TEMP "SystemIntegrityCheck-$timestamp.log"

    Write-Host "Running system integrity checks..."

    # Build list of selected commands
    $commands = @()

    if ($SystemHealth) {
        $commands += @(
            @{ Title = "Windows Defender Summary"; Command = 'Get-MpComputerStatus | Select-Object AMServiceEnabled, RealTimeProtectionEnabled, AntivirusEnabled, NISProtectionEnabled | Format-List | Out-String' },
            @{ Title = "System Reliability Issues (Last 7 Days)"; Command = 'Get-WinEvent -FilterHashtable @{LogName="System"; StartTime=(Get-Date).AddDays(-7)} | Where-Object {$_.LevelDisplayName -eq "Error"} | Format-Table TimeCreated, Message | Out-String' },
            @{ Title = "Startup Programs"; Command = 'Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location | Format-Table | Out-String' },
            @{ Title = "DISM ScanHealth"; Command = 'DISM /Online /Cleanup-Image /RestoreHealth' },
            @{ Title = "System File Checker (SFC)"; Command = 'gsudo sfc /scannow' },
            @{ Title = "CHKDSK with Fix"; Command = 'echo Y | gsudo chkdsk C: /f /r /x' }
        )
    }

    if ($StorageHealth) {
        $commands += @{ Title = "Physical Disk Health"; Command = 'Get-PhysicalDisk | Select-Object DeviceID, MediaType, HealthStatus, OperationalStatus | Format-Table | Out-String' }
    }

    if ($Cleanup) {
        $commands += @(
            @{ Title = "Broken Desktop Shortcuts"; Command = 'Get-ChildItem -Path "$env:USERPROFILE\Desktop" -Filter *.lnk -Recurse | ForEach-Object { $shell = New-Object -ComObject WScript.Shell; $shortcut = $shell.CreateShortcut($_.FullName); if (-not (Test-Path $shortcut.TargetPath)) { Write-Warning "Broken shortcut: $($_.FullName)" } }'},
            @{ Title = "Disk Cleanup"; Command = 'cleanmgr /sagerun:1 /autoclean' }
            )
    }	

    # Run commands
    foreach ($cmd in $commands) {
        Write-Host "`n=== $($cmd.Title) ===" -ForegroundColor Cyan
        "`n=== $($cmd.Title) ===`n" | Out-File -Append -FilePath $logFile
    
        try {
            Write-Host "Executing: $($cmd.Command)" -ForegroundColor DarkCyan
            Invoke-Expression $cmd.Command
        } catch {
            Write-Warning "$($cmd.Title) failed: $_"
        }
    }

    Write-Host "`nSystem integrity check completed." -ForegroundColor Green
}
