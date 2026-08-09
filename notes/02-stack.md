# Tools and stack

What Karolis already has. Default to these before proposing anything new.

## Confirmed in use

- **Claude Pro/Max** — Cowork on desktop, mobile app, and this repo's runner all draw on it.
- **Claude Cowork (desktop)** — local sandbox with file access. Handles anything needing local
  files, connected apps, or computer control. Requires his machine awake.
- **GitHub** — this repo. The cloud queue.
- **Windows** — desktop paths look like `C:\Users\PC\Documents\PROJEKTAI\...`. PowerShell,
  not bash, for anything he runs himself.

## Connected / available

- **Gmail** — connected via MCP.
- **Apify** — web scraping and data extraction actors.
- **Airtable** — plugin installed, but **not yet authorized**. Needs OAuth before use.
- **Google Drive-style file connector** — connected.

## Considered and rejected

- **Linear** — good tool, but Claude Code isn't in its native agent directory; would need a
  third-party runner (Cyrus) bolted on. Not worth the glue for a general-purpose queue.
- **n8n / Zapier / Make** — automation middleware. Rejected as unnecessary once GitHub Actions
  covers scheduling and execution for free.
- **Custom orchestrator** — rejected. Rebuilding what the subscription already provides.

## The two-workspace split

| Task needs… | Use |
|---|---|
| Local files, connected apps, computer control | Desktop Cowork + Dispatch from phone |
| To run while the computer is off | This repo — open an issue |

If a task lands in the wrong place, say so in the issue comment rather than half-doing it.

## Free-tier ceilings worth remembering

- GitHub Actions, private repo: 2,000 minutes/month. Typical task: 3–10 minutes.
- Public repos: unlimited minutes, but everything is world-readable. This repo stays private.
