---
name: repo-memory
description: >-
  Maintain lightweight per-repo memory without making memory always active. Use
  when updating a runbook, theory, learnings, durable project facts, or when the
  user asks what should be remembered for future sessions. Distinct from seance
  or qmd search: this curates memory artifacts; search tools retrieve history.
argument-hint: "[runbook|theory|learning|audit|recall] [note or question]"
arguments:
  - request
license: MIT
effort: low
allowed-tools: Read Write Edit Bash Glob Grep
---

# Repo Memory

Memory is context, not a workflow tax. Do not load or rewrite memory files unless the user asks or the current work produced a durable fact worth preserving.

## Files

Prefer repo-local files under `.claude/memory/`:

- `runbook.md`: commands, setup, gotchas, stable operational facts.
- `theory.md`: current problem thesis and strategy, rewritten holistically when useful.
- `learnings.md`: durable lessons from sessions, failures, and reviews.

Stable agent instructions still belong in `CLAUDE.md` or `AGENTS.md`.

## Modes

### `runbook`

Add commands, environment details, setup steps, and operational gotchas that future agents should reuse.

### `theory`

Capture why the current approach exists and how evidence changed the strategy. Rewrite, do not append, when the theory changes.

### `learning`

Record reusable lessons from a mistake, review finding, or repeated pattern. Keep each learning short and general enough to transfer. Record only what was demonstrated — a failure actually hit, a command actually needed — not things merely discussed; coverage is not evidence.

### `audit`

Read current memory files and remove stale, duplicate, or overly specific notes. Do not delete uncertain notes without saying why. When a note is contradicted rather than stale, mark it superseded with a one-line pointer to what replaced it instead of deleting — how the understanding evolved is itself signal.

### `recall`

If the answer is in memory files, read them. If the user asks for session history or transcript search, route to `seance` or `qmd` instead of duplicating search behavior.

## Guardrails

- Do not store secrets, tokens, private session material, or raw logs.
- Do not append chronology. Curate concise facts.
- Do not create all files by default; create lazily when there is something useful to save.

## Handoffs

- If the requested memory belongs in repo docs, glossary, or ADRs, route to `domain-model`.
- If the user asks for old session history or transcript search, route to the appropriate search tool instead of duplicating recall behavior.
- If the lesson is uncertain or high-impact, route to `review` before preserving it.
- If the memory is about an unresolved recurring failure, route to `diagnose`.
- If the memory should become future work, route to `plan` rather than storing it as a vague note.

## Credits

- The evidence gate for learnings (record only what was demonstrated) and supersession-over-deletion in audits are adapted from the learning-record format in Matt Pocock's [`teach`](https://github.com/mattpocock/skills/tree/main/skills/productivity/teach) skill.
