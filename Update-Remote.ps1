function Update-Remote {
  <#
    .Synopsis
    Goes through all of the subfolders (with or without pattern matching) and sets the remote origin of git projects to the new location.

    .Description
    Goes through all of the subfolders (with or without pattern matching) and sets the remote origin of git projects to the new location.

    .Parameter LocalGitDir
    The directory that houses your git projects.

    .Parameter GitFolderName
    Specific git repo directory name (optional) or folder name pattern.

    .Parameter NewRemoteBaseUrl
    The url up to the git repo name. ex. http://yourServer/tfs/organization/project/_git/

    .Example
    # Update to new tfs location
    $gitDirectory = "C:\Source\repos" # Change this to your local parent folder for your git projects
    $newRemote = "http://server:8080/tfs/collection/project/_git" # Your Remote root

    Update-Remote -LocalGitDir $gitDirectory -NewRemoteBaseUrl $newRemote
  #>
  param(
    [Parameter(Mandatory=$true)]
    [string]
    $LocalGitDir,

    [Parameter(Mandatory=$false)]
    [string]
    $GitFolderName = '*',

    [Parameter(Mandatory=$true)]
    [string]
    $NewRemoteBaseUrl
  )

  Process {
    if ($LocalGitDir[-1] -notmatch '\\') {
      $LocalGitDir += '\'
    }
    if ($NewRemoteBaseUrl[-1] -notmatch '/') {
      $NewRemoteBaseUrl += '/'
    }
  
    if ($GitFolderName -like '*') {
      foreach($folder in Get-ChildItem "$($LocalGitDir)$($GitFolderName)") {
        Set-Location "$($folder)"
        $currentRemoteUrl = "$(git remote get-url origin)"
        Write-Host "Current remote: $currentRemoteUrl"
        $currentRemoteRepo = ($currentRemoteUrl -split "/")[-1]
        $newRepoUrl = "$($NewRemoteBaseUrl)$($currentRemoteRepo)"
        Write-Host "Setting remote to: $newRepoUrl"
        git remote set-url origin $newRepoUrl
        Set-Location $LocalGitDir
      }
    } else {
      Set-Location "$($LocalGitDir)$($GitFolderName)"
      $currentRemoteUrl = "$(git remote get-url origin)"
      Write-Host "Current remote: $currentRemoteUrl"
      $currentRemoteRepo = ($currentRemoteUrl -split "/")[-1]
      $newRepoUrl = "$($NewRemoteBaseUrl)$($currentRemoteRepo)"
      Write-Host "Setting remote to: $newRepoUrl"
      git remote set-url origin $newRepoUrl
      Set-Location $LocalGitDir
    }
  }  
}
