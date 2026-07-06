---
name: git
description: Advanced git workflows — absorb, stacking, bisect, worktrees, conflict resolution, commit cleanup. Use when user mentions stacking PRs, split PR, fixup, absorb, bisect, regression, worktree, rebase conflict, messy commits, clean up history, or when commit history needs cleanup before a PR. Also triggers on merge conflicts and bad rebase recovery. History and workflow surgery only — the PR/delivery flow itself belongs to finish-task.
argument-hint: "[workflow or situation description]"
arguments:
  - workflow
license: MIT
effort: medium
allowed-tools: Bash Read Glob Grep
---

# Git

## When to Use

- User mentions stacking, splitting a PR, or breaking up a large PR
- User addressed PR review feedback and needs to distribute fixes into prior commits
- User says "when did this break", "this used to work", or is debugging a regression
- About to create a PR with messy/WIP commits that need cleanup
- User needs to work on something else without losing context (worktree)
- Merge conflict encountered during rebase or merge
- User says they messed up a rebase or lost changes

## When NOT to Use

- Basic git operations (commit, push, pull, branch, checkout, simple merge) — host agent handles these
- User is writing new code, not restructuring history
- User explicitly declines history rewriting

## Trigger Table

| Trigger | Signals | Recipe |
|---------|---------|--------|
| **Post-review fixup** | Changes exist + open PR with review comments | `fixup-history.md` |
| **Messy history before PR** | About to create PR + commits contain "wip", "fix", "tmp", "squash me", "address review", duplicated prefixes, or 5+ groupable commits | `clean-commits.md` + `fixup-history.md` |
| **Regression debugging** | "when did this break", "this used to work", test was passing before | `bisect-regression.md` |
| **Large PR / split** | User asks to split/stack, OR PR touches 5+ files across multiple concerns | `stack-prs.md` |
| **Parallel work needed** | User needs to switch context without losing current work | `parallel-worktrees.md` |
| **Merge conflict** | `git status` shows unmerged paths or conflict markers | `resolve-conflicts.md` |
| **Bad rewrite recovery** | "I messed up", "lost my changes", "committed to wrong branch", unexpected range-diff | `recover-from-mistake.md` |

### Escalation

- **Conflicts and recovery:** Auto-activate and begin guiding (reactive situations).
- **Everything else:** Suggest & confirm. Never act unilaterally on history rewrites.

## Tool Detection

On first activation, check for enhanced tools: `git-absorb`, `gt` (Graphite), `wt` (worktrunk), and `git --version` (need 2.38+ for `--update-refs`). Cache results for the session.

If an enhanced tool is detected, load its override file alongside the recipe:
- `tools/absorb.md` → `recipes/fixup-history.md`
- `tools/graphite.md` → `recipes/stack-prs.md`
- `tools/worktrunk.md` → `recipes/parallel-worktrees.md`

All workflows work with native git. Never block on a missing tool. Recommend `git-absorb` as the biggest QoL win if not installed.

## One-Time Repo Config Check

On first activation, check and suggest missing settings:

```bash
git config --get merge.conflictStyle    # want: zdiff3
git config --get rerere.enabled         # want: true
git config --get rerere.autoUpdate      # want: true
git config --get rebase.autosquash      # want: true
git config --get rebase.autoStash       # want: true
git config --get pull.rebase            # want: true
```

Suggest a single command block to fix all missing. Offer once, respect the answer.

If `commit.gpgsign=true` is set, verify the signing key works. Never suggest enabling signing if not already configured.

Note `core.hooksPath` if set (custom hooks are outside skill control). Verify `credential.helper` is configured if pushing to remotes.

## Core Policies

Non-negotiable safety rules, always active.

<!-- WHY: Model default is --force; this prevents overwriting others' work -->
### 1. Force-Push Safety
NEVER `git push --force`. Always `git push --force-with-lease --force-if-includes`.

### 2. Force-Push Authorization
Before any force-push, check for shared work:
```bash
git ls-remote --heads origin <branch>
gh pr view <branch> --json reviews,comments
git log --format='%ae' origin/main..<branch> | sort -u
```
If any indicate shared work, warn and require explicit confirmation.

<!-- WHY: Core safety net — recipes reference this as "per policy 3" -->
### 3. Pre-Destructive Backup
Before any rebase, reset, or history rewrite:
```bash
git branch "ai-backup/$(git branch --show-current)-$(date +%Y%m%d-%H%M%S)"
```
Tell the user. Prune old backups with `git branch --list 'ai-backup/*' | xargs git branch -D`.

### 4. Verify After Rewrite
Run `git range-diff` against pre-rewrite state after every rebase or history surgery. Flag unexpected changes before proceeding.

### 5. Independent Commits Commute
Independent commits (different files/lines) commute freely. Dependent commits (overlapping lines) must maintain order.

### 6. Commit Messages
Include *why* the change was made in the commit body — the agent has this context and should preserve it.

## Dynamic Context

On activation, gather: current branch, recent commits (`git log --oneline -10`), working tree state (`git status --short`), and unpushed commits (`git log --oneline origin/main..HEAD`).

## Examples

<!-- WHY: Subtle routing — "push?" after review should trigger fixup, not literal push -->
**"I just addressed the review comments, want me to push?"** → Trigger post-review fixup. Check if changes should be absorbed into prior commits rather than added as a new "address review" commit.

**"I messed up the rebase and my commits are gone"** → Auto-activate recovery. Check for backup branches first, then reflog.
