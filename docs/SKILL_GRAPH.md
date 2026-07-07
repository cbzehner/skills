# Skill Graph

The active shadow skill stack is a graph, not a folder hierarchy. Each skill owns a small capability and hands off when required input is missing.

Active skills:

- `counsel`
- `complexity-guard`
- `spike`
- `plan`
- `domain-model`
- `diagnose`
- `validate`
- `review`
- `optimize`
- `finish-task`
- `repo-memory`
- `design`

Meta skills:

- `create-skill`: active utility for creating, updating, and auditing skills. It is not a normal product/code workflow node.
- `browser`: active utility for browser automation, screenshots, live UI checks, scraping, and frontend debugging. Use from `design`, `validate`, `review`, and `finish-task` when visual evidence is needed.
- `git`: active utility for advanced git workflows: worktrees, stacking, bisect, fixups, conflict recovery, and history cleanup. Use from `finish-task` or when git complexity is the task.
- `seance`: active retrieval utility for past local agent sessions. Use when prior session evidence is needed; it is not always-active memory.

## Graph Rules

1. Start with the user's intent, not the skill name.
2. Use the skill whose required input is already available.
3. If required input is missing, route to the skill that can produce it.
4. Prefer artifacts over hidden context: PRDs, `./plans/*.md`, `CONTEXT.md`, ADRs, screenshots, review reports, memory files.
5. Do not use routers to invent missing product direction.
6. Do not edit quarantined skills while evaluating the active graph.

## Evidence Convention

Use `.agent/evidence/<run-slug>/` for local proof bundles shared across skills.

```text
.agent/evidence/<run-slug>/
  manifest.json
  checks.ndjson
  index.html
  summary.md
  artifacts/
```

- `manifest.json` is the machine-readable contract: producer, claim, target, timestamps, artifact paths, verdict, and gaps.
- `checks.ndjson` is the append-only check log: command, status, exit code, duration, and evidence pointer.
- `index.html` is the human review surface for screenshots, tables, command output, and comparison views.
- `summary.md` is optional compact text for PR bodies, issues, or chat.
- `artifacts/` stores screenshots, traces, HARs, logs, videos, and other bulky evidence.

Do not commit `.agent/evidence/` unless the user explicitly asks for an evidence fixture. Skills may link to local paths in final reports, but external upload requires explicit approval.

## Nodes

### `counsel`

Requires:

- A question, plan, claim, design, or decision to interrogate.

Produces:

- Interview decisions, adversarial verdicts, panel synthesis, or a wildcard improvement.

Routes to:

- `plan --interview` when the user needs a durable product/spec artifact.
- `domain-model audit` when terminology or repo language is confused.
- `review` when the user needs findings against a concrete diff, artifact, or implementation.

Consumed by:

- `plan`
- `domain-model`
- `review`

### `plan`

Requires:

- Intent, PRD, issue, or spec source.

Produces:

- PRD/issue body or ralph-compatible `./plans/<slug>.md`.

Routes to:

- `spike` when feasibility, library behavior, API shape, performance, UI approach, or integration risk is too unknown to plan responsibly.
- `counsel --interview` when a choice needs conversational interrogation.
- `domain-model update` when terms or architecture decisions need to be captured.
- `design` when UI/workflow shape is the main unknown.
- `diagnose` when planning is blocked by an unexplained failure.

Consumed by:

- `spike`
- `validate`
- `review --as spec`
- `review --as architecture`
- `repo-memory`
- future execution via `ralph` when restored or explicitly used.

### `spike`

Requires:

- One uncertainty that blocks responsible planning or implementation.

Produces:

- Disposable experiment output and `.agent/evidence/<run-slug>/spike/SPIKE_NOTES.md`.

Routes to:

- `plan` when the spike answered enough to implement.
- `counsel` when the spike reveals a real tradeoff between viable approaches.
- `domain-model` when the spike clarifies names, boundaries, or domain language.
- `repo-memory learning` when the result should be remembered.

Consumed by:

- `plan`
- `counsel`
- `repo-memory`

### `domain-model`

Requires:

- Repo docs/code, a term, a decision, or a plan needing language alignment.

Produces:

- `CONTEXT.md`, `CONTEXT-MAP.md`, ADRs, or drift findings.

Routes to:

- `plan` when terminology is clear enough to plan implementation.
- `review --as architecture` when domain drift indicates structural risk.
- `repo-memory learning` when a term/decision should be remembered but not written into repo docs.

Consumed by:

- `plan`
- `design`
- `review`

### `diagnose`

Requires:

- A concrete symptom, failing command, failing test, or reproducible user-visible behavior.

Produces:

- Reproduction evidence, root-cause hypothesis, fix, and regression verification.

Routes to:

- `validate` after a fix needs proof against the original symptom.
- `plan --ralph` when the fix is too large for one focused change.
- `review --as complexity` after a risky or broad fix.
- `repo-memory learning` when the failure reveals a reusable gotcha.

Consumed by:

- `plan`
- `validate`
- `review`
- `repo-memory`

### `design`

Requires:

- At least one of: target user, domain, core workflow, product category, existing app/project, or concrete screen/flow.

Produces:

- Prototype, UI edits, critique, visual direction, accessibility/content/flow findings, or design-language notes.

Routes to:

- `plan --interview` when the intended user, purpose, or core workflow is missing.
- `domain-model audit` when UI language conflicts with repo/product terminology.
- `validate --ui` when produced or changed UI needs live proof or screenshots.
- `review --as design` after producing or changing UI.
- `review --as accessibility` before shipping UI.

Consumed by:

- `plan`
- `validate`
- `review`
- `repo-memory`

### `validate`

Requires:

- A concrete artifact and an observable claim: diff, branch, bug fix, UI flow, plan acceptance criteria, PR, or release candidate.

Produces:

- Validation verdict, commands run, evidence artifacts, coverage, gaps, and next step.

Routes to:

- `plan` when acceptance criteria or validation scope are unclear.
- `browser` when live UI interaction or screenshots are needed.
- `diagnose` when a required check fails for an unknown reason.
- `review` when evidence surfaces design, architecture, security, docs, release, or complexity concerns.
- `finish-task` when validation passed and the user wants delivery.
- `repo-memory learning` when a repeated validation lesson should be preserved.

Consumed by:

- `review --as release`
- `finish-task`
- `repo-memory`

### `review`

Requires:

- A concrete artifact: diff, branch, plan, PRD, screenshot, prototype, docs, or release candidate.

Produces:

- Findings, open questions, checks run, and smallest corrections.

Routes to:

- `diagnose` when a finding depends on reproducing an unexplained failure.
- `validate` when the artifact needs proof rather than critique.
- `plan` when the fix requires multi-step work.
- `domain-model update` when a finding is really vocabulary/ADR drift.
- `repo-memory learning` when a review finding should prevent future mistakes.

Consumed by:

- `plan`
- `diagnose`
- `finish-task`
- `repo-memory`

### `finish-task`

Requires:

- Implementation believed complete, with a concrete diff/branch/worktree and enough repo metadata to choose PR or guarded default-branch delivery.

Produces:

- Final validation/review evidence, PR or guarded local commit/merge, screenshot handling, and a short finish report.

Routes to:

- `validate` first for proof that the artifact works.
- `review` for code, architecture, release, design, security, docs, and complexity gates.
- `counsel --panel` or `magi` for non-trivial multi-model review.
- `browser` for visual evidence and optional screenshot upload workflow.
- `git` for worktrees, fixups, history cleanup, PR stack handling, and conflict recovery.
- `diagnose` when validation fails for unclear reasons.

Consumed by:

- User delivery requests: finish, wrap up, ship, make/update PR, merge worktree, commit to default branch.

### `complexity-guard`

Requires:

- Any code planning, editing, reviewing, architecture, or completion context.

Produces:

- Simplicity constraints, overengineering findings, and behavior-preserving simplification guidance.

Routes to:

- `review --as complexity` when a full findings report is needed.
- `plan` when simplification requires multi-step work.

Consumed by:

- All code-writing and code-review workflows.
- `finish-task`

### `optimize`

Requires:

- A codebase, subsystem, or cleanup goal with a scope and stop condition.

Produces:

- Safe local simplifications, validation evidence, and scoped follow-up tickets for larger design changes.

Routes to:

- `plan` when the cleanup goal is too vague to execute.
- `diagnose` when checks fail for unclear reasons.
- `review` or `complexity-guard` when the user only wants findings.

Consumed by:

- Broad simplify, optimize, reduce, and cleanup requests.

### `repo-memory`

Requires:

- A durable project fact, learning, runbook detail, theory update, or memory audit request.

Produces:

- `.claude/memory/runbook.md`
- `.claude/memory/theory.md`
- `.claude/memory/learnings.md`

Routes to:

- `review` before preserving a risky or uncertain lesson.
- `domain-model` when the memory belongs in repo docs, glossary, or ADRs.
- `diagnose` when the requested memory is actually a recurring unresolved failure.

Consumed by:

- All active skills as optional repo context when relevant.

## Common Flows

### Vague App Request

```text
plan --interview
-> design static-html
-> validate --ui
-> review --as design
-> review --as accessibility
```

### Feature With Fuzzy Language

```text
counsel --interview
-> domain-model update
-> plan --ralph
-> validate
-> review --as architecture
```

### Unknown Feasibility

```text
spike
-> plan
-> validate
```

### Bug

```text
diagnose
-> validate
-> review --as complexity
-> repo-memory learning
```

### UI Polish

```text
design visual
-> validate --ui
-> review --as design
-> review --as accessibility
```

### Finish Work

```text
validate
-> review --as release
-> finish-task
```

### Big Decision

```text
counsel --panel
-> domain-model update
-> plan --from-prd
```
