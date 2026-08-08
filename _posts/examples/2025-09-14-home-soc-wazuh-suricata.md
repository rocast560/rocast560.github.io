---
title: "Building a Home SOC with Wazuh and Suricata"
date: 2025-09-14 10:30:00 -0500
categories: [Security, Blue Team]
tags: [wazuh, suricata, detection, homelab]
description: Standing up a small security operations lab to practice detection engineering at home.
---

## Why bother?

Reading about detections is one thing; watching an alert fire because *you* wrote
the rule is another. I wanted a place to break things safely and see the telemetry
land, so I built a tiny SOC on a spare mini-PC.

## The stack

- **Wazuh** as the SIEM + agent for log collection and file integrity monitoring.
- **Suricata** as the network IDS, mirroring traffic off the lab switch.
- A **Windows VM** and a **Kali VM** to generate benign and malicious activity.

## A first detection

The classic starting point is catching a bad PowerShell one-liner. Wazuh ships
Sysmon-friendly rules, but writing a custom one makes the pipeline click:

```xml
<rule id="100200" level="12">
  <if_sid>92000</if_sid>
  <field name="win.eventdata.commandLine">FromBase64String</field>
  <description>Possible encoded PowerShell payload</description>
</rule>
```

Fire an encoded command from Kali, and the alert shows up in the dashboard with the
full command line attached. Simple, but it's the whole feedback loop in miniature.

## What's next

I want to pipe Suricata's `eve.json` into Wazuh so network and host events sit in
one timeline, then start mapping detections to MITRE ATT&CK.
