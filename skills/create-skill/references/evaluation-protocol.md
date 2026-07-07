# Skill Evaluation Protocol

Quantitative measurement of a skill's cost, routing, and behavior — without changing it. The audit (Step 7) changes a skill; evaluation measures one. Run it at Step 5 packaging, before and after an audit (so changes are eval-gated, not vibes-gated), or as a periodic health check.

Order checks by determinism: scripts first, probe panels second, LLM judging last and only for subjective qualities.

## Candidate Fitness Gate

Before evaluating skill quality, decide whether the candidate should be a skill at all.

Classify the candidate as one of:

- `new-skill`: distinct trigger, artifact, recurring failure mode, and testable behavior not owned elsewhere
- `existing-skill-mode`: useful workflow that belongs under an active neighboring skill
- `reference-recipe`: prompt pattern, rubric, or checklist with no unique trigger
- `deterministic-tool`: script or CLI should exist before prose can reliably help
- `reject`: one-off, untestable, or likely to increase routing ambiguity

Required evidence:

| Check | Question |
|---|---|
| Neighbor overlap | Which active skills could already handle this? |
| Distinct trigger | What prompt should select this instead of neighbors? |
| Distinct artifact | What output does it produce that others do not? |
| Tool need | Does it require deterministic machinery? |
| Failure cost | What recurring agent failure does this prevent? |
| Testability | What trigger, near-miss, and behavior probes prove it works? |
| Net complexity | Does it reduce ambiguity more than it adds? |

Default to `existing-skill-mode`, `reference-recipe`, `deterministic-tool`, or `reject`. Create a new top-level skill only when the candidate has a distinct trigger, distinct artifact, recurring failure mode, and probes that prove its boundary against nearest neighbors.

For existing skills, run the same gate as a continued-existence check:

- `keep-top-level`: still has a distinct trigger, artifact, and tested boundary
- `fold-into-neighbor`: another active skill now owns the trigger or artifact
- `reference-recipe`: useful guidance but no longer needs routing surface
- `deterministic-tool`: prose should shrink behind a script or CLI
- `archive`: no clear owner, usage, or current failure mode

Low usage alone is not a reason to archive. Treat usage as a pointer for where to inspect first; rare skills can still be load-bearing when the failure cost is high.

## Metrics

1. **Token profile** — `scripts/token-profile.sh <skill-dir>`. Reports tokens by load tier: frontmatter (always in the skill listing), SKILL.md (every invocation), references (on demand).
2. **Usage stats** — `scripts/usage-stats.sh <skill-name>`. Session counts and per-reference read rates from local transcripts, across both harnesses (Claude Code projects and Codex sessions). Approximate, but enough to compute expected load.
3. **Expected load** — `SKILL.md tokens + Σ(reference tokens × read rate)`. This is the number that matters: optimization priority follows expected load, not file size. A cut in a reference read in 2% of sessions is worth 2% of the same cut in SKILL.md. Conversely, references are cheap places to add depth.
4. **Trigger-selection F1** — probe panel below.
5. **Behavioral adherence** — binary criteria checks below.
6. **Wild adherence** — what real sessions did, not what lab probes predict. Fingerprints in `<skill-dir>/tests/fingerprints.txt` (2-3 distinctive body phrases, one per line) let `usage-stats.sh` distinguish "body actually loaded" from listing noise — essential for Codex transcripts, where every session contains every description. Two signals to read from the output:
   - **Path drop-off**: grep for step/mode markers across invoking sessions to find where workflows stall (this is how a 39% Step 5 abandonment rate was found). Fix drop-offs structurally — change what the step produces or requires — not with exhortation.
   - **Reference re-reads**: a reference read 2+ times in one session signals bad structure (missing summary in SKILL.md, or a file serving two unrelated purposes).

   Do not bother summing per-invocation token usage from transcript usage blocks: it conflates skill cost with task size and cache behavior. The controllable quantity is what the skill injects into context, and metrics 1-3 already measure that.

## Probe Panel (trigger F1)

Skills with `disable-model-invocation: true` skip this section entirely — they are slash-command-only, their description never competes in routing, so trigger F1 is undefined. Token profile and adherence are their only metrics. (Corollary: a skill whose triggers are all explicit user vocabulary can set that flag instead of fighting for routing.)

Probes live in `<skill-dir>/tests/probes.yaml` — superpowers-bench-compatible entries of `prompt`, `expected_skills`, optional `trigger_hint`, and a `note` explaining the expected routing (essential on near-misses: name the neighboring skill that should win and why, so a flipped probe can be triaged as description drift vs. borderline-by-design). Minimum 6 should-trigger and 4 near-miss probes. Every `expected_skills` value must name an installed skill — check this before running the panel; a typo silently scores as a miss. Write them realistically: casual phrasing, concrete paths, no skill names — a probe that quotes the description tests nothing.

Invent every identifying detail. Probes ship with the skill, often to public repos. No real proper names from the author's environment: employer or personal org/repo names, internal service or product names, team names, personal domains or URLs, issue/PR numbers, or the employer's business-domain vocabulary (an internal repo name next to its actual domain terms fingerprints a workplace even when each looks generic alone). Realistic-but-fictional stand-ins of equal concreteness (`acme/billing-api`, `~/work/storefront-api`, `staging.acme.dev`) test routing just as well. Before committing probes, grep them for the user's employer, username, projects, and domains.

**Cheap tier (recommended first): tool-call simulation.** Before spawning subagents, run the panel as raw API calls: present each candidate skill as a function-calling tool (name + description verbatim), set `tool_choice: required`, temperature 0, max_tokens ≤200, and assert which tool the model calls for each probe. One call per probe (~1¢) instead of one agent session (~13k tokens) makes it affordable to run the panel 3× per variant and per model. Include a `no_match` tool whose description explicitly names plausible out-of-scope domains ("general coding questions, git operations, planning...") so near-miss probes have a legitimate target instead of being forced onto the least-bad skill. Reserve the subagent panel below for the final pre/post comparison, where the realistic harness listing matters.

For each probe, spawn an independent subagent (Agent tool) given:
- a skill listing — the target skill's name + description verbatim, plus 10-15 plausible confuser skills with their real descriptions
- the probe prompt
- the instruction to pick the single skill it would invoke first (or none) and answer in JSON

The probe agent must not know which skill is under test, and probes must run as separate agents — a single agent grading all probes anchors on its earlier answers. Run the panel in parallel.

Score precision, recall, and F1 for the target skill, with per-probe routing in the report. Thresholds:

| F1 | Verdict |
|---|---|
| ≥ 0.9 | Healthy routing |
| 0.7 – 0.9 | Description needs trigger work — check which probes missed and what vocabulary they used |
| < 0.7 | Routing is broken; treat the description as the bug |

When changing a description, re-run the same panel before and after. Never compare across different probe sets, and never edit probe wording between runs — even an innocuous added sentence (e.g., cost framing) changes routing behavior and invalidates the comparison.

Selection is stochastic: before treating a single surprising result as signal, re-run that probe 3× on both the old and new description with identical wording. A probe that flips occasionally under both versions is borderline by design — note its false-positive rate in `probes.yaml` rather than chasing it with description changes.

For audit/change gating, compute a combined pass rate across all probe families (trigger + near-miss + tier-sufficiency); a change may not ship below 90% or below the pre-change rate, whichever is higher.

### Tier-Sufficiency Probes (skills with references only)

For each reference, write 2-4 queries labeled `answerable_from_body: true|false`. Give a model ONLY the SKILL.md body plus the query and two tools — `answer_from_body` and `need_reference` — and assert the labeled tool is called (same cheap tool-call setup as above). A `true` query that routes to `need_reference` means SKILL.md lost load-bearing content to a reference; a `false` query answered from the body means the reference may be dead weight. This is the quantitative form of the SKILL.md/references boundary and the natural regression gate for audit cuts that move content between tiers. (For gateway-style skills whose SKILL.md is a routing table over many references, the same setup with one tool per reference also tests internal routing.)

### Cross-Harness Coverage

Skill selection is harness- and model-dependent: Codex truncates long descriptions first and routes with a different model, so an F1 of 1.0 under Claude does not transfer. If the skill is installed for both harnesses, run the panel for both:

- **Claude**: parallel subagents via the Agent tool, as above.
- **Codex**: run each probe through `codex exec --skip-git-repo-check -s read-only '<listing + probe + JSON answer instruction>'` (verified working; ~30s and ~13k tokens per probe), or graduate `tests/probes.yaml` to superpowers-bench, which has codex conditions built in.

Tune the description to satisfy the weaker harness — and re-run *both* panels after any description change, since a fix for one can regress the other.

When panels disagree across harnesses/models, triage by agreement: a probe failing under **all** models indicts the description (or the probe); a probe failing under **one** model is that model's routing quirk — record it in probes.yaml with the failing model rather than distorting the description to satisfy an outlier, unless that model is the primary harness.

## Adherence Checks

Define 3-6 binary pass/fail criteria from the skill's load-bearing behaviors — output paths, gates, question cadence, thresholds, escalation rules (see techniques.md, Technique 6). Pre-register them before running anything.

**Single variant** (health check): give a fresh subagent the SKILL.md text as its only instruction source plus a realistic invocation, and ask for its concrete execution plan. Score the criteria deterministically against the plan.

**Comparing variants** (after an audit): stage both versions under neutral names (`/tmp/skill-variant-A.md`, `-B.md`) so responders can't tell baseline from candidate. Run one responder per variant in parallel. Score deterministic criteria first — if all assertions are unambiguous, no judge is needed. Use an LLM judge only for subjective qualities, and then: pairwise with a rubric, run twice with positions swapped, disagreement counts as a tie, 3+ repeats. Position bias in pairwise judging is worst exactly when variants are close — the normal case for audit comparisons.

## External Tools (deeper passes, optional)

- **skill-cleaner** (agent-scripts) — library-wide description budget vs. the Codex 2% metadata cap, duplicate detection, unused-skill candidates.
- **superpowers-bench** — full-session selection benchmark across agents/models; `tests/probes.yaml` matches its task format, so probes written here can graduate to full-session runs.

## Report Format

```
## Evaluation: <skill-name> (<date>)

| Metric            | Value                       | Verdict |
|-------------------|-----------------------------|---------|
| Frontmatter       | 131 tokens                  | OK      |
| SKILL.md          | 1,563 tokens                | OK      |
| Expected load     | ~1,830 tokens/invocation    | OK      |
| Trigger F1        | 1.0 (6/6 trigger, 4/4 miss) | Healthy |
| Adherence         | 5/5 criteria                | Pass    |

Per-probe routing: <table or bullet list>
Notes: <anything surprising — misrouted probes, never-read references, drop-off patterns>
```

## Why These Measures

- Long/dense instruction sets measurably degrade compliance (context rot; instruction-density studies show primacy bias toward early rules) — hence per-tier token accounting and expected load.
- Skill selection happens on the description alone, so routing must be tested against the description in a realistic listing, not against the full body.
- LLM judges flip verdicts based on answer order; deterministic criteria and swap tests are the mitigation.
