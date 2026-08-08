---
title: "Living off the Land: Red Team Notes from a Campus Competition"
date: 2026-07-18 14:00:00 -0700
categories: [Security, Red Team]
tags: [ccdc, active-directory, powershell, opsec]
description: What actually worked on the red team side of a student competition, and why the loud tooling mostly didn't.
---

I spent this one on the other side of the scoreboard. The lesson that stuck: the tooling that
looks best in a demo is the tooling that gets you caught first.

## Loud things get caught

Dropping a well-known agent on a box in a lab where every blue team has been told to watch for
exactly that is not a strategy. Half the operators on our side were burned in the first hour
because a defender ran a hash check against a list they had memorized.

The accounts that survived to the end of the day did three things:

- Used binaries already on the host.
- Authenticated as accounts that were *supposed* to authenticate.
- Made changes that looked like administration, not intrusion.

## Enumeration without dropping anything

You do not need a toolkit to map a small domain. The built-in AD module, if it is present, is
enough:

```powershell
Get-ADUser -Filter * -Properties LastLogonDate, ServicePrincipalName |
  Where-Object { $_.ServicePrincipalName } |
  Select-Object SamAccountName, LastLogonDate
```

Accounts with an SPN and a stale last-logon are the interesting ones: they are service accounts
nobody is watching, and in a student environment their passwords are frequently older than the
competition itself.

Where the module is missing, `net` and LDAP over ADSI still work and raise nothing:

```powershell
([adsisearcher]'(&(objectCategory=user)(serv