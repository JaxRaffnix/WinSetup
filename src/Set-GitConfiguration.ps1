function Set-GitConfiguration {
    <#
    .SYNOPSIS
    Configures Git with a global user name and email.

    .DESCRIPTION
    Runs `git config --global` to set your name and email for all repositories. 
    Also sets some default Git configurations for convenience.

    .PARAMETER UserName
    The name to associate with commits.

    .PARAMETER UserEmail
    The email address to associate with commits.

    .EXAMPLE
    Set-GitConfiguration -UserName "Alice" -UserEmail "alice@example.com"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$UserName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$UserEmail
    )

    Test-Installation -App 'git'

    try {
        # Check if user configurations already exist
        $existingUserName = git config --global user.name
        $existingUserEmail = git config --global user.email

        if ($existingUserName -eq $UserName -and $existingUserEmail -eq $UserEmail) {
            Write-Warning "Git is already configured with the same user name and email. Skipping configuration."
        } else {
            # Set default Git configurations
            git config --global init.defaultBranch main
            git config --global credential.helper manager
            git config --global color.ui auto
            git config --global core.autocrlf true
            git config --global pull.rebase false

            # Set user-specific configurations
            git config --global user.name $UserName
            git config --global user.email $UserEmail

            Write-Host "Git has been successfully configured with the following settings:"
            Write-Host "User Name: $UserName"
            Write-Host "User Email: $UserEmail"
        }
    }
    catch {
        Write-Error "An error occurred while configuring Git: $_"
    }
}
