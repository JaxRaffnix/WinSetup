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

- **User Folder Management**: Automatically creates common user folders (e.g., `Documents`, `Projects`, `Workspace`).
- **Quick Access Integration**: Adds folders to Quick Access and creates desktop shortcuts.
- **System Customization**: Configures wallpapers, explorer settings, and other system settings.
- **Git Configuration**: Sets up a local Git account with user details.
- **Software Installation**: Installs applications using **Scoop** and **Winget**.
- **Repository Management**: Clones repositories to a specified target folder.
- **System Integrity Testing**: Verifies system health and configuration.

## Installation

### Prerequisites

- Windows PowerShell 5.1 or later.
- Administrative privileges.
- Internet connection for downloading dependencies.

### Steps

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

1. Clone the repository:
    ```powershell
    git clone https://github.com/JaxRaffnix/WinSetup.git
    ```

2. Navigate to the repository folder:
    ```powershell
    cd WinSetup
    ```

3. Run the installation script:
    ```powershell
    .\install.ps1
    ```

## Usage

### Default Configuration

Run the following commands from the project root folder to set up a default configuration:

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
) -TargetFolder "C:\Users\Jax\Coding"

# Test system integrity
Test-SystemIntegrity -All
```


## Configuration

### Customizing User Folders

You can specify custom folders to create:
```powershell
New-UserFolders -Folders @("CustomFolder1", "CustomFolder2") -CreateShortcuts -PinToQuickAccess
```

### Git Configuration

Set up Git with your preferred username and email:
```powershell
Set-GitConfiguration -UserName 'Your Name' -UserEmail 'your.email@example.com'
```

### Application Installation

Install specific applications:
```powershell
Install-Applications -Apps @("7zip", "notepadplusplus", "vscode")
```

## Development

### Updating the Manifest

To regenerate the module's manifest file, run:
```powershell
.\Generate-Manifest.ps1
```

## Known Issues
Winget also updates applications installed with Scoop. This results in a duplication issue, because winget runs the default app installer and doesnt touch the scoop/apps folder.

Whatsapp is installed with ID `9NKSQGP7F2NH`, not with Meta.Whatsapp.

set git aborts if user name and email already match. the other settings are ignored.

Visual Studio Code
Settings and extensions are managed via your GitHub account.

KeePassXC
Enable browser integration for Google Chrome in the settings.
Enable lock after x seconds.

## unsure
"M2Team.NanaZip"

## To Do
Add gcc complier for c with winget


add the following steps to enable posh terminal
https://ohmyposh.dev/docs/installation/prompt

add a font to posh
https://ohmyposh.dev/docs/installation/fonts

add disbale recall option
[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsAI]
"DisableAIDataAnalysis"=dword:00000001

python versions have to be installed explictly:
Python.Python.3.13

add a lazy powerhsell alias that appends the last git commit with the newly added stuff without triggering a new commti,