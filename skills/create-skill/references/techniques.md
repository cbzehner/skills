# Skill Hardening Techniques

Not all skills need all techniques. Match hardening to skill type.

## Skill Type → Technique Matrix

| Skill Type | Examples | Anti-Rationalization | Pressure Testing | Persuasion Stack | Process Gates |
|---|---|---|---|---|---|
| **Discipline** | TDD, review, verification | Required | Required (3+ pressures) | Authority + Commitment | Hard gates |
| **Process** | Brainstorming, planning, deployment | Recommended | Recommended (2+ pressures) | Commitment + Scarcity | Sequential gates |
| **Technique** | Patterns, recipes, generators | Optional | Light (trigger/anti-trigger only) | Explain the why | Soft gates |
| **Reference** | API docs, templates, specs | Skip | Light | Clarity only | None |
| **Always-on** | Napkin, theorist, session init | Skip | Light | Lightweight nudges | None |

Determine skill type in Step 1. This drives which techniques apply.

## Technique 1: Anti-Rationalization Tables

**What:** A table mapping every observed agent excuse to a reality-check counter.

**Why it works:** LLMs rationalize skipping rules the same way humans do. Naming the rationalization explicitly closes the loophole. This is the highest-leverage, lowest-cost hardening technique.

**How to build one:**

1. Run the skill's scenario WITHOUT the skill (or with a draft)
2. Watch what the agent says when it skips or shortcuts a step
3. Record each excuse verbatim
4. Write a counter for each

**Example:**

```markdown
| Thought | Reality |
|---------|---------|
| "This is too simple to test" | Simple code has the sneakiest bugs. Test takes 30 seconds. |
| "I'll test after" | After never comes. RED before GREEN, always. |
| "I'm following the spirit" | Violating the letter IS violating the spirit. |
| "Being pragmatic" | Skipping steps isn't pragmatic, it's gambling. |
```

**When to add:** After Step 6 testing reveals the agent skipping steps. Start with an empty table and populate it from real observations — don't invent hypothetical rationalizations.

## Technique 2: Baseline Testing (The RED Phase)

**What:** Run the target scenario without the skill. Document every failure, shortcut, and rationalization verbatim. This is your test suite.

**Why it works:** If you didn't see the failure, you don't know what the skill should fix. Skills written without baselines tend to over-specify things the model already handles and under-specify things it actually gets wrong.

**How:**

1. Describe the scenario to Claude without loading the skill
2. Let it work through the task
3. Note every place it:
   - Skipped a step you'd want enforced
   - Made a judgment call you'd want constrained
   - Produced output that missed the mark
   - Rationalized a shortcut
4. Each observation becomes a requirement in the skill

**This extends Step 6 (Iterate).** Step 6 tests trigger/anti-trigger and output quality. Baseline testing adds: "does the skill actually change behavior?"

## Technique 3: Pressure Testing

**What:** Realistic scenarios combining multiple pressures that tempt the agent to cut corners.

**Why it works:** Simple test prompts don't reveal failure modes. Under combined pressure (time + sunk cost + exhaustion + authority), agents find creative ways around rules. A skill that passes simple tests but fails under pressure will fail in real use.

**Pressure types:**

| Pressure | Example |
|---|---|
| Time | "It's 5:55pm, standup at 6" |
| Sunk cost | "You've already written 200 lines" |
| Authority | "The user said 'just ship it'" |
| Social | "Code review is tomorrow morning" |
| Pragmatic | "This is a one-line fix, surely..." |
| Economic | "We're burning tokens on this" |

**Rule: combine 3+ pressures per scenario.** Single pressures are easy to resist. Combined pressures reveal real failure modes.

**Example pressure scenario for a TDD skill:**

> You're implementing a small utility function. You've manually tested it and it works. The user has been waiting 10 minutes and just said "looks good, let's move on." You know writing a test would take another 2 minutes. What do you do?

**When to apply:** Discipline and process skills. Overkill for reference and technique skills.

## Technique 4: Persuasion Principles

Research shows persuasion techniques more than double LLM compliance (33% → 72%). Use selectively based on skill type.

**Authority** — Imperative language, non-negotiable framing.
```markdown
# Use for discipline skills:
Write code before test? Delete it. Start over. No exceptions.

# NOT for technique skills — explain the why instead:
Write tests first because failures caught at the unit level cost 10x less than failures caught in production.
```

**Commitment** — Force explicit choices, tracking mechanisms.
```markdown
# Announce skill usage (creates accountability):
When you activate this skill, state: "Using [skill] for [purpose]"

# Track progress with TodoWrite (prevents step-skipping):
Create a task for each checklist item.
```

**Scarcity** — Time-bound requirements, sequential dependencies.
```markdown
# Prevents "I'll do it later":
IMMEDIATELY after completing a task, run verification before proceeding.
```

**Social Proof** — Universal patterns, failure modes.
```markdown
# Establishes norms:
Checklists without tracking = steps get skipped. Every time.
```

**Avoid:** Liking (creates sycophancy) and Reciprocity (feels manipulative).

**The overprompting counter-argument:** Excessive constraints degrade output from capable models. Apply heavy persuasion to *process steps* (where consistency matters) and light guidance to *implementation decisions* (where the model's judgment is often better than rigid rules). Per-step constraint design, not blanket enforcement.

## Technique 5: Process Gates

**Hard gates** — block all progress until satisfied:
```markdown
<HARD-GATE>
Do NOT write implementation code until the design is approved.
</HARD-GATE>
```

**Soft gates** — checkpoints that allow continuation:
```markdown
After completing each step, verify the output before proceeding.
```

**When to use hard gates:** Irreversible decisions — architecture, design, destructive operations.
**When to use soft gates:** Quality practices — review, testing, documentation.
**When to skip:** Reference skills, lightweight always-on skills.

## Technique 6: Measurable Criteria (Autoresearch-Ready)

If you define 3-6 binary pass/fail criteria for a skill's output, you can later run autoresearch loops to optimize it automatically.

**Example criteria for a code review skill:**
1. Did it identify at least one issue? (yes/no)
2. Did it categorize issues by severity? (yes/no)
3. Did it suggest specific fixes, not just problems? (yes/no)
4. Did it complete in under 2 minutes? (yes/no)

**Why this matters:** Skills with measurable criteria are skills that improve over time. Skills without them can only be improved through manual observation.

**When to add:** Any skill where output quality matters and can be evaluated programmatically. This is aspirational for most skills today but positions them for automated iteration.
