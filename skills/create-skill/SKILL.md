---
name: create-skill
description: >-
  Create, update, audit, or triage candidate agent skills and SKILL.md files.
  Use to decide whether an idea should become a skill, make skills or
  commands, fix trigger pickup, benchmark selection, evaluate token
  cost/routing/adherence, prune token bloat, or validate existing skills.
  Produces skill definitions, not implementation plans.
argument-hint: "[workflow description]"
arguments:
  - description
license: MIT
effort: medium
allowed-tools: AskUserQuestion Write Read Edit Bash Glob Grep Agent Skill
---

# /create-skill

Build skills through interview, not scaffolding.

## When to Use

- Deciding whether a workflow idea deserves a new skill, existing-skill mode, reference recipe, deterministic tool, or rejection
- Formalizing a repeatable workflow into a reusable skill
- User says "make a skill", "slash command", "automate this"
- Turning a conversation's workflow into something reproducible
- Building a new capability for Claude Code

## When NOT to Use

- **One-off scripts**: If the user just needs a bash script or utility, write it directly — don't wrap it in a skill
- **Configuration changes**: Edit the harness config directly for hooks, permissions, env vars, and settings files
- **Editing an existing skill**: Read and edit the skill directly — don't re-run the full interview. To audit for token efficiency, use Step 7 below
- **Documentation**: If the user wants docs, write docs — skills are executable workflows, not reference material

## What to Skip

- **README.md**: SKILL.md is the readme
- **CHANGELOG.md**: Use git history
- **LICENSE**: Inherit from parent
- **Separate config files**: Use YAML frontmatter
- **Heavy frameworks**: Skills are markdown + optional scripts, not applications

## Philosophy

- **Interview-driven**: Questions reveal requirements better than templates
- **Capture, don't invent**: Extract workflows already present in the conversation before asking fresh questions
- **3 examples minimum**: Specificity before abstraction
- **Principles before examples**: Use examples to discover the boundary, then write the reusable rule in principle-based language
- **Graph-aware by default**: For skills that compose with other skills, define required inputs, produced artifacts, and handoffs
- **Additive-first migration**: When consolidating or replacing skills, create the new skill alongside old ones before editing or shimming the old entry points
- **Explain the why**: Instructions that explain reasoning outperform rigid MUSTs. The agent is smart — give it context to make judgment calls, not just rules to follow
- **Progressive disclosure**: Keep SKILL.md lean, split heavy content to reference files
- **Lean over rigid**: Remove instructions that aren't pulling their weight. If test runs show the agent ignoring a section, cut it rather than adding enforcement

## Workflow

Guide the user through the shortest path that produces a tested skill. Use
AskUserQuestion when requirements are ambiguous; skip the interview when the
conversation already contains enough concrete examples and workflow evidence.
Steps 7-8 are standalone audit and evaluation modes for existing skills.

**Before starting**: Check if the current conversation already contains a workflow the user wants to capture. If so, extract the tools used, the sequence of steps, corrections the user made, and input/output formats observed. Present this as a starting point — the user fills gaps and confirms.

## Step 0: Candidate Fitness Gate

Before creating a new top-level skill, classify the candidate:

- `new-skill`: distinct trigger, artifact, recurring failure mode, and testable behavior not owned elsewhere
- `existing-skill-mode`: useful workflow that belongs under an active neighboring skill
- `reference-recipe`: prompt pattern, rubric, or checklist with no unique trigger
- `deterministic-tool`: script or CLI should exist before prose can reliably help
- `reject`: one-off, untestable, or likely to increase routing ambiguity

Default to mode, recipe, tool, or reject. Create a new top-level skill only when the candidate has a distinct trigger, distinct artifact, recurring failure mode, and probes that prove its boundary against nearest neighbors.

## Fast Path From Observed Workflow

Use this path when the current session already contains at least three concrete
examples, a clear trigger boundary, and observable good/bad outputs:

1. Run the Candidate Fitness Gate and record why the candidate should not fold into an existing skill.
2. Extract the workflow contract: trigger, required inputs, produced artifact,
   evidence, stop condition, and handoffs.
3. Compare neighboring skills so the new skill owns one narrow job instead of
   duplicating an existing route.
4. Write the skill, UI metadata, probes, and body fingerprints in one pass.
5. Run structural validation and at least one realistic probe or manual routing
   check.
6. Report the skill as packaged and whether it has been exercised in a real run.

Fall back to the interview path when examples are thin, the trigger overlaps
another skill, or the user has not approved the intended behavior.

---

### Step 1: Understand with Examples

Gather concrete use cases to clarify what the skill does and when it fires. Use the interview questions from [references/interview-structure.md](references/interview-structure.md) — skill type classification, core questions, and 3 concrete example walkthroughs.

After examples, synthesize the general boundary. Do not leave the skill defined by a list of example phrases. The final trigger should describe the underlying input shape, missing context, artifact, or decision point that makes the skill appropriate.

---

### Step 2: Plan Reusable Contents

Identify which bundled resources the skill needs beyond SKILL.md. Use the tool check, planning questions, and effort assessment from [references/interview-structure.md](references/interview-structure.md).

If the skill is a router, replacement, consolidation, or part of a larger local workflow, apply [references/graph-and-migration-guidance.md](references/graph-and-migration-guidance.md) before writing it. Define its graph contract and use additive-first migration.

---

### Step 3: Init

Create the initial SKILL.md from interview answers. Use the template, description writing guidelines, and instruction language rules from [references/skill-template.md](references/skill-template.md).

Write descriptions and first rules in principle-based language. Keep concrete examples in `## Examples` and trigger tests, not in evergreen routing rules unless the phrase is itself the durable user vocabulary.

Write the initial SKILL.md to `~/.claude/skills/{skill-name}/SKILL.md`. Only create reference files if content exceeds 300 lines or has distinct reference material.

---

### Step 4: Edit

Refine the skill with edge cases, failure modes, and hardening. Use the completeness questions, validation questions, and hardening guidance from [references/validation-checklist.md](references/validation-checklist.md).

See [references/techniques.md](references/techniques.md) for the full hardening guide.

For graph-aware skills, add or tighten `## Handoffs` so missing inputs route to the skill that can produce them instead of being invented locally.

Update the SKILL.md with refinements from this step.

---

### Step 5: Package

Validate the skill meets quality standards before declaring it ready. Run all checks from [references/validation-checklist.md](references/validation-checklist.md) and report results to the user using the validation table format.

Fix any failures before proceeding. Warnings are advisory.

A passing table is proof of form, not function. Before moving on: store the check #10 trigger probes in the skill's `tests/probes.yaml`, then run them as a live probe panel ([references/evaluation-protocol.md](references/evaluation-protocol.md)) and report routing results alongside the validation table.

---

### Step 6: Iterate

Test and refine based on real usage. Follow the testing protocol in [references/validation-checklist.md](references/validation-checklist.md) — including additional discipline/process skill steps if applicable.

Run the first test prompt now, in this session — most regressions surface on first contact, and a skill that has never executed is unproven. If the skill genuinely can't be exercised yet (it needs real usage over time or external events), don't end silently after Step 5: say the skill is packaged but unproven, and hand the user a re-entry line — `/create-skill iterate <skill-name> against tests/probes.yaml` — for after first real use.

---

### Step 7: Audit

Optimize an existing skill for token efficiency without behavioral regression. Use when a skill is bloated, after it's been in use long enough to identify dead weight, or as part of a periodic skill sweep.

This step uses the autoresearch pattern: iterative single-change experiments with a ratchet (improvements kept, failures reverted). The protocol defends against systematic over-pruning through risk classification, steel-man testing, and a multi-advisor commit gate.

See [references/audit-protocol.md](references/audit-protocol.md) for the full protocol: 4-step evaluation loop, escalation triggers, recovery procedures, and write-time prevention practices.

**Quick reference — the 4-step loop per experiment:**
1. **Classify** — Is this cut low-risk (narrator voice, restatements) or high-risk (behavioral instructions, boundaries, guardrails)?
2. **Steel-Man** (high-risk) — Why was this here? Where is this behavior now encoded? Who reads this?
3. **Probe** (high-risk) — 1-2 adversarial prompts targeting the specific behavior.
4. **Streak Check** — After 4+ consecutive accepts, invert: argue for keeping the next content first.

**Escalation → `counsel --panel` gate** when: reduction exceeds 40%, probe is ambiguous, pre-release, or you're unsure. `magi` is an alias for this panel workflow.

---

### Step 8: Evaluate

Measure a skill quantitatively without changing it: token profile and expected load, real usage stats from transcripts, trigger-selection F1 from a probe panel, and behavioral adherence against binary criteria. Use at Step 5 packaging, before and after a Step 7 audit (changes should be eval-gated, not vibes-gated), or as a periodic health check.

See [references/evaluation-protocol.md](references/evaluation-protocol.md) for the protocol. Deterministic measurements are bundled as scripts: `scripts/token-profile.sh <skill-dir>` and `scripts/usage-stats.sh <skill-name>`.
