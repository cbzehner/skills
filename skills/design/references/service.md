---
name: service-design
description: Designs end-to-end services. Use for journeys, service blueprints, touchpoints, backstage work, handoffs, support, trust, and failure recovery.
argument-hint: "[service, journey, or experience to map]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

# service-design

Design the whole service around the user's journey and the organization's ability to deliver it reliably.

## When to Use

- The user mentions service design, customer journeys, service blueprints, touchpoints, channels, support, operations, or handoffs.
- A product experience depends on people, policies, email, moderation, fulfillment, onboarding, support, or offline work.
- The problem is bigger than a single screen.

## When NOT to Use

- The task is one interface screen with no operational complexity; use UX or visual design.
- The user only needs page hierarchy or navigation labels; use information architecture.
- The user needs production code immediately and the service model is already clear.

## What to Skip

- Do not reduce the service to UI screens.
- Do not invent internal teams, policies, or SLAs as facts. Mark assumptions.
- Do not create a polished blueprint before identifying the moments where the service can fail.

## Workflow

1. Define the service promise.
   State what the user believes the service will do for them and what the organization must deliver to keep that promise.

2. Identify actors and channels.
   Include customers, staff, automated systems, partners, moderators, support, emails, documents, and external services.

3. Map the journey.
   Break the journey into stages: trigger, entry, evaluation, action, waiting, resolution, follow-up, and return.

4. Separate frontstage and backstage.
   For each stage, list what the user sees, what staff or systems do behind the scenes, and which artifacts move the service forward.

5. Find handoffs and failure modes.
   Highlight places where context can be lost, delays occur, trust drops, responsibility is ambiguous, or recovery is weak.

6. Design recovery.
   Define how the service prevents errors, detects them, communicates clearly, escalates, compensates, and closes the loop.

7. Produce a blueprint.
   Use a simple table unless a diagram is requested: stage, user goal, frontstage touchpoint, backstage process, evidence, risk, improvement.

## Examples

- "Design the appeal process" -> map submission, review, evidence, notification, support, decision, escalation, and audit trail.
- "Improve onboarding for organizations" -> include sales/support handoffs, admin setup, invitations, training, and first success.
- "Map trust and safety moderation" -> include reporting, triage, review, user communication, appeals, and policy learning.

## Failure Handling

If backstage operations are unknown, label the assumptions and produce a "questions to validate" list. If the user wants only UI after a service map, hand off the relevant stages to UX flow design.
