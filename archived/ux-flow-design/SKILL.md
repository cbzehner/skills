---
name: ux-flow-design
description: Designs UX flows and interaction states. Use for user flows, forms, onboarding, navigation, task completion, usability, and interaction models.
argument-hint: "[task, flow, or product area]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

# ux-flow-design

Design user flows by clarifying the user's goal, the system's response, and every state needed to complete the task.

## When to Use

- The user asks about UX, usability, flows, onboarding, forms, navigation, task completion, or interaction design.
- A feature needs screen-to-screen behavior before code.
- A current flow feels confusing, long, brittle, or hard to recover from.

## When NOT to Use

- The work is only visual polish; use visual design standards.
- The work spans multiple channels, teams, policies, or operational handoffs; use service design.
- The user only needs production code for a fully specified interaction.

## What to Skip

- Do not start with pixels. Start with tasks, decisions, states, and failure recovery.
- Do not assume an app shell, client-side routing, or SPA state model.
- Do not hide core workflow behind JavaScript-only behavior.

## Workflow

1. Name the user and their job.
   Identify who is acting, what they are trying to accomplish, what they know at the start, and what success looks like.

2. Map the happy path.
   List the minimum steps from entry point to completion. Remove steps that only exist because the implementation is convenient.

3. Add decision points and alternate paths.
   Capture permission differences, empty data, invalid inputs, cancellations, edits, retries, and destructive actions.

4. Define screen and component states.
   Include default, loading, partial, empty, error, success, disabled, read-only, and confirmation states.

5. Design feedback and recovery.
   Every action should answer: did it work, what changed, what can be undone, and what happens next?

6. Check progressive enhancement.
   Core form submissions, navigation, and destructive actions should have standard web behavior before enhancement.

7. Produce an implementation-ready flow.
   Summarize the flow in plain language, then provide a state table or step list that a build agent can implement without guessing.

## Examples

- "Design signup UX" -> entry paths, fields, validation timing, email verification, errors, resend, success, and next step.
- "Fix this settings flow" -> identify user intent, group settings, prevent data loss, define save/cancel feedback.
- "Make onboarding better" -> reduce upfront questions, expose progress, support skipping, and define recovery.

## Failure Handling

If user goals or roles are unclear, make the smallest explicit assumption and mark it. Ask only when different answers would produce materially different flows.
