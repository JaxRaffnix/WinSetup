# WinSetup - Windows Configuration Helper

A PowerShell module that simplifies the process of configuring Windows, such as creating user folders, setting up Git, and installing software with Scoop and Winget.

## Features

- Creates common user folders (`Documents`, `Projects`, etc.).
- Configures a local Git account.
- Installs software using **Scoop** and **Winget**.
- Adds folders to Quick Access and creates desktop shortcuts.

## Installation

To install this module, download the `WinSetup` repository and run the `install.ps1` script.

The default configuration can be created with this:
```
New-UserFolders -Folders @("Workspace", "Workspace\Temp", "Coding")
Set-Git -UserName 'Jax Raffnix' -UserEmail '75493600+JaxRaffnix@users.noreply.github.com'
Copy-Repos -RepoUrls @("https://github.com/JaxRaffnix/Hilfestellung.git", "https://github.com/JaxRaffnix/Backup-Manager.git", "https://github.com/JaxRaffnix/WinSetup.git") -TargetFolder "C:\Users\Jax\Coding"
```

## Developing

To update the manifest file, run the `Generate-Manifest.ps1` file.