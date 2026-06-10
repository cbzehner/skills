# Tool Override: Graphite

## Overrides for stack-prs.md

Detection: `command -v gt 2>/dev/null`. Install: `npm i -g @withgraphite/graphite-cli && gt auth`.

Replace manual branch creation and PR management:

| Native step | Graphite equivalent |
|-------------|-------------------|
| Create branch based on previous | `gt stack create` |
| Push all branches + create PRs | `gt stack submit` |
| Rebase stack after changes | `gt stack restack` |
| Visualize the stack | `gt log` |
| Land PRs in order | `gt stack land` |

### Creating a stack
```bash
gt stack create  # creates new branch in current stack
# make changes, commit
gt stack create  # another branch
# make changes, commit
gt stack submit  # pushes all, creates/updates PRs
```

### After review feedback

Same checkpoint rules as stack-prs.md (audit state, confirm, backup, verify). Use Graphite commands:

1. Audit: `gt log` (shows stack with PR/CI status)
2. Restack: `gt stack restack`
3. Verify: `git range-diff`

### Submitting

Before `gt stack submit`, check divergence per stack-prs.md checkpoint rules. For `--force` submits, confirm each diverged branch. Verify PR diffs after: `gh pr diff <number>`.

### Landing

Before `gt stack land`, verify CI on all PRs (`gt log`). Confirm merge order is bottom-up. Graphite handles ordering but verify.

## Failure Recovery

### Mid-restack conflict

When `gt stack restack` hits a conflict:

1. Graphite pauses and shows the conflicted files
2. Resolve the conflict in the affected files
3. Stage resolved files: `git add <files>`
4. Continue: `git rebase --continue` (Graphite's restack uses rebase internally)
5. After completion, verify with `gt log` and `git range-diff`

If the conflict is too complex:
```bash
git rebase --abort
# Restore from backup branches (per SKILL.md policy 3)
```

### Accidentally force-pushed wrong branch

If `gt stack submit --force` pushed stale content to a branch:

1. **Check reflog for the pre-push state**:
   ```bash
   git reflog show origin/<branch>
   ```
2. **Reset remote to the correct state**:
   ```bash
   git push --force-with-lease origin <correct-SHA>:<branch>
   ```
3. Verify the PR diff: `gh pr diff <number>`
4. Re-run `gt stack submit` to ensure Graphite's metadata is consistent

### Stack out of order after partial merge

If a PR was merged out of order (e.g., via GitHub UI instead of `gt stack land`):

1. Sync Graphite's view of the world:
   ```bash
   gt repo sync
   ```
2. Check which branches are orphaned: `gt log`
3. Restack the remaining branches:
   ```bash
   gt stack restack
   ```
4. Resolve any conflicts, then re-submit:
   ```bash
   gt stack submit
   ```
5. Verify each PR diff is clean: `gh pr diff <number>`

Graphite is GitHub-only. Skip if user prefers native git or has a single PR.
