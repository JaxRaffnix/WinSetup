function Set-WindowsConfiguration {
    <#
    .SYNOPSIS
    Configures local Windows settings.

    .DESCRIPTION
    This function sets up various local Windows settings such as time zone, power settings, and system preferences.

    .PARAMETER All
    Enables all configuration options.

    .PARAMETER EnableClipboardSync
    Enables clipboard history and sync with devices.

    .PARAMETER HideSearchIcon
    Hides or shows the Windows Search icon.

    .PARAMETER EnableSearchIndex
    Enables the Windows Search Indexing service.

    .PARAMETER EnableDarkMode
    Enables dark mode for Windows.

    .PARAMETER EnableFullPathInExplorer
    Enables showing the full path in the Explorer title bar.

    .PARAMETER ShowHiddenFiles
    Enables showing hidden files in File Explorer.

    .PARAMETER ShowFileExtensions
    Enables showing file extensions in File Explorer.

    .PARAMETER EnableLongPaths
    Enables support for long file paths.

    .PARAMETER EnableDeveloperMode
    Enables Windows Developer Mode.

    .EXAMPLE
    Set-WindowsConfiguration -All
    #>

    [CmdletBinding()]
    param (
        [switch]$All,
        [switch]$EnableClipboardSync,
        [switch]$HideSearchIcon,
        [switch]$EnableSearchIndex,
        [switch]$EnableDarkMode,
        [switch]$EnableFullPathInExplorer,
        [switch]$ShowHiddenFiles,
        [switch]$ShowFileExtensions,
        [switch]$EnableLongPaths,
        [switch]$EnableDeveloperMode
    )

    Write-Host "Starting Windows configuration setup..." 

    # If -All switch is provided, enable all options
    if ($All) {
        $EnableClipboardSync = $true
        $HideSearchIcon = $true
        $EnableSearchIndex = $true
        $EnableDarkMode = $true
        $EnableFullPathInExplorer = $true
        $ShowHiddenFiles = $true
        $ShowFileExtensions = $true
        $EnableLongPaths = $true
        $EnableDeveloperMode = $true
    }

    # Enable clipboard history and sync if the switch is provided
    if ($EnableClipboardSync) {
        try {
            Write-Host "Enabling clipboard history and sync with devices..." 
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Value 1 -Force
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "EnableClipboardSync" -Value 1 -Force
            Write-Host "Clipboard history and sync enabled successfully." 
        } catch {
            Write-Warning "Failed to enable clipboard history and sync: $_" 
        }
    }

    # Configure Windows Search icon visibility if the switch is provided
    if ($HideSearchIcon) {
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -Force
            Write-Host "Windows Search icon hidden successfully." 
        } catch {
            Write-Warning "Failed to hide the Windows Search icon: $_" 
        }
    }

    # Enable Windows Search Indexing if the switch is provided
    if ($EnableSearchIndex) {
        try {
            Start-Service -Name "WSearch" -ErrorAction Stop
            Set-Service -Name "WSearch" -StartupType Automatic -ErrorAction Stop
            Write-Host "Windows Search Indexing service enabled successfully." 
        } catch {
            Write-Warning "Failed to enable Windows Search Indexing service: $_" 
        }
    }

    # Enable dark mode if the switch is provided
    if ($EnableDarkMode) {
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 -Force
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0 -Force
            Write-Host "Dark mode enabled successfully." 
        } catch {
            Write-Warning "Failed to enable dark mode: $_" 
        }
    }

    # Enable full path in Explorer title bar if the switch is provided
    if ($EnableFullPathInExplorer) {
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPathAddress" -Value 1 -Force
            Write-Host "Full path in Explorer title bar enabled successfully." 
        } catch {
            Write-Warning "Failed to enable full path in Explorer title bar: $_" 
        }
    }

    # Show hidden files if the switch is provided
    if ($ShowHiddenFiles) {
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 -Force
            Write-Host "Hidden files are now visible in File Explorer." 
        } catch {
            Write-Warning "Failed to show hidden files: $_" 
        }
    }

    # Show file extensions if the switch is provided
    if ($ShowFileExtensions) {
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Force
            Write-Host "File extensions are now visible in File Explorer." 
        } catch {
            Write-Warning "Failed to show file extensions: $_" 
        }
    }

    # Enable long paths if the switch is provided
    if ($EnableLongPaths) {
        try {
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -Force
            Write-Host "Support for long file paths enabled successfully." 
        } catch {
            Write-Warning "Failed to enable support for long file paths: $_" 
        }
    }

    # Enable Developer Mode if the switch is provided
    if ($EnableDeveloperMode) {
        try {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Force
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowAllTrustedApps" -Value 1 -Force
            Write-Host "Developer Mode enabled successfully." 
        } catch {
            Write-Warning "Failed to enable Developer Mode: $_" 
        }
    }

    Write-Host "Windows configuration setup completed." -ForegroundColor Green
}

function Set-WallpaperAndLockScreen {
    <#
    .SYNOPSIS
    Sets the Windows wallpaper and lock screen image.

    .DESCRIPTION
    This function allows you to set a custom image as the Windows desktop wallpaper and lock screen image.

    .PARAMETER WallpaperPath
    The file path to the image to be used as the desktop wallpaper.

    .PARAMETER LockScreenPath
    The file path to the image to be used as the lock screen image.

    .EXAMPLE
    Set-WallpaperAndLockScreen -WallpaperPath "C:\Images\wallpaper.jpg" -LockScreenPath "C:\Images\lockscreen.jpg"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$WallpaperPath,

        [Parameter(Mandatory = $true)]
        [string]$LockScreenPath
    )

    try {
        # Set the desktop wallpaper
        Write-Host "Setting desktop wallpaper to $WallpaperPath..."
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);

    public const int SPI_SETDESKWALLPAPER = 20;
    public const int SPIF_UPDATEINIFILE = 0x01;
    public const int SPIF_SENDCHANGE = 0x02;

    public static void SetWallpaper(string path) {
        SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, path, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
    }
}
"@
        [Wallpaper]::SetWallpaper($WallpaperPath)
        Write-Host "Desktop wallpaper set successfully."

        # Set the lock screen image
        $lockScreenKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
        Set-ItemProperty -Path $lockScreenKey -Name "LockScreenImagePath" -Value $LockScreenPath -Force
        Set-ItemProperty -Path $lockScreenKey -Name "LockScreenImageStatus" -Value 1 -Force

        # Disable Widgets
        # Get-AppxPackage | Where-Object {$_.Name -like "*WebExperience*"} | Remove-AppxPackage

        Write-Host "Lock screen image set successfully."
    } catch {
        Write-Warning "Failed to set wallpaper or lock screen image: $_"
    }
}