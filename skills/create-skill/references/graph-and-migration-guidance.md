# Skill Graph And Migration Guidance

Use this when creating router skills, replacement skills, or skills that should compose with an existing local stack.

## Core Model

Skills are graph nodes, not folders.

Each skill should state:

- **Requires**: what input must already be known.
- **Produces**: what durable result it creates.
- **Routes to**: which skill should run when required input is missing.
- **Consumed by**: which downstream skill or workflow can use its output.

Prefer handoffs through artifacts over hidden conversation state:

- PRDs and issue bodies
- `./plans/<slug>.md`
- `CONTEXT.md` and ADRs
- screenshots and review reports
- `.claude/memory/*.md`

## Additive-First Migration

When replacing or consolidating existing skills, do not edit the source skills first.

Safe migration order:

1. Create the new router or canonical skill as an additive repo.
2. Install it alongside the existing skills.
3. Leave old skills untouched as the known-good baseline.
4. Use the new skill manually on real work.
5. Track routing misses, vague behavior, and repeated wins.
6. Only then convert old skills into shims, archive them, or remove their symlinks.

This avoids losing battle-tested behavior while still testing a simpler skill surface.

## Trigger Writing

Prefer principle-based triggers over lists tied to the current migration.

Good:

```yaml
description: >-
  Clarify intent and turn product, feature, PRD, or issue requests into durable
  planning artifacts. Use before implementation when purpose, audience,
  workflow, constraints, or acceptance criteria are unclear.
```

Too situation-specific:

```yaml
description: >-
  Use when the user says "build me an app", "make a site", or asks for the new
  shadow planning router instead of old brainstorming skills.
```

Concrete trigger phrases are still useful, but they belong in test prompts and examples more than in broad routing rules.

When you find yourself writing a list of prompts, ask what input condition they share. The shared condition belongs in `description`, `## First Rule`, `## Routing`, and `## Handoffs`. The prompts belong in validation.

## First-Rule Pattern

For skills that can accidentally invent missing direction, add a first rule.

Example:

```markdown
## First Rule

When the user asks to create something but the purpose, audience, or core workflow is not yet clear, use interview mode before planning or implementation.

Ask exactly one question first:

> What should this help someone do, and who is that person?
```

Use this pattern for planning, product, design, architecture, and review skills that need a concrete artifact before they can do good work.

## Handoff Section

Every graph-aware skill should include a short `## Handoffs` section:

```markdown
## Handoffs

- If required input is missing, route to `<skill>`.
- If terminology conflicts with repo language, route to `domain-model`.
- If the work reveals an unexplained failure, route to `diagnose`.
- If the output is a concrete artifact, route to `review`.
- If the result is a durable lesson, route to `repo-memory`.
```

Keep handoffs short. They are routing contracts, not workflow duplication.

## What Not To Encode

Do not bake migration mechanics into permanent skill text:

- "shadow router"
- "old skill"
- "known-good baseline"
- "during this trial"
- project-specific paths or organizations
- examples that only make sense in the current cleanup session

Use those terms in migration plans or commit messages, not in evergreen skill instructions.

## Skill Graph Update

If the new skill participates in the local graph, update the workspace `SKILL_GRAPH.md` with:

- node name
- requires
- produces
- routes to
- consumed by

If the skill is standalone or niche, it does not need to appear in the graph.
