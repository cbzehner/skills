---
name: sre-incident-response
description: >-
  Coordinates active service incidents, customer-impact triage, reversible
  mitigation, recovery verification, postmortems, and SLO burn-rate alerts.
  Use when operational impact or error-budget decisions drive the work;
  not routine application debugging or an isolated unit configuration task.
license: MIT
metadata:
  author: cbzehner
  version: "0.1.0"
  reviewed: "2026-10-28"
---

# SRE incident response

Mitigation and root-cause proof are separate outcomes.

## Inputs and result

Establish affected service/environment, user impact, start time/timezone,
known changes, response owner, and authorization boundary. Maintain a concise
incident record: observations, hypotheses, actions/results, current impact,
next check, and recovery decision. Distinguish facts from estimates.

## Workflow

1. **Scope and coordinate.** Determine who is affected, which user journey is
   impaired, and whether the incident is ongoing. Identify the incident lead
   and change owner; use the team's severity and communication conventions
   instead of inventing policy. Parallelize investigation only with explicit
   ownership so responders do not apply competing changes.
2. **Preserve bounded evidence.** Capture timestamps, relevant metrics, a limited
   log window, deployment/config revisions, and resource state before a restart
   or failover. Keep secrets and personal data out of the record. Compare an
   affected path with a healthy control. Rank a few hypotheses and name the
   observation that would distinguish them; do not turn guesses into a timeline.
3. **Choose a reversible mitigation.** Compare expected impact reduction,
   blast radius, time to effect, data integrity, and rollback. Prefer a scoped,
   observed change over simultaneous restarts or speculative tuning. Confirm
   authorization for disruptive production actions not already approved. If
   access or ownership is missing, provide the exact proposed action and needed
   evidence rather than executing against an assumed target. Record each
   action's outcome before choosing the next one.
4. **Prove recovery at the user boundary.** Use the original impact signal and
   representative user journeys. State an observation duration justified by
   normal traffic and the failure cadence; if these are unknown, name the
   missing baseline rather than referring vaguely to an agreed interval. Check
   backlog/retry load and data consistency where relevant. A green process or
   a single successful request is not recovery. State remaining uncertainty,
   partial mitigations, and whether a rollback was actually exercised.
5. **Close and learn.** Hand off current state, owners, remaining risks, and the
   next update/check time. Write a blameless postmortem from evidence: impact,
   timeline with timezone, contributing conditions, what helped/hindered, and
   concrete follow-ups with owners and validation criteria. Do not invent a
   root cause simply to make the incident look complete.

## SLO calculations when relevant

Define the SLI's good/total events, target, evaluation period, and exclusions
before choosing thresholds. For an event-ratio SLO:

- `burn rate = observed bad-event ratio / (1 - SLO target)`.
- Exact budget fraction consumed is `bad events in window /
  ((1 - SLO target) * total eligible events in SLO period)`.
- With steady traffic (or a time-based SLI), the approximation is
  `burn rate * alert window / SLO period`, using consistent units.

For a 30-day period (720 hours), 1x burn for 6 hours consumes about **0.83%**,
not 5%; 6x for 6 hours consumes 5%, and 14.4x for 1 hour consumes 2%.
For variable traffic, do not present the time-ratio approximation as exact.
Use multiwindow evidence and service-specific page/ticket policy; copied Google
thresholds are examples, not universal production settings.

## When NOT to use

- An ordinary test failure or local development bug with no service impact.
- An isolated systemd/Quadlet/Nix change; load its domain skill instead.

## What to skip

No automatic chaos tests, load tests, credential rotation, broad restarts,
failovers, alert disabling, or log deletion merely because an incident exists.

## Handoffs

Use `linux-systemd`, `podman-quadlet`, `hetzner-operations`, or
`nix-infrastructure` for the relevant technical surface. Keep coordination and
recovery criteria here; do not duplicate those skills' execution procedures.

## Sources

Original local guidance; primary references reviewed on the metadata date.

- [Google SRE Workbook: Incident Response](https://sre.google/workbook/incident-response/)
- [Google SRE Workbook: Alerting on SLOs](https://sre.google/workbook/alerting-on-slos/)
