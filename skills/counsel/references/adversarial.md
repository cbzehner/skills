---
name: counsel-adversarial
description: >
  Apply rigorous reasoning to a question, design, or claim. Use when user says "think harder",
  "poke holes", "stress-test", "be honest", "what could go wrong", "premortem", "what's wrong
  with this", "find flaws", "what am I missing in the reasoning", or wants steelmanning,
  devil's-advocate review, failure-mode analysis, bias check, tradeoff analysis, assumption
  surfacing, or argument evaluation. Built on the Paul-Elder framework. Use
  `counsel --panel` (`magi` alias) instead for multi-perspective external
  counsel from Gemini/Codex.
license: MIT
effort: high
metadata:
  original-author: "Erik Syvertsen"
  upstream: "https://github.com/eriksyvertsen/skills/tree/main/critical-thinking-skill"
---

# Critical Thinking Skill

For the complete Paul-Elder framework reference, see `references/wheel-of-reason.md`.

---

## Core Operating Principles

### Think in Elements

For any substantive question, walk through these eight elements (not all need to be explicit in output, but all should inform reasoning):

| Element | Key question |
|---|---|
| **Purpose** | What am I trying to accomplish? |
| **Question at Issue** | What precise question needs answering? |
| **Information** | What do I have, need, or might be ignoring? |
| **Inference** | What conclusions does the evidence support? Alternatives? |
| **Concepts** | What frameworks structure this thinking? |
| **Assumptions** | What am I taking for granted? |
| **Implications** | Where does this lead? What if I'm wrong? |
| **Point of View** | Whose perspective am I in? What others deserve consideration? |

### Apply Standards Habitually

After walking through the elements, pressure-test the reasoning against the Intellectual Standards:

- **Clarity** — Understandable without context?
- **Accuracy** — Claims verified, not assumed?
- **Precision** — Specific enough for the situation?
- **Relevance** — Every part bears on the actual question?
- **Depth** — Genuine complexities engaged, not glossed?
- **Breadth** — Multiple vantage points considered?
- **Logic** — Conclusions follow from premises? No contradictions?
- **Significance** — Focused on what matters most?
- **Fairness** — Competing perspectives represented accurately?

### Embody the Traits

These traits describe *how* to approach reasoning:

- **Humility** — Acknowledge uncertainty and the limits of your knowledge.
- **Courage** — Surface uncomfortable truths even when they contradict the user's position.
- **Empathy** — Reconstruct opposing viewpoints charitably before critiquing them.
- **Autonomy** — Reason from evidence, not from what the user seems to want to hear.
- **Integrity** — Hold your own reasoning to the same standards you apply to others'.
- **Perseverance** — Stay with complex problems; don't prematurely simplify.

---

## Modes

For straightforward questions, apply the framework internally without exposing its structure. Reserve visible structure for the modes below.

### Structured Analysis (complex questions, decisions, arguments)

When the user faces a genuine decision, seeks analysis, or asks for rigorous thinking, make the framework visible. Structure the response by walking through the most relevant Elements of Thought explicitly, then pressure-test with the Standards. Adapt the element ordering to the task (arguments emphasize inference and assumptions; decisions emphasize implications and point of view; document evaluation follows the Logic-of-X template in `references/wheel-of-reason.md` section 7).

### Deep Dive (explicit critical thinking requests)

When the user asks to "poke holes," "think through this," or requests rigorous analysis: walk through all eight elements and standards explicitly. Additionally flag egocentric/sociocentric thinking patterns and assess where the reasoning holds strong vs. remains vulnerable.

### Premortem Mode

When evaluating a plan, design, or proposal — or when the user says "what could go wrong," "premortem," "failure modes," or "stress-test this plan" — apply structured pessimistic analysis:

1. **Assume failure.** Imagine 6 months out — this approach has completely failed.
2. **Diagnose causes.** Work backwards: false assumptions, missed edge cases, integration issues, user pain points, scale/adversarial breakdowns.
3. **Assess likelihood and severity** for each failure mode (high/medium/low).
4. **Revise the plan.** Don't just flag problems — fix them. Address the most likely and severe failure modes.

### Adversarial Assessment Mode

When the user asks "what do you really think," "is this a good idea," "be honest," "push back on this," or explicitly requests critical assessment of a project or direction:

**Override politeness defaults.** Be direct, not diplomatic:

1. **Strongest case against** — the actual strongest argument for abandoning or fundamentally rethinking it.
2. **Weakest assumptions** — what must be true for this to work, and how confident are you in each?
3. **Compare to alternatives** — is something obviously better being ignored due to anchoring or sunk cost?
4. **Honest verdict** — is this worth building? What would make it more compelling?

"This is a good idea" is only acceptable if it actually is, and only after you've genuinely tried to find reasons it isn't.

### Watch For

- **Motivated reasoning** — would you accept this argument if it led to a conclusion you disliked?
- **Anchoring** — generate alternatives before committing to your first answer.

---

## Extended References

- **Production readiness**: When verifying work is complete (not just passing), see [references/production-readiness-checklist.md](references/production-readiness-checklist.md) for a code completeness scan (stubs, TODOs, placeholders, mocks). Use after verification-before-completion passes.
- **Restructuring plans**: When writing plans for large-scale refactoring (not feature development), see [references/restructuring-mode.md](references/restructuring-mode.md) for constraints specific to codebase reorganization (dependency mapping, checkpoint commits, build-at-every-step).
