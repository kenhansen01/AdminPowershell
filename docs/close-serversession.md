---
layout: page
title: Close-ServerSession
---

[Close-ServerSession](https://github.com/kenhansen01/AdminPowershell/blob/master/Close-ServerSession.ps1)

## Close your server sessions remotely
I work for a fairly large corporation, manage a not insignificant number of server, and have to change my password every 90 days. Sometimes, I would change my password and not be fully signed out of some obscure server somewhere. This server would attempt to refresh my credentials until my account was locked. Then I get to call the helpdesk, unlock and quickly try to find the offending server.

That was exausting. Now I use this function.

## How To
Load it into a PowerShell session and either pipe your server names in or add them as a parameter. I keep a file with all my servers in an array and I pipe that value through.

## Result
Closes all my sessions, and I no longer call the helpdesk. :)

### Ideas
This would be easy to make into a module that is available in your PowerShell environment. You could also rewrite it a bit to accept any user, not just the current one. Have fun.
