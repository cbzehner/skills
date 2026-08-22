---
name: codebase-audit
description: >-
  Run a read-only whole-codebase audit of data structures, state models,
  algorithms, and ownership. Use when the user asks to audit the codebase,
  re-audit after simplifications, inventory subsystems for invalid states, or
  run a coverage-contract review with independent verification. Report-only;
  do not edit. Diff reviews belong to review; applying simplifications belongs
  to complexity-guard; stop-condition campaigns belong to optimize.
argument-hint: "[repo or subsystem scope]"
arguments:
  - scope
license: MIT
effort: high
allowed-tools: Read Glob Grep Bash Agent
---

# /codebase-audit

Audit a repository for materially useful simplifications in data structures, state representation, control flow, algorithms, and ownership. Stay read-only until the user asks to implement.

## When to Use

- The user asks to audit a codebase, re-audit after shipped simplifications, or run a coverage-contract review.
- The target is data structures, state models, invalid combinations, duplicated branching, or unclear ownership.
- The user wants mixed-lane workers (Grok, Claude Opus, Codex Sol) plus an independent coordinator.

## When NOT to Use

- A concrete diff, PR, or plan needs a role-based findings report → `review`.
- The user wants overengineering fixes applied now → `complexity-guard`.
- The user wants a stop-condition cleanup campaign with edits → `optimize`.
- The problem is glossary, ADR, or ubiquitous-language drift → `domain-model`.
- The problem is an unexplained failure → `diagnose`.

## What to Skip

- Do not edit files, run mutating tests, implement recommendations, commit, or push.
- Do not recommend style-only consistency, hypothetical extensibility, minor line-count cuts, or wrapping existing branches in a new type.
- Do not force an abstraction when boring local code is already clear.
- Do not treat a catch-all row as coverage. Missing subsystems get their own row and their own review.

## Workflow

### Step 1: Coverage contract

Inspect the repository and inventory every identifiable subsystem.

Give each row a stable ID, descriptive name, exact ownership boundary, key files, public interfaces or call sites, tests, and a status: `queued`, `in review`, `recommend`, or `skip`.

Include frontend, backend, shared infrastructure, generated-contract ownership, and test/tooling where they own a real model. Skip vendor, build output, caches, and generated copies owned by another row.

Write one canonical scratchpad outside the repo. That file is the coverage contract: inventory, confirmed opportunities, explicit skips, duplicates, priorities, and an audit log.

### Step 2: Bounded subsystem reviews

Give every worker one subsystem and a non-overlapping ownership boundary. At most two opportunities per worker. If nothing meets the threshold, the worker returns `skip`.

Keep concurrency to the lanes you can actually harvest. Prefer mixed models when available: Grok explore for several subsystems in parallel, one Claude Opus lane, one Codex Sol lane. See [references/lanes.md](references/lanes.md).

Send each worker the brief in [references/worker-brief.md](references/worker-brief.md).

### Step 3: Coordinator verification

Independently check every finding against the current repository before accepting it.

Reject, narrow, or demote findings that are vague, duplicate another row, misunderstand intentional semantics, merely relocate complexity, or require a public-contract cutover the user already declined.

Assign each accepted recommendation to one authoritative subsystem. Record skips as completed coverage.

Continue batches until every inventory row is `recommend` or `skip`.

### Step 4: Audit the audit

Run a last pass for:

- missing subsystem boundaries
- duplication and ownership overlap
- materiality and over-abstraction
- complete evidence / scope / risk / validation fields
- dependency-aware ranking

If a real omission appears, add a row and review it. Do not hide it by widening a finished boundary.

Rank remaining work by concrete impact, confidence, implementation effort, blast radius, and prerequisites. Name the best first implementation slices.

The audit is complete only when every identifiable subsystem has been reviewed, every finding has complete fields, weak abstractions are gone, priorities are consistent, and the repository is unchanged.

## Output

```markdown
Coverage
- SID Name — recommend | skip — one-line reason

Accepted
1. [priority] SID: finding. Why it matters. Smallest slice. Confidence.

Rejected
- SID: finding. Why it is not a simplification.

First slices
- Ordered, dependency-aware starting points.

Checks
- Repo remained unchanged: yes/no
```

## Handoffs

- User asks to implement accepted findings → `complexity-guard` for safe cuts, `plan` for schema or public-contract changes.
- User only wanted a diff critique → `review`.
- User wants ongoing cleanup with a stop condition → `optimize`.
- A finding is really vocabulary drift → `domain-model`.

## Examples

**Prompt:** "Audit this entire codebase for data-structure simplifications. Read-only."

**Good:** Inventory subsystems, run bounded workers, verify each finding, rank leftovers, leave the repo untouched.

**Prompt:** "We just shipped the model cleanup. Re-run the coverage-contract audit."

**Good:** Fresh inventory on current HEAD. Do not assume prior findings still exist. Reject anything the last pass already landed.

**Prompt:** "Take a pass over my working tree and delete the extra cache layer."

**Bad for this skill:** that is `complexity-guard` (apply fixes) or `review` (report on a diff).

## Credits

Coverage-contract workflow adapted from Aaron Francis's [codebase audit prompt](https://gist.github.com/aarondfrancis/8735edbe48532f97ee5ea818db4dbd47).
