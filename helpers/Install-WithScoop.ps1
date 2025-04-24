function Install-WithScoop {
    param (
        [Parameter(Mandatory = $true)]
        [string]$App
    )

    $Result = Invoke-Expression "scoop install $app"

    

    if ($result.Output -match "is already installed"){ 
        Write-Warning "Already installed $app."
    } elseif ($Result.Errors) {
        Write-Error "Could not install $app."
    } else {
        # Write-Log "Successfully installed $app."
    }
}


    