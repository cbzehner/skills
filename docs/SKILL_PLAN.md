# Skill Stack Simplification Plan

## Goal

Radically simplify the local `skill-*` stack without throwing away hard-won behavior.

The target is not to recreate Superpowers locally. The target is a smaller, clearer stack built around a few durable lanes:

```text
think -> plan -> execute -> review -> verify/ship -> remember
```

The migration should reduce trigger ambiguity, remove Superpowers as a default dependency, preserve useful workflow discipline, and move deterministic policy out of prose and into scripts or hooks.

## Current Diagnosis

The stack is useful but over-specified.

Main issues:

- Too many adjacent skills can fire for the same intent.
- Multiple memory systems overlap: `napkin`, `theorist`, `evolver`, `seance`, `qmd`.
- Multiple counsel/review systems overlap: `magi`, `innovate`, `critical-thinking`, `complexity-guard`, `finish-task` review gates.
- Planning/product flow is fragmented: `grill-me`, `write-a-prd`, `prd-to-plan`, proposed `planning`, proposed `domain-model`, `ralph`.
- Some large skills contain deterministic mechanics that should live in scripts or CLIs.
- Several skills still route to or describe themselves relative to Superpowers.

The main simplification move is to consolidate the trigger surface while keeping proven internals available as references or tools.

## What We Win

- Clearer routing: fewer skills compete for the same request.
- Lower context load: less repeated process text in active skill instructions.
- Easier maintenance: improve one router or role once, and downstream workflows benefit.
- Better portability across Claude, Codex, OpenCode, and OpenClaw-style hosts.
- More modern structure: thin harness, focused skills, explicit artifacts, deterministic hooks.
- Cleaner handoffs through files: `CONTEXT.md`, ADRs, `./plans/*.md`, memory files, review reports.

## What We Lose

- Some precise auto-trigger behavior from many narrow skills.
- Some conceptual purity, especially if `counsel` or `plan` becomes too broad.
- Some battle-tested edge cases if large skills are compressed too aggressively.
- Temporary migration cost while wrappers and routers coexist.

Mitigation: consolidate entry points first, not implementations. Old skills become compatibility shims until the routers have proven themselves.

## Target Skill Lanes

### 1. Counsel

New canonical skill: `skill-counsel`

Modes:

- `--interview`: one-question-at-a-time grilling, based on `grill-me`.
- `--adversarial`: rigorous critique, based on `critical-thinking`.
- `--panel`: multi-model council, based on `magi`.
- `--wildcard`: frontier/novel addition, based on `innovate`.

Keep the old mechanics as references initially. Do not delete `magi` internals until the panel mode is proven.

### 2. Plan

New canonical skill: `skill-plan`

Modes:

- `--interview`: clarify vague intent.
- `--prd`: produce a PRD or issue.
- `--from-prd`: convert a PRD into a ralph-compatible plan.
- `--from-issue`: turn a ticket into a ralph-compatible plan.
- `--ralph`: write `./plans/<slug>.md`.

This replaces the Superpowers `writing-plans` role and eventually absorbs direct entry to `write-a-prd` and `prd-to-plan`.

### 3. Domain Model

New canonical skill: `skill-domain-model`

Modes:

- `init`: bootstrap glossary and architecture-language files from the repo.
- `update`: add resolved terms and ADRs as decisions crystallize.
- `audit`: find drift between user terms, docs, and code symbols.

Keep this lightweight. It should not become a full DDD framework. It owns `CONTEXT.md`, `CONTEXT-MAP.md`, and `docs/adr/` conventions.

### 4. Diagnose

New canonical skill: `skill-diagnose`

Purpose:

```text
reproduce -> minimize -> hypothesize -> instrument -> fix -> regression test
```

This should replace generic Superpowers debugging references. It should stay small, closer to Matt Pocock's `diagnose` than a large framework.

### 5. Review

New canonical skill: `skill-review`

Modes or roles:

- `--as complexity`
- `--as architecture`
- `--as security`
- `--as design`
- `--as accessibility`
- `--as docs`
- `--as spec`
- `--as release`

This should absorb the review surface of `complexity-guard`, parts of `critical-thinking`, design review, and `finish-task` gates.

### 6. Design

New canonical skill: `skill-design`

Collapse `skill-boring-web-design` into one router skill plus references:

- accessibility
- content
- critique
- design language
- precedent
- information architecture
- service design
- static HTML playground
- UX flow
- visual standards

The router decides which reference to load. The old 10 skills should become wrappers first, then be archived.

### 7. Execute

Keep `ralph`, but shrink it.

Target:

- `SKILL.md` explains the contract and when to invoke.
- deterministic orchestration moves to `bin/ralph` or scripts.
- prompt templates and special cases move to references.

Do not delete `ralph` early. It contains operational lessons.

### 8. Verify / Ship

Keep `finish-task`, but refactor it into a gate.

It should delegate:

- git history and worktrees to `git`
- browser and screenshots to `browser`
- multi-model counsel to `counsel --panel` or `magi`
- complexity and architecture review to `review`
- plan state to `ralph`

State-changing behavior should require explicit confirmation or deterministic hooks.

### 9. Memory

New canonical skill: `skill-repo-memory`

Consolidate:

- `napkin` -> `.claude/memory/runbook.md`
- `theorist` -> `.claude/memory/theory.md`
- `evolver` -> `.claude/memory/learnings.md` or trace source for later distillation
- `seance` -> search tool for past sessions, not always-active memory
- `qmd` -> markdown search tool, not a memory policy

Stable project instructions belong in `CLAUDE.md` or `AGENTS.md`.

## Superpowers Replacement Map

Replace:

- `superpowers:brainstorming` -> `counsel --interview` or `plan --interview`
- `superpowers:writing-plans` -> `plan`
- `superpowers:executing-plans` -> `ralph`
- `superpowers:systematic-debugging` -> `diagnose`
- `superpowers:verification-before-completion` -> `finish-task` gate and hooks
- `superpowers:finishing-a-development-branch` -> `finish-task`
- `superpowers:writing-skills` -> `create-skill`

Do not clone:

- `using-superpowers`
- broad meta-enforcement
- giant prompt frameworks
- separate requesting/receiving code review skills
- subagent orchestration as a standalone skill when `ralph` and host-native delegation cover it

## Migration Strategy

### Migration Lesson: Additive First

Router experiments should be additive before they are canonical.

Do not edit or shim source skills until the new router has proven itself in real use. The safe pattern is:

1. Create and install the new router skill.
2. Leave old skills untouched as the known-good baseline.
3. Use the router manually for one to two weeks.
4. Track routing misses, vague behavior, and repeated wins.
5. Only then convert old skills into shims or archive them.

This avoids losing battle-tested behavior while still testing a simpler skill surface.

### Phase 1: Add Routers

Create new router skills without deleting existing skills:

```text
skill-counsel
skill-plan
skill-design
skill-review
skill-repo-memory
skill-diagnose
skill-domain-model
```

Each router starts with a short `SKILL.md` and references migrated from current skills.

Example:

```text
skill-counsel/
  skills/counsel/SKILL.md
  skills/counsel/references/interview.md
  skills/counsel/references/adversarial.md
  skills/counsel/references/panel.md
  skills/counsel/references/wildcard.md
```

### Phase 2: Convert Old Skills To Shims

Rewrite old direct-entry skills as compatibility wrappers.

Example:

```markdown
# grill-me

This workflow is now handled by `counsel --interview`.

Use counsel's interview mode. Preserve one-question-at-a-time behavior and recommended-answer style.
```

This preserves muscle memory while reducing canonical routing.

### Phase 3: Remove Superpowers References

Clean these first:

```text
skill-grill-me
skill-write-a-prd
skill-prd-to-plan
skill-ralph
skill-how-it-works
skill-finish-task
skill-create-skill
```

Replace Superpowers references with local canonical skills from the replacement map.

### Phase 4: Move Mechanics Out Of Skills

For large skills, move deterministic behavior into scripts or CLIs.

Priority:

```text
ralph        -> bin/ralph + references
browser      -> scripts/probes + references
git          -> references/worktrees.md, references/stacking.md
seance       -> bin/seance search CLI
finish-task  -> scripts/checks + references
```

Rule:

- deterministic shell logic -> script
- judgment and routing -> skill
- stable project facts -> `CLAUDE.md`, `AGENTS.md`, or `.claude/memory`

### Phase 5: Add Hooks For Policy

Use hooks for safety that should not depend on model memory:

- block `git reset --hard`
- block `git clean -fd`
- block unsafe force-push
- warn before pushing to default branch
- optionally run finish checks on Stop when `.finish-task.toml` exists

Prompt discipline is not enough for destructive operations.

### Phase 6: Archive After Proving Routers

After two weeks of router use, archive old repos that are only shims:

```text
skill-grill-me
skill-innovate
skill-critical-thinking
skill-prd-to-plan
skill-write-a-prd
skill-boring-web-design
skill-napkin
skill-theorist
skill-evolver
```

Do not archive early:

```text
skill-magi
skill-ralph
skill-browser
skill-git
skill-seance
```

Shrink these first.

## First Concrete PR

Start with the safest proof of pattern:

1. Create `skill-design`.
2. Move the 10 `skill-boring-web-design` skill bodies into `skill-design/skills/design/references/`.
3. Add a short router `SKILL.md`.
4. Change the old 10 design skills to wrapper shims.
5. Validate that design requests still route correctly.

This gives an immediate trigger-surface reduction without touching sensitive execution or delivery skills.

## Target End State

Core canonical skills:

```text
counsel
plan
domain-model
diagnose
ralph
review
design
browser
git
finish-task
create-skill
repo-memory
```

Expected result:

- roughly 24 skill repos reduced to 10-12 canonical skills
- Superpowers removed as a default dependency
- old workflows preserved as references or shims
- deterministic safety moved to hooks
- large orchestration moved to scripts/CLIs
- lower context load and less skill-selection ambiguity
