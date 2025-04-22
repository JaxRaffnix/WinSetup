function Test-SystemIntegrity {
    <#
    .SYNOPSIS
    Runs grouped system integrity and cleanup checks.

    .DESCRIPTION
    Supports high-level switches: -SystemHealth, -StorageHealth, -CleanupTasks, -All

    .EXAMPLE
    Test-SystemIntegrity -All
    Test-SystemIntegrity -SystemHealth -CleanupTasks
    #>

    [CmdletBinding()]
    param (
        [switch]$SystemHealth,
        [switch]$StorageHealth,
        [switch]$CleanupTasks,
        [switch]$All
    )

    # Expand group switches
    if ($All) {
        $SystemHealth = $true
        $StorageHealth = $true
        $CleanupTasks = $true
    }

    if (-not ($SystemHealth -or $StorageHealth -or $CleanupTasks)) {
        Write-Warning "No checks selected. Use -SystemHealth, -StorageHealth, -CleanupTasks, or -All."
        return
    }

    Test-SystemIntegrity -App 'gsudo'

    $timestamp = Get-Date -Format 'yyyy-MM-dd-HHmmss'
    $logFile = Join-Path $env:TEMP "SystemIntegrityCheck-$timestamp.log"

    Write-Host "Running system integrity checks..."
    Write-Host "Log file: $logFile`n"

    # CleanupTasks – Broken shortcuts
    if ($CleanupTasks) {
        Write-Host "Checking for broken shortcuts..."
        Get-ChildItem -Path "$env:USERPROFILE\Desktop" -Filter *.lnk -Recurse | ForEach-Object {
            if (-not (Test-Path ($_ | Select-Object -ExpandProperty Target))) {
                Write-Warning "Broken shortcut: $($_.FullName)"
            }
        }
    }

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

    if ($CleanupTasks) {
        $commands += @{ Title = "Disk Cleanup"; Command = 'cleanmgr /sagerun:1 /autoclean' }
    }

    # Run commands
    foreach ($cmd in $commands) {
        Write-Host "`n=== $($cmd.Title) ===" -ForegroundColor Cyan
        "`n=== $($cmd.Title) ===`n" | Out-File -Append -FilePath $logFile

        try {
            Invoke-Expression $cmd.Command 2>&1 | Tee-Object -Variable output | Out-File -Append -FilePath $logFile
            $output
        } catch {
            Write-Warning "$($cmd.Title) failed: $_"
            "ERROR: $_" | Out-File -Append -FilePath $logFile
        }
    }

    Write-Host "`nSystem integrity check completed. Log saved to:`n$logFile" -ForegroundColor Green
}
