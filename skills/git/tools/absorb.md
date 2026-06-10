# Tool Override: git-absorb

Detection: `command -v git-absorb 2>/dev/null`. Install: `cargo install git-absorb`.

## Overrides for fixup-history.md

Replace the manual fixup workflow (steps 1-4) with:

```bash
git absorb --and-rebase
```

If `--and-rebase` flag is not supported in the installed version:
```bash
git absorb
git rebase -i --autosquash HEAD~N
```

**Critical: Always check output for unabsorbed hunks.** Absorb reports which hunks it could not place. Fall back to manual `git commit --fixup=<SHA>` for those.

Example output to watch for:
```
Could not absorb hunk into any commit
```

## When NOT to use
- Changes span too many commits (absorb gets confused)
- All changes belong to a single commit (just amend)
- Working tree has unrelated changes mixed in (stage selectively first with git add -p, then absorb)
