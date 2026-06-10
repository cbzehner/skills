---
name: write-a-prd
description: Create a Product Requirements Document through user interview, codebase exploration, and module sketching, then file it as a GitHub issue or local Markdown. Use when user wants a PRD, product requirements, feature spec, or to formalize a feature idea into a shareable document. Distinct from superpowers:writing-plans — this produces a PRD before any implementation plan exists.
license: MIT
effort: high
allowed-tools: Read Write Edit Bash Glob Grep Skill
metadata:
  based-on: "Matt Pocock's write-a-prd skill"
  upstream: "https://github.com/mattpocock/skills/tree/main/write-a-prd"
---

# /write-a-prd

Create a PRD by interviewing the user, exploring the codebase, sketching deep modules, then filing the PRD as a GitHub issue (or local file if no remote).

## When NOT to Use

- **Implementation plan from an existing PRD** → use `prd-to-plan`. PRDs describe what to build; plans describe phased execution.
- **Brainstorming an idea before commitment** → use `superpowers:brainstorming`. Brainstorming explores intent; this captures decisions.
- **Refactor planning** → use `request-refactor-plan` (if available) or just write the plan directly. PRDs are for new features, not internal restructures.

## Workflow

You may skip steps when the conversation already covered them — capture, don't re-interview.

### 1. Get a long, detailed description

Ask the user for a long, detailed description of the problem they want to solve and any potential solutions they've considered. Encourage rambling — you'll structure it later.

### 2. Verify in the codebase

Explore the repo to confirm the user's assertions and understand current state. If the user says "we don't have X yet", check. If they say "this currently does Y", trace it.

### 3. Grill the user

Interview relentlessly about every aspect of the plan. For every question, **provide your recommended answer** — lead with "I'd recommend X because Y. Want to go with that, or something different?"

Walk down each branch of the design tree, resolving dependencies between decisions one at a time. Sub-decisions before siblings.

If a question can be answered by the codebase, **explore the codebase instead of asking**.

If grilling gets long, consider invoking `/grill-me` for a tighter loop.

### 4. Sketch modules

Sketch the major modules you'll need to build or modify. Actively look for opportunities to extract **deep modules** that can be tested in isolation.

A deep module = small interface + lots of implementation. The interface rarely changes; the implementation hides complexity. Shallow modules = wide interface + thin implementation, and should be avoided.

Ask the user: do these modules match expectations? Which need tests? What's the test surface — unit, integration, end-to-end?

### 5. Write the PRD

Use the template below. Submit as a GitHub issue when a remote exists; otherwise write to `./prds/<feature-slug>.md`.

**Tool detection**: prefer `gh-axi` over `gh` if available (`command -v gh-axi`) because its output is optimized for agent parsing and idempotent mutations. Fall back to `gh issue create` when `gh-axi` is absent.

**Durability rule**: do NOT include specific file paths, line numbers, or current code snippets. Code moves; the PRD shouldn't break the moment it's read three weeks from now. Describe modules, behaviors, and contracts — not implementation.

<prd-template>

## Problem Statement

The problem the user is facing, from the user's perspective. Not "the system has bug X" but "users can't accomplish Y because of X".

## Solution

The solution to the problem, from the user's perspective. What changes for them when this ships?

## User Stories

A LONG, numbered list of user stories. Each follows the format:

`As an <actor>, I want <feature>, so that <benefit>`

Example:
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending

This list should be extensive — cover all aspects of the feature, including edge cases, error states, and admin paths. Aim for ≥ 8 stories on a non-trivial feature.

## Implementation Decisions

Decisions made during the interview. Include:

- Modules to build/modify (by name and responsibility, not file path)
- Interfaces to be modified (signature shape, not source location)
- Technical clarifications from the developer
- Architectural decisions
- Schema or data-model changes
- API contracts
- Specific interactions or flows

Do NOT include file paths, line numbers, or code snippets — they go stale.

## Testing Decisions

- A description of what makes a good test for this feature (test behavior through public interfaces, not implementation)
- Which modules will be tested
- Prior art in the codebase — similar test patterns already established

## Out of Scope

What is NOT being built in this PRD. Be explicit. This prevents gold-plating during implementation.

## Further Notes

Optional. Anything else worth recording.

</prd-template>

After filing, share the issue URL or file path with the user. Suggest `prd-to-plan` as the next step.
