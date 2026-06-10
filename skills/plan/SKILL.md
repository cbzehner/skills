---
name: plan
description: >-
  Clarify intent and turn product, feature, site, app, tool, PRD, or issue
  requests into durable planning artifacts. Use before implementation when the
  purpose, audience, workflow, constraints, acceptance criteria, or execution
  slices are unclear.
argument-hint: "[--interview|--prd|--from-prd|--from-issue|--plan-file] [source]"
arguments:
  - request
license: MIT
effort: medium
allowed-tools: Read Write Edit Bash Glob Grep Skill
---

# Plan

Use this as the canonical entry point for planning. Pick the narrowest mode, load only the matching reference, and produce a durable artifact.

Do not fabricate plans from vague input. If the input is not clear enough, route to `--interview` first.

## First Rule

When the user asks to create something but the purpose, audience, or core workflow is not yet clear, use `--interview` before planning or implementation.

Ask exactly one question first:

> What should this help someone do, and who is that person?

## Routing

| Intent | Mode | Load |
|---|---|---|
| Clarify rough intent or a draft idea before writing artifacts | `--interview` | [references/interview.md](references/interview.md) |
| Write a PRD, product requirements, or issue-ready spec | `--prd` | [references/prd.md](references/prd.md) |
| Convert a PRD into agent-executable phases | `--from-prd` | [references/from-prd.md](references/from-prd.md) |
| Convert an issue/ticket into agent-executable phases | `--from-issue` | Use `--from-prd` structure after fetching/reading the issue |
| Write or normalize `./plans/<slug>.md` | `--plan-file` | Use `--from-prd` structure and plan frontmatter |

## Artifact Contract

Planning should end with one of:

- A PRD or GitHub issue body.
- An agent-executable file under `./plans/`.
- A concise refusal saying what input is missing and which mode should run first.

Plan files use:

```yaml
---
status: pending
gaps: []
edge_cases: []
progress: []
last_review: null
iterations: 0
no_progress_count: 0
started_at: null
---
```

Each phase must be a vertical slice with observable acceptance criteria and credible verification.

<!-- WHY: without this, the model defaults to citing file paths/lines, which go stale before the plan is executed -->
Durability rule (all artifacts): describe modules, behaviors, and contracts — never specific file paths, line numbers, or current code snippets. Durable names (routes, schema shapes, data model names) are fine.

## Handoffs

- If the intended user, purpose, or core workflow is missing, run `--interview` before routing anywhere else.
- If a choice needs Socratic interrogation rather than an artifact, route to `counsel --interview`.
- If terms, domain concepts, or architecture decisions are unclear, route to `domain-model update` or `domain-model audit`.
- If UI/workflow shape is the main unknown after product direction is known, route to `design`.
- If planning is blocked by an unexplained failing command or behavior, route to `diagnose`.
- After writing a plan, route to `review --as spec` or `review --as architecture` when risk is non-trivial.
