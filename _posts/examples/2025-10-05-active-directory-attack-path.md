---
title: "Owning the Lab: An Active Directory Attack Path"
date: 2025-10-05 18:00:00 -0500
categories: [Security, Red Team]
tags: [active-directory, bloodhound, kerberos, ctf]
description: Walking a full attack path in a practice AD lab, from a low-priv foothold to Domain Admin.
---

## The setup

This is a write-up of a deliberately vulnerable Active Directory lab I built for
practice. Everything here happened on hardware I own. The point is to *understand*
the path, not to hand out a playbook for someone else's network.

## Recon with BloodHound

After landing a low-privilege shell, the first move is mapping the domain:

```bash
bloodhound-python -u lowpriv -p 'Password1' -d lab.local -c All -ns 10.0.0.10
```

BloodHound's "Shortest Path to Domain Admins" query did the heavy lifting and
surfaced a service account that was Kerberoastable *and* a member of a nested group
with `GenericAll` over a DA.

## Kerberoasting

```bash
GetUserSPNs.py lab.local/lowpriv:Password1 -request -outputfile hashes.txt
hashcat -m 13100 hashes.txt rockyou.txt
```

The service account used a weak password, so the hash fell in minutes.

## The takeaway

The interesting part isn't any single tool, it's that a weak service-account
password plus one over-privileged group turned a foothold into full domain
compromise. On the blue side, that's a tiered-admin and managed-service-account
problem, which ties back nicely to my [home SOC](/posts/home-soc-wazuh-suricata/) work.
