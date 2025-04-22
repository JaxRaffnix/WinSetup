function Set-GitConfiguration {
    <#
    .SYNOPSIS
    Configures Git with a global user name and email.

    .DESCRIPTION
    Runs `git config --global` to set your name and email for all repositories.

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
        [string]$UserName,

        [Parameter(Mandatory)]
        [string]$UserEmail
    )

    git config --global user.name $UserName
    git config --global user.email $UserEmail
    Write-Host "Git configured with $UserName <$UserEmail>"
}

Export-ModuleMember -Function Set-GitConfiguration
