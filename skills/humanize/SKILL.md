---
name: humanize
description: Make prose sound like a real person wrote it. Use when cleaning up
  AI-assisted text, documentation, READMEs, product copy, emails, posts, or any
  writing that feels generic, over-polished, robotic, or detector-shaped. Also
  trigger on "humanize", "de-slop", "de-slopify", "make this sound human",
  "less AI", "remove AI patterns", or "this reads like AI wrote it".
license: MIT
effort: low
allowed-tools: Read Edit Write Grep
---

# Humanize

Rewrite or audit prose so it sounds natural in its actual setting: README, technical doc, Slack update, email, blog post, product copy, or notes. Preserve meaning. Remove the synthetic feel.

## Why This Exists

LLM-assisted text often has the same tells: safe vocabulary, smooth paragraph arcs, filler transitions, over-balanced claims, and punctuation used as structure. Readers notice even when they cannot name the pattern. This skill edits for credibility, clarity, and register fit.

This skill borrows useful signal categories from Harshaneel's [`humanize`](https://github.com/harshaneel/humanize) work, especially the audit-first framing around burstiness, hedges, specificity, punctuation, and rhetorical scaffolding. It does not copy that workflow wholesale. Keep this version smaller, less detector-evasion-centered, and more focused on making public writing good.

## Process

1. Read the full text before editing.
2. Identify the register: README, docs, email, Slack, long-form prose, marketing copy, or notes.
3. Run a quick audit using [references/pattern-checklist.md](references/pattern-checklist.md). Look for repeated vocabulary, hedges, symmetry, over-smooth transitions, punctuation tells, and missing concrete detail.
4. Rewrite in one coherent pass. Do not do mechanical find-and-replace.
5. Read the result mentally. It should sound like a specific person in the right context, not a helpful assistant trying to pass as casual.

When the user asks for an audit, score the issues before rewriting:

```markdown
Humanize Audit
- Register: README / docs / Slack / email / prose / other
- Strong tells: ...
- Weak tells: ...
- Keep: phrasing or structure that already works
- Edit plan: 3-5 concrete changes
```

## Pattern Checklist

See [references/pattern-checklist.md](references/pattern-checklist.md) for the working list of vocabulary, structure, punctuation, and register tells.

## Register Rules

- README/docs: be direct, concrete, and short. Avoid marketing verbs, generic benefit claims, and perfectly symmetric bullets.
- Technical prose: use domain nouns and verbs. Keep tradeoffs direct. Do not inflate ordinary engineering work.
- Email: cut throat-clearing openers and templated closers. Put the ask early.
- Slack/chat: allow fragments, approximations, and small course corrections. Do not write a polished status report with casual markers sprinkled on top.
- Long-form prose: vary sentence length and paragraph shape. Drop miniature aphorism closers unless they are genuinely earned.

## What NOT to Do

- Don't make the text bland. Humanizing means adding fit and specificity, not sanding every edge off.
- Don't promise to bypass detectors. The goal is credible human writing, not evasion.
- Don't replace every flagged word mechanically. A word can be fine once and suspicious four times.
- Don't add your own AI patterns while fixing others.
- Don't change technical terms, code, or quoted material.

## Output

Return the edited text first unless the user asked for an audit. Then briefly note what changed, for example: "Cut filler openers, broke up two symmetrical bullets, made the README examples more concrete."
