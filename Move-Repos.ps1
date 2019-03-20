function Move-Repos {
  <#
  .SYNOPSIS
    Move repos from one TFS (or DevOps) Collection to anonther.
  .DESCRIPTION
    Move repos from one TFS (or DevOps) Collection to anonther. Only supports a single project in the new Collection (would be pretty easy to rewrite for more options). 

    Suggestion is to create config object or file and pipe to this command.
  .PARAMETER VSTS_PAT
    PAT string from TFS/DevOps to authorize commands
  .PARAMETER LocalRepo
    Local file folder where repos are kept
  .PARAMETER TFSServer
    URL of the Server (root level, collection names are appended)
  .PARAMETER CurrentCollection
    Name of Collection where projects should be moved from
  .PARAMETER NewCollection
    Name of new collection where projects will go. This needs to already exist (or rewrite to create)
  .PARAMETER NewProject
    Name of project where repos should be relocated to. Currently supporting a single Project for all repos.
  #>
  [cmdletbinding()]
  Param(
    [# PAT string from vsts
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string]
    $VSTS_PAT],
    [# Location of local repo folder
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string]
    $LocalRepo],
    [# Root tfs server location
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string]
    $TFSServer],
    [# Collection where repos currently reside
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string]
    $CurrentCollection],
    [# Collection where new repos should go
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string]
    $NewCollection],
    [# Project in Collection where new repos should go
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string]
    $NewProject]
  )

  Begin {
    Set-Item -Path Env:VSTS_CLI_PAT -Value $VSTS_PAT
    Set-Location $LocalRepo

    vsts login --token ($env:VSTS_CLI_PAT)
    
    vsts configure --defaults instance="$TFSServer/$CurrentCollection" --use-git-aliases yes

    [Object[]]$projects = "$(vsts project list)" | ConvertFrom-Json
  }
  Process {
    $projects | ForEach-Object {
      $project = $_
      Write-Host "Project Name: $($project.name)"
      $repos = "$(vsts code repo list --project $project.id)" | ConvertFrom-Json
      
      $repos | ForEach-Object {
        $repo = $_ 
        Write-Host "Cloning repo $($repo.name)"
        git clone --bare ($repo.remoteUrl -replace " ", "%20")
        Write-Host "Creating new repo in $NewProject"
        $newRepo = "$(vsts code repo create --name $repo.name --instance $TFSServer/$NewCollection --project $NewProject)" | ConvertFrom-Json
        Set-Location "$LocalRepo\$($repo.name -replace " ", "%20").git"
        git push --mirror ($newRepo.remoteUrl -replace " ", "%20")
        Write-Host "$($repo.name) moved to $NewProject"
        Set-Location "$LocalRepo"
        Remove-Item ".\$($repo.name)" -Force -Recurse
      }
    }
  }
  End {
    vsts logout
  }
}