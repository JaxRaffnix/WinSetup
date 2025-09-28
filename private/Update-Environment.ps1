function Update-Environment {
    <#
    .SYNOPSIS
        Refresh environment variables from the registry without restarting PowerShell.

    .DESCRIPTION
        This function reloads system and user environment variables from the registry
        and updates the current session accordingly.

    .NOTES
        Inspired by @beatcracker's Detect-Subshell and Chocolatey's RefreshEnv.cmd
    #>

    [CmdletBinding()]
    param()

    Write-Host "Refreshing environment variables from registry for PowerShell. Please wait..."

    # Helper function to set environment variables from a registry key
    function Set-FromReg($regPath, $valueName, $envVarName) {
        $output = (Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue).$valueName
        if ($null -ne $output) {
            Set-Item -Path "Env:$envVarName" -Value $output
        }
    }

    # Helper function to get all environment variables from a registry key
    function Get-RegEnv($regPath) {
        try {
            $properties = Get-ItemProperty -Path $regPath -ErrorAction Stop | Select-Object -Property * -ExcludeProperty PSPath, PSParentPath, PSChildName, PSDrive, PSProvider
            foreach ($prop in $properties.PSObject.Properties) {
                if ($prop.Name -ne 'Path') {
                    Set-FromReg -regPath $regPath -valueName $prop.Name -envVarName $prop.Name
                }
            }
        } catch {
            # Ignore if path not found
        }
    }

    # Refresh all environment variables
    Get-RegEnv -regPath 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment'
    Get-RegEnv -regPath 'HKCU:\Environment'

    # Special handling for PATH
    $pathHKLM = (Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment' -Name Path -ErrorAction SilentlyContinue).Path
    $pathHKCU = (Get-ItemProperty -Path 'HKCU:\Environment' -Name Path -ErrorAction SilentlyContinue).Path

    if ($pathHKLM -and $pathHKCU) {
        $newPath = "$pathHKLM;$pathHKCU"
    } elseif ($pathHKLM) {
        $newPath = $pathHKLM
    } elseif ($pathHKCU) {
        $newPath = $pathHKCU
    }

    if ($newPath) {
        Set-Item -Path Env:Path -Value $newPath
    }

    Write-Host "Finished refreshing environment variables."
}
