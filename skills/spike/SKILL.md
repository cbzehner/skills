---
name: spike
description: >-
  Run a timeboxed disposable experiment before planning or implementation when
  feasibility, library behavior, API shape, performance, UI approach, or an
  integration risk is unknown. Use for throwaway prototypes, "would this even
  work?", "I don't know enough to plan", or de-risking without committing code.
argument-hint: "[--timebox 60m] [question]"
arguments:
  - request
license: MIT
effort: medium
allowed-tools: Bash Read Glob Grep
---

# Spike

Answer one uncertainty cheaply, then throw the work away.

A spike is not implementation. It is a reversible learning tool used before a plan or production change would otherwise be speculative.

## First Rule

Define the question before touching code:

```text
Spike question: <the smallest uncertainty this experiment must answer>
```

If the user already has enough information to plan or implement, route to `plan` or continue directly. If the question is really a decision/tradeoff rather than feasibility, route to `counsel`.

## Contract

- Default timebox: 60 minutes unless the user sets another limit.
- Work outside the production path by default.
- Do not polish, generalize, or create reusable abstractions.
- Do not merge spike code.
- If spike code is worth keeping, rebuild the real version through `plan -> validate -> review -> finish-task`.
- Produce notes even when the result is negative.

## Workspace

Prefer one of these, in order:

1. `.agent/evidence/<run-slug>/spike/` for scratch files, logs, and local experiments that do not need repo dependencies.
2. A temporary git worktree when the experiment needs the full repo but must stay isolated.
3. A clearly named scratch branch only when a worktree is impractical.

Use `.agent/evidence/<run-slug>/` as the evidence bundle:

```text
.agent/evidence/<run-slug>/
  manifest.json
  index.html
  summary.md
  artifacts/
  spike/
    SPIKE_NOTES.md
```

Never place throwaway spike code into the main source tree unless the user explicitly asks and understands it will be deleted or rewritten.

## Workflow

### 1. Frame

Capture:

- the question
- the cheapest experiment that could answer it
- timebox
- success and failure signals
- what must not become production code

### 2. Explore

Keep the experiment narrow:

- use public APIs or documented local boundaries first
- prefer tiny scripts, fixtures, or throwaway screens
- measure only what answers the question
- stop when the answer is clear, even if the prototype is ugly

Do not refactor surrounding code to make the spike nicer.

### 3. Record

Write `.agent/evidence/<run-slug>/spike/SPIKE_NOTES.md`:

```markdown
# Spike Notes

Question:
- ...

Result:
- Works / Does not work / Inconclusive

Evidence:
- command, screenshot, log, tiny code path, or API response

Recommendation:
- Plan this approach / Do not use this approach / Need one more spike

Delete By:
- YYYY-MM-DD

Production Notes:
- What should be rebuilt cleanly if this becomes real work
```

If the spike has screenshots, command output, or comparisons, add or update `.agent/evidence/<run-slug>/index.html` as the human review surface. Keep `SPIKE_NOTES.md` as the concise source of truth.

### 4. Clean Up Or Hand Off

At the end:

- delete scratch files unless they are part of the evidence bundle
- remove temporary worktrees when safe
- route durable learnings to `repo-memory` only if they will matter later
- route the next real change to `plan`
- route unresolved feasibility questions to another smaller spike

## Handoffs

- Route to `plan` when the spike produced enough information to implement.
- Route to `counsel` when the spike exposed a decision with multiple viable paths.
- Route to `domain-model` when the spike clarifies names, boundaries, or domain language.
- Route to `validate` only for the later production implementation, not the throwaway spike itself.
- Route stable lessons to `repo-memory`.

## What Not To Do

- Do not call spike code production-ready.
- Do not merge, polish, or extend the spike into real implementation.
- Do not use a spike to avoid making a clear product or architecture decision.
- Do not leave worktrees, servers, temp branches, or background processes running.
- Do not commit `.agent/evidence/` unless the user explicitly wants an evidence fixture.
