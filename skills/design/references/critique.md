---
name: design-critique
description: Critiques designs and screens. Use for design review, UX audit, visual critique, polish pass, usability risks, and implementation-ready fixes.
argument-hint: "[screen, URL, screenshot, prototype, or files]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

# design-critique

Critique a design with practical findings: what blocks understanding, what hurts task completion, and what specific changes would improve it.

## When to Use

- The user asks for design review, UX audit, critique, polish pass, "make this better", "what's wrong", or "why does this feel off".
- There is an existing screen, screenshot, URL, prototype, or source file to evaluate.
- The user needs prioritized fixes rather than a new design direction.

## When NOT to Use

- The user asks to create a prototype from scratch; use static HTML playground.
- The user asks to map a whole service; use service design.
- The user asks only for copy edits; use content design.

## What to Skip

- Do not produce vague praise or taste commentary.
- Do not redesign everything when a few targeted changes would solve the problem.
- Do not recommend a component library or design system as the fix.

## Workflow

1. Inspect the current artifact.
   Use the provided screenshot, URL, file, or description. If a browser is available, experience the page at mobile and desktop sizes.

2. Identify the intended job.
   A critique needs a standard. State what the screen appears to be trying to help the user do.

3. Review in order of user impact.
   Check comprehension, primary action, flow continuity, accessibility, responsiveness, content clarity, visual hierarchy, and polish.

4. Apply the reduction filter.
   Remove or demote elements that do not help the user decide, understand, or act.

5. Prioritize findings.
   Group issues as blocking, high-impact, medium, and polish. Each finding should include why it matters and how to fix it.

6. Produce an implementation-ready pass.
   Include concrete recommendations: change label, move action, reduce competing styles, add state, improve focus, adjust spacing.

7. Separate facts from taste.
   Mark subjective direction choices separately from usability or accessibility problems.

## Examples

- "Review this signup page" -> primary action clarity, field burden, trust language, validation, mobile layout.
- "Why does this dashboard feel messy?" -> competing hierarchy, over-carded layout, weak grouping, poor density.
- "Audit this prototype" -> prioritized findings and a small set of changes, not a full rewrite.

## Failure Handling

If the artifact cannot be opened, critique the available source or screenshot and state the limitation. If user goals are unclear, infer the likely goal and label it as an assumption.
