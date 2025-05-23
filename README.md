<!-- LTeX: language=en-US -->

# WinSetup - Windows Configuration Helper

A PowerShell module designed to streamline the process of configuring Windows environments. With **WinSetup**, tasks such as creating user folders, setting up Git, and installing software using **Winget** are automated.

## Table of Contents

- [WinSetup - Windows Configuration Helper](#winsetup---windows-configuration-helper)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Installation](#installation)
    - [Prerequisites](#prerequisites)
    - [Steps](#steps)
    - [Manual Configurations](#manual-configurations)
  - [Usage](#usage)
    - [Available Commands](#available-commands)
    - [Imported Functions](#imported-functions)
  - [Development](#development)
    - [Updating the Manifest](#updating-the-manifest)
    - [Known Issues](#known-issues)
    - [Unsure to Include](#unsure-to-include)
    - [To Do](#to-do)

## Features

- **User Folder Management**: Automatically creates common user folders (e.g., `Temp`, `Coding`, `Workspace`).
- **Quick Access Integration**: Adds folders to Quick Access and creates desktop shortcuts.
- **System Customization**: Configures wallpapers, explorer settings, and other system settings.
- **Git Configuration**: Sets up a local Git account with user details.
- **Software Installation**: Installs applications using **Winget**.
- **Repository Management**: Clones repositories to a specified target folder.
- **System Integrity Testing**: Verifies system health and configuration.

## Installation

### Prerequisites

- Windows PowerShell 5.1 or later.
- Administrative privileges.
- Internet connection for downloading dependencies.

### Steps

1. Allow the execution of script files:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

2. Clone the repository:

```powershell
git clone https://github.com/JaxRaffnix/WinSetup.git
```

3. Navigate to the setup folder:

```powershell
cd WinSetup/setup
```

4. Install the module:

```powershell
.\install.ps1
```

5. Configure your machine with custom setup parameters (optionally change configuration details)

```powershell
config\DefaultSetup.ps1
```

### Manual Configurations

- **Visual Studio Code:** Settings and extensions are managed via your GitHub account.
- **KeepassXC:** Enable browser integration for Google Chrome in the settings. Enable lock after x seconds. Set Auto Type Shortcut to `CTRL+ALT+A`.
- **MikTeX:** Check for upgrades.

## Usage 

### Available Commands

| Command                      | Description                                                                                   | Example Usage                                 |
|------------------------------|-----------------------------------------------------------------------------------------------|-----------------------------------------------|
| `ga`                         | Alias for amending the latest Git commit with all current changes.                            | `ga`                                          |
| `Copy-Repositories`          | Clones a list of repositories to a specified target folder.                                   | `Copy-Repositories -RepoUrls @("https://github.com/user/repo1.git", "https://github.com/user/repo2.git") -TargetFolder "$HOME\Projects"`  |
| `Install-Applications`       | Installs a predefined list of applications using Winget.                                      | `Install-Applications -All`                        |
| `Install-MSOffice`           | Installs Microsoft Office suite using the appropriate installer.                              | `Install-MSOffice -ConfigLocation "$HOME\OfficeConfig.xml"`                            |
| `Set-Posh`                   | Installs and configures Oh My Posh for PowerShell prompt customization.                       | `Set-Posh -FontName "MesloLGM Nerd Font"`                                    |
| `New-UserFolders`            | Creates common user folders (e.g., Temp, Coding, Workspace) in the user's profile directory.  | `New-UserFolders -Folders @("Workspace", "Coding") -CreateDesktopShortcuts -PinToQuickAccess`                             |
| `Set-GitConfiguration`       | Configures Git user name, email, and other settings for the current user.                     | `Set-GitConfiguration -UserName "Alice" -UserEmail "alice@example.com"` |
| `Set-WindowsConfiguration`   | Applies system settings such as explorer preferences and privacy options.                      | `Set-WindowsConfiguration -All`                    |
| `Set-WallpaperAndLockScreen` | Sets the desktop wallpaper and lock screen image.                                             | `Set-WallpaperAndLockScreen -WallpaperPath "$HOME\Images\wallpaper.jpg" -LockScreenPath "$HOME\Images\lockscreen.jpg"`        |
| `Test-SystemIntegrity`       | Runs checks to verify system health and configuration integrity.                              | `Test-SystemIntegrity -All`                        |
| `Update-Applications`        | Updates installed applications via Winget.                                                    | `Update-Applications`                         |

> [!NOTE] 
> Use `Get-Help <Command>` in PowerShell for detailed usage and parameter information.

### Imported Functions
- PSScriptTools, eg. Show-Tree -InColor -ShowItem
- Terminal-Icons, Get-ChildItem -Path . -Force
- PSReadLine, `CTRL+SPACE` for auto complete

## Development

### Updating the Manifest

To regenerate the module's manifest file, run:

```powershell
.\Generate-Manifest.ps1
```

### Known Issues

- `Set-GitConfiguration` aborts if user name and email already match. The other settings are ignored.
- Some App IDs are strings, not a descriptive name. E.g. `9NKSQGP7F2NH` for WhatsApp.
- Python versions have to be installed explicitly: `Python.Python.3.13`
- BattleNet requires an install location. Specify the install root: `C:\Program Files (x86)`.
- No explicit C compiler is necessary, it is already part of Strawberry.

### Unsure to Include

- M2Team.NanaZip
- Zoom.Zoom

### To Do

-
