---
name: grill-me
description: Interview the user one question at a time about an existing plan or design, walking down each branch of the decision tree. Use when user says "grill me", "interview me", "push back on me", "ask me questions", or wants the assistant to probe their reasoning conversationally. Distinct from superpowers:brainstorming (starts from intent, not a draft) and critical-thinking (delivers a verdict via analysis — grill-me asks questions instead of analyzing). Do NOT use for premortem, failure-mode analysis, or stress-testing claims — those are critical-thinking.
license: MIT
effort: low
allowed-tools: Read Glob Grep
metadata:
  based-on: "Matt Pocock's grill-me skill"
  upstream: "https://github.com/mattpocock/skills/tree/main/grill-me"
---

# /grill-me

Interview the user relentlessly about every aspect of an existing plan or design until you reach shared understanding. Walk down each branch of the decision tree, resolving dependencies between decisions one at a time.

## When NOT to Use

- **Exploring requirements from scratch** → use `superpowers:brainstorming`. Brainstorming starts from intent. grill-me starts from a draft.
- **Multi-perspective external counsel** → use `magi`. magi gathers parallel opinions; grill-me drives a focused single-thread interview.
- **Verdict on whether a plan is good** → use `critical-thinking` Adversarial Assessment mode. critical-thinking gives the verdict; grill-me uncovers blind spots.

## How

Ask questions **one at a time**. Wait for the answer before moving on.

For every question, **provide your recommended answer** alongside the question. Lead with "I'd recommend X because Y. Want to go with that, or something different?"

If a question can be answered by exploring the codebase, **explore the codebase instead of asking**. The user shouldn't have to remember details that the code already has.

Walk down each branch of the decision tree. When a decision opens up new sub-decisions, surface those before moving sideways. Resolve dependencies before exploring siblings.

Stop when each remaining decision is either resolved with shared understanding, or out of scope for this draft.
