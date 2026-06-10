# Tool Override: worktrunk

Detection: `command -v wt 2>/dev/null`. Install: `cargo install worktrunk`.

## Overrides for parallel-worktrees.md

Replace manual worktree commands:

| Native step | worktrunk equivalent |
|-------------|---------------------|
| `git worktree add ... -b branch` | `wt switch --create branch` |
| `git worktree list` | `wt list` (richer output: branch status, commits, changes) |
| Manual cleanup | Merge workflow handles cleanup |

### Create and switch
```bash
wt switch --create feature-auth
```
Creates branch + worktree in one step. Automatically handles directory placement.

### List worktrees
```bash
wt list
```
Shows branch status, number of commits, and uncommitted changes per worktree.

### Hooks
worktrunk supports hooks for automating setup per worktree:
- Post-create: install deps, copy .env files
- Pre-merge: run tests
- Post-merge: clean up

### Merge back
worktrunk provides a one-command merge workflow: squash, rebase, or merge + clean up the worktree.

## When NOT to use
- Single quick worktree (raw git is fine)
- User doesn't have Rust/cargo for installation
