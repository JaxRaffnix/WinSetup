function Install-ScoopBucket {
    param (
        [string]$bucket
    )

    # Write-Log "Installing Scoop bucket $bucket..."
    $Result = Invoke-Expression "scoop bucket add $bucket"
    
    if ($Result.Errors) {
        if ($Result.Output -match "bucket already exists") {
            Write-Warning "Already installed bucket $bucket."
        } else {
            Write-Error "Could not install bucket $bucket."
        }
    } else {
        # Write-Host "Successfully installed bucket $bucket."
    }    
}