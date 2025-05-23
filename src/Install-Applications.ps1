function Install-Applications {
    <#
    .SYNOPSIS
    Installs applications using Scoop and Winget.

    .DESCRIPTION
    Automatically installs a list of applications using Scoop and Winget.

    .PARAMETER Core
    Installs core applications using Scoop.

    .PARAMETER Games
    Installs games using Winget.

    .PARAMETER Messengers
    Installs messaging applications.

    .PARAMETER ProgrammingTools
    Installs programming-related applications.

    .PARAMETER All
    Installs all categories of applications.

    .EXAMPLE
    Install-Applications -All
    Installs all categories of applications.
    #>

    [CmdletBinding()]
    param (
        [switch]$Core,
        [switch]$Games,
        [switch]$Messengers,
        [switch]$ProgrammingTools,
        [switch]$All,
        [string]$ConfigLocation = (Join-Path -Path $PSScriptRoot -ChildPath '..\config\apps.json')
    )

    # Enable all categories if -All is specified
    if ($All) {
        $Core = $true
        $Games = $true
        $Messengers = $true
        $ProgrammingTools = $true
    }

    if (-not ($Core -or $Games -or $Messengers -or $ProgrammingTools)) {
        Throw "No categories specified. Use -Core, -Games, -Messengers, or -ProgrammingTools to specify categories."
    }

    # Update-Applications

    if ($Core) {
        Install-Category -Category 'Core' -ConfigLocation $ConfigLocation
    }
    if ($Games) {
        Install-Category -Category 'Games' -ConfigLocation $ConfigLocation
    }
    if ($Messengers) {
        Install-Category -Category 'Messengers' -ConfigLocation $ConfigLocation
    }
    if ($ProgrammingTools) {
        Install-Category -Category 'ProgrammingTools' -ConfigLocation $ConfigLocation
    }

    # Update software repositories
    Update-Applications 

    Write-Host "Finished app install process." -ForegroundColor Green
}


function Install-MSOffice {
    <#
    .SYNOPSIS
        Installs Microsoft Office using the Office Deployment Tool and a specified configuration file.

    .DESCRIPTION
        This function installs Microsoft Office by first ensuring the Office Deployment Tool is installed via winget.
        It then runs the setup executable with the provided configuration XML file to perform a customized Office installation.

    .PARAMETER ConfigLocation
        The full path to the Office Deployment Tool configuration XML file. The file must exist.

    .EXAMPLE
        Install-MSOffice -ConfigLocation "$HOME\OfficeConfig.xml"

        Installs Microsoft Office using the configuration specified in OfficeConfig.xml.

    .NOTES
        Requires administrative privileges and the Office Deployment Tool to be available via winget.
    #>


    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$ConfigLocation
    )

    if (-not (Test-Path $ConfigLocation)) {
        Throw "Configuration file not found at $ConfigLocation."
    }

    Install-WithWinget Microsoft.OfficeDeploymentTool
    Set-Location "C:\Program Files\OfficeDeploymentTool"
    .\setup.exe /configure "$ConfigLocation"
    
    Write-Host "MS Office installation completed." -ForegroundColor Green
}

function Set-Posh {
    <#
    .SYNOPSIS
        Configures Oh My Posh and sets the MesloLGM Nerd Font for Windows Terminal.

    .DESCRIPTION
        Ensures Oh My Posh is initialized in the PowerShell profile, installs the MesloLGM Nerd Font,
        and updates Windows Terminal settings to use the font.

    .PARAMETER ProfilePath
        Optional. Path to the PowerShell profile to update. Defaults to $PROFILE.

    .EXAMPLE
        Set-Posh
        Sets up Oh My Posh and configures the font for Windows Terminal.
    #>
    [CmdletBinding()]
    param (
        [string]$ProfilePath = $PROFILE,
        [string]$FontName = "MesloLGM Nerd Font"
    )

    Write-Host "Setting up Oh My Posh..." -ForegroundColor Cyan

    # Ensure profile file exists
    if (!(Test-Path $ProfilePath)) {
        New-Item -Path $ProfilePath -Type File -Force | Out-Null
    }

    # Add Oh My Posh initialization if not already present
    $initLine = 'oh-my-posh init pwsh | Invoke-Expression'
    $profileContent = Get-Content $ProfilePath -Raw
    if ($profileContent -notmatch [regex]::Escape($initLine)) {
        Add-Content $ProfilePath "`n$initLine"
        Write-Host "Added Oh My Posh initialization to profile."
    } else {
        Write-Warning "Oh My Posh initialization already present in profile."
    }

    # Install MesloLGM Nerd Font if not already installed
    $fontInstalled = (Get-WmiObject -Query "Select * from Win32_FontInfoAction" | Where-Object { $_.Caption -like "*$FontName*" }).Count -gt 0
    if (-not $fontInstalled) {
        oh-my-posh font install meslo
        Write-Host "Installed MesloLGM Nerd Font." 
    } else {
        Write-Warning "MesloLGM Nerd Font already installed." 
    }

    # Update Windows Terminal font
    $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    if (Test-Path $settingsPath) {
        $json = Get-Content $settingsPath -Raw | ConvertFrom-Json
        if ($null -eq $json.profiles) { $json | Add-Member -MemberType NoteProperty -Name profiles -Value @{} }
        if ($null -eq $json.profiles.defaults) { $json.profiles | Add-Member -MemberType NoteProperty -Name defaults -Value @{} }
        $json.profiles.defaults.font = $json.profiles.defaults.font ?? @{}
        $json.profiles.defaults.font.face = $fontName
        $json | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8
        Write-Host "Windows Terminal font updated to $fontName!"
    } else {
        Write-Warning "Windows Terminal settings.json not found. Skipping font update."
    }

    Write-Host "Oh My Posh setup completed." -ForegroundColor Green
}
