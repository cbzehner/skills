# SKILL.md Template

## Description Writing Guidelines

Most important field — the host agent uses the description alone to decide whether to load.

- Write in third person ("Processes files..." not "I can help...")
- Include trigger words matching how users naturally phrase requests
- State WHAT it does AND WHEN to use it
- Be deliberately "pushy" — agents tend to under-trigger. Add phrases like "Use this whenever the user mentions X, even if they don't explicitly ask for it"
- Prefer principle-based triggers over examples tied to the current repo or migration. Use examples in tests, not as the main boundary.
- Describe the durable input condition, not only sample phrases. For example, "when purpose, audience, workflow, constraints, or acceptance criteria are unclear" is stronger than a list of app-building prompts.
- Target under ~350 characters (hard limit 1024), trigger words front-loaded — but prioritize trigger coverage over brevity
- State WHEN to trigger, not a summary of the workflow — a workflow-summary description tempts the agent to follow the description alone and skip reading the body
- If sibling skills share phrase space, differentiate — name what this skill does NOT own and which sibling owns it (e.g. "reviewing a diff belongs to review"). Mutual exclusion works best when both siblings state it.

## Instruction Language

- Use imperative commands, not questions ("Extract the data" not "Can you extract?")
- Explain the why behind instructions rather than piling on rigid MUSTs
- Be concrete ("Use UTF-8 encoding") not abstract ("Use appropriate encoding")
- Number workflow steps explicitly
- Include 3-5 input/output examples for non-obvious behavior

## Template

```yaml
---
name: skill-name
description: [third-person, trigger-word-rich, WHAT + WHEN, deliberately pushy, under ~350 chars]
argument-hint: "[expected arguments]"
allowed-tools: [tools identified in Step 2]
# effort: high          # skill-routing metadata: low|medium|high, not provider reasoning effort
# disable-model-invocation: true  # uncomment for skills with side effects
---

# /skill-name

[One sentence: what this skill does]

## When to Use

- [Trigger condition 1 from Step 1]
- [Trigger condition 2]

## When NOT to Use

- [Near-miss anti-pattern 1 from Step 1 — explain WHY it's a near-miss]
- [Near-miss anti-pattern 2]

## What to Skip

- [Thing this skill should NOT include or do — with reason]
- [Common over-engineering temptation to avoid]

## Workflow

### Step 1: [From Step 1 examples]
[Imperative instructions with reasoning — explain WHY, not just WHAT]

### Step 2: [...]
[...]

## Examples

[3-5 concrete input/output pairs from Step 1. Examples validate the principle; they should not be the only definition of the skill boundary.]

## Handoffs

[For graph-aware skills only: what to do when required input is missing, what downstream skill consumes the output, and when to route to review/diagnose/memory/domain-model.]

## Error Handling

[From Step 2 completeness questions — what to do when things fail]
```

## Dynamic Context Injection

If Step 2 identified runtime state needs, use shell injection:

```markdown
Current branch: !`git branch --show-current`
Changed files: !`git diff --name-only`
```

## Bundled Files

If Step 2 identified supporting files:

```markdown
See [reference.md](references/reference.md) for details.
Run: ./scripts/validate.sh
```

Bundle scripts when the agent would otherwise regenerate the same helper every invocation. Scripts execute without loading code into context — big token savings.

Target: under 5000 words in SKILL.md. Under 300 lines is ideal. Split to reference files early.
