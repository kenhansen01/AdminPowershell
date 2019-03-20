function Initialize-ExistingSearchInstance {
    <#
    .SYNOPSIS
        Rebuilds components of malfunctioning search instance
    .DESCRIPTION
        Removes and reprovisions all search instance components for all search servers. If this doesn't work, start from scratch!
    .PARAMETER AppServerNames
        Array of Server Names where the search instance runs. If not provided, this defaults to the current active instances
    .PARAMETER RemoveDisabled
        Switch to enable cleanup of disabled Search Instances
    .EXAMPLE
        Initialize-ExistingSearchInstance -RemoveDisabled

            This gets the currently active toplogy and rebuilds all the services, then removes the disabled ones.
    #>
    [cmdletbinding()]
    Param(
        [Parameter(Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('__Server','DNSHostName','IPAddress','ServerNames')]
        [string[]]$AppServerNames,

        [switch]$RemoveDisabled
    )
    Begin {
        Add-PSSnapin Microsoft.SharePoint.Powershell -ErrorAction SilentlyContinue

        if ($AppServerNames) {
            $activeHosts = $AppServerNames | ForEach-Object { Get-SPEnterpriseSearchServiceInstance -Identity $_ }
        } else {
            $activeHosts = Get-SPEnterpriseSearchServiceInstance | Where-Object {$_.Status -eq "Online"}
        }

        $ssa = Get-SPEnterpriseSearchServiceApplication
        $active = Get-SPEnterpriseSearchTopology -Active -SearchApplication $ssa
        $clone = New-SPEnterpriseSearchTopology -SearchApplication $ssa -Clone -SearchTopology $active
        $components = Get-SPEnterpriseSearchComponent -SearchTopology $clone
    }
    Process {
        $components | ForEach-Object -Process {Remove-SPEnterpriseSearchComponent -Identity $_ -SearchTopology $clone}

        $activeHosts | ForEach-Object -Process {
            Write-Host "${$_.Server} adding Components" -ForegroundColor Green
            New-SPEnterpriseSearchAdminComponent -SearchTopology $clone -SearchServiceInstance $_
            New-SPEnterpriseSearchAnalyticsProcessingComponent -SearchTopology $clone -SearchServiceInstance $_
            New-SPEnterpriseSearchContentProcessingComponent -SearchTopology $clone -SearchServiceInstance $_
            New-SPEnterpriseSearchCrawlComponent -SearchTopology $clone -SearchServiceInstance $_
            New-SPEnterpriseSearchIndexComponent -SearchTopology $clone -SearchServiceInstance $_
            New-SPEnterpriseSearchQueryProcessingComponent -SearchTopology $clone -SearchServiceInstance $_
        }

        Set-SPEnterpriseSearchTopology -Identity $clone

        $activeHosts | ForEach-Object -Process {Start-SPEnterpriseSearchServiceInstance -Identity $_}

        Write-Host "Starting Service Instance:" -ForegroundColor White
        $provisioningHosts = Get-SPEnterpriseSearchServiceInstance | Where-Object {$_.Status -eq "Provisioning"}

        while ($provisioningHosts.Length -gt 0) {
            Write-Host '.' -NoNewline
            Start-Sleep -Seconds 5
            $provisioningHosts = Get-SPEnterpriseSearchServiceInstance | Where-Object {$_.Status -eq "Provisioning"}
        }
    }
    End {
        if ($RemoveDisabled) {
            Write-Host "Deleting Disabled Service Instances" -ForegroundColor Red
            Get-SPEnterpriseSearchServiceInstance | Where-Object {$_.Status -eq "Disabled"} | ForEach-Object {$_.Delete()}
        }
    }
}