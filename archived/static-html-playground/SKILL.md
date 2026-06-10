---
name: static-html-playground
description: Builds static HTML/CSS playgrounds for design exploration. Use for prototypes, mockups, visual directions, UI sketches, and HTML artifacts.
argument-hint: "[brief or screen/flow to prototype]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

# static-html-playground

Build a self-contained static HTML artifact to explore a design idea with boring web standards: semantic HTML, plain CSS, minimal JavaScript, and no framework assumptions.

## When to Use

- The user asks for a prototype, mockup, visual exploration, UI sketch, or HTML artifact.
- The design question is easier to answer by seeing a working page than by describing it.
- The user wants design progress without committing to a production framework.
- The target project is Rails, Rust, static HTML, Hotwire, htmx, or another server-rendered stack.

## When NOT to Use

- The user asks for production integration in a specific app; implement in that app instead.
- The user needs a design critique only; use a critique skill before building.
- The user already has a working screen and wants tiny copy or spacing changes; edit the source directly.

## What to Skip

- Do not install React, Vue, Svelte, shadcn, Tailwind, animation libraries, build tools, or npm packages.
- Do not invent a design system. Use a few local CSS custom properties only when they make the artifact easier to edit.
- Do not create marketing-page boilerplate unless the brief is actually for a marketing page.

## Workflow

1. Identify the design question.
   State the screen, flow, audience, and decision being explored. A playground should answer one concrete question, not become a full app.

2. Choose the smallest useful artifact.
   Prefer one HTML file with embedded CSS and optional tiny JavaScript. Use real-looking content because placeholder text hides layout and wrapping problems.

3. Build from semantic structure outward.
   Start with headings, landmarks, forms, tables, lists, and buttons before styling. Boring HTML makes the prototype portable to Rails views, Rust templates, static sites, and docs.

4. Use CSS that can survive migration.
   Prefer normal flow, grid, flexbox, relative units, `max-width`, `min()`, `max()`, and `clamp()`. Keep selectors readable and avoid clever cascade tricks.

5. Add interaction only when it clarifies the design.
   If needed, use small vanilla JavaScript for tabs, disclosure, filters, or preview states. Keep core content visible and usable without JavaScript.

6. Verify the artifact.
   Open it locally when possible. Check desktop and mobile widths, keyboard focus, text wrapping, contrast, and whether the page still communicates with CSS or JS disabled.

## Output Shape

- Save the file where the user expects it, or in the working repo under a clearly named scratch/prototype location.
- Tell the user what design question the artifact answers.
- Mention any assumptions and what should be migrated into production if accepted.

## Examples

- "Mock up an account settings page" -> create one static HTML file with realistic account data, labels, errors, and responsive layout.
- "Show me three homepage directions" -> create one file with three stacked variants, each labeled in comments and visually distinct.
- "Prototype the onboarding flow" -> create a static multi-section page showing each step and state, not a routed SPA.

## Failure Handling

If the artifact would need project data or assets that are unavailable, use realistic neutral stand-ins and mark the assumption in the final response. If browser verification is unavailable, state that only source-level checks were completed.
