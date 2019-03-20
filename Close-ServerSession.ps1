function Close-ServerSession {
  <#
  .SYNOPSIS
    Quickly sign out of all servers.
  .DESCRIPTION
    This is super useful if you work in an environment where changing your password can cause a lockout when signed in to multiple servers.
  .PARAMETER Servers
    Array of server names that you want to sign out of
  .EXAMPLE
    @('SERVER01','SERVER02','SERVER03') | Close-ServerSession
  #>
  [cmdletbinding()]
  Param(
    [Parameter(ValueFromPipeline)]
    [string[]]$Servers
  )
  Begin {}
  Process {
    foreach($server in $Servers) {
      Write-Host $server
      $session = ((quser /server:$server | Where-Object{$_ -match $env:USERNAME}) -split ' +')[2]
      Write-Host $session
      logoff $session /server:$server
    }
  }
}

