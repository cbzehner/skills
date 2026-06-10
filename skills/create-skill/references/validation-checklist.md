# Validation Checklist

## Step 4: Edit — Refinement Questions

### Completeness

```
Q: If the skill fails, what should happen?
  1. Stop and show error
  2. Ask user how to proceed
  3. Try alternative approach
  4. Fail silently (non-critical)
```

- What if [likely failure] happens?
- Should this persist state or be ephemeral?
- Should the host agent auto-invoke this, or manual-only? (side effects = manual-only)

### Validation Questions (define success before testing)

- "Give me 3 test prompts that SHOULD trigger this skill"
- "Give me 2 prompts that should NOT trigger it"
- "For the first test prompt, what does good output look like?"

Guide the user toward **realistic** test prompts — concrete, with file paths, casual phrasing, maybe typos. Not abstract ("format this data") but specific ("ok so I have this CSV in ~/Downloads called q4-sales.xlsx and I need to..."). Invent the specifics: prompts stored in `tests/` travel with the skill repo, so no real proper names from the user's environment (employer, internal services, usernames, personal domains) and no business-domain vocabulary that fingerprints a workplace — use fictional stand-ins of equal concreteness.

Anti-trigger prompts should be **near-misses**: queries that share keywords with the skill but actually need something different.

### Hardening (based on skill type from Step 1)

For discipline and process skills, also ask:
- "What corners would an agent cut if it were in a rush?" -> seeds the anti-rationalization table
- "What does failure look like if the skill is ignored?" -> defines what baseline testing should catch

See [techniques.md](techniques.md) for the full hardening guide. Apply techniques matched to the skill type:
- Discipline skills: full stack (anti-rationalization, pressure testing, persuasion, hard gates)
- Process skills: recommended (anti-rationalization, pressure testing, sequential gates)
- Technique/Reference/Always-on: light validation only

## Step 5: Package — Quality Checks

Run these checks and report results to user:

1. **Frontmatter completeness** — verify all required fields present:
   - `name` (required, must match directory name)
   - `description` (required, third-person, trigger words front-loaded)
   - `allowed-tools` (required, must list every tool the skill body references)
   - `argument-hint` (recommended if skill takes arguments)

2. **Description quality** — the description must:
   - Front-load trigger words and target under ~350 characters (hard limit 1024; Codex-style harnesses truncate long descriptions first)
   - State WHAT the skill does AND WHEN to use it
   - Use third person
   - Include natural trigger phrases
   - Express a principle-based boundary rather than only a list of examples

3. **Principled routing language** — scan the description, first rule, routing table, and handoffs:
   - Examples should support the rule, not define it
   - Avoid migration-specific phrases in evergreen instructions
   - Replace phrase lists with the underlying input condition where possible
   - Keep concrete phrases in `## Examples`, trigger tests, or validation prompts

4. **Word count** — SKILL.md must be under 5000 words. If over, extract content to `references/` files.

5. **Rejection criteria** — verify both sections exist:
   - "When NOT to Use" with at least 2 near-miss anti-patterns
   - "What to Skip" with at least 1 exclusion

6. **Resource references resolve** — every `[text](path)` link in SKILL.md must point to a file that exists. Check with Glob.

7. **Allowed-tools match actual usage** — scan SKILL.md body for tool references (Read, Write, Bash, Edit, Glob, Grep, Task, AskUserQuestion, Agent, Skill, etc.). Every tool mentioned must appear in `allowed-tools`. Flag tools in frontmatter that aren't referenced in the body.

8. **No forbidden patterns:**
   - No "I can help..." or first-person descriptions
   - No empty sections (every ## heading must have content)
   - No TODO/FIXME/placeholder text

9. **Durable artifacts** (only for skills that produce GitHub issues, plans, briefs, design docs, or other persistent artifacts):
   - The skill must instruct: no file paths in output
   - The skill must instruct: no line numbers in output
   - The skill must instruct: describe behaviors and contracts, not current code structure
   - The skill must instruct: artifact should remain useful after a major refactor

   **Why**: Issues, plans, and briefs sit in queues for days or weeks. The codebase moves underneath them. An issue that says "fix the bug on line 42 of handler.ts" is dead the moment that file is renamed. An issue that says "the SkillConfig type should accept an optional schedule field" survives.

   **How to apply**: Skills like `triage-issue`, `plan --prd`, `plan --from-prd`, or anything filing GitHub issues need this. Skills that only write code or run commands don't.

10. **Triggerability harness** — capture enough data to benchmark skill selection later:
   - 3 realistic prompts that should trigger the skill
   - 2 near-miss prompts that should not trigger it
   - 2-3 distinctive phrases from the SKILL.md body, not frontmatter, that prove the full skill loaded

   **Why**: Description quality is only real if agents select the skill unaided. Body fingerprints make it possible to detect actual loading in Codex-style transcripts where frontmatter is always present.

   **How to apply**: Store the prompts in `<skill-dir>/tests/probes.yaml` (superpowers-bench-compatible: `prompt`, `expected_skills`, optional `trigger_hint`) and the body fingerprints in `<skill-dir>/tests/fingerprints.txt` (one phrase per line — `usage-stats.sh` greps these to measure real body loading across Claude and Codex transcripts). Then run the probes as a live probe panel per [evaluation-protocol.md](evaluation-protocol.md) and report F1. The stored files are what make Step 6 and future re-evaluation cheap instead of reconstructed from scratch.

11. **Graph contract** (for router, replacement, consolidation, or workflow-composing skills):
   - Required inputs are explicit
   - Produced artifact/decision/state is explicit
   - `## Handoffs` exists and routes missing input to another skill or workflow
   - Trigger rules are principle-based, not tied to a one-off migration example
   - If replacing an existing skill, migration is additive-first unless the user explicitly asked to edit the old skill now

   **Why**: Skills that compose as a web fail when they invent missing direction or silently duplicate another skill's job. A graph contract keeps each skill small and makes routing testable.

### Report Format

```
## Validation Results

| Check                    | Status | Notes                       |
|--------------------------|--------|-----------------------------|
| Frontmatter complete     | PASS   |                             |
| Description quality      | PASS   | 142 chars, third-person     |
| Principled routing       | PASS   | Examples kept in tests      |
| Word count               | PASS   | 1,847 / 5,000               |
| Rejection criteria       | PASS   | 3 anti-patterns, 2 skips    |
| References resolve       | PASS   | 2/2 links valid             |
| Allowed-tools match      | WARN   | Bash used but not listed    |
| No forbidden patterns    | PASS   |                             |
| Durable artifacts        | N/A    | Skill doesn't produce docs  |
| Triggerability harness   | PASS   | 3 triggers, 2 anti-triggers |
| Graph contract           | PASS   | Requires/produces/handoffs clear |
```

Fix any failures before proceeding. Warnings are advisory.

## Step 6: Iterate — Testing Protocol

1. **Review description against test prompts** — would the Step 4 trigger prompts activate this skill based on the description alone? If not, the description needs more trigger words
2. **Test immediately** — invoke the skill on the first test prompt
3. **Verify anti-triggers** — confirm near-miss prompts don't activate it
4. **Read the transcript** — did the agent follow the skill or drift? If it ignored a section, that section needs rewriting (explain the why) or cutting (it wasn't pulling its weight)
5. Optionally: `counsel --panel "review this skill for clarity and completeness"` (or `magi` as an alias)

**If iteration must be deferred** (the skill needs real usage over time): say so explicitly — a passing Step 5 table is not completion — and give the user a re-entry path: `/create-skill iterate <skill-name> against tests/probes.yaml`. Roughly 40% of historical creation sessions ended at Step 5 with the skill never exercised; the deferral contract exists to close that gap.

### For Discipline/Process Skills (additional steps)

6. **Baseline test** — run the scenario without the skill loaded. Note every shortcut, skip, or rationalization. If the agent already does the right thing without the skill, the skill isn't needed
7. **Populate anti-rationalization table** — from baseline observations, add each excuse and counter to the skill
8. **Pressure test** — combine 3+ pressures (time + sunk cost + authority) in a test prompt. If the agent shortcuts under pressure, tighten the gates or add to the rationalization table
9. **Define measurable criteria** — 3-6 binary pass/fail questions for the skill's output. This makes the skill autoresearch-ready for future optimization
