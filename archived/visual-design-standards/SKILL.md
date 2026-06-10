---
name: visual-design-standards
description: Applies boring web visual design standards. Use for layout, typography, color, spacing, visual hierarchy, polish, and non-generic UI direction.
argument-hint: "[screen, page, or design brief]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

# visual-design-standards

Improve visual design through durable web fundamentals: hierarchy, typography, spacing, alignment, contrast, imagery, and restraint.

## When to Use

- The user asks to make an interface look better, cleaner, calmer, more trustworthy, more professional, or less AI-generated.
- The work involves layout, type scale, color, spacing, visual rhythm, affordance, or visual polish.
- A design direction is needed before implementation.

## When NOT to Use

- The user needs service-level journey mapping; use service design.
- The problem is mostly wording, labels, or error messages; use content design.
- The request is only to enforce accessibility conformance; use accessibility review.

## What to Skip

- Do not create a full design system unless explicitly asked. Favor local rules that make the current page better.
- Do not add decorative gradients, oversized cards, glass effects, generic SaaS hero layouts, or theme-heavy palettes by default.
- Do not propose framework-specific components.

## Workflow

1. Establish the page's job.
   Visual choices should make the primary task easier to understand and complete. Name the primary action, secondary actions, and information hierarchy.

2. Audit hierarchy before decoration.
   Check whether the eye lands in the right place, headings describe the content, primary actions are obvious, and related elements are grouped.

3. Set body text first.
   Choose readable body size, line height, and line length before tuning headings. Good typography starts with text people can actually read.

4. Use a restrained palette.
   Prefer neutral surfaces, strong text contrast, one action color, and explicit status colors. Color should communicate role or state, not fill empty space.

5. Normalize spacing and alignment.
   Use a small spacing scale and consistent edges. Fix visual noise before adding new elements.

6. Design states.
   Cover hover, focus, active, disabled, loading, empty, and error states. An interface is not visually complete if only the happy path is styled.

7. Keep motion practical.
   Use motion to orient or confirm, usually under 300ms. Respect reduced motion and avoid animation that delays work.

## Examples

- "Make this dashboard less cluttered" -> reduce competing visual weights, tighten grouping, clarify page title and primary actions.
- "This form feels bad" -> fix label rhythm, input widths, help text, validation states, and submission hierarchy.
- "Give this page a visual direction" -> choose typography, spacing, tone, and restrained color rules without naming a component library.

## Failure Handling

If brand constraints are missing, infer a conservative direction from the product and audience, then state the assumption. If a requested style would hurt usability, explain the tradeoff and offer a standards-first alternative.
