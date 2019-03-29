---
layout: mixer
title: Move-Repos
permalink: /move-repos/
---

[Move-Repos](https://github.com/kenhansen01/AdminPowershell/blob/master/Move-Repos.ps1)

### What am I looking at?
This is fairly specific. It is something I wrote to move repos from one TFS (Azure DevOps) Collection to another. It uses the VSTS cli. This is deprecated in favor of Azure cli, but I'm working on-premise. It shouldn't be that hard to reconfigure.

### What's the value?
Well the vsts commands return JSON and it was no trouble finding how to get responses in the console, but there was very little information about working with the responses in PowerShell. Once I put the calls inside double quotes, I was able to convert the JSON to an Object that was parsable.
