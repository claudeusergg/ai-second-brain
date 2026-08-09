# Cloud Second Brain

A task queue that lives on GitHub and an AI that empties it — **without your computer being on**.

```
  your phone            GitHub Issues          GitHub Actions runner
  (anywhere)     ──►     (the queue)     ──►    (Claude, in the cloud)
                                                        │
                              results/  ◄───────────────┘
                              + a comment on the issue
```

## Why this and not the desktop version

The desktop setup (Cowork Dispatch) needs your machine awake. This doesn't. You open an
issue at 2am from a bar in Vilnius, GitHub spins up a fresh Ubuntu runner, Claude does the
work, commits the result, comments, and closes the issue. Your laptop is in a drawer.

## What it costs

**Nothing beyond your existing Claude subscription.**

- Runner minutes: private repos get 2,000 free minutes/month. A typical task burns 3–10, so
  roughly 200–600 tasks/month before you'd pay a cent.
- Claude: authenticates with a subscription token (`sk-ant-oat01-…`), so runs draw on your
  Pro/Max plan instead of pay-per-token API billing.

The repo is **private** by default. Public repos get unlimited free minutes, but your tasks
and results would be world-readable. Not worth it for a second brain.

## Setup

Two commands and one button.

```powershell
cd "C:\Users\PC\Documents\PROJEKTAI\Claude Code\AI second Brain\cloud-brain"
.\setup.ps1
```

The script creates the private repo, pushes everything, stores your token as a secret, and
creates the labels. It'll prompt you to run `claude setup-token` in another terminal to mint
the token — that's the browser-approval step it can't do for you.

**Then the one manual bit:** install the [Claude GitHub App](https://github.com/apps/claude)
on the new repo. Configure → select `ai-second-brain` → Save. Nothing works until you do this.

Prereqs, if you don't have them:

```powershell
winget install GitHub.cli
gh auth login
```

## Using it

Install the **GitHub mobile app**. That's your interface from anywhere.

- **New task** → new issue, pick the *Task* template. `@claude` is pre-filled, just describe
  the work. Claude starts within a minute.
- **Follow up** → comment `@claude <more>` on the issue. It picks up where it left off.
- **Ask something** → *Question* template. Answer only, no files touched.
- **Check status** → the issues list *is* your queue. Open = pending or in progress.
  Closed = done.

Tasks stack infinitely. Open twelve issues at once and twelve runners work them in parallel.

## What's in here

| File | Does what |
|---|---|
| `.github/workflows/claude.yml` | The worker. Fires on any issue or comment containing `@claude`. |
| `.github/workflows/digest.yml` | Daily 06:00 UTC summary of what finished and what's stuck. Delete if annoying. |
| `.github/ISSUE_TEMPLATE/` | Pre-filled task and question forms. |
| `CLAUDE.md` | Standing rules — how to finish a task, when to stop and ask, house style. |
| `notes/` | Background context. Claude reads this before every task. Feed it. |
| `results/` | Finished work lands here, dated. |

## Tuning

- **Model** — `claude.yml` uses `claude-sonnet-5`. Swap to `claude-opus-5` for harder tasks
  at higher token cost.
- **Runaway protection** — 30-minute job timeout and `--max-turns 30`. Raise for `!big` work.
- **Serial instead of parallel** — add to the `work:` job in `claude.yml`:
  ```yaml
  concurrency:
    group: claude-queue
    cancel-in-progress: false
  ```

## Gotchas worth knowing up front

- Only users with **write access** to the repo can trigger Claude. It's your private repo, so
  that's you — but it means you can't hand someone a link and let them queue tasks.
- Scheduled workflows on public repos get disabled after 60 days of inactivity. Private repos
  are unaffected, which is another reason to stay private.
- The digest workflow is instructed never to write `@claude` in its own output. If you edit
  that prompt, keep that rule or it will trigger itself forever.
- Don't commit the token. It goes in repo secrets only. `setup.ps1` handles this correctly.
