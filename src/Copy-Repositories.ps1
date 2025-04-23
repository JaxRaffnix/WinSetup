function Copy-Repositories {
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
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$RepoUrls,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TargetFolder
    )

    Test-Installation -App 'git'

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
            Write-Warning "Repository already exists: $repoPath"
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
