---
name: review
description: >-
  Run focused role-based reviews. Use when the user asks for code review,
  architecture review, complexity/simplification review, security review,
  design or accessibility review, docs review, spec alignment review, release
  readiness, deep review of a PR or bug fix, or asks to review a branch/diff/plan
  with a specific lens.
argument-hint: "[--as complexity|architecture|security|design|accessibility|docs|spec|release|deep] [target]"
arguments:
  - request
license: MIT
effort: medium
allowed-tools: Bash Read Glob Grep Task
---

# Review

Pick one role first. Run multiple roles only when the user asks, or when finishing a task with broad blast radius.

Lead with findings. Cite files, lines, commands, specs, or screenshots where possible. Do not rewrite code unless the user asks for fixes after the review.

## Routing

| Role | Use for | Reference |
|---|---|---|
| `complexity` | overengineering, maintainability, simplify sweeps | the `complexity-guard` skill (`~/.claude/skills/complexity-guard/SKILL.md`) owns this rubric |
| `architecture` | boundaries, module shape, coupling, deep modules, alignment | inline role below |
| `security` | auth, secrets, permissions, injection, data exposure | inline role below |
| `design` | UI/UX critique and visual quality | the `design` skill's critique guidance (`~/.claude/skills/design/references/critique.md`) |
| `accessibility` | WCAG, keyboard, semantics, focus, contrast | the `design` skill's accessibility guidance (`~/.claude/skills/design/references/accessibility.md`) |
| `docs` | README, guides, API docs, release notes | inline role below |
| `spec` | diff vs PRD/issue/plan acceptance criteria | inline role below |
| `release` | readiness, migration, rollback, deploy risk | inline role below |
| `deep` | bug-fix or PR review where root cause, provenance, and fix quality must be defended | inline role below |

The `complexity`, `design`, and `accessibility` rubrics are owned by their home skills — read the file named above rather than duplicating it here. If that skill is not installed, run the lens inline from the role's one-line "Use for" scope.

## Handoffs

- If there is no concrete artifact to review, route to `plan`, `design`, or `counsel` based on what is missing.
- If a finding depends on reproducing an unexplained failure, route to `diagnose`.
- If a finding requires multi-step implementation work, route to `plan`.
- If a finding is really glossary, naming, or ADR drift, route to `domain-model update`.
- If a finding should prevent future mistakes, route to `repo-memory learning`.
- If reviewing UI before delivery, run both `--as design` and `--as accessibility`.

## Inline Roles

### Architecture

Check whether the change preserves the repo's dominant patterns, keeps boundaries clear, avoids shallow abstractions, and names concepts in the repo's language. Prefer specific smaller alternatives over broad redesigns.

### Security

Look for exposed secrets, unsafe shell construction, auth/authorization bypass, overbroad permissions, injection, SSRF/path traversal, private data leaks, and unsafe dependency or workflow changes. Distinguish confirmed issues from questions.

### Docs

Check whether docs match current behavior, include setup and verification details, avoid stale file paths when unnecessary, and make failure/recovery paths clear.

### Spec

Find the source spec or plan. Report missing requirements, scope creep, and behavior that appears implemented incorrectly. Quote or cite the spec for each finding.

### Release

Check local verification, migrations, config/env changes, rollback path, compatibility, observability, and user-facing risk. Do not approve release when required verification failed.

### Deep

Use this lens when reviewing a bug fix, regression, or PR where the cost of a wrong call is high. Demand evidence and name root cause; do not accept "looks fine" surface review.

Read the full call path before judging: entrypoint → routing → business logic → persistence/IO boundary. Read adjacent tests. Check upstream dependency docs rather than assuming behavior.

Trace provenance: when did the bug land, who introduced it, what change was the trigger. Use `git log`, `git blame`, and linked issues. Distinguish who *introduced* the code from who *made it visible*. Rate confidence as `clear | likely | unknown` — never higher than the evidence supports.

Use the structured output below for every finding. If any field cannot be answered from evidence, write `unknown` — do not paper over.

```markdown
Ref: <PR URL, branch, commit, or issue URL>
Surface: <affected modules, packages, public APIs, or user flows>
Bug: <one-sentence statement of the buggy or risky behavior>
Cause: <root cause in code with file:line; not just symptoms>
Provenance: <when introduced, by which change, confidence: clear|likely|unknown>
Best fix: <whether this fix is at the right ownership boundary; alternatives considered>
Refactor: <whether a small adjacent refactor would prevent recurrence; what and why>
Proof: <tests added, reproduction, CI status, screenshots, or "none — gap">
Risk: <remaining risk after this fix lands; what could still bite>
```

Quality bar:

- No invented facts. If you did not read it, say so.
- Name the fix's *ownership boundary* — pushing a fix to the wrong layer is a finding.
- Regression tests are the default proof. "Tested manually" is a gap, not proof.
- If the fix only treats a symptom, flag it.

## Output

```markdown
Findings
1. [severity] path:line - issue, impact, and smallest correction.

Open Questions
- ...

Checks Run
- `command`: result
```

## Credits

- The `deep` lens (call-path reading, provenance tracing, and the Ref / Surface / Bug / Cause / Provenance / Best-fix / Refactor / Proof / Risk template) is adapted from Peter Steinberger's [`github-deep-review`](https://github.com/steipete/agent-scripts/tree/main/skills/github-deep-review) skill.
