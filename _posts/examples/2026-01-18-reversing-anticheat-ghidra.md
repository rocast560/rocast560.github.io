---
title: "Reversing a Game's Anti-Cheat with Ghidra"
date: 2026-01-18 15:45:00 -0500
categories: [Game Hacking, Reverse Engineering]
tags: [reverse-engineering, ghidra, game-hacking, cpp]
description: A look at how a simple user-mode anti-cheat detects tampering, on a game I own, played offline.
---

> Everything here is on a single-player game I own, played offline. This is about
> understanding protections, not defeating them online.
{: .prompt-warning }

## Finding the check

The game refused to launch under a debugger, so the first job was locating the
detection. A quick `IsDebuggerPresent` import search in **Ghidra** pointed straight
at it:

```c
if (IsDebuggerPresent() != 0) {
    ExitProcess(0xdead);
}
```

## Beyond the obvious

The interesting anti-cheat wasn't that one call, it was a periodic thread that
CRC-checked its own `.text` section to catch inline patches:

```c
DWORD crc = crc32(text_base, text_size);
if (crc != EXPECTED_CRC)
    report_tamper();
```

That's a neat pattern: the program treats its own code as data and validates it.
Beating it *properly* means not touching `.text` at all: hook via the IAT or a
VEH instead, which is a whole rabbit hole for another post.

## Takeaway

Anti-cheat design is really just applied reverse engineering pointed at yourself.
Reading one carefully taught me more about PE internals than any tutorial did.
