function Test-SystemIntegrity {
    <#
    .SYNOPSIS
    Executes a comprehensive suite of system integrity, storage health, and cleanup checks.

    .DESCRIPTION
    The Test-SystemIntegrity includes checks for system reliability, storage health, and cleanup tasks.

    .PARAMETER SystemHealth
    Performs system health checks, including:
    - Windows Defender status (e.g., real-time protection, antivirus status).
    - System reliability issues from the last 7 days.
    - Startup programs and their configurations.
    - DISM health scan to detect and repair Windows image issues.
    - System File Checker (SFC) to verify and repair system files.
    - CHKDSK to check and repair disk errors.

    .PARAMETER StorageHealth
    Evaluates the health of physical disks, providing details such as:
    - Device ID.
    - Media type (e.g., SSD, HDD).
    - Health status and operational status.

    .PARAMETER Cleanup
    Executes cleanup tasks to optimize system performance, including:
    - Identifying and removing broken desktop shortcuts.
    - Running Disk Cleanup to remove unnecessary files.

    .PARAMETER All
    Runs all available checks, combining system health, storage health, and cleanup tasks.

    .EXAMPLE
    Test-SystemIntegrity -All
    Executes all available checks in one command.

    .NOTES
    Ensure you have administrative privileges and the 'gsudo' tool installed.
    #>

    [CmdletBinding()]
    param (
        [switch]$SystemHealth,
        [switch]$StorageHealth,
        [switch]$Cleanup,
        [switch]$All
    )

    # Expand group switches
    if ($All) {
        $SystemHealth = $true
        $StorageHealth = $true
        $Cleanup = $true
    }

    if (-not ($SystemHealth -or $StorageHealth -or $Cleanup)) {
        Throw "No checks selected. Use -SystemHealth, -StorageHealth, -Cleanup, or -All."
    }

    # Ensure required tools are installed
    Test-Installation -App 'gsudo'

    Write-Host "Starting system integrity checks..." -ForegroundColor Cyan

    # Build list of selected commands
    $commands = @()

    if ($SystemHealth) {
        $commands += @(
            @{ Title = "Windows Defender Summary"; Command = { Get-MpComputerStatus | Select-Object AMServiceEnabled, RealTimeProtectionEnabled, AntivirusEnabled, NISProtectionEnabled | Format-List | Out-String } },
            @{ Title = "System Reliability Issues (Last 7 Days)"; Command = { Get-WinEvent -FilterHashtable @{LogName="System"; StartTime=(Get-Date).AddDays(-7)} | Where-Object {$_.LevelDisplayName -eq "Error"} | Format-Table TimeCreated, Message | Out-String } },
            @{ Title = "Startup Programs"; Command = { Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location | Format-Table | Out-String } },
            @{ Title = "DISM ScanHealth"; Command = { DISM /Online /Cleanup-Image /RestoreHealth } },
            @{ Title = "System File Checker (SFC)"; Command = { gsudo sfc /scannow } },
            @{ Title = "CHKDSK with Fix"; Command = { Write-Output Y | gsudo chkdsk C: /f /r /x } }
        )
    }

    if ($StorageHealth) {
        $commands += @(
            @{ Title = "Physical Disk Health"; Command = { Get-PhysicalDisk | Select-Object DeviceID, MediaType, HealthStatus, OperationalStatus | Format-Table | Out-String } },
            @{ Title = "Disk Usage Analysis"; Command = { Get-PSDrive -PSProvider FileSystem | Select-Object Name, Used, Free, @{Name="Used(%)"; Expression={[math]::Round(($_.Used / ($_.Used + $_.Free)) * 100, 2)}} | Format-Table | Out-String } }
        )
    }

    if ($Cleanup) {
        $commands += @(
            @{ Title = "Broken Desktop Shortcuts"; Command = { 
                Get-ChildItem -Path "$env:USERPROFILE\Desktop" -Filter *.lnk -Recurse | ForEach-Object { 
                    $shell = New-Object -ComObject WScript.Shell
                    $shortcut = $shell.CreateShortcut($_.FullName)
                    if (-not (Test-Path $shortcut.TargetPath)) { 
                        Remove-Item -Path $_.FullName -Force

                        Write-Warning "Removed broken shortcut: $($_.FullName)" 
                    } 
                }
            } },
            @{ Title = "Disk Cleanup"; Command = { cleanmgr /sagerun:1 /autoclean } }
            @{ Title = "Recycle Bin Cleanup"; Command = { Clear-RecycleBin -Force -ErrorAction SilentlyContinue } }
        )
    }

    # Run commands
    foreach ($cmd in $commands) {
        Write-Host "`n=== $($cmd.Title) ===" -ForegroundColor Cyan
        Write-Host "Executing: $($cmd.Command)" -ForegroundColor DarkCyan
        
        try {
            $cmd.Command
        } catch {
            Write-Error "$($cmd.Title) failed: $_"
        }
    }

    Write-Host "`nSystem integrity check completed." -ForegroundColor Green
}
