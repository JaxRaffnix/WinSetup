function New-UserFolders {
    <#
    .SYNOPSIS
    Creates user folders and optionally links them via Desktop shortcuts and Quick Access.

    .DESCRIPTION
    For each folder under $env:USERPROFILE:
    - Creates the folder if it doesn't exist
    - Optionally creates a shortcut on the Desktop
    - Optionally pins the folder to Quick Access

    .PARAMETER Folders
    List of folder paths (relative to $env:USERPROFILE).

    .PARAMETER CreateDesktopShortcuts
    Switch to create Desktop shortcuts for the folders.

    .PARAMETER PinToQuickAccess
    Switch to pin the folders to Quick Access.

    .EXAMPLE
    New-UserFolders -Folders @("Workspace", "Workspace\Temp", "Coding") -CreateDesktopShortcuts -PinToQuickAccess
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Folders,

        [Parameter()]
        [switch]$CreateDesktopShortcuts,

        [Parameter()]
        [switch]$PinToQuickAccess
    )

    Write-Host "Creating user folders..." -ForegroundColor Cyan

    foreach ($folder in $Folders) {
        $path = Join-Path -Path $env:USERPROFILE -ChildPath $folder

        try {
            if (-not (Test-Path $path)) {
                New-Item -ItemType Directory -Path $path -Force | Out-Null
                Write-Host "Created folder: $path"
            } else {
                Write-Warning "Folder already exists: $path"
            }
        } catch {
            Write-Error "Failed to create folder '$path': $($_.Exception.Message)"
        }

        if ($CreateDesktopShortcuts) {
            Add-Shortcut -TargetPath $path
        }

        if ($PinToQuickAccess) {
            Switch-ToQuickAccess -FolderPath $path
        }
    }

    Write-Host "Finished creating user folders." -ForegroundColor Green
}

function Add-Shortcut {
    <#
    .SYNOPSIS
    Creates a desktop shortcut to a given folder.

    .DESCRIPTION
    Creates a `.lnk` file on the desktop that links to the specified folder.

    .PARAMETER TargetPath
    The full path of the folder to create a shortcut for.

    .EXAMPLE
    Add-Shortcut -TargetPath "$env:USERPROFILE\Projects"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$TargetPath
    )

    try {
        $desktop = [Environment]::GetFolderPath("Desktop")
        $shortcutName = "$([System.IO.Path]::GetFileName($TargetPath)).lnk"
        $shortcutPath = Join-Path $desktop $shortcutName

        if (Test-Path $shortcutPath) {
            $shell = New-Object -ComObject WScript.Shell
            $existingShortcut = $shell.CreateShortcut($shortcutPath)

            if ($existingShortcut.TargetPath -eq $TargetPath) {
                Write-Warning "Shortcut already exists and points to the correct target: $shortcutPath"
                return 1
            } else {
                Write-Warning "Shortcut exists but points to a different target. Overwriting: $shortcutPath"
            }
        }

        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $TargetPath
        $shortcut.Save()

        Write-Host "Shortcut created: $shortcutPath"
    } catch {
        Write-Error "Failed to create shortcut for '$TargetPath': $($_.Exception.Message)"
    }
}

function Switch-ToQuickAccess {
    <#
    .SYNOPSIS
    Pins a folder to Quick Access in File Explorer.

    .DESCRIPTION
    Uses Windows Shell COM to pin the folder to Quick Access.

    .PARAMETER FolderPath
    Full path to the folder to pin.

    .EXAMPLE
    Switch-ToQuickAccess -FolderPath "$env:USERPROFILE\Projects"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$FolderPath
    )

    try {
        $Shell = New-Object -ComObject Shell.Application
        $Namespace = $Shell.Namespace($FolderPath)
        if ($Namespace) {
            $Namespace.Self.InvokeVerb("pintohome")
            Write-Host "Folder added to Quick Access: '$FolderPath'"
        } else {
            Write-Error "Cannot access folder: $FolderPath"
        }

    } catch {
        Write-Error "Failed to pin to Quick Access: $($_.Exception.Message)"
    }
}
