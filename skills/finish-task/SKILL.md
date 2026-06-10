---
name: finish-task
description: >-
  Finish coding work end-to-end after implementation is believed complete:
  validate evidence, capture provenance, run local autoreview or equivalent
  review gates, use `counsel --panel` and complexity-guard, check
  architecture/philosophy alignment, capture or attach screenshots for UI work,
  then deliver through a PR, guarded default-branch commit, or worktree merge
  based on repository metadata. Use when the user says finish, wrap up, ship it,
  make a PR, create/update the PR, merge this worktree into the default branch,
  commit directly to the default branch, or asks for a task completion flow.
argument-hint: "[--work-pr|--personal-main] [--skip-screenshots] [--upload] [--yes]"
arguments:
  - options
license: MIT
effort: high
allowed-tools: Bash Read Glob Grep
---

# Finish Task

Finish the current coding task with evidence, review, and the delivery path that matches the repo.

This is a finalization workflow, not an implementation loop. If the task is not actually done, stop and report the remaining work instead of packaging an incomplete change.

`validate` owns proof that the artifact works. This skill consumes that evidence, adds review gates, and performs repo-appropriate delivery.

## Generic Routing

Choose delivery mode from explicit user wording first, then repository metadata, then local project instructions. Do not hard-code organization, project, or parent-directory names.

Treat any `~/Developer/<group>/<repo>` path as just a workspace location. The `<group>` segment can appear in reports, but it must not decide whether a repo is "work" or "personal."

Detection order:

1. User override: `--work-pr`, `--personal-main`, "make a PR", "commit to the default branch", "merge this worktree."
2. Repo-local policy: `AGENTS.md`, `CLAUDE.md`, `.cursorrules`, `.github/`, branch protection, or explicit contribution docs.
3. GitHub metadata: authenticated login, `origin` owner, fork status, parent repo, default branch, viewer permission.
4. Git metadata: remotes, `upstream`, current branch, upstream tracking branch, worktree state.
5. Conservative fallback: PR mode for repos with remotes; local commit mode for repos with no remote.

| Signal | Mode |
|---|---|
| User asks for PR, repo has `upstream`, repo is a fork, default branch is protected, origin owner is not the authenticated user, or policy docs say PR/review | PR |
| User asks for default-branch delivery and repo has no remote, or origin owner is the authenticated user with no upstream/fork signal | Guarded Default Branch |
| Non-GitHub remote or unknown owner | PR/branch delivery unless user explicitly requests local default-branch delivery |
| Ambiguous repo with destructive delivery risk | Ask one concise question before pushing or merging |

Never merge a repository you do not own to its default branch. Create or update a PR and leave merge to normal review/CI.

Guarded Default Branch mode is allowed only when the remote owner is the authenticated user, the repo has no remote, or the user explicitly confirms `--personal-main` after seeing the detected owner/remotes. Pushing the default branch always needs explicit confirmation.

## Workflow

Follow the workflow in order. Load the companion recipes only when you reach that section.

### 1. Preflight

Gather enough state to understand what is being finished:

```bash
pwd
git rev-parse --show-toplevel
git status --short --branch
git branch --show-current
git remote -v
git worktree list --porcelain
git log --oneline --decorate -10
git diff --stat
git diff --cached --stat
```

When GitHub delivery is possible, check repository ownership and auth. If `gh` is unavailable, continue with Git metadata and choose the conservative mode:

```bash
gh auth status
gh repo view --json owner,isFork,parent,viewerPermission 2>/dev/null
git remote get-url origin 2>/dev/null
git remote get-url upstream 2>/dev/null
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null || true
```

If this is a branch with an upstream, also inspect:

```bash
git fetch --all --prune
git log --oneline --decorate --left-right --cherry-pick @{upstream}...HEAD
```

Find an existing PR if possible:

```bash
gh pr view --json number,title,url,baseRefName,headRefName,isDraft,state,statusCheckRollup 2>/dev/null
```

Stop early if:

- There are merge conflicts.
- The working tree contains unrelated changes that cannot be separated.
- Required credentials are missing for the requested delivery path.
- The diff is empty and there are no unpushed commits.

When unrelated user changes exist, preserve them. Do not revert or restage them casually.

### 2. Define The Finish Scope

Write a short internal scope note:

- What changed?
- What user goal does it satisfy?
- Which files and runtime surfaces are affected?
- Which parts are intentionally out of scope?
- What would make this unsafe to deliver?

Use this scope note to decide tests, screenshots, and PR body contents.

### 3. Validate

Use the `validate` skill to prove the scoped artifact works before review or delivery. Pass it the finish scope, changed surfaces, plan/issue/PR acceptance criteria, and any user-requested proof.

Validation must cover the smallest credible set for the touched surfaces:

- Existing targeted tests for changed modules.
- Typecheck/lint/build when the language or repo expects it.
- Migrations/generation checks when schema, generated code, or lockfiles changed.
- Browser verification and screenshots for UI-facing changes.
- Acceptance criteria from plans, issues, PRDs, or user instructions.

If `validate` reports `fail` or `blocked`, do not proceed to delivery. Fix in-scope failures, route unexplained failures to `diagnose`, or stop with the validation report.

Do not proceed past failed required validation unless the user explicitly acknowledges the blocker. `--yes` does not override failed validation.

### 4. Evidence And Provenance

Create or update a concise finish evidence note before review so later sessions can reconstruct what happened. Prefer `.agent/evidence/<run-slug>/summary.md` when validation already created a bundle; otherwise keep the note in your working summary and include it in the final report.

Capture:

- User goal and finish scope.
- Branch name, commit range, and delivery mode.
- Validation commands and artifact paths.
- Review commands or reviewer sessions.
- Local screenshots or visual evidence paths when applicable.
- Agent/session provenance when discoverable: Codex/Claude/session ID, current conversation/session URL, task/run ID, and the supervising agent name.

If a session ID is not available from local logs, environment, or the running tool, write `session: unavailable` rather than guessing. Never include secrets, cookies, auth headers, raw prompts containing credentials, or private browser state in evidence files, commits, or PR bodies.

### 5. Review Gates

Load [recipes/review-gates.md](recipes/review-gates.md) and complete every applicable gate. The recipe owns the detailed review checklist; do not duplicate it in the final report.

- Thorough code review.
- Complexity guard pass.
- Architecture pass.
- Philosophy/alignment pass.
- Magi review.
- Final self-review after any fixes.

Do not proceed to delivery with unresolved high-severity findings. Fix them or stop.

### 6. Visual Evidence

For UI, visual, workflow, browser, docs-rendering, email-template, report, or screenshot-requested changes, load [recipes/visual-evidence.md](recipes/visual-evidence.md). Keep project-specific screenshot helpers as optional examples, not required behavior.

Screenshots are mandatory for UI-facing work unless the app cannot run. If `validate` already captured them, inspect and reuse those artifacts. If blocked, include the exact blocker, the attempted command, and the partial evidence collected.

Do not upload screenshots externally unless the user passes `--upload` or approves it during this workflow after seeing the privacy note in [recipes/visual-evidence.md](recipes/visual-evidence.md). Local evidence lives under `.agent/evidence/<run-slug>/`; screenshots and other bulky files live under its `artifacts/` directory.

### 7. Commit Hygiene

Inspect the final diff:

```bash
git diff --stat
git diff
git diff --cached --stat
git diff --cached
```

Stage only intended files. Exclude local evidence bundles, auth state, logs, temporary screenshots, and unrelated user edits. If `.agent/evidence/` is not ignored, warn the user; change `.gitignore` only when they want that cleanup included.

Create commits with messages that explain why the change exists, not only what changed. If the branch already contains WIP commits, clean them before opening a PR when doing so is safe and not shared. History cleanup follows the same gate as Delivery: backup branch first, and explicit user confirmation before any force-push of a shared or already-pushed branch.

### 8. Delivery

Load [recipes/delivery.md](recipes/delivery.md) and execute the selected mode:

- **PR:** push branch, create or update draft/non-draft PR, include review/test/screenshot evidence, never merge.
- **Guarded Default Branch:** commit on default branch or merge the task worktree into it, run post-merge verification, ask before pushing.

Create a backup branch before rebasing, force-pushing, or merging across worktrees.

### 9. Finish Report

Final response shape:

```markdown
Finished <delivery target>.

Review:
- <findings fixed or "No unresolved high-severity findings">
- Multi-model review: <summary/path or unavailable reason>
- Complexity/architecture/philosophy: <summary>

Verification:
- `<command>`: pass/fail
- Screenshots: <local path or PR links>
- Evidence: <summary path or "inline only">
- Provenance: <session/task id or unavailable>

Delivery:
- PR: <url> / Commit: <sha> / Default branch updated: <sha>
- Remaining risks: <only real residual risks>
```

Keep it short. Include blockers plainly when delivery could not complete.

## Options

- `--work-pr`: Force PR delivery.
- `--personal-main`: Request guarded default-branch delivery after repo metadata is shown.
- `--skip-screenshots`: Skip screenshots only when the user explicitly requests it or the change has no visual surface.
- `--upload`: Request GitHub screenshot upload. Private/work repos still require public-URL acknowledgement.
- `--yes`: Continue through non-destructive delivery steps. Still stop for default-branch pushes, force-pushes, cross-worktree merge conflicts, destructive cleanup, failed validation, or external screenshot upload without privacy acknowledgement.

## Companion Recipes

- [Review gates](recipes/review-gates.md)
- [Visual evidence](recipes/visual-evidence.md)
- [Delivery](recipes/delivery.md)
