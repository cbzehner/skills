---
name: evolver
description: Self-improvement trace collection. Post-session hook writes structured traces to ~/.claude/evolver/traces/ for future distillation into reusable principles.
license: MIT
effort: low
---

# Evolver

Collects structured session traces for offline distillation into principles.

## What It Does

A SessionEnd hook (`trace-collector.sh`) summarizes each session via `claude -p --model haiku --tools ""` and appends a JSONL trace to `~/.claude/evolver/traces/YYYY-MM-DD.jsonl`. Traces capture goal, approaches, outcome, and active principles — summaries, not transcripts.

## Hook Location

The hook script lives at `~/.claude/skills/evolver/trace-collector.sh` and is wired into `~/.claude/settings.json` under `hooks.SessionEnd`.

A lock file (`~/.claude/evolver/.collecting`) prevents recursive hook firing when the `claude -p` summarization call itself triggers SessionEnd.

## Trace Format (v2)

Each line in a JSONL file:

```json
{
  "session_id": "abc123",
  "date": "2026-04-03",
  "goal": "What the session was trying to accomplish",
  "approaches": ["First approach tried", "Second approach after pivot"],
  "outcome": "succeeded | partial | failed | abandoned",
  "active_principle_ids": [],
  "principle_hits": [],
  "principle_misses": [],
  "tags": ["backend", "debugging"],
  "meta": {
    "user_turns": 12,
    "assistant_turns": 11,
    "transcript_chars": 45000,
    "collector_version": 2
  }
}
```

### v2 changes (from magi counsel on Claude Code dream system)
- **Low-signal skip**: sessions with < 2 user turns are silently dropped
- **Principle attribution**: `principle_hits` and `principle_misses` fields populated when `~/.claude/PRINCIPLES.md` exists
- **Provenance metadata**: turn counts, transcript size, collector version in `meta` block
- **Sharpened prompt**: focuses on goal/approach/outcome, ignores tool noise and meta-chatter

## Backfill

`backfill.sh` processes existing session logs through the same trace-collector:

```bash
./backfill.sh              # process all sessions
./backfill.sh --dry-run    # show what would be processed
./backfill.sh --limit 10   # process only 10 sessions
```

Deduplicates against existing traces by session_id.

## Phase 1 (current)

- Trace collection via SessionEnd hook (v2 format)
- Historical sessions can be backfilled via `backfill.sh`
- `active_principle_ids` populates when `~/.claude/PRINCIPLES.md` exists; empty otherwise
- Schema: see `project-briefs/shared-provenance-schema.md`

## Phase 2 (deferred)

- Distillation pipeline: extract "When X, do Y" principles from traces
- Promote validated principles to CLAUDE.md / PRINCIPLES.md (static docs, not dynamic injection)
- See `project-briefs/p1-self-distiller.md` for the full roadmap
