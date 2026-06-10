---
name: plan-from-prd
description: Turn a PRD into a multi-phase implementation plan using tracer-bullet vertical slices, saved as an agent-executable plan file in ./plans/. Use when user has a PRD and wants to break it into phases, create an implementation plan, plan tracer bullets, or move from spec to executable plan. Distinct from generic plan writing — this consumes a PRD and produces executable phases.
license: MIT
effort: medium
allowed-tools: Read Write Edit Bash Glob Grep
metadata:
  based-on: "Matt Pocock's prd-to-plan skill"
  upstream: "https://github.com/mattpocock/skills/tree/main/prd-to-plan"
---

# Plan From PRD

Break a PRD into a phased implementation plan using vertical slices (tracer bullets). Output is a Markdown file in `./plans/` that a coding agent can execute phase by phase.

## When NOT to Use

- **No PRD exists** → use `plan --prd` first.
- **Generic plan-writing without a PRD** → use `superpowers:writing-plans`.
- **Direct execution of an existing plan** → follow the current agent's implementation workflow, then validate/review each phase.

## Workflow

### 1. Confirm the PRD is in context

The PRD should already be in conversation or pointed to by the user. If not, ask the user to paste it or share the path. Don't proceed without it.

### 2. Explore the codebase

If you haven't already, explore the codebase to understand current architecture, existing patterns, and integration layers the plan will touch.

### 3. Identify durable architectural decisions

Before slicing, identify decisions that are unlikely to change throughout implementation. These go in the plan header so every phase can reference them:

- Route structures / URL patterns
- Database schema shape
- Key data models
- Auth / authorization approach
- Third-party service boundaries

### 4. Draft vertical slices

Break the PRD into **tracer bullet** phases. Each phase is a thin vertical slice that cuts through ALL integration layers end-to-end — NOT a horizontal slice of one layer.

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests where applicable)
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
- Do NOT include specific file names, function names, or implementation details that will change as later phases are built
- DO include durable decisions: route paths, schema shapes, data model names
</vertical-slice-rules>

**Why vertical**: Horizontal slicing (all schema, then all API, then all UI) outruns headlights. You commit to interfaces before knowing if they work end-to-end. Vertical tracer bullets prove the path works at each step.

### 5. Quiz the user

Present the breakdown as a numbered list. For each phase show:
- **Title**: short descriptive name
- **User stories covered**: which stories from the PRD this addresses

Ask:
- Does the granularity feel right? (too coarse / too fine)
- Should any phases be merged or split further?

For each question, **provide a recommended answer**. Lead with "I'd recommend X because Y."

Iterate until the user approves.

### 6. Write the plan file

Create `./plans/` if it doesn't exist. Write the plan as `./plans/<feature-slug>.md` using the template below.

**Format**: agent-executable. YAML frontmatter with status/progress fields, then `## Phase N` headings.

<plan-template>
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

# Plan: <Feature Name>

> Source PRD: <issue link or file path>

## Architectural decisions

Durable decisions that apply across all phases:

- **Routes**: ...
- **Schema**: ...
- **Key models**: ...

(Add or remove sections as appropriate. No file paths, no line numbers.)

---

## Phase 1: <Title>

**User stories**: <list from PRD>

### What to build

A concise description of this vertical slice. Describe end-to-end behavior, not layer-by-layer implementation.

### Acceptance criteria

- [ ] Criterion 1 (testable, observable through public interface)
- [ ] Criterion 2
- [ ] Criterion 3

---

## Phase 2: <Title>

**User stories**: <list from PRD>

### What to build

...

### Acceptance criteria

- [ ] ...

<!-- Repeat for each phase -->
</plan-template>

After writing, share the file path and suggest starting with Phase 1 as the next step.
