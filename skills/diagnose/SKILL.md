---
name: diagnose
description: >-
  Debug failures systematically. Use when tests fail, behavior regressed,
  errors are unclear, the user says diagnose/debug/root cause/reproduce, or work
  is stuck due to an unknown cause.
argument-hint: "[failure, command, issue, or symptom]"
arguments:
  - failure
license: MIT
effort: medium
allowed-tools: Read Write Edit Bash Glob Grep
---

# Diagnose

Do not start by rewriting code. First make the failure concrete.

## Workflow

1. **Reproduce**
   Run the smallest command or interaction that shows the failure. Capture the exact command, input, output, and environment assumptions.

2. **Minimize**
   Reduce the failure to the smallest test, fixture, route, component, or data shape that still fails.

3. **Hypothesize**
   List 2-3 plausible causes. For each, name the observation that would confirm or falsify it.

4. **Instrument**
   Add the smallest temporary logging, assertion, focused test, debugger command, or query needed to distinguish the hypotheses.

5. **Fix**
   Make the smallest change that explains the evidence. Remove temporary instrumentation unless it should become a permanent regression test or diagnostic.

6. **Regression-Test**
   Add or update a test when practical. Re-run the original reproduction and the relevant focused verification.

## Guardrails

- If you cannot reproduce, say that and report what you tried.
- Do not stack speculative fixes.
- Do not trust a passing broad suite if the original failure path was never re-run.
- If the bug is architectural, stop after diagnosis and propose the smallest safe repair plan.

## Handoffs

- If the fix is too large for one focused change, route to `plan`.
- If root cause is unclear because domain terms or repo concepts conflict, route to `domain-model audit`.
- After a risky or broad fix, route to `review --as complexity` or `review --as architecture`.
- If the failure reveals a reusable setup gotcha or recurring trap, route to `repo-memory learning`.
- If UI behavior is the failing surface, route to `design` only after reproducing the failure.
