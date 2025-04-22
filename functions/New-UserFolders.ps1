function New-UserFolders {
    <#
    .SYNOPSIS
    Creates user folders and links them via Desktop shortcuts and Quick Access.

    .DESCRIPTION
    For each folder under $env:USERPROFILE:
    - Creates the folder if it doesn't exist
    - Creates a shortcut on the Desktop
    - Pins the folder to Quick Access

    .PARAMETER Folders
    List of folder paths (relative to $env:USERPROFILE).
    Default is @("Workspace", "Workspace\Temp", "Coding").

    .EXAMPLE
    New-UserFolders -Folders @("Workspace", "Workspace\Temp", "Coding")
    #>

    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string[]]$Folders = @("Workspace", "Workspace\Temp", "Coding")
    )

    foreach ($folder in $Folders) {
        $path = Join-Path -Path $env:USERPROFILE -ChildPath $folder

        if (-not (Test-Path $path)) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
            Write-Host "Created folder: $path"
        } else {
            Write-Host "Folder already exists: $path"
        }

        Add-Shortcut -TargetPath $path
        Add-ToQuickAccess -FolderPath $path
    }
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

    $desktop = [Environment]::GetFolderPath("Desktop")
    $shortcutName = "$([System.IO.Path]::GetFileName($TargetPath)).lnk"
    $shortcutPath = Join-Path $desktop $shortcutName

    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $TargetPath
    $shortcut.Save()

    Write-Host "Shortcut created: $shortcutPath"
}

function Add-ToQuickAccess {
    <#
    .SYNOPSIS
    Pins a folder to Quick Access in File Explorer.

    .DESCRIPTION
    Uses Windows Shell COM to pin the folder to Quick Access.

    .PARAMETER FolderPath
    Full path to the folder to pin.

    .EXAMPLE
    Add-ToQuickAccess -FolderPath "$env:USERPROFILE\Projects"
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
            Write-Warning "Cannot access folder: $FolderPath"
        }

    } catch {
        Write-Warning "Failed to pin to Quick Access: $($_.Exception.Message)"
    }
}
