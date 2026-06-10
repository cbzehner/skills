# Recipe: Fixup History

## Steps (native git)
1. Stage relevant changes: `git add -p`
2. Identify target commit: `git log --oneline` to find SHA
3. Create fixup: `git commit --fixup=<target-SHA>`
4. Repeat for each group targeting different commits
5. Create backup branch (per SKILL.md policy 3)
6. Squash fixups: `git rebase -i --autosquash HEAD~N`
7. Verify: `git range-diff` (per SKILL.md policy 4)

## With git-absorb (see tools/absorb.md)
Replace steps 1-4 with: `git absorb --and-rebase`

Critical: absorb fails silently on ambiguous hunks. Check output. Handle unabsorbed hunks manually.

## Failure modes
| Failure | Fix |
|---------|-----|
| Rebase conflict (fixup touches lines modified by later commits) | Resolve conflict, continue rebase |
| Absorb skips hunks (ambiguous target) | Use manual --fixup for those hunks |
| Wrong commit targeted | Reset to backup, retry with correct SHA |
