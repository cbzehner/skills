---
name: design
description: >-
  Route standards-first design work to the right focused guidance. Use for
  design critique, visual polish, UX flows, accessibility, content, information
  architecture, service design, precedent study, lightweight design language
  extraction, or static HTML/CSS prototypes. For reviewing an existing artifact
  through a design or accessibility lens, use the review skill.
argument-hint: "[mode or design task]"
arguments:
  - task
license: MIT
effort: medium
allowed-tools: Read Write Edit Bash Glob Grep
---

# Design

Use this as the canonical entry point for design work. Pick the narrowest mode that fits the user's task, load only that reference file, then execute the workflow from the reference.

Do not load every reference. The point of this router is to reduce trigger surface without paying the context cost for all design disciplines.

## Routing

| User intent | Mode | Load |
|---|---|---|
| Design review, UX audit, polish pass, "what feels off" | `critique` | [references/critique.md](references/critique.md) |
| Layout, typography, color, spacing, hierarchy, visual polish | `visual` | [references/visual.md](references/visual.md) |
| Flows, forms, states, onboarding, task completion | `ux-flow` | [references/ux-flow.md](references/ux-flow.md) |
| WCAG, semantic HTML, keyboard nav, focus, contrast, ARIA | `accessibility` | [references/accessibility.md](references/accessibility.md) |
| Product copy, labels, CTAs, errors, empty states, tone | `content` | [references/content.md](references/content.md) |
| Navigation, sitemap, taxonomy, labels, page hierarchy | `information-architecture` | [references/information-architecture.md](references/information-architecture.md) |
| Service journeys, touchpoints, backstage work, handoffs, trust | `service` | [references/service.md](references/service.md) |
| Inspiration, references, precedent study, taste-building | `precedent` | [references/precedent.md](references/precedent.md) |
| DESIGN.md, tokens, consistency, visual rules, pattern inventory | `language` | [references/language.md](references/language.md) |
| Static HTML/CSS prototype, mockup, UI sketch, design artifact | `static-html` | [references/static-html.md](references/static-html.md) |

If the task spans multiple modes, load the primary mode first. Load a second reference only when the first one explicitly leaves a gap.

## Defaults

- For existing screens, start with `critique`.
- For new UI or prototype requests, start with `static-html` unless the user asked for production integration.
- For "make it look better", start with `visual`.
- For confusing flows, start with `ux-flow`.
- For shipping UI, pair the primary mode with `accessibility` before final review.

## Handoffs

- If the intended user, purpose, or core workflow is missing, route to `plan --interview`. Do not invent product direction inside `design`.
- If UI terminology conflicts with repo/product language, route to `domain-model audit`.
- If a design direction needs product interrogation, route to `counsel --interview`.
- After producing or changing UI, route to `review --as design`.
- Before shipping UI, route to `review --as accessibility`.
- If implementation uncovers a reproducible UI bug, route to `diagnose`.
