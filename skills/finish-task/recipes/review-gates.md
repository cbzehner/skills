# Review Gates

Use these gates before delivery. Fix in-scope issues immediately, then rerun the affected verification.

## Code Review

Review the complete diff as if reviewing someone else's PR. Lead with bugs and behavioral risks, not style.

Check:

- Correctness: wrong branches, stale assumptions, off-by-one errors, async races, missing cleanup, migration order.
- Data integrity: idempotency, uniqueness, transactions, backfills, partial writes, rollback behavior.
- Security/privacy: authz checks, secrets in logs/artifacts, path traversal, SSRF, injection, token leakage.
- API/contracts: backwards compatibility, schema drift, generated code, client/server mismatch.
- Tests: missing regression coverage for changed behavior, brittle assertions, tests that only pin implementation.
- Operations: slow queries, full-table scans, noisy jobs, non-deterministic local or CI behavior.

Use file/line references for findings when practical. Do not bury a real bug in a summary.

## Local Autoreview

Run the repo's local autoreview path when one exists. This can be an `autoreview` skill, a project script, a documented `make review` target, or a local reviewer command named in repo docs. Prefer the local path because it usually knows project conventions and catches edge cases before PR/CI.

Discovery commands:

```bash
find . -maxdepth 3 \( -iname '*autoreview*' -o -iname '*auto-review*' -o -iname '*review*' \) -print
rg -n "autoreview|auto review|make review|review gate|reviewer" AGENTS.md CLAUDE.md README.md docs .github 2>/dev/null
```

If no local autoreview path exists, record `Autoreview: unavailable; used manual review gates instead.` Do not install a new tool during finish-task unless the user explicitly asked for that setup.

If autoreview produces findings:

- Fix valid in-scope high-severity findings before delivery.
- Record false positives with a short reason.
- Save the command and output path in the finish evidence note.

## Complexity Guard

Apply the complexity-guard skill:

- Prefer local patterns over invented frameworks.
- Remove speculative hooks, generic registries, and "future mode" branches with no current caller.
- Keep earned complexity when it protects a real invariant.
- Separate behavior-preserving simplifications from risky design changes.

Output one of:

- `Complexity: no blocking issues.`
- `Complexity: fixed <summary>.`
- `Complexity: blocking finding <file:line>.`

## Architecture Pass

Read nearby architecture sources before judging:

```bash
ROOT="$(git rev-parse --show-toplevel)"
find "$ROOT" -maxdepth 3 \( -name 'AGENTS.md' -o -name 'PHILOSOPHY.md' -o -name 'THEORY.md' -o -name 'ARCHITECTURE.md' -o -name 'README.md' \) -print
```

Then check:

- Does this preserve existing module boundaries?
- Is the dependency direction consistent with nearby code?
- Are new abstractions owned by a current caller?
- Does the change create a migration path that leaves dead scaffolding behind?
- Does the data model or API shape match the canonical owner?
- Will the code be easier to delete after the migration/flag is done?

If the repo has no explicit philosophy file, use the local default:

- Local-first evidence over SaaS dashboards when feasible.
- Show your work with commands, screenshots, and links.
- Boring, reversible changes before meta-orchestration.
- Small reviewable commits; avoid task-ending hero diffs.
- Agent workflows are working software and should be updated when the process breaks twice.

## Philosophy Alignment

Write a short alignment note:

```text
Alignment: <one or two sentences>
Tradeoff accepted: <only if real>
```

This note should be specific to the repo, not a generic compliment.

## Multi-Model Review

Use `counsel --panel` for non-trivial changes, architecture changes, risky bug fixes, security-sensitive work, UI migrations, and any task where the user requested multi-model review. `magi` is accepted as an alias for the same workflow. Build a prompt with:

- User goal.
- Delivery mode.
- Diff stat.
- Important snippets or file paths.
- Verification commands and results.
- Known blockers or uncertainties.
- Specific request: find correctness, architecture, complexity, security, and missing-test risks.

Ask advisors to return severity-ranked findings and whether anything blocks delivery.

If external advisors are unavailable because CLIs/auth are missing, report that as a review gap. Do not invent a multi-advisor result. For tiny documentation-only changes, a local-only review is acceptable if you say why.

After the panel returns:

- Fix any valid blocking findings.
- Record false positives and why they are false.
- Save or cite the session path if the review skill produced one.

## Final Self-Review

After fixes and before delivery:

```bash
git diff --check
git status --short
```

Re-read the final staged diff. Confirm:

- No unrelated files staged.
- No secrets, local auth state, or screenshots committed accidentally.
- PR body or final report matches the actual final diff.
