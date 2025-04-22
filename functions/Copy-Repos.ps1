function Copy-Repos {
    <#
    .SYNOPSIS
    Clones a list of GitHub repositories to a specific folder.

    .DESCRIPTION
    Given a list of GitHub repository URLs, this function clones them into the specified folder.
    The target folder is created if it doesn't already exist.

    .PARAMETER RepoUrls
    A list of GitHub repository URLs to clone.

    .PARAMETER TargetFolder
    The folder where the repositories should be cloned.

    .EXAMPLE
    Clone-GitRepos -RepoUrls @("https://github.com/user/repo1.git", "https://github.com/user/repo2.git") -TargetFolder "C:\Projects"
    #>

    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string[]]$RepoUrls = @("https://github.com/JaxRaffnix/Hilfestellung.git", "https://github.com/JaxRaffnix/Backup-Manager.git", "https://github.com/JaxRaffnix/WinSetup.git"),

        [ValidateNotNullOrEmpty()]
        [string]$TargetFolder = "C:\Users\Jax\Coding"
    )

    # Check if Git is installed
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error "Git is not installed or not available in the PATH. Please install Git and try again."
        return
    }

    # Create the target folder if it doesn't exist
    if (-not (Test-Path $TargetFolder)) {
        New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null
        Write-Host "Created target folder: $TargetFolder"
    }

    # Loop through each repo URL and clone
    foreach ($repoUrl in $RepoUrls) {
        $repoName = [System.IO.Path]::GetFileNameWithoutExtension($repoUrl)
        $repoPath = Join-Path -Path $TargetFolder -ChildPath $repoName

        if (Test-Path $repoPath) {
            Write-Host "Repository already exists: $repoPath"
        } else {
            try {
                git clone $repoUrl $repoPath
                Write-Host "Successfully cloned: $repoName"
            }
            catch {
                Write-Error "Failed to clone repository '$repoUrl': $_"
            }
        }
    }
}
