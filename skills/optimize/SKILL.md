---
name: optimize
description: >-
  Optimize or simplify codebases end-to-end. Use when the user asks to optimize,
  simplify, reduce, remove complexity, keep working until a stop condition, or
  turn a broad cleanup goal into safe edits plus scoped follow-up tickets.
  Differentiator: an execution campaign that applies changes, not a review — for
  findings-only passes use review or complexity-guard.
argument-hint: "[goal, scope, or stop condition]"
license: MIT
effort: high
allowed-tools: Bash Read Write Edit Glob Grep Task Skill
---

# Optimize

Run a disciplined optimization loop: establish the goal and stop condition, find
real waste, apply safe reductions, and turn larger cuts into scoped follow-ups.

## When to Use

- The user asks to optimize, simplify, reduce, slim down, clean up, or remove
  complexity from a codebase.
- The request includes an open-ended stop condition such as "don't stop until",
  "keep going", "use `date` to check the time", or "work until this is handled."
- The user wants both local cleanup and durable tickets for larger data-model,
  architecture, config, workflow, or operator-surface changes.
- The task needs a loop that combines implementation, simplification review,
  validation, and follow-up scoping.
- The user wants an agent to work autonomously for a while, but still needs
  evidence, budget, and review gates that prevent "done" from becoming vibes.

## When NOT to Use

- For a narrow code review where the user only wants findings and no edits, use
  `review` or `complexity-guard`.
- For an unexplained failure, use `diagnose` first; optimizing a broken unknown
  usually spreads the uncertainty.
- For a vague product or architecture idea with no target outcome, use `plan` or
  `counsel` before changing code.
- For pure performance tuning with benchmarks and profiling, use the local
  language/tooling workflow and treat this skill only as the simplification
  guardrail.

## What to Skip

- Do not create speculative frameworks, registries, queues, or abstractions to
  make future optimization easier.
- Do not batch unrelated risky changes into one "cleanup" commit.
- Do not preserve deprecated aliases, compatibility shims, or dual paths unless
  the user explicitly asks for them.
- Do not keep working past an explicit stop condition; report remaining work as
  scoped follow-ups.

## Workflow

### Step 1: Anchor The Loop

Restate the goal, scope, and stop condition. If the user gave a time-based stop
condition, run `date` before starting and periodically during long work. If the
stop condition is ambiguous enough to risk destructive churn, ask one concise
question; otherwise proceed.

Write the stop condition like a contract:

- **Goal:** the measurable improvement sought.
- **Scope:** files, subsystem, diff, or repo area to inspect first.
- **Evidence:** test, lint, diff review, ticket state, benchmark, screenshot, or
  other proof required before claiming done.
- **Safety:** behavior that must not change.
- **Budget:** time, turns, token/cost ceiling, issue count, or commit count.
- **Stop:** time, ticket readiness, tests passing, commit boundary, or explicit
  user checkpoint.

Do not let the worker grade its own completion on high-impact work. Use an
independent verifier pass when the loop is long-running, architectural, or likely
to create follow-up work.

### Step 2: Inspect Before Editing

Read the nearest existing implementation, callers, schema/config, tests, and
docs. Use fast search first. Look for stronger owners already in the stack:
standard library, database constraints, type system, framework primitives,
project helpers, CLIs, package-manager scripts, system services, or existing
operator workflows.

Manage context deliberately. Prefer targeted search, local docs, schema
introspection, and current tool output over pasting whole files or stale prose.
Use MCP/connectors when needed context changes frequently or lives outside the
repo.

Classify each opportunity:

- **Safe local cut:** behavior-free deletion, name cleanup, dead branch removal,
  duplicate helper replacement, or docs cleanup.
- **Behavior-preserving simplification:** small code change that needs tests.
- **Design correction:** schema, domain model, config, workflow, command surface,
  or external integration ownership change.
- **Leave alone:** complexity with a current consumer, invariant, or failure mode.

### Step 3: Choose The Smallest Action

Apply safe local cuts directly when they are inside the requested scope. For
behavior changes, make one logically scoped edit at a time and verify it before
continuing. For design corrections, write or update a durable spec/ticket instead
of smuggling the redesign into a cleanup commit.

For parallel work, use worktrees or explicitly disjoint scopes. Give any
subagent a narrow, opinionated job and a tool surface that matches that job.
Separate maker and checker roles; do not spawn general helpers just to look busy.

Use `complexity-guard` as the simplifying rubric whenever code or architecture
is touched. Use `domain-model` when the issue is vocabulary, invariants, schema,
or bounded-context drift. Use `plan` when the outcome should become a PRD, issue
body, or agent-executable plan.

### Step 4: Validate And Review

Run the smallest credible checks after each meaningful edit. Prefer existing
test and lint commands over invented scripts. If checks fail, switch to
`diagnose` rather than layering more cleanup on top.

Before calling the loop complete:

- Run a `complexity-guard` pass over the diff or plan.
- Use `counsel --panel` when the decision is architectural, irreversible, or the
  user asked for "magi."
- Reconcile the evidence against the original loop contract; do not substitute a
  different proof after the fact unless you explain why.
- Record tickets for larger cuts that should not be handled in the current
  commit.

### Step 5: Package The Work

Keep commits semantic and small. One commit should correspond to one local cut,
behavior-preserving simplification, or documentation/spec update. Do not commit
unrelated dirty worktree changes.

Final output should include:

- What changed locally, if anything.
- What was deliberately left alone and why.
- Tickets or follow-ups created, with semantic titles before IDs.
- Checks run and any gaps.
- Evidence that satisfies the loop contract, or the exact missing evidence.
- Whether the stop condition was met.

## Anti-Rationalization Table

| Shortcut | Correction |
|---|---|
| "This is cleanup, so it can all go in one commit." | Cleanup is easier to break because reviewers lower their guard. Split by behavior and ownership. |
| "This abstraction might help later." | Later is not a current consumer. Delete, defer, or ticket the actual missing primitive. |
| "The code is ugly, so broad refactor is justified." | Ugliness is not a scope. Name the invariant, duplication, or unsupported surface being removed. |
| "Tests are slow; this was just simplification." | Behavior-preserving changes still need proof. Run the smallest credible check. |
| "A ticket would slow us down." | Schema, config, workflow, and operator-surface changes need durable scope unless the user explicitly chose local execution. |
| "The agent can run unattended now." | Autonomy raises the verification bar. Add budget, independent review, and human-readable evidence. |
| "This bad pattern appeared again; clean it up manually." | Repetition means the repository needs a durable rule, test, hook, skill, or scheduled cleanup check. |

## Examples

**Prompt:** "Optimize this codebase, use `date` to check the time, and don't stop
until 7am."

**Good response shape:** Check the clock, state the stop condition, inspect the
repo, make safe scoped cuts, create tickets for risky simplifications, verify,
and continue until the stop condition or a blocking decision.

**Prompt:** "Can we simplify our data model? I think we modeled incidents instead
of the domain."

**Good response shape:** Read schema, persistence types, and domain docs; use
`domain-model`; document vocabulary corrections; create scoped tickets for
schema changes instead of doing a drive-by migration.

**Prompt:** "This PR feels overbuilt. What can we remove?"

**Good response shape:** If the user only wants findings, route to
`complexity-guard` or `review`. If they want action, apply only safe cuts and
ticket or plan the risky ones.

## Handoffs

- Missing goal, audience, or acceptance criteria: route to `plan`.
- Unclear architecture tradeoff: route to `counsel --adversarial` or
  `counsel --panel` for high-impact decisions.
- Domain vocabulary or schema drift: route to `domain-model`.
- Buggy or failing checks: route to `diagnose`.
- Final delivery, PR, or commit hygiene: route to `finish-task` or `git` when
  those skills match the user's request.

## Output Contract

Persistent artifacts such as tickets and plans must avoid file paths, line
numbers, and current implementation trivia. Describe behavior, contracts,
domain names, and acceptance criteria so the artifact survives refactors.
