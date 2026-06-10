# Recipe: Screenshot Diff

**When:** Visually compare a page across git branches or deploys.
**Tools:** agent-browser → Playwright → native.
**Prereqs:** Clean git working tree (`git status --porcelain` empty), dev server running.

## Steps

### 1. Screenshot current branch
```bash
mkdir -p .agent/evidence/<run-slug>/artifacts
agent-browser open http://localhost:3000/target-page
agent-browser screenshot --full-page
# Save to .agent/evidence/<run-slug>/artifacts/current-branch-name.png
```

### 2. Set up comparison branch via worktree
```bash
# Create a temporary worktree for the comparison branch
git worktree add /tmp/browser-diff-worktree main  # or whatever branch to compare

# Start a second dev server on a DIFFERENT port from the worktree
cd /tmp/browser-diff-worktree
# Detect start command from package.json, use a different port
PORT=3001 npm run dev &
DIFF_SERVER_PID=$!

# Wait for server to be ready
until curl -s -o /dev/null http://localhost:3001; do sleep 1; done
```

### 3. Screenshot comparison branch
```bash
agent-browser open http://localhost:3001/target-page
agent-browser screenshot --full-page
# Save to .agent/evidence/<run-slug>/artifacts/comparison-branch-name.png
```

### 4. Present results
Show both screenshots to the user with clear labels:
- `current.png` -- [current branch name]
- `comparison.png` -- [comparison branch name]

Let the user visually compare. Note any obvious differences if visible from the screenshots.

### 5. Clean up (ALWAYS, even on failure)
```bash
# Kill the second dev server
kill $DIFF_SERVER_PID 2>/dev/null

# Remove the worktree
cd /original/project/dir
git worktree remove /tmp/browser-diff-worktree --force
```

## Output
Two labeled screenshots in `.agent/evidence/<run-slug>/artifacts/` with branch names in filenames.

## Cleanup (MUST happen even on failure)
Kill comparison server → remove worktree → close browser sessions. Never leave orphaned worktrees or processes.

## Failure Modes
| Failure | Fix |
|---------|-----|
| Dirty working tree | Ask user to commit or stash |
| Worktree creation fails | Check branch name exists |
| Port conflict on comparison server | Try ports 3002, 3003, etc. |
| Worktree removal fails | Kill server first, then force remove |

## Gotchas
- **Viewport:** Set consistent size for both screenshots (`--viewport 1280x720`)
- **Animations:** Wait for `networkidle`, consider disabling CSS animations
- **Dynamic content:** Timestamps/random content create false diffs — warn user
