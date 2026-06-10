---
name: theorist
description: Maintain a per-repo THEORY.MD — a living narrative of the operating theory behind current work.
effort: high
metadata:
  author: blader
  version: "1.3.0"
  date: "2026-02-28"
  upstream: "https://github.com/blader/theorist"
  local-modifications: "skill audit 2026-04-05, ~58% reduction"
---

# Theorist

Maintain a per-repo `THEORY.MD` that captures the operating theory of the work being done — *why* the work exists, *what* the systematic strategy is, and *how* the current approach connects to the larger picture.

Always active during every session. Once active, stays active for the full session.

Not a changelog, not a plan, not a todo list, not a postmortem, not a status report. A cohesive narrative rewritten holistically as understanding evolves — never appended to.

<!-- WHY: Contrastive examples are decision boundaries, not redundancy — they disambiguate adjacent concepts -->
- A **plan** says "do X then Y." A theory says "X matters because of Y, and the right lever is Z."
- A **changelog** appends entries. A theory is rewritten end-to-end as understanding deepens.
- A **status report** says "today I did X." A theory says "the current approach is X because the evidence shows Y."

## What THEORY.MD Captures

- **Problem thesis**: What problem is being solved and why. Not "fix bug X" but "the export pipeline assumes Y, which breaks under Z."
- **Operating theory**: Current mental model — how the system works, where leverage points are, what's been tried and learned.
- **Systematic strategy**: The higher-order approach connecting individual changes, not task-by-task steps.
- **Key discoveries and pivots**: Where understanding shifted — old theory, what broke it, what replaced it.
- **Open questions**: What's still unknown, where the theory might be wrong, what would change the approach.

## Session Behavior

**Start**: Read `THEORY.MD` if it exists. Use it to orient. Don't announce it. Create one once you have enough context for a meaningful narrative (not before).

**Update triggers** — when the *theory* changes, not the *code*:
- Root cause identified that changes the approach
- Strategy pivot (tried X, learned Y, now doing Z)
- Key discovery narrows or expands scope
- Open question answered, or new uncertainty emerges

**Cadence**:
- Update after each investigate→implement→verify loop
- Update when verification materially changes confidence (new failure mode, passing fix, large benchmark shift)
- Update when 2-3 meaningful learnings accumulate, even close together
- If ~10 minutes of active work pass without a refresh, do a concise rewrite
- Batch burst discoveries into one immediate rewrite — don't defer to session end

**How**: Rewrite relevant sections in place. The full document should read coherently at any point. Note superseded theories briefly as pivots, don't delete them entirely.

If the session is trivial (one-liner fix, config change), no-op. For multiple workstreams, cover the primary one with brief notes on how others connect.

## Document Structure

```markdown
# Theory: [Short Title]

## Problem
[What exists, why it matters, what makes it hard — structural causes, not just symptoms.]

## Operating Theory
[Current mental model. Key dynamics. Where the leverage is.]

## Strategy
[Systematic approach. Principles connecting changes, not individual tasks.]

## Key Discoveries
[Pivots in understanding. Specific, not "found a bug" but the precise insight.]

## Open Questions
[What remains uncertain. What evidence would change the approach.]
```

## Rules

- One `THEORY.MD` per repo, at repo root. Maximum ~200 lines.
- Write as a thoughtful engineer explaining to a peer: direct, specific, no filler.
- State theories clearly; separately note where confidence is low.
- Prefer frequent concise rewrites over infrequent large ones.
- Stay active for the whole session once activated.
