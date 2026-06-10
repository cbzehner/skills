# Recipe: Recover From Mistake

## Recovery via backup branches
1. List backup branches:
   ```bash
   git branch --list 'ai-backup/*'
   ```
2. Find the right recovery point:
   ```bash
   git log --oneline ai-backup/<branch>-<timestamp>
   ```
3. Reset to it:
   ```bash
   git reset --hard ai-backup/<branch>-<timestamp>
   ```

## Recovery via reflog (no backup branch)
1. See recent HEAD history:
   ```bash
   git reflog --date=relative
   ```
2. Find the state before the bad operation.
3. Reset to it:
   ```bash
   git reset --hard HEAD@{N}
   ```

## Pruning old backups
- List all backup branches with their dates:
  ```bash
  git branch --list 'ai-backup/*' --format='%(refname:short) %(creatordate:relative)'
  ```
- Delete old backups when no longer needed:
  ```bash
  git branch -D ai-backup/<branch>-<timestamp>
  ```

## Committed to the wrong branch

### Move last N commits to a new branch
```bash
# Create the new branch at current HEAD (keeps the commits)
git branch correct-branch

# Reset the current branch back, removing the commits from it
git reset --hard HEAD~N

# Switch to the correct branch
git checkout correct-branch
```

### Move last N commits to an existing branch
```bash
# Note the SHAs of the commits to move
git log --oneline -N

# Reset the current branch
git reset --hard HEAD~N

# Switch and cherry-pick
git checkout existing-branch
git cherry-pick <sha1> <sha2> ...
```

**Key:** Use `--soft` reset if you want to keep changes staged (useful if you want to re-commit differently). Use `--hard` if the commits are complete and you're moving them as-is.

## Failure modes
| Failure | Fix |
|---------|-----|
| Reflog entry expired (default 90 days) | Recover from backup branches instead; keep backups until confident |
| Backup branch already deleted | Fall back to reflog recovery |
| Reset to wrong point | Re-check with `git log --oneline` before resetting; reflog still has the bad reset |
