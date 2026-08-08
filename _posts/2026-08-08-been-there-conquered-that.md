---
title: "I got tired of writing pentest notes in Word"
date: 2026-08-08 00:00:00 -0400
categories: [Projects, Security Tooling]
tags: [pentest, cptc, reporting, crdt, typst, react, claude, mcp]
description: "Been There, Conquered That: a real-time notes and reporting workspace for a collegiate pentest competition."
---

*Been There, Conquered That: a real-time notes and reporting workspace for a
collegiate pentest competition.*

![BTCT: typing a highlighted code block, command palette, graph auto-layout, nmap XML import, findings, live command log, split panes and the Typst report](/assets/img/posts/btct/btct-demo.gif)

## Why

Five of us, five Word documents, no merge.

That was the actual setup. Somebody would ask "did anyone already look at the
file server" and the honest answer was that you'd have to go ask all four other
people, because the only record was in a `.docx` on their laptop. At the end of
the engagement we'd stitch it all together into one report under time pressure,
which is exactly when you discover that two operators wrote up the same finding
with different CVSS scores.

We also ran
[SLORPIN](https://github.com/nationalcptc-teamtools/Cal-Poly-Pomona/tree/master/SLORPIN),
Cal Poly Pomona's nmap aggregator, which stands for Some Lone Operator Remakes
Program Intended for Nmap. It's a Go and Gin web app that pulls everyone's scan
results into one database behind a login, organized into named operations, so
you can at least review the team's recon in one place instead of five. That part
was genuinely useful and it's the reason this project exists at all. But it only
covers recon, it doesn't sync in real time, and it wasn't something you wanted to
stare at on hour thirty of a competition.

So I built the thing I wanted. Recon aggregation like SLORPIN had, plus the
note-taking, the attack narrative, the evidence trail, and the report. All of it
in one place, all of it live, none of it leaving the LAN. One container, one
port, one volume on the engagement network.

## Notes

Pages are a nestable tree with titles, slugs, tags, and icons. The body is a
live-preview markdown editor, so you type markdown and it renders as you go.
There's no source pane and preview pane to keep in sync.

![The page editor with an engagement notes document](/assets/img/posts/btct/pages-editor.png)

Type `/` to get a block menu: headings, lists, quotes, tables, code, images.

![The slash menu open in the editor](/assets/img/posts/btct/slash-menu.png)

Input rules fire as you type too. Open a fence with ` ```bash ` and the paragraph
becomes a real CodeMirror block with line numbers and live highlighting. That's
the first few seconds of the clip. New code blocks default to `shell`, which is
what you're pasting most of the time anyway.

Select text and a format bar appears with the usual bold, italic, strike, inline
code, block conversions, and a seven-color highlighter. The highlighter marks
are deliberately session-only. CommonMark has no highlight syntax, so keeping
them would mean the exported markdown stops being portable.

## The attack narrative is a graph, not a paragraph

Every engagement gets one or more canvases. Nodes are typed: Host, Credential,
Service, Finding, Pivot. Each one carries real structured data, so a Finding node
holds CVSS and vector, likelihood, impact, exploit steps, MITRE mapping, and
remediation, not just a title. Edges are typed too, with `AdminTo`, `HasSession`,
`MemberOf`, `Exploits` and `PivotsTo`.

![The attack narrative graph for an internal network engagement](/assets/img/posts/btct/attack-graph.png)

Double-click a node and you land on its write-up page. Select two nodes and
Highlight Path runs a BFS between them and lights up the route in gold. `Ctrl+F`
fuzzy-searches every field on every node, which matters more than it sounds like
once a narrative has forty of them.

Auto Layout re-flows the whole canvas into a dagre hierarchy in one click. You
can watch it in the clip. Honestly it zooms out further than you want and you
have to scroll back in, but it beats dragging thirty-seven nodes into place by
hand.

## Findings and the timeline build themselves

The findings list isn't a list you maintain. It's a view over every Finding node
in every narrative, grouped by severity and sorted by CVSS. You maintain the
graph and this falls out of it.

![The findings collector grouped by severity](/assets/img/posts/btct/findings.png)

The timeline is the same trick applied to time. Every node in the workspace
ordered by when it was discovered, grouped by day, with each node's incoming
edges shown underneath as lineage. One button copies the lot as a markdown
outline, and that outline is a first draft of your narrative section.

![The attack timeline, grouped by day with edge lineage](/assets/img/posts/btct/timeline.png)

## nmap import

Drop nmap XML into a scan group. It pulls hosts, OS detection, ports, service
versions, and NSE script output. Re-import the same IP and the ports merge rather
than duplicating. Hosts can be bound to Host nodes on the graph, and open ports
sync across the link.

![A parsed nmap host with 30 open ports and service versions](/assets/img/posts/btct/nmap-host.png)

## The command log writes your evidence trail

This is the part I'd want if I only got to keep one feature.

A small Python agent runs on each operator's Kali box. It's standard library
only, no pip install on a competition machine. A shell hook catches whitelisted
commands as they're typed and ships them with the operator name, hostname,
working directory, start time, exit code, and duration. A long scan shows up the
moment it starts and fills in its result when it finishes.

![The command log showing captured commands from three operators](/assets/img/posts/btct/command-log.png)

Secrets get redacted before they leave the operator's box. Passwords, hashes,
auth headers and URL credentials become `«REDACTED»`, and the redaction is
tool-aware, so `nmap -p 1-65535` keeps its ports while `mysql -pSECRET` gets
scrubbed. The unredacted line stays in a local log on that machine.

New commands push in live. No reload, no polling. In the clip the counter goes
from 14 to 19 while you watch, as three operators' boxes ship `feroxbuster`,
`certipy`, `nxc`, `ntlmrelayx` and `sqlmap`, and the tool filter chips grow to
match. Filter by operator, tool, host, status or free text, then export whatever
you've filtered to as CSV or JSON for the report appendix.

Only whitelisted tools are logged. Everything else you type never leaves the box.

## The report is typeset locally

There's a Typst tab: source on the left, the rendered document in the middle,
assets on the right.

![The Typst editor with a live-rendered report preview](/assets/img/posts/btct/typst-report.png)

The compiler and the renderer are WebAssembly, bundled into the app, with the
default font set embedded. It renders with no network at all. That was the whole
point. Competition networks are hostile and air-gapped segments are normal, so a
report tool that phones home to typst.app is a report tool you can't use. Export
goes to PDF or SVG.

Screenshots don't get pasted wherever your cursor happens to be. You assign them
to a declared figure slot, which renders as a grey captioned box until something
fills it. An unfinished figure is then visibly unfinished in the PDF instead of
quietly missing, and the caption and figure numbering stay put no matter who
fills it in later. Click anywhere in the rendered preview and the editor jumps to
the matching source line.

## Split panes

Drag any tab to a pane edge. Pages, graphs, findings, the timeline, the Typst
editor, the assistant, all of them.

![The graph and a notes page side by side in split panes](/assets/img/posts/btct/split-panes.png)

Attack path on the left, write-up on the right, which is how I actually used it.

## Everything is live, and there's no database

There isn't a traditional database anywhere in this. Every record lives in a Yjs
CRDT document, synced over WebSockets and cached in IndexedDB.

Entity records sit in a `Y.Map` per table, keyed by id. Every collaborative text
field is backed by a `Y.Text`, so page titles, node labels, scan names and
hostnames merge character by character instead of one person's save clobbering
another's. Page bodies get their own per-page document, bound to the editor with
remote cursors and name tags.

Presence rides along with it, so you can follow a teammate and have your view
mirror theirs as they move around. And because IndexedDB caches everything
locally, the UI renders immediately on load and reconciles when the connection
comes back, which is a nicer property than it sounds like on a flaky competition
VLAN.

## Command palette

`Ctrl/⌘+K` for everything. Create a page or a narrative, open the Typst document,
jump to any page or graph by name, ask Claude, flip dark mode.

![The command palette](/assets/img/posts/btct/command-palette.png)

## Claude, in both directions

An admin sets an Anthropic API key in the admin panel. The key is stored
server-side and never reaches the browser or the JS bundle.

![Admin panel showing the Claude AI, MCP server, and command log settings](/assets/img/posts/btct/admin-ai-mcp.png)

The built-in assistant is a tab like any other. It reads the live workspace,
pages, graphs, findings, nmap results, and in edit mode it can write back:
create a narrative, spawn host and service and credential and finding nodes,
connect them, add findings, turn a scanned nmap host into a graph node. Its tools
run in-process against the shared CRDT, so anything it does appears on everyone
else's canvas immediately and lands in the change log with everything else. There
are no delete tools, on purpose.

The other direction is an MCP server at `POST /mcp`, so an external client like
the Claude Code CLI can read and optionally write the whole workspace. It reuses
the same tool catalog as the in-app assistant, which means the two can't drift
apart. Auth is a bearer token the admin generates.

```bash
claude mcp add btct --transport http http://<host>:8080/mcp \
  --header "Authorization: Bearer <token>"
```

## Stack

Bun everywhere. React 19, Vite and Tailwind on the client. Milkdown and
ProseMirror for the editor, React Flow for the graph, CodeMirror for code,
typst.ts for the report.

The server is deliberately dumb. It's `node:http`, `ws` and `bun:sqlite`, and it
does auth, static hosting and a Yjs relay. It knows nothing about pages or graphs
or findings, and there are only three places where that's not true: the AI
assistant, the asset store, and the command log ingest. Keeping it that way is
the reason the client can work offline at all.

```bash
docker compose up -d --build   # needs AUTH_SECRET in .env
curl localhost:8080/healthz
```

