# Interview Structure

## Step 1: Understand with Examples

### Skill Type Classification

Determines hardening approach later (see [techniques.md](techniques.md)):

```
Q: What type of skill is this?
  1. Discipline (enforces a practice — TDD, review, verification)
  2. Process (guides multi-step workflows — brainstorming, planning, deployment)
  3. Technique (teaches patterns/recipes — code generation, analysis)
  4. Reference (provides information — API docs, templates, specs)
  5. Always-on (runs every session — runbooks, session state)
```

### Core Questions

- What does this skill do? (1 sentence)
- When should it trigger? (specific scenarios, natural phrasings a user would say)
- When should it NOT trigger? (near-misses — adjacent tasks that seem similar but aren't)
- Who uses it? (personal, team, public)
- What input must already be known before this skill can work well?
- What artifact, decision, or state does this skill produce?
- If required input is missing, which skill or workflow should produce it first?
- Which downstream skill or workflow consumes this output?

### Always Recommend an Answer

When this skill (or any skill it produces) interviews the user, every question must include a recommended answer. Never present an open-ended question without a default.

```
GOOD: "Should this skill bundle a script for parsing the output? I'd recommend
       yes — the parsing logic is deterministic and would be regenerated on
       every invocation otherwise."

BAD:  "Should this skill bundle a script?"
```

**Why**: Open-ended questions stall the user. They have to think harder about a domain they may not know well. A recommended answer gives them something concrete to react to — accept, reject, or modify. The user is the editor, not the writer.

**How to apply**:
- Use multiple-choice (AskUserQuestion) where the option set is small and stable
- For open questions, lead with "I'd recommend X because Y. Want to go with that or do something different?"
- If you genuinely don't have a recommendation, state why ("I see two reasonable paths and don't know which fits your context — A vs B")
- The recommendation should reflect the codebase or prior conversation, not a generic best practice

### Walk Through 3 Concrete Examples

```
Q: In example 1, what's the first thing you do?
  1. Read a file
  2. Run a command
  3. Ask the user something
  4. Search the codebase
```

- "Describe example 1 step by step"
- "Now a different scenario (example 2)"
- "What's an edge case? (example 3)"

Extract common patterns and variations. Look for repeated work across examples — if all three involve the same helper logic, that's a signal to bundle a script.

### Generalize The Boundary

After the examples, translate them into a principle.

Ask:

- What do these examples have in common beyond the exact words the user used?
- What required input or artifact makes this skill appropriate?
- What missing input should route somewhere else first?
- Which example details are just current-session accidents and should not appear in permanent instructions?

Good boundary:

> Use when the purpose, audience, workflow, constraints, or acceptance criteria are unclear before implementation.

Weak boundary:

> Use when the user says "build me an app" or "make a website."

Examples should become tests. The skill's main trigger should become the durable rule those examples reveal.

## Step 2: Plan Reusable Contents

### External Tool Check

```
Q: Does this skill need external tools?
  1. No, just built-in tools
  2. Yes, CLI tools (specify which)
  3. Yes, APIs (specify which)
  4. Not sure yet
```

### Questions

- What tools does it need? (Read, Write, Bash, Task, etc.)
- External dependencies? (CLIs, APIs)
- What's deterministic vs needs LLM judgment? (deterministic operations -> bundle as scripts in `scripts/`)
- What must it NEVER do? (hard constraints — but explain why, not just the rule)
- Does it need dynamic context at invocation time? (current branch, project state, etc.)
- Does it bundle supporting files? (scripts -> `scripts/`, reference docs -> `references/`, templates -> `assets/`)
- Is this replacing or consolidating an existing skill? If yes, create it additively first; do not edit the old skill until real usage proves the new route works.
- Does this skill need a `## Handoffs` section? If it composes with other skills, the answer is yes.
- Are any trigger rules example-led? Rewrite them as principle-based boundaries, then keep the examples in tests.

### Effort Assessment

This is skill-routing metadata, not provider reasoning effort. Use only
`low|medium|high`; provider-specific effort policies belong in the workflow
that invokes a model.

```
Q: How much reasoning effort does this skill need?
  1. Low — simple, procedural steps
  2. Medium — multi-step workflow with some judgment
  3. High — complex orchestration, deep analysis, or architecture decisions
```

### Resource Guidelines

- `scripts/` — deterministic, reusable code the agent executes (saves tokens vs regenerating)
- `references/` — documentation the agent reads while working (inner prompts, specs, examples)
- `assets/` — templates and files used in outputs (not loaded into context automatically)
