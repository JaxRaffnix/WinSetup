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
Set-Posh

# Clone repositories
Copy-Repositories -RepoUrls @(
     "https://github.com/JaxRaffnix/Hilfestellung.git",
     "https://github.com/JaxRaffnix/Backup-Manager.git",
     "https://github.com/JaxRaffnix/WinSetup.git"
) -TargetFolder "$HOME\Coding"

# Test system integrity
Test-SystemIntegrity -All