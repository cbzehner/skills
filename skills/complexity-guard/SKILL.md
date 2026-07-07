---
name: complexity-guard
description: >-
  Keeps code simple as a standing guardrail for code changes and architecture
  planning. Owns fix-applying overengineering sweeps: bloat, premature
  abstraction, YAGNI, or simplify/maintainability cleanup with safe fixes. For
  report-only critique use review; for broad stop-condition campaigns use
  optimize.
license: MIT
effort: low
---

# Complexity Guard

Use this as a standing engineering constraint: preserve behavior, follow the codebase's existing patterns, and challenge complexity before adding new structure.

## When to Use

- Every time you write, modify, review, or plan code.
- When the user mentions overengineering, simplification, maintainability, bloat, cleanup, architecture, YAGNI, "boil the ocean", or "sweep".
- When a change introduces a new abstraction, framework, protocol, schema surface, background process, cache, registry, hook, DSL, generic extension point, or multi-agent workflow.
- When reviewing changed code before calling work complete.

## Default Guardrail

Before editing, spend a short pass on the local code shape:

1. Read the nearest existing implementation, caller, and test.
2. Identify the dominant local pattern and reuse it unless it is actively causing the bug or friction.
3. Prefer the smallest behavior-preserving change that satisfies the request.
4. Add abstractions only when there are current callers, current duplication, or a concrete boundary that becomes easier to test or reason about.
5. Keep changes inside the requested scope. If a larger simplification is real but not needed now, report it separately.

Do not confuse ambition with overengineering. A 10x product goal can still be implemented through small, boring, verifiable steps. Push back on speculative machinery, not on ambitious outcomes.

## Complexity Gate

Ask these internally before adding structure:

- **Current consumer:** Who calls this today? If nobody does, defer it.
- **Local precedent:** Does the codebase already solve this nearby? Use that shape.
- **Standard owner:** Can the language, database, framework, type system, or existing helper own this invariant?
- **Failure mode:** What breaks if this layer does not exist? If the answer is vague future flexibility, leave it out.
- **Ambition check:** Is this complexity required to reach the user's larger goal, or is it just a way to feel ready before building the first useful slice?
- **Interface depth:** Does this create a smaller interface hiding real complexity, or a shallow wrapper with more names?
- **Test value:** Does the test prove behavior, or restate implementation details and literals?

## Overengineering Sweep

When the user asks for an overengineering sweep, bloat review, simplify pass, or maintainability audit:

1. Establish scope: current diff first; if no diff or the user asks broadly, inspect the named files, feature, or codebase area.
2. Search for nearby helpers, prior implementations, callers, schema definitions, and tests before judging.
3. Group findings by impact, not by file order.
4. Fix only no-behavior-change simplifications directly. For risky design changes, present the finding and the smallest safe next step.
5. Keep positives sparse: mention only patterns worth preserving because they prevent future overengineering.

Use this output shape for sweeps:

```markdown
Findings
1. [severity] file:line - What is more complex than needed, why it matters, and the smallest simpler alternative.

Safe Fixes Applied
- file:line - What changed without behavior change.

Leave Alone
- file:line - Abstraction or complexity that is earned, with the current consumer or invariant that justifies it.

Follow-ups
- Larger simplifications that should become separate issues or PRs.
```

## Smell Catalog

These smells came from repeated manual Claude/Codex/Magi reviews. Treat them as search prompts, not automatic verdicts:

- **Speculative protocol surface:** generic functions, interfaces, registries, callbacks, flags, or hook contracts with no specialized implementation or caller.
- **Future enum sprawl:** database values, modes, event kinds, or API branches with no read/write path.
- **Over-classification:** fine-grained buckets that split the signal before a consumer proves the distinction matters.
- **Stringly code generation:** constructing source, SQL, schemas, paths, or commands with ad hoc string formatting when structured builders or native syntax exist.
- **Layer leaks:** reaching through package, persistence, or framework internals instead of using the established boundary.
- **Nested defensive handling:** stacked rescues, guards, locks, retries, or validations for states the DB/schema/framework already prevents.
- **Impossible or hostile guards:** checks that cannot fail in normal flow, or fail during ordinary local iteration.
- **Trivial tests:** tests that walk static literals, assert private ordering, pin implementation math, or duplicate framework behavior.
- **Cosmetic helpers:** functions whose only observable effect is ordering, wrapping, or renaming with no caller value.
- **JSON/blob sprawl:** metadata written "just in case" with no reader, UI, query, or lifecycle.
- **Full-table local scans:** in-memory dedupe or filtering that the database can own with a targeted query or index.
- **Hard caps without a failure mode:** numeric limits that encode unease rather than a real resource or product constraint.
- **Framework or agent orchestration overkill:** parallel agents, worktrees, schedulers, background loops, or generated plans for a change that can be done directly.
- **Ambition disguised as infrastructure:** planning for a 10x outcome by building meta-systems first instead of shipping the first lake-sized slice.

## What to Preserve

Do not flatten everything. Keep complexity when it has a current job:

- A narrow interface hides substantial messy behavior.
- A boundary protects data integrity, security, concurrency, or external failure modes.
- Duplication is small, readable, and cheaper than a premature abstraction.
- A boring service object or explicit transaction makes the operation easier to test.
- Local conventions are consistent even if another style is theoretically cleaner.

## Reporting Style

Be direct and concrete. Prefer "delete this guard because the unique index owns it" over "consider simplifying". Cite files and lines when available. Avoid style-only churn unless the style issue creates maintenance cost or violates the repo's own pattern.
