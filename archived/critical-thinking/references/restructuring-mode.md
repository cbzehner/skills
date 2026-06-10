# Restructuring Mode for Writing Plans

When using `writing-plans` for large-scale refactoring (not feature development), these additional constraints apply.

## How Restructuring Differs from Feature Planning

| Dimension | Feature Plan | Restructuring Plan |
|---|---|---|
| Goal | Add capability | Reorganize existing code |
| Risk | Incomplete feature | Broken imports, lost functionality |
| Verification | Tests pass for new code | Build passes at EVERY step |
| Rollback | Delete new files | Complex — changes are entangled |
| Dependencies | Forward-only | Must trace all consumers |

## Additional Constraints for Restructuring Plans

### 1. Dependency Mapping (before any tasks)

Before defining restructuring tasks, map:
- Every file being moved and every file that imports it
- Every public symbol being renamed and every call site
- Every path referenced in config, CI, or scripts

Include this map in the plan header. The engineer needs it to verify nothing was missed.

### 2. Build-at-Every-Step Rule

Every task in a restructuring plan must end with a passing build. No "we'll fix imports in a later step." If moving a file breaks 12 imports, the task includes fixing all 12 imports.

### 3. Checkpoint Commits

Every restructuring task gets its own commit. If something goes wrong, you can `git bisect` to find exactly which move broke things. Never batch multiple file moves into one commit.

### 4. Proposal Document

For restructuring that touches >10 files, write a `PROPOSED_RESTRUCTURING.md` before executing:
- Current structure (relevant directory tree)
- Proposed structure (new directory tree)
- Rationale for each move (not just "better organization" — why this specific structure)
- Import chain impact (which files need updates)
- Risk assessment (what could break)

Get user approval before executing.

### 5. Verification Strategy

After all restructuring tasks complete:
- Full build passes
- Full test suite passes
- No dead imports (unused import warnings)
- No references to old paths in config, CI, docs
- `git diff --diff-filter=M` against pre-restructuring baseline should be empty or minimal (modified files indicate logic changes, not pure moves). Use `git diff --diff-filter=R --stat` to confirm renames
