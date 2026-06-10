# Delivery

Deliver through PRs or guarded default-branch updates based on repository metadata.

## Shared Safety

Before any rebase, force-push, or cross-worktree merge:

```bash
git branch "ai-backup/$(git branch --show-current)-$(date +%Y%m%d-%H%M%S)"
```

Use `git push --force-with-lease --force-if-includes`, never plain `--force`.

Do not push or merge if high-severity review findings remain unresolved.

Do not push the default branch automatically. Ever. Print the exact command and wait for explicit user confirmation.

## PR Mode

Use when the user asks for a PR, the repo is a fork, the repo has an upstream, the origin owner is not the authenticated user, branch protection is detected, or repo docs require review.

1. Confirm branch and base:

```bash
git branch --show-current
gh pr view --json number,title,url,baseRefName,headRefName,isDraft,state 2>/dev/null
```

Abort if the current branch is the repository default branch. Create a feature branch first:

```bash
DEFAULT_BRANCH="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's#^refs/remotes/origin/##' || true)"
test -n "$DEFAULT_BRANCH"
test "$(git branch --show-current)" != "$DEFAULT_BRANCH"
```

2. Preview commits that will be pushed:

```bash
DEFAULT_REF="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's#^refs/remotes/##' || true)"
test -n "$DEFAULT_REF"
git log --oneline --decorate @{upstream}..HEAD 2>/dev/null || git log --oneline --decorate "${DEFAULT_REF}..HEAD"
```

3. Push the branch when the user asked to create/update a PR or passed `--yes`:

```bash
git push -u origin HEAD
```

If history was rewritten, first check whether the branch is shared. Skip history rewrite if the branch has an upstream unless the user opts in. When force-pushing is explicitly approved, use:

```bash
git push --force-with-lease --force-if-includes
```

4. Create or update the PR.

PR body structure:

```markdown
## Summary

- <what changed>
- <why>

## Review

- Code review: <summary>
- Complexity: <summary>
- Architecture/philosophy: <summary>
- Magi: <summary/path>

## Screenshots

<links or "Not visual">

## Test plan

- [x] `<command>`
- [ ] <manual reviewer step, only if real>

## Risks / Notes

- <residual risk or "None known">
```

5. If CI is available, fetch status:

```bash
gh pr checks
```

Do not merge. Report PR URL and any pending checks.

## Guarded Default Branch Mode

Use when the repo has no remote, the origin owner is the authenticated user with no fork/upstream signal, or the user explicitly requests default-branch delivery after seeing repo metadata.

Detect the default branch from the remote. If there is no remote/default-branch metadata and the current branch is not obviously the intended delivery branch, ask before merging:

```bash
DEFAULT_BRANCH="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's#^refs/remotes/origin/##' || true)"
if [ -z "$DEFAULT_BRANCH" ]; then
  printf 'No remote default branch detected; ask the user which local branch is the delivery branch.\n' >&2
  exit 1
fi
```

### Already On Default Branch

1. Verify branch:

```bash
git branch --show-current
```

2. Stage intended files and commit.
3. Run post-commit verification if not already run on the committed state.
4. Do not push the default branch automatically. Print `git push origin "$DEFAULT_BRANCH"` as the next command and wait for explicit user confirmation.

### Feature Branch In Same Worktree

Use this when the current branch is not the default branch and no separate default-branch worktree is needed:

```bash
git fetch origin
git checkout "$DEFAULT_BRANCH"
git pull --ff-only origin "$DEFAULT_BRANCH"
git merge --ff-only <feature-branch>
```

If fast-forward fails, stop and show the divergence. Ask whether to rebase the feature branch or create a merge commit. If a merge attempt conflicts, immediately run `git merge --abort` and stop.

Run verification on the default branch after the merge.

### Separate Worktree Into Default Branch

Use this when the task was done in a separate git worktree.

1. Commit all intended changes in the task worktree.
2. Find the default-branch worktree:

```bash
git worktree list --porcelain
```

3. In the default-branch worktree:

```bash
git status --short
git checkout "$DEFAULT_BRANCH"
git pull --ff-only origin "$DEFAULT_BRANCH"
git merge --ff-only <task-branch>
```

4. Run post-merge verification from the default-branch worktree.
5. Do not push the default branch automatically. Print `git push origin "$DEFAULT_BRANCH"` and wait for explicit confirmation.
6. Remove the task worktree only when the user asked or after confirming no extra files remain:

```bash
git worktree remove <path>
```

Never remove a worktree with uncommitted changes.

## Final Delivery Checks

After delivery:

```bash
git status --short --branch
git log --oneline --decorate -5
```

For PRs:

```bash
gh pr view --json number,title,url,state,isDraft,statusCheckRollup
```

For guarded default-branch delivery, report the final commit SHA:

```bash
git rev-parse --short HEAD
```
