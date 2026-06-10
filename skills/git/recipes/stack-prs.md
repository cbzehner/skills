# Recipe: Stack PRs

## Steps (native git, requires Git 2.38+)

### Creating a stack from scratch
1. Identify logical concerns in the work
2. Create branch for first concern off main:
   ```bash
   git checkout -b feat/db-schema main
   # cherry-pick or rebase relevant commits
   ```
3. Create branch for next concern off previous branch:
   ```bash
   git checkout -b feat/api feat/db-schema
   # cherry-pick or rebase the next set
   ```
4. Repeat for each concern
5. Push each branch, create separate PRs noting dependencies in descriptions

### Splitting an existing branch
1. Create backup branch (per SKILL.md policy 3)
2. `git rebase -i main` -- reorder commits by concern
3. Note SHA boundaries between concerns
4. Create branches at split points:
   ```bash
   git branch feat/first-concern <SHA-at-boundary>
   git branch feat/second-concern <SHA-at-next-boundary>
   ```
5. Push each as separate PR

### Keeping the stack in sync

**CHECKPOINT: Pre-rebase stack audit (mandatory)**

Before running `git rebase --update-refs`, gather and display the full stack state:

```bash
# 1. Visualize the stack: branch -> PR -> CI status
for branch in $(git branch --list 'feat/*' --format='%(refname:short)'); do
  pr_info=$(gh pr view "$branch" --json number,title,statusCheckRollup,state \
    --jq '"PR #\(.number) [\(.state)] \(.title) — checks: \(.statusCheckRollup | map(.conclusion // .status) | join(", "))"' 2>/dev/null || echo "no PR")
  echo "  $branch → $pr_info"
done

# 2. List branches that will be force-pushed after rebase
git branch --list 'feat/*' --format='%(refname:short)' | while read b; do
  if git ls-remote --heads origin "$b" | grep -q .; then
    echo "  WILL FORCE-PUSH: $b"
  fi
done
```

Display this to the user. Then:
- List every branch that will be force-pushed
- If any branch has reviews, comments, or commits from other authors (per SKILL.md policy 2), warn explicitly
- **Require explicit user confirmation before proceeding**

Only after confirmation:
1. Create backup branch for each branch in the stack (per SKILL.md policy 3)
2. Run the rebase:
   ```bash
   git rebase --update-refs main
   ```
3. Verify with `git range-diff` (per SKILL.md policy 4)

### After review changes
Rebase the stack again with `--update-refs` to propagate changes through all dependent branches. The same pre-rebase checkpoint applies.

### Syncing to remote (force-push)

**CHECKPOINT: Pre-sync divergence check (mandatory)**

Before pushing the rebased stack, check each branch for divergence:

```bash
for branch in $(git branch --list 'feat/*' --format='%(refname:short)'); do
  if git ls-remote --heads origin "$branch" | grep -q .; then
    local_sha=$(git rev-parse "$branch")
    remote_sha=$(git rev-parse "origin/$branch" 2>/dev/null)
    if [ "$local_sha" != "$remote_sha" ]; then
      ahead=$(git rev-list --count "origin/$branch..$branch")
      behind=$(git rev-list --count "$branch..origin/$branch")
      echo "  DIVERGED: $branch (local +$ahead, remote +$behind)"
    else
      echo "  UP-TO-DATE: $branch"
    fi
  else
    echo "  NEW (not on remote): $branch"
  fi
done
```

Display divergence summary. For each diverged branch:
- Show commit diff: `git log --oneline origin/<branch>..<branch>`
- **Confirm each force-push individually**
- Always use `git push --force-with-lease --force-if-includes` (per SKILL.md policy 1)

### Landing order

**CHECKPOINT: Pre-land verification (mandatory)**

Before merging any PR in the stack:

```bash
# Verify CI status on ALL PRs
for branch in $(git branch --list 'feat/*' --format='%(refname:short)'); do
  gh pr view "$branch" --json number,statusCheckRollup,mergeable \
    --jq '"PR \(.number): mergeable=\(.mergeable) checks=\([ .statusCheckRollup[] | .conclusion // .status ] | join(", "))"' 2>/dev/null
done
```

- If any PR has failing checks, **warn and list failures** -- do not proceed without explicit acknowledgment
- Confirm merge order is bottom-up (base branch first): display the planned order
- **Require explicit user confirmation of the merge order**

Land bottom-up (base branch first). After each merge, rebase remaining branches onto the updated main.

## With Graphite (see tools/graphite.md)
Replace manual branching with `gt` commands: `gt stack create`, `gt stack submit`, `gt stack restack`, `gt stack land`.

## Failure Recovery

### Mid-rebase conflict in a stack

When a conflict occurs during `git rebase --update-refs`:

1. **Identify which branch has the conflict**: `git status` shows the current branch being rebased
2. Resolve the conflict in the affected files
3. Stage resolved files: `git add <files>`
4. Continue: `git rebase --continue`
5. The rebase will proceed through remaining branches in the stack
6. After completion, verify all branches with `git range-diff`

If the conflict is too complex to resolve mid-rebase:
```bash
git rebase --abort
# The entire stack returns to pre-rebase state
# Backup branches are still available (per SKILL.md policy 3)
```

### Accidentally force-pushed wrong branch

1. **Check reflog for the pre-push state**:
   ```bash
   git reflog show origin/<branch>
   ```
2. **Reset remote to the correct state**:
   ```bash
   git push --force-with-lease origin <correct-SHA>:<branch>
   ```
3. If the branch had an open PR, verify the PR diff is correct: `gh pr diff <number>`
4. Notify collaborators if the branch had other contributors

### Stack out of order after partial merge

If a dependent PR was merged before its base (wrong order):

1. **Identify the orphaned branches**: branches whose base was not yet merged
2. Rebase each orphaned branch onto the updated main:
   ```bash
   git fetch origin
   git checkout feat/orphaned-branch
   git rebase origin/main
   ```
3. Resolve any conflicts (expected -- the base PR's changes are now in main via a different path)
4. Force-push the rebased branch: `git push --force-with-lease --force-if-includes`
5. Verify the PR diff is clean: `gh pr diff <number>`

## Failure modes
| Failure | Fix |
|---------|-----|
| Conflict during restack (overlapping changes) | Resolve conflicts, `git rebase --continue`, then re-run `--update-refs` |
| Orphaned branches (base merged, dependents not rebased) | Rebase orphaned branches onto updated main |
| Wrong merge order | Rebase the dependent onto main, resolve conflicts, re-push |

## Cleanup
Remove merged branches: `git branch -d feat/db-schema feat/api`. Prune stale remote references: `git fetch --prune`.
