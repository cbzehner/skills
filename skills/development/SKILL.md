---
name: development
description: >-
  Run a software change through one recoverable lifecycle: intent, approved
  scope and Plan, isolated Build, Candidate-bound V&V and Review, human merge,
  and bounded post-deploy observation. Use for end-to-end feature, bugfix,
  migration, delivery, or resume work. Use plan, validate, review, or
  finish-task when that focused standalone job is the whole request.
argument-hint: "[software change or status request]"
arguments:
  - request
license: MIT
effort: high
allowed-tools: Bash Read Write Edit Glob Grep Skill
---

# Development

Run one managed software-development lifecycle. The primary session
coordinates the work and is the only writer to Development workflow state.

## First rule

Before planning or editing, look for matching Development artifacts and check
the current Git, GitHub, and deployment facts. Resume the first incomplete or
stale boundary. Start Intake only when no matching work exists.

Approval is explicit and content-bound. Enthusiasm, silence, or approval of
different content grants no authority.

## Boundary

Read [domain language](references/domain.md) before starting or resuming. Read
[artifact contracts](references/artifacts.md) when creating an artifact. Use
[the lifecycle guide](references/lifecycle.md) for the active stage.

The transcript is disposable. Development artifacts, Git, GitHub, and provider
facts are the recovery boundary. Agent prose is a claim; exact commits,
executed checks, observed user journeys, and provider read-backs are evidence.

Do not add a tracker, scheduler, daemon, workflow DSL, database, model router,
or background worker. Use existing harness, Git, GitHub, and provider tools.

## Recovery and stage selection

Set the local state root:

```bash
DEVELOPMENT_HOME="${DEVELOPMENT_HOME:-$HOME/Library/Application Support/Development}"
```

Development home contains a small state Git repository. Worktrees follow the
target repository's convention and remain discoverable through Git. Resume by
reading the repository's work directory, checking approved artifact paths
against their presentation commits, and observing external facts that may have
changed. External facts override stale prose; missing evidence remains missing.

Choose the first missing or stale boundary:

| Boundary | Question | Result |
|---|---|---|
| Intake | What does the Operator want? | Proposal |
| Scoping | What approved Request graph captures it? | approved Request graph |
| Ready | Is one leaf executable without invented intent? | approved Plan |
| Build | What exact change implements the leaf? | Candidate |
| Publication | Does that Candidate have one draft PR? | provider read-back |
| V&V | Was it built correctly, and is it the right outcome? | passing V&V report |
| Review | Is the proven Candidate acceptable to advance? | accepted Review |
| Release | May this Candidate enter the default branch? | observed merge |
| Observe | Did the delivered outcome work in reality? | bounded Observation |

After all leaves merge, run root V&V against the observed default-branch
composition.

## Fixed roster

Use direct invocations with explicit model, effort, access, and output. Do not
substitute a model when a required invocation cannot start.

| Responsibility | Invocation | Model | Effort | Access |
|---|---|---|---|---|
| Proposal and Plan authoring | `codex exec` | `gpt-5.6-sol` | medium | read target; return content |
| Proposal and Plan review | `claude -p` | `claude-fable-5` | low | read-only |
| Build | `codex exec` | `gpt-5.6-luna` | medium | write one leaf worktree |
| V&V and final Review | primary session | actual host model | actual host effort | observe evidence; write state |

Record requested and runtime-reported provenance. Missing provenance is
`unavailable`, never guessed. Give an invocation only its named artifacts,
repository instructions, exact identities, and result contract.

## Invariants

1. Scope approval binds exact Proposal and Request paths at one state-repository
   presentation commit. Plan approval separately binds the exact Plan at its
   presentation commit. A changed listed path makes that approval stale.
2. One leaf has one writing owner and one worktree. Build produces one clean
   local Candidate commit and stops before publication or self-review.
3. V&V binds every Request criterion to fresh evidence for the exact Candidate.
   Verification without an observed outcome cannot pass.
4. Review follows V&V, includes `counsel --panel`, and resolves every blocking
   finding. Panel output is advice, not proof.
5. Any Candidate change invalidates prior V&V and Review. A rebase is a new
   Candidate even when the content appears equivalent.
6. Read GitHub immediately before release. The Operator performs the initial
   merge; Development observes the result before recording Release.
7. Observe establishes deployed identity before interpreting signals, uses a
   deadline and poll cap, and never rolls back without separate authority.
8. Root V&V proves the composed outcome. Failure creates corrective work; it
   does not rewrite delivered history.

## Deterministic identities

Use the state repository to bind approvals. Starting from a clean index, stage
only the named Proposal and Request files or the named Plan, inspect the staged
diff, and commit that presentation. Present its commit SHA and exact relative
paths to the Operator. Before relying on approval, use Git to confirm every
listed path still matches that commit.

Use `git worktree list --porcelain`, `git status`, `git rev-parse`, and
`git merge-base` for worktree and Candidate identity; `gh pr view` for live
pull-request state; and provider read-backs for deployed identity. Before
advancement, compare the approved scope presentation with V&V and the current
Candidate SHA with both V&V and Review. Keep judgment, GitHub actions, and
polling in the skill rather than hiding them behind custom code.

## Handoffs

- `spike`, `diagnose`, `design`, `domain-model`, `browser`, `git`, and
  `complexity-guard` may contribute bounded work without becoming lifecycle
  authorities.
- `plan`, `validate`, `review`, and `finish-task` remain standalone outside
  managed Development work. Inside it, Development owns the corresponding
  stage and advancement decision.
- Promote lasting decisions or learning with `domain-model` or `repo-memory`;
  keep routine workflow bookkeeping in Development home.

When blocked, preserve partial work and observed facts, name the missing
authority or evidence, and stop at that boundary.
