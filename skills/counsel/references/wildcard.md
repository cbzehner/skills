---
name: counsel-wildcard
description: Queries frontier models in parallel for the single highest-leverage
  addition to a plan or project. Use when brainstorming, seeking creative push,
  or asking "what am I missing?"
argument-hint: "[plan file or project description]"
arguments:
  - input
effort: high
license: MIT
allowed-tools: Bash Read Glob Grep Agent AskUserQuestion
---

# Innovate

Surface the single most impactful addition to a plan or project by querying
multiple frontier models in parallel and synthesizing their best ideas.

Based on Jeffrey Emanuel's technique: after you think you're done, ask
"What's the single smartest and most radically innovative addition you
could make?"

## Guard Rails

Do NOT activate for: bug fixing, execution/implementation tasks, incomplete plans, scope-constrained (MVP) work, or routine refactoring.

## Workflow

### Step 1: Gather Context

Read `$ARGUMENTS` if it points to a file. Otherwise, search for plan or project
files in the current directory (PLAN.md, README.md, AGENTS.md, CLAUDE.md, src/, etc.).
Summarize: goals, architecture, current state, constraints.

### Step 2: Query Advisors in Parallel

Run three advisors in parallel (one message, three Agent/Bash calls).
See [references/advisor-prompt.md](references/advisor-prompt.md) for the prompt template and advisor specifications.

### Step 3: Synthesize

Critically evaluate proposals, find themes, elevate the most practical high-impact idea.
Present results using the format in [references/synthesis-template.md](references/synthesis-template.md).

### Step 4: Ask

Use AskUserQuestion:
> Want to incorporate this into your plan/project, explore it further, or skip?

## Error Handling

| Situation | Action |
|-----------|--------|
| Tool not installed | Note "Unavailable" in output, proceed with others |
| Rate limit / permission denied | Retry once after 60s, then mark unavailable |
| Thin context | Ask user for more context before querying |
| All proposals generic | Tighten prompt with more specific context, re-query one advisor |
| No novel idea | Say so honestly — don't force a recommendation |

## Examples

`counsel --wildcard PLAN.md` — reads plan, queries advisors when useful, and synthesizes one recommended addition with next steps.

`counsel --wildcard` in a project directory — reads README + src/, proposes one high-leverage addition.

Anti-trigger: "Fix this OAuth bug" — this is debugging, not ideation. Do not activate.
