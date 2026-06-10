# Skill Audit Protocol

Iterative optimization of existing skills for token efficiency without behavioral regression.

Uses the autoresearch pattern (Karpathy hill-climbing): single-change experiments with a ratchet — improvements kept, failures reverted. The protocol adds defenses against the systematic over-pruning bias inherent in structural reasoning about prompt content.

## When to Audit

- A skill is flagged as BLOATED by a parallel sweep (20%+ dead weight)
- A frequently-used skill hasn't been reviewed since initial creation
- Context window pressure — the skill is large and loaded often
- User explicitly asks to prune or optimize a skill

## Setup

1. **Gather usage data**: Run `scripts/usage-stats.sh <skill-name>` (or `/seance` for deeper narrative) to find real invocations: which modes/paths are exercised, which features are never used, how often each reference file is actually read. Usage data informs which cuts are safe (unused features) vs. risky (frequently exercised paths) — and where cuts pay off at all: expected savings = tokens × load probability, so SKILL.md (loaded every invocation) dominates references (typically read in <10% of sessions).
2. Read the target SKILL.md fully — this is your baseline
3. `cp SKILL.md SKILL.md.baseline`
4. Define 3-5 test prompts that exercise the skill's main paths and edge cases — reuse `tests/probes.yaml` if it exists, informed by the usage data from step 1
5. Initialize an experiment log: `experiment | status | word_count | description`
6. Evaluate baseline: `scripts/token-profile.sh <skill-dir>` + verify all reference files exist
7. `cp SKILL.md SKILL.md.current_best`

## The Loop (per experiment)

### 1. Classify Risk

Every proposed cut is either **low** or **high** risk:

**Low risk** — structural reasoning is sufficient:
- Narrator voice ("this skill does X") — the model just received the prompt
- Redundant restatements of content defined elsewhere in the skill
- Verbose examples that could be half the length
- Meta-commentary about the skill's design
- Sections that restate the model's default behavior

**High risk** — requires steel-man + probe:
- Behavioral instructions (how to act, when to escalate, what to check)
- Negative boundaries ("When NOT to Use", anti-patterns)
- Calibration/tiering instructions ("apply lightly for simple questions")
- Anti-failure-mode guardrails (anti-sycophancy, anti-anchoring, anti-rationalization)
- Frontmatter description keywords (these are routing code, not prose)
- Content consumed by sub-agents, dispatched tasks, or other skills
- Mode definitions and trigger conditions

### 2. Steel-Man (high-risk only)

Before accepting a high-risk cut, answer three questions:

1. **Why was this here?** Articulate the strongest argument for keeping it. Not a token objection — the actual reason someone wrote this line.

2. **Replacement invariant:** Where is this behavior now encoded? If the answer is "the model already knows this" — that's a rationalization flag, not a replacement. Valid replacements: another section of the skill, a reference file, a standard the model demonstrably follows. If the behavior isn't encoded anywhere after the cut, it's a behavior change, not a reduction.

3. **Who reads this?** The SKILL.md isn't the only consumer. Sub-agents dispatched via Task/Agent may receive excerpts. Other skills may reference this one. Seance may read session logs that reference skill behavior. If the content serves any consumer beyond the primary model context, it's load-bearing even if it looks redundant.

If any answer raises doubt, proceed to Probe. If all three are clearly safe, accept the cut.

### 3. Probe (high-risk only)

Construct 1-2 adversarial test prompts that specifically target the behavior the cut was supposed to preserve. Not a general "does the skill still work" test — a pointed "would this specific scenario regress?"

Examples:
- Cut a "When NOT to Use" section → test with a near-miss prompt that should NOT trigger the skill
- Cut an anti-sycophancy guardrail → test with "is this a good idea?" on a bad idea
- Cut calibration instructions → test with a simple question that should get a lightweight response
- Cut sub-agent dispatch context → trace what the dispatched agent would actually receive

If the probe passes, accept the cut. If ambiguous, escalate to a `counsel --panel` gate.

### 4. Streak Check

After **4+ consecutive accepted cuts** without a rejection, the protocol inverts:

- The next experiment must argue for **keeping** the content first
- Only proceed with the cut if the keep-argument fails
- This breaks the momentum bias of a "hot streak" where every cut feels justified

This is a circuit breaker, not a permanent state. After the inverted evaluation, the counter resets.

## After the Loop

### Live Comparison

Run the skill's primary test prompt against both the baseline and optimized version. Use parallel agents so the comparison is blind (neither knows it's being compared) — stage the variants under neutral file names and score deterministic adherence criteria first, per [evaluation-protocol.md](evaluation-protocol.md). Check:

- Does the optimized version hit the same modes/paths?
- Does it produce equivalent quality output?
- Does it handle edge cases (empty args, near-miss triggers)?

### Escalation Triggers (→ `counsel --panel` gate)

The panel gate is a multi-advisor review (Gemini + Codex + Claude) of the full before/after diff. Required when:

- **Word reduction exceeds 40%** in a single audit pass — high cumulative risk of interaction effects between individually-safe cuts
- **A probe result is ambiguous** — not clearly pass or fail
- **Pre-release audit** of a frequently-used or high-impact skill
- **Auditor's judgment** — when you're genuinely unsure

The panel prompt should include: a summary of what was removed (not full files), the specific evaluation questions, and the instruction to be rigorous ("the point of this review is to catch things the optimizer rationalized away").

### Recovery: Selective Revert

After panel review (or live comparison) flags issues:

1. Restore flagged items in **compact form** — don't revert to baseline verbosity
2. Record a **tombstone note** in the experiment log: what was cut, what was restored, why
3. The goal is the minimum effective restoration, not the original text

## Prevention: Write-Time Annotations

The cheapest defense against over-pruning is knowing why content exists. When writing or editing skills:

- Annotate non-obvious behavioral instructions with `<!-- WHY: brief reason -->` comments
- These serve as Chesterton's Fence markers — a future auditor sees the intent before cutting
- Only annotate what's non-obvious. Don't annotate narrator voice or standard structure.

Examples:
```markdown
<!-- WHY: Without this, model applies full framework structure to simple questions -->
For straightforward questions, apply the framework internally without exposing its structure.

<!-- WHY: Dispatched sub-agent doesn't have full SKILL.md, needs self-contained instructions -->
**On Claude Code:** Run as a single background Agent that:
```

## What Good Looks Like

| Metric | Target |
|---|---|
| Token reduction on BLOATED skills | 20-40% |
| Token reduction on TIGHT skills | 5-10% |
| Behavioral regressions | Zero (verified by live comparison) |
| Rejection rate | 10-30% of experiments (0% is suspicious, 50%+ means cuts are too aggressive) |
| Magi gate verdict | SAFE TO SHIP or REVERT SPECIFIC CUTS (not REVERT ALL) |

## Anti-Patterns

- **"The model already knows this"** as justification for every cut — this is the primary over-pruning rationalization. Sometimes the model does already know. But calibration instructions, anti-failure-mode guardrails, and negative boundaries exist precisely because the model's default behavior isn't sufficient.
- **Cutting frontmatter keywords for brevity** — description keywords are routing code. They determine whether the skill activates. Treat them like function signatures, not comments.
- **Optimizing for word count alone** — the goal is minimum effective prompt, not minimum prompt. A skill that's 30% shorter but misses edge cases is worse, not better.
- **Skipping the panel gate** to save time — the gate exists because the optimization loop has a demonstrated systematic bias. Budget for it.
