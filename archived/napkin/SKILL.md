---
name: napkin
description: Maintain a per-repo curated runbook; always active, every session.
effort: low
metadata:
  author: blader
  version: "6.0.0"
  date: "2026-02-21"
  upstream: "https://github.com/blader/napkin"
---

# Napkin

You maintain a per-repo markdown runbook, not a chronological log. The napkin
must be continuously curated for fast reuse in future sessions.

## Session Start: Read And Curate

First thing, every session, locate the napkin file and read it before doing
anything else. Internalize what's there and apply it silently. Don't announce
that you read it. Just apply what you know.

Path resolution priority:

1. `.claude/napkin.md` if it already exists
2. `.codex/napkin.md` if it already exists
3. `NAPKIN.md` at repo root

Every time you read it, curate it immediately:

- Re-prioritize items by importance (highest first).
- Merge duplicates and remove stale/low-signal notes.
- Keep only recurring, high-frequency guidance.
- Ensure each item contains an explicit "Do instead" action.
- Enforce category caps (top 10 per category).

If no napkin exists yet, create one at `NAPKIN.md` in the repo root:

```markdown
# Napkin Runbook

## Curation Rules
- Re-prioritize on every read.
- Keep recurring, high-value notes only.
- Max 10 items per category.
- Each item includes date + "Do instead".

## Execution & Validation (Highest Priority)
1. **[YYYY-MM-DD] Short rule**
   Do instead: concrete repeatable action.

## Shell & Command Reliability
1. **[YYYY-MM-DD] Short rule**
   Do instead: concrete repeatable action.

## Domain Behavior Guardrails
1. **[YYYY-MM-DD] Short rule**
   Do instead: concrete repeatable action.

## User Directives
1. **[YYYY-MM-DD] Directive**
   Do instead: exactly follow this preference.
```

Adapt categories to the repo, but keep category structure and priority ordering.
Do not use raw journal-style entries.

## Continuous Runbook Updates

Update during work whenever you learn something reusable.

What qualifies for inclusion:

- Frequent gotchas or surprising behavior in this repo/toolchain.
- User directives that affect repeated behavior.
- Non-obvious tactics that repeatedly work.


## Example Entry

```markdown
1. **[2026-02-21] `rg` fails on giant expanded path lists**
   Do instead: run `rg` on directory roots or iterate files via `while IFS= read -r`.
```
