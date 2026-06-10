---
name: domain-model
description: >-
  Align a repo's domain language with its docs and code. Use when terms are
  fuzzy or conflicting, when adding or auditing CONTEXT.md, CONTEXT-MAP.md, or
  docs/adr/, when a plan needs architecture-language grounding, or when the user
  asks for domain model, glossary, ubiquitous language, ADR, bounded context, or
  vocabulary drift review.
argument-hint: "[init|update|audit] [topic]"
arguments:
  - request
license: MIT
effort: medium
allowed-tools: Read Write Edit Bash Glob Grep
---

# Domain Model

Keep this lightweight. The goal is shared language that helps agents and humans make fewer mistakes, not DDD ceremony.

## Modes

### `init`

Bootstrap repo language from existing evidence.

1. Read `CLAUDE.md`, `AGENTS.md`, `README*`, `docs/`, `CONTEXT.md`, and `CONTEXT-MAP.md` if present.
2. Inspect names in code for recurring domain concepts.
3. Draft the smallest useful `CONTEXT.md` if none exists.
4. Do not invent a complete model. Mark uncertain terms as questions.

### `update`

Capture resolved terms or decisions.

1. Compare the proposed term with existing docs and code names.
2. If it is glossary-level, update `CONTEXT.md`.
3. If it is hard to reverse, surprising without context, and a real tradeoff, propose or write an ADR under `docs/adr/`.
4. Keep implementation details out of `CONTEXT.md`.

### `audit`

Find drift.

1. Search for term variants in docs and code.
2. Identify conflicting names, overloaded words, and aspirational glossary entries with no code or product reality.
3. Report findings with the smallest correction: rename docs, rename code, add glossary note, or write ADR.

## Artifact Rules

- `CONTEXT.md` is a glossary and invariant file, not a spec or scratchpad.
- Be opinionated: when several names exist for one concept, pick the canonical term and list the rest as `_Avoid:_` aliases under the entry. Promote a term only once it is settled in code or product reality, not aspirationally.
- ADRs explain why, not just what changed.
- Prefer one small context file until the repo proves it has multiple bounded contexts.
- Do not rewrite large documentation surfaces unless the user asked for it.

## Handoffs

- If clarified language is ready to become implementation work, route to `plan`.
- If a term conflict reveals structural risk, route to `review --as architecture`.
- If UI copy or labels are the surface where language matters, route to `design content`.
- If the insight is a reusable project gotcha but not repo documentation, route to `repo-memory learning`.
- If the discussion is still mostly a decision interview, route to `counsel --interview`.

## Credits

- The opinionated canonical-term rule (`_Avoid:_` aliases, promote only settled terms) is adapted from the glossary format in Matt Pocock's [`teach`](https://github.com/mattpocock/skills/tree/main/skills/productivity/teach) skill.
