<!-- LTeX: language=en-US -->

# WinSetup - Windows Configuration Helper

A PowerShell module designed to streamline the process of configuring Windows environments. With **WinSetup**, you can automate tasks such as creating user folders, setting up Git, and installing software using **Scoop** and **Winget**.

## Table of Contents

1. [Features](#features)
2. [Installation](#installation)
3. [Usage](#usage)
4. [Configuration](#configuration)
5. [Development](#development)
6. [To Do](#to-do)

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

3. Navigate to the repository folder:

```powershell
cd WinSetup
```

4. Install the module:

```powershell
.\install.ps1
```

5. Run the Installation in a Powershell console:
This is an example how a configuration could look like.

```powershell
# Remember evelated credentials in cache, results in less pop ups
gsudo cache on

# Configure Git
Set-GitConfiguration -UserName 'Jax Raffnix' -UserEmail '75493600+JaxRaffnix@users.noreply.github.com'

# Create user folders and shortcuts
New-UserFolders -Folders @("Workspace", "Coding") -CreateDesktopShortcuts -PinToQuickAccess
New-UserFolders -Folders @("Temp")

# Apply system-wide configurations
Set-WindowsConfiguration -All
Set-WallpaperAndLockScreen -WallpaperPath ".\assets\wallpaper.jpg" -LockScreenPath ".\assets\wallpaper.jpg"

# Install applications
Install-Applications -Core -Messengers -ProgrammingTools -Games
Install-MSOffice -ConfigLocation ".\assets\office365.xml"

# Clone repositories
Copy-Repositories -RepoUrls @(
     "https://github.com/JaxRaffnix/Hilfestellung.git",
     "https://github.com/JaxRaffnix/Backup-Manager.git",
     "https://github.com/JaxRaffnix/WinSetup.git"
) -TargetFolder "$HOME\Coding"

# Test system integrity
Test-SystemIntegrity -All
```

### Manual Configurations

- **Visual Studio Code:** Settings and extensions are managed via your GitHub account.
- **KeepassXC:** Enable browser integration for Google Chrome in the settings. Enable lock after x seconds. Set Auto Type Shortcut to `CTRl+ALT+A`
- **MikTeX:** Check for Upgrades,

## Available Commands

- Copy-Repositories
- Install-Applications
- Install-MSOffice
- New-UserFolders
- Switch-ToQuickAccess
- Set-GitConfiguration
- Set-WindowsConfiguration
- Set-WallpaperAndLockScreen
- Test-SystemIntegrity
- Update-Applications

## Development

### Updating the Manifest

To regenerate the module's manifest file, run:

```powershell
.\Generate-Manifest.ps1
```

### Known Issues

- `Set-GitConfiguration` aborts if user name and email already match. the other settings are ignored.
- Some App IDs are strings and not with a descriptive name. E.g. `9NKSQGP7F2NH` for whatsapp.
- python versions have to be installed explictly: `Python.Python.3.13`
- BattleNet requires an install location. Specify the install root: `C:\Program Files (x86)`.
- C Compiler is part of Strawberry

### Unsure to Include

- M2Team.NanaZip
- Zoom.Zoom

### To Do

- add the following steps to enable posh terminal <https://ohmyposh.dev/docs/installation/prompt>
- add a font to posh <https://ohmyposh.dev/docs/installation/fonts>
- add a lazy powerhsell alias that appends the last git commit with the newly added stuff without triggering a new commti,
