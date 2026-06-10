# Recipe: Clean Commits

## Commit style detection
1. Check for config: `.commitlintrc`, `.cz.json`, `commitizen` in `package.json`, `.conventional-commits`
2. If no config, sample recent history:
   ```bash
   git log --oneline --no-merges -50 --format='%s' | grep -v '^fixup!' | grep -v '\[bot\]'
   ```
3. Look for patterns: conventional prefixes (`feat:`, `fix:`), imperative mood, ticket prefixes (`JIRA-123`), emoji
4. Match detected style. No clear pattern -> fall back to Conventional Commits

## Conventional Commits format
```
<type>(<optional scope>): <description>

<optional body -- explain why, not what>

<optional footer -- Fixes #123, Co-authored-by:, BREAKING CHANGE:>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`, `build`

## 50/72 rule
Subject line under 50 chars. Body wrapped at 72 chars.

## Logical commit ordering
1. Mechanical/automated changes (formatting, imports, renames)
2. Infrastructure/schema changes (DB migrations, API contracts)
3. Implementation (the actual feature/fix)
4. Tests
5. Documentation

Each commit should compile and pass tests independently.

## Interactive rebase workflow
1. Create backup branch (per SKILL.md policy 3)
2. `git rebase -i main` (or appropriate base)
3. Reorder commits to logical order (per SKILL.md policy 5 -- reorder independents freely, maintain order for dependents)
4. Squash WIP commits into their logical parent
5. Edit commit messages to match repo style
6. Verify: `git range-diff` (per SKILL.md policy 4)

## Agent-specific rule
The agent knows *why* the change was made. That context belongs in the commit body (per SKILL.md policy 6). Include: what prompted the change, what approach was taken and why.

## Failure modes
| Failure | Fix |
|---------|-----|
| Rebase conflict during reorder (dependent commits reordered past each other) | Reset to backup, re-analyze dependencies, maintain order for dependents |
| Style detection wrong (small sample or mixed conventions) | Ask user to confirm style, check for config files again |
| Commit too large to split | Use `git reset HEAD~1` then `git add -p` to re-stage in logical chunks |

## Status
```yaml
status: complete | failed
backup_branch: <ai-backup/branch-timestamp>
commits_before: <count>
commits_after: <count>
style_used: <conventional | imperative | repo-detected>
```
