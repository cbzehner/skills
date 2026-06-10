---
name: design-language-extraction
description: Extracts a lightweight design language from existing work. Use for DESIGN.md, consistency, visual rules, patterns, tokens, and UI cleanup.
argument-hint: "[project, screens, files, or prototype]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

# design-language-extraction

Extract the smallest useful design language from existing screens, prototypes, or code so future work can stay consistent without creating a heavy design system.

## When to Use

- The user asks for a lightweight `DESIGN.md`, style guide, visual language, pattern inventory, or consistency pass.
- A project has repeated UI patterns but no documented rules.
- Agents need to understand existing typography, spacing, color, components, and states before editing UI.
- The user mentions design systems but wants to avoid ceremony.

## When NOT to Use

- The user wants a full governed component library with tokens, versioning, and contribution process.
- The project has no existing screens or visual references; use visual design standards or static HTML playground first.
- The task is only a single-screen critique.

## What to Skip

- Do not invent a design system from scratch.
- Do not create token taxonomies, component APIs, naming schemes, or governance unless explicitly requested.
- Do not normalize every difference. Preserve useful local variation when it serves different content or workflows.

## Workflow

1. Inventory what exists.
   Review representative screens, CSS, templates, screenshots, or prototypes. Capture recurring choices before judging them.

2. Extract visible rules.
   Document typography, spacing, color roles, layout widths, border/radius use, imagery, icon style, density, and common interaction states.

3. Identify stable patterns.
   Name repeated page structures, forms, navigation patterns, cards, tables, lists, modals, empty states, loading states, and error states.

4. Separate rules from accidents.
   Mark what appears intentional, what is inconsistent but harmless, and what creates user-facing confusion.

5. Keep the language lightweight.
   Prefer examples and practical rules over abstraction. Write guidance a build agent can apply directly.

6. Define "use" and "avoid".
   Include approved patterns, common mistakes, anti-patterns, and when exceptions are acceptable.

7. Produce a durable artifact if requested.
   A lightweight `DESIGN.md` should describe behaviors and visual contracts, not fragile file paths or line numbers.

## Output Shape

- Current visual language
- Repeated patterns
- Local rules of thumb
- States to preserve
- Inconsistencies to fix
- Avoid list
- Open questions

## Examples

- "Make a DESIGN.md for this Rails app" -> extract page structure, forms, buttons, alerts, tables, nav, spacing, and state rules.
- "Do we have a design system?" -> answer with the actual design language present, not a maturity-theater framework.
- "Clean up UI consistency" -> identify specific divergences and the smallest set of rules needed.

## Failure Handling

If the project has too few examples, say so and create a starter design language from the available screens only. If screenshots and source disagree, privilege the live or most recent user-facing artifact.
