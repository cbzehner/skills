# Recipe: Resolve Conflicts

## Scope (v1)
Rebase conflicts during history rewriting + generated file regeneration. Exotic types (rename/rename, binary, symlink) are out of scope -- provide status and let the user decide.

## zdiff3 marker format
Requires `merge.conflictStyle = zdiff3`. Four sections:
```
<<<<<<< HEAD (ours)
  our changes
||||||| base
  original code (common ancestor)
=======
  their changes
>>>>>>> feature-branch (theirs)
```
The base section is critical -- it shows what both sides started from. Without it (default `merge` style), you are guessing.

## Semantic resolution protocol
For each conflicted hunk:
1. **Read base** -- what both sides started from
2. **Compare ours vs base** -- determine our intent (what did we change and why?)
3. **Compare theirs vs base** -- determine their intent (what did they change and why?)
4. **Compatible intents** -- merge both changes into the result
5. **Incompatible intents** -- ask the user, don't guess
6. **Run tests** after every file resolution, not just at the end

## Generated files (lockfiles, compiled output)
Never merge generated files. They produce garbage. Instead:
1. Accept one side: `git checkout --ours <file>` or `git checkout --theirs <file>`
2. Regenerate with the appropriate command:
   - `npm install` / `yarn install` / `pnpm install` (JS lockfiles)
   - `cargo generate-lockfile` (Rust)
   - `pip compile` / `uv pip compile` (Python)
   - `go mod tidy` (Go)
3. Stage the regenerated file: `git add <file>`

## rerere
- `rerere.enabled=true` records conflict resolutions automatically
- Especially valuable for stacked branches where the same conflict recurs across rebases
- `rerere.autoUpdate=true` auto-stages rerere resolutions (skips manual `git add`)
- Verify rerere applied correctly -- it replays past resolutions blindly

## When to resolve autonomously
- Adjacent-line changes (proximity conflict, not actual conflict)
- Import/dependency additions from both sides
- Formatting or whitespace differences

## When to ask the user
- Both sides modified the same function with different logic
- One side deleted code the other modified
- Semantic incompatibility (e.g., different approaches to same problem)
- More than 3 files in conflict simultaneously

## After resolution
Verify all three:
1. `git status` -- no unmerged paths remain
2. Run tests -- full suite passes
3. `git diff` -- review final state matches expected outcome

## Failure modes
| Failure | Fix |
|---------|-----|
| Many files in conflict (>3) | Stop. Present list to user and ask for prioritization |
| Lockfile merge garbage | Accept one side, regenerate (see generated files section) |
| rerere wrong resolution (tests fail after auto-resolution) | `git checkout -m <file>` to restore conflict markers, resolve manually |
| Exotic conflict type (rename/rename, binary, symlink) | Report status to user, let them decide |

## Status
Return on completion:
```yaml
status: success | partial | failed
files_resolved: [list]
files_skipped: [list]
tests_pass: true | false
user_action_needed: true | false
```
