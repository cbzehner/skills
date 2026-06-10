# Recipe: Parallel Worktrees

## Steps (native git)
```bash
# Create a worktree for a new branch
git worktree add ../project-hotfix -b hotfix/urgent-fix

# List worktrees
git worktree list

# Do work in the new worktree
cd ../project-hotfix
# ... make changes, commit, push ...

# Return and clean up
cd ../project
git worktree remove ../project-hotfix
```

Prune stale refs: `git worktree prune`

## Port conflicts
Different ports per worktree when running dev servers. Set `PORT` environment variable per worktree.

## Worktrees vs stash
Always prefer worktrees. Stash is fragile (applies can conflict, easy to forget, no branch isolation). Worktrees give full isolation with zero risk.

## With worktrunk (see tools/worktrunk.md)
Replace manual commands with:
- `wt switch --create <branch>` instead of `git worktree add` + `git checkout -b`
- `wt list` instead of `git worktree list` (shows branch status, commits, changes)
- Hooks system for automating setup (install deps, copy .env, etc.)
- Merge workflow: squash, rebase, merge, and clean up in one command

## Failure modes
| Failure | Fix |
|---------|-----|
| Port conflicts (multiple dev servers) | Set `PORT` env var per worktree |
| Branch already checked out error | Remove or switch the other worktree first, or create a new branch |

Always remove worktrees when done. Prune stale references with `git worktree prune`.
