---
name: accessibility-review
description: Reviews accessibility and inclusive design. Use for WCAG, semantic HTML, keyboard nav, focus, contrast, forms, ARIA, and non-color cues.
argument-hint: "[page, file, flow, or prototype]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

# accessibility-review

Review web experiences for accessibility using web standards, semantic HTML, keyboard behavior, contrast, clear language, and inclusive interaction patterns.

## When to Use

- The user asks for accessibility, WCAG, keyboard navigation, focus states, contrast, ARIA, screen readers, or inclusive design.
- UI work is being reviewed before shipping.
- A static HTML prototype or server-rendered page needs a quality gate.

## When NOT to Use

- The user only wants visual style exploration and accessibility is not the focus.
- The problem is service operations or support policy rather than interface access.
- The user asks for a legal compliance opinion; provide engineering review, not legal advice.

## What to Skip

- Do not add ARIA where native HTML already provides the right role and behavior.
- Do not rely on color alone to communicate status.
- Do not accept custom interactive elements unless keyboard and focus behavior match native controls.

## Workflow

1. Start with semantics.
   Check landmarks, headings, links, buttons, lists, tables, forms, labels, and alt text. Native elements carry accessibility for free.

2. Check keyboard operation.
   Every interactive element must be reachable, visible on focus, operable with keyboard, and ordered logically.

3. Review forms and errors.
   Labels must be programmatically associated. Required fields, hints, invalid states, error summaries, and recovery actions must be clear.

4. Check contrast and visual dependence.
   Normal text needs strong contrast. Status must include text, shape, or icon in addition to color.

5. Review dynamic updates.
   Loading, success, error, modal, disclosure, tab, and toast behavior must preserve focus and communicate changes.

6. Test responsive and zoom behavior.
   Content should remain usable at narrow widths and high zoom without overlap or hidden controls.

7. Report findings by severity.
   Lead with issues that block use, then serious friction, then polish. Include concrete fixes.

## Examples

- "Audit this form" -> labels, hints, autocomplete, required state, errors, focus order, submission recovery.
- "Check this prototype for WCAG issues" -> semantic structure, contrast, keyboard, non-color cues, headings.
- "Is this custom dropdown accessible?" -> compare against native select/button/listbox expectations.

## Failure Handling

If automated tools are unavailable, perform manual source and behavior review and state that automated axe/Lighthouse checks were not run. If a pattern cannot be made accessible cheaply, recommend a native HTML alternative.
