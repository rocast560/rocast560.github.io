---
title: "How about we not take our pentesting notes in Microsoft Word"
date: 2026-08-08 00:00:00 -0400
categories: [Projects, Security Tooling]
tags: [pentest, cptc, reporting, crdt, typst, react, claude, mcp]
description: "Been There, Conquered That: a real-time notes and reporting workspace for a collegiate pentest competition."
---

*Been There, Conquered That: a real-time notes and reporting workspace for a
collegiate pentest competition.*

<video class="embed-video file" controls muted loop width="960" style="max-width:100%;height:auto">
  <source src="/assets/img/posts/btct/btct-demo.mp4" type="video/mp4">
  Your browser does not support the video tag. Here is a
  <a href="/assets/img/posts/btct/btct-demo.mp4">link to the video file</a> instead.
</video>

*Full-quality 1920x1080 clip, one take against a small demo workspace called Fake Company.*

## Why

All of it went in one Word document. Five of us, same document, all day.

To be fair, that mostly works. Word handles five cursors without complaining and
nothing gets lost. But a few hours things get a little messey and there is alot of back and fourth of where is stuff located and when writing asking the question of who did this and where did you write it down.

What actually bothered me is that none of us take notes like that anywhere else.
We all use Notion or Obsidian for our own stuff, with linked pages, tags, a
sidebar you can navigate, code blocks that look like code. Then we'd sit down for
the one weekend of the year that matters and drop straight back to using Word because that's what we have to use.

We did have one purpose-built tool. We ran
[SLORPIN](https://github.com/nationalcptc-teamtools/Cal-Poly-Pomona/tree/master/SLORPIN),
Cal Poly Pomona's nmap aggregator, which stands for Some Lone Operator Remakes
Program Intended for Nmap. It's a Go and Gin web app that pulls everyone's scan
results into one database behind a login, organized into named operations, so you
can review the team's recon in one place instead of on five separate boxes. That
part was genuinely useful and it's the reason this project exists at all. But it
only covers recon, it doesn't sync in real time, and it wasn't something you
wanted to stare at on hour thirty of a competition.

So why not just build the rest of it? Word is fine. It just isn't built
for this, and there's no rule saying the workflow you use for the
highest-pressure three days of the year has to be the one you're using for class assignments.

BTCT is that build. Recon aggregation like SLORPIN had, plus the note-taking, the
attack narrative, the evidence trail, and the report. All of it in one place, all
of it live, none of it leaving the LAN. One container, one port, one volume on
the engagement network.

## Notes

The notes view is where the project starts, because that is where CPTC teams lose the most time. During a competition, someone finds a weak password, someone else is still scanning, and another person is already trying to turn that into a report paragraph. If the notes are buried in one long Word document, people spend too much time asking where something was written down.

BTCT keeps notes as a tree of pages. Each page has a title, slug, tags, and an icon, so the team can split the work by host, service, finding, or report section without making a mess. The editor still feels familiar: type Markdown, use headings and lists, paste commands into code blocks, and keep going.

![The page editor with an engagement notes document](/assets/img/posts/btct/pages-editor.png)

Type `/` and the editor opens a small block menu for headings, lists, quotes, tables, code, and images.

![The slash menu open in the editor](/assets/img/posts/btct/slash-menu.png)

Code blocks use CodeMirror, so pasted commands look like commands instead of paragraph text. That sounds small, but it matters when the report team is trying to prove exactly what happened three hours later.

## The attack path belongs on a graph

A written narrative is useful in the final report. It is not always the best way to think while the attack is still unfolding.

BTCT gives each workspace one or more attack graphs. A node can be a host, service, credential, pivot, or finding. Each node carries useful data, not decoration. A finding carries the fields the report needs later: severity, CVSS, likelihood, impact, exploit steps, MITRE mapping, evidence, and remediation.

![The attack narrative graph for an internal network engagement](/assets/img/posts/btct/attack-graph.png)

For CPTC, this helps the team agree on the story faster. If FC-WEB01 leads to FC-SQL01, which exposes a service account, which leads to a domain controller issue, that path is visible. A teammate can open the graph and understand the chain without reading five pages first.

The graph can also highlight a path between two nodes and lay itself out automatically. That makes it easier to clean up the narrative before reporting, especially when the board starts as a rough map built during exploitation.

## Findings come from the work

The findings list is generated from finding nodes across the workspace. It is grouped by severity and sorted by CVSS, so the report writer is not maintaining a second spreadsheet while everyone else is still changing the facts.

![The findings collector grouped by severity](/assets/img/posts/btct/findings.png)

That is the real advantage: the same finding used in the attack graph can feed the report view. When the team edits the remediation or adds better evidence, the update stays attached to the finding instead of living in a separate document that someone has to reconcile later.

The timeline uses the same idea. It orders the workspace by discovery time and shows incoming edges under each item, so the team can turn a messy day of work into a cleaner narrative.

![The attack timeline, grouped by day with edge lineage](/assets/img/posts/btct/timeline.png)

One button copies the timeline as Markdown. It will not write the final report for you, which is a good thing. It gives you a starting outline that already has the order and lineage right.

## Nmap import keeps recon connected

Recon usually starts as files scattered across operator machines. BTCT lets the team drop nmap XML into a scan group, then parses hosts, ports, service versions, OS guesses, and NSE script output.

![A parsed nmap host with its open ports and service versions](/assets/img/posts/btct/nmap-host.png)

Re-importing the same host merges the ports instead of duplicating the machine. A scanned host can also be linked to a host node on the graph. Once that link exists, the open ports and service names stay close to the attack path and the write-up.

The demo uses a small fake environment scan:
[`fake-environment.xml`](/assets/img/posts/btct/fake-environment.xml). It is an `nmap -sS -sV -sC -O` run over a five-host demo network, with one intentionally down host so the parser has to ignore it.

## The command log saves the receipts

This is the feature I would want most during CPTC.

A small Python agent runs on each operator's box. It uses the standard library, so there is no pile of dependencies to install on a competition machine. A shell hook records approved tools as they run and sends BTCT the operator name, host, working directory, command, start time, exit code, and duration.

![The command log showing captured commands from three operators](/assets/img/posts/btct/command-log.png)

The goal is not surveillance. It is evidence. When someone says, "I got a shell on SQL," the command, timing, and target can already be in the shared log. The report team can filter by operator, host, tool, status, or text, then export the result as CSV or JSON for an appendix.

Secrets are redacted before they leave the operator's machine. Passwords, hashes, auth headers, and URL credentials become `[REDACTED]`. The original command stays in a local log on that operator's box.

For a collegiate penetration testing competition, this cuts down on the worst kind of end-of-day work: asking every teammate to remember what they ran, where they ran it, and whether it mattered.

## The report stays local

BTCT includes a Typst tab with source on the left, a rendered preview in the middle, and assets on the right.

![The Typst editor with a live-rendered report preview](/assets/img/posts/btct/typst-report.png)

The compiler and renderer run in WebAssembly inside the app. The default fonts are bundled. That means the report can render without sending content to an outside service, which matters on a competition network where internet access may be limited or where the engagement data should stay on the LAN.

Screenshots can be assigned to figure slots instead of pasted wherever the cursor happens to be. Empty figures stay visible as placeholders, so missing evidence is obvious before submission. Click in the rendered preview and the editor jumps back to the matching source line.

## Split panes keep people oriented

Tabs can be dragged into split panes. Notes, graphs, findings, timeline, command log, Typst, and the assistant can sit next to each other.

![The graph and a notes page side by side in split panes](/assets/img/posts/btct/split-panes.png)

That is not a flashy feature. It is a practical one. Put the attack graph on the left and the write-up on the right. Keep the nmap host open beside the finding. Review the command log while filling in evidence. Fewer window hops means fewer chances to lose your place.

## Live sync without a traditional database

Under the hood, BTCT uses Yjs, a CRDT library, to sync the workspace over WebSockets. A CRDT is a data structure built for collaborative editing. It lets multiple people change the same shared document and merge those changes without one person's save wiping out someone else's work.

Records live in shared maps, and collaborative text fields use shared text objects. Page bodies have their own documents, which lets the editor show remote cursors and name tags. IndexedDB caches the workspace locally, so the interface can load quickly and catch up when the connection comes back.

The high-level version is simpler: everyone is looking at the same workspace, even when the work is split across notes, graphs, scans, findings, commands, and the report.

## Command palette

`Ctrl/Command+K` opens the command palette. From there, you can create a page or graph, open the Typst report, jump to a scan, search the workspace, ask the assistant, or switch themes.

![The command palette](/assets/img/posts/btct/command-palette.png)

This is there for speed. During a competition, navigation should not become another task.

## Claude and MCP

The admin panel can store an Anthropic API key on the server. The key does not go into the browser bundle.

![Admin panel showing the Claude AI, MCP server, and command log settings](/assets/img/posts/btct/admin-ai-mcp.png)

The in-app assistant can read the current workspace and, when allowed, write back to it. It can create pages, graph nodes, findings, and links using the same shared data model as the rest of the app. There are no delete tools exposed to the assistant.

BTCT also exposes an MCP endpoint at `POST /mcp`, so an outside client like Claude Code can inspect the same workspace through a bearer token.

```bash
claude mcp add btct --transport http http://<host>:8080/mcp \
  --header "Authorization: Bearer <token>"
```

The point is not to make AI the center of the workflow. The point is to let it help with the repetitive parts, like turning a scan host into a graph node or drafting a finding shell, while the team keeps control of the evidence and final wording.

## Stack

The app uses Bun, React, Vite, Tailwind, Milkdown, ProseMirror, React Flow, CodeMirror, and Typst in the browser.

The server is intentionally small. It handles login, static hosting, the WebSocket relay, assets, AI calls, and command-log ingest. Most of the competition data model lives in the shared Yjs document, which is why the client can stay useful when the network is unreliable.

That shape fits CPTC well: one container, one port, one shared workspace, and a report process that starts while the technical work is still happening.


