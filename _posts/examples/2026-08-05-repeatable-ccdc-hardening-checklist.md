---
title: A Repeatable CCDC Hardening Checklist
date: 2026-08-05 09:30:00 -0700
categories: [Security, Blue Team]
tags: [ccdc, linux, hardening, powershell]
description: The first fifteen minutes of a competition decide the rest of it. Here's the checklist I run before touching anything else.
---

Every competition starts the same way: eight boxes you have never seen, a scoring engine that
is already counting against you, and a red team that got in before the whistle. The teams that
do well are not the ones who improvise the fastest, they are the ones who have a script.

## The first fifteen minutes

Nothing clever here. In order:

1. Change every password you own, including service accounts.
2. Inventory what is listening.
3. Snapshot the current state so you can tell later what changed.
4. *Then* start reading logs.

Step 3 is the one people skip, and it is the one that saves you at hour four when you cannot
remember whether that scheduled task was always there.

## Inventory what is listening

On Linux:

```bash
ss -tulpn | awk 'NR>1 {print $1, $5, $7}' | sort -u > /root/baseline-ports.txt
```

On Windows, the equivalent that actually gives you the owning process:

```powershell
Get-NetTCPConnection -State Listen |
  Select-Object LocalAddress, LocalPort, @{
    Name = 'Process'
    Expression = { (Get-Process -Id $_.OwningProcess).ProcessName }
  } | Sort-Object LocalPort | Export-Csv baseline-ports.csv -NoTypeInformation
```

Anything on that list you cannot explain is a finding. Do not kill it yet: a scored service
you did not recognize is still a scored service, and taking it down costs more points than the
persistence you were worried about.

## Passwords, properly

The classic mistake is rotating the domain admin password and calling it done. Service accounts,
local accounts on every box, database users, and the router all count.

```bash
for user in $(awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd); do
  echo "$user:$(openssl rand -base64 18)" >> /root/rotations.txt
done
chpasswd < /root/rotations.txt
```

Write them down somewhere the team can read and the red team cannot.

> Keep the injects in mind. A perfectly hardened box with zero submitted injects loses to a
> mediocre box with all of them.
{: .prompt-tip }

## What I got wrong last time

I spent forty minutes writing firewall rules on a host whose scored service I then blocked. The
scoring engine noticed immediately. Now the rule is: allow the scored ports explicitly *first*,
default-deny second, and verify from outside the box before moving on.
