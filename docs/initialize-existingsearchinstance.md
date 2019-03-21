---
layout: page
title: Initialize-ExistingSearchInstance
---

[Initialize-ExistingSearchInstance](https://github.com/kenhansen01/AdminPowershell/blob/master/Initialize-ExistingSearchInstance.ps1)

### SharePoint Search Service Woes
The other day, our search service just stopped working. OK, maybe it was longer than a day...

Anyway, this is a last ditch effort to try before rebuilding Search from scratch. It will take your current topology and rebuild all the components and start it up again. If there is a malfunctioning component, this might help. If it happens to be analytics causing your troubles, you may need to delete those databases as well. The reason I say try it, is it causes no down time in your search service (the same cannot be said for a rebuild).
