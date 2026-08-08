---
title: "Writing a Memory Scanner in C++"
date: 2026-02-27 13:20:00 -0500
categories: [Game Hacking, Tooling]
tags: [cpp, game-hacking, windows, memory]
description: Building a tiny Cheat-Engine-style value scanner to learn the Windows memory APIs.
---

## The goal

I wanted to understand what Cheat Engine actually does under the hood, so I wrote a
minimal value scanner: attach to a process, scan for an `int`, then rescan as the
value changes until one address survives.

## Reading another process

The whole thing hangs on three Win32 calls: `OpenProcess`,
`VirtualQueryEx` to walk committed regions, and `ReadProcessMemory` to pull bytes.

```cpp
MEMORY_BASIC_INFORMATION mbi;
BYTE* addr = nullptr;

while (VirtualQueryEx(proc, addr, &mbi, sizeof(mbi))) {
    if (mbi.State == MEM_COMMIT &&
        (mbi.Protect & (PAGE_READWRITE | PAGE_READONLY))) {
        std::vector<BYTE> buf(mbi.RegionSize);
        SIZE_T got = 0;
        ReadProcessMemory(proc, mbi.BaseAddress, buf.data(), buf.size(), &got);
        scan_region(mbi.BaseAddress, buf, got, target);
    }
    addr = static_cast<BYTE*>(mbi.BaseAddress) + mbi.RegionSize;
}
```

## Narrowing down

The first scan yields thousands of candidate addresses. The trick, the same one Cheat
Engine uses, is to keep only the addresses whose values still match after you
change the number in-game. Two or three rounds and you're down to one.

## What I learned

Page protection flags matter a lot; skipping `PAGE_GUARD` and non-readable regions
is the difference between a clean scan and a crash. Next up: turning the found
address into a stable pointer chain so it survives a restart.
