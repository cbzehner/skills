# Recipe: Bisect Regression

## Steps
1. Identify boundaries:
   - Bad: `HEAD` (current broken state)
   - Good: ask user, check CI, or `git log --oneline` for a known-good commit
2. Write a deterministic test script OUTSIDE the repo:
   ```bash
   cat > /tmp/bisect-test.sh << 'SCRIPT'
   #!/bin/bash
   # Exit 0 = good, 1-124 = bad, 125 = skip (can't test this commit)
   cd "$1"
   # Test the specific behavior, not the entire suite
   npm test -- --grep "specific test name" 2>/dev/null
   SCRIPT
   chmod +x /tmp/bisect-test.sh
   ```
3. Run automated bisect:
   ```bash
   git bisect start HEAD <good-SHA>
   git bisect run /tmp/bisect-test.sh "$(pwd)"
   ```
4. Record the culprit commit, then reset:
   ```bash
   git bisect reset
   ```
5. Report the guilty commit with its diff and message.

## Key rules for bisect scripts
- **Self-contained** -- working tree changes per commit, script must not depend on it
- **Place in /tmp** -- use absolute path, never inside the repo
- **Exit codes matter** -- 0=good, 1-124=bad, 125=skip
- **Specific test** -- test the exact broken behavior, not the full suite

## Failure modes
| Failure | Fix |
|---------|-----|
| Build fails on old commits (deps/tooling changed) | Use `exit 125` to skip untestable commits |
| Script references files in working tree | Move all logic into `/tmp/bisect-test.sh` with no repo-relative paths |
| Regression older than assumed | Widen the range with an earlier known-good commit |

## Cleanup
Always run `git bisect reset` to return to original state. Remove `/tmp/bisect-test.sh`.
