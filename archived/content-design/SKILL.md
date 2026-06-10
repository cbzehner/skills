---
name: content-design
description: Designs product copy and microcopy. Use for labels, CTAs, forms, errors, empty states, onboarding, help text, tone, and clarity.
argument-hint: "[screen, flow, or copy to improve]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

# content-design

Write interface content that helps users understand what is happening, what to do next, and how to recover.

## When to Use

- The user asks for copy, microcopy, labels, CTAs, forms, empty states, errors, onboarding, help text, or tone.
- A UI is confusing because the words are vague, technical, generic, or too long.
- A flow needs trust, consent, warning, confirmation, or recovery language.

## When NOT to Use

- The problem is page structure or navigation grouping; use information architecture.
- The problem is visual layout or typography.
- The user asks for marketing copy unrelated to product use.

## What to Skip

- Do not write cute copy where clarity matters.
- Do not use "Oops", "Something went wrong", or blame-shifting language for important errors.
- Do not hide requirements, consequences, or irreversible actions.

## Workflow

1. Identify the user's moment.
   Determine whether they are starting, deciding, waiting, succeeding, failing, recovering, or leaving.

2. Define the message job.
   Every bit of UI copy should inform, guide, reassure, warn, or confirm. Cut copy with no job.

3. Use plain language.
   Prefer short sentences, concrete verbs, active voice, and domain terms users already know.

4. Make actions specific.
   Buttons should describe the action: "Send invite", "Save changes", "Request review", "Delete workspace".

5. Make errors actionable.
   Explain what happened, why if useful, and exactly how to fix it. Preserve user input after errors.

6. Design empty states honestly.
   Say why the area is empty and what the user can do next. Do not use empty states as generic marketing blocks.

7. Check tone against risk.
   Higher-risk moments need calmer, more explicit language.

## Examples

- "Improve this error message" -> replace vague failure with cause, recovery action, and support path if needed.
- "Write empty states" -> create variants for no data yet, no results, permission denied, and cleared filters.
- "Fix button labels" -> make labels specific and consistent across the flow.

## Failure Handling

If product facts are missing, do not invent policy. Use neutral copy and mark the fact that needs confirmation.
