# Skill Candidates from Bookmark Digests

Ready-to-run `/create-skill` prompts harvested from the 2026-07-06 twitter-digest run.
Vault references are relative to `~/Developer/Personal/vault/`. Full digest with source
map: `insights/twitter-bookmark-digests/2026-07-06-bookmark-digest.md`.

Work each candidate in this repo: draft under `skills/<name>/`, add to `manifest.txt`
when active. Check overlap against existing skills before minting (per SKILL_PLAN.md's
consolidation goal).

## repo-audit — four-phase principal-engineer audit

**Prompt for /create-skill:**
> Create a `repo-audit` skill that runs Michael Aubry's four-phase principal-engineer
> audit against the current repo: (1) architecture and boundary mapping, (2) risk and
> debt inventory, (3) convention/consistency review, (4) prioritized remediation plan
> with effort estimates. The full prompt text is captured verbatim in the vault entry —
> lift the phase structure and rubric from there rather than reinventing. Output a
> single audit report artifact. Overlap check: `review` (role-based lenses) and
> `cartographer` (teaching artifact) are adjacent — this one is a findings-first audit
> with remediation priorities, closest to `review` with an architecture lens; consider
> extending `review` instead of a new skill.

- Vault: `insights/agentic-coding/prompting-and-inquiry-patterns.md` ("Four-phase principal-engineer repo audit prompt")
- Bookmark: https://x.com/michaelaubry/status/2064501658936349151

## storm-research — 4-prompt research pipeline

**Prompt for /create-skill:**
> Create a `storm-research` skill implementing the STORM-style research workflow in four
> sequential prompts: (1) generate diverse expert perspectives on the question,
> (2) hunt contradictions between those perspectives, (3) synthesize into a grounded
> draft, (4) adversarial peer review of the draft. Vault entry has the four prompts.
> Overlap check: `counsel` (multi-model panel/critique) and `spike` (feasibility) are
> adjacent — this is a research/writing pipeline, likely a `counsel` mode rather than a
> standalone skill.

- Vault: `insights/agentic-coding/prompting-and-inquiry-patterns.md` ("STORM-style research in 4 prompts")
- Bookmark: https://x.com/heynavtoor/status/2067194761446920264

## ripple — call-graph-signatures context (the run's only `skill`-class item)

**Prompt for /create-skill:**
> Create a `ripple` skill that, before an agent edits a function, pulls the call graph
> around the edit target — signatures only, not bodies — plus the related tests into
> context, instead of whole files. Goal: fewer broken-caller regressions and lower token
> use. Implementation likely wants LSP or tree-sitter tooling in a script, not prose.
> Trigger: editing shared/library code with many callers.

- Vault: `insights/agentic-coding/context-retrieval-and-tooling.md` ("'Ripple' skill: pull the call graph (signatures only) + related tests into context")
- Bookmark: https://x.com/i/status/2065716083948953850
- Worked if: fewer broken-caller regressions from agent edits and lower token use than whole-file context.

## mine-sessions — session-log self-improvement loop

**Prompt for /create-skill:**
> Create a `mine-sessions` skill (or slash command + cron) that reads Claude Code
> (`~/.claude/projects/` JSONL) and Codex (`~/.codex/sessions/`) session logs and asks
> two questions per session: what content should exist from this, and what reusable
> improvement would have made it shorter/safer/cheaper? Route each lesson to one of
> seven homes: content idea, context file, slash command, skill patch, hook, tool/CLI
> fix, or config. Rules: store evidence not transcript dumps, detect real tool use not
> mentions, require approval before any change — schedule the scan, never the changes.
> Reference implementation exists (open-sourced as agent-improvement-loop). Overlap
> check: `seance` (session search) is read-only recall; this is a proposal generator —
> distinct trigger, but should reuse seance's log-reading internals if practical.

- Vault: `insights/agentic-coding/autoresearch-and-self-improvement.md` ("Mine your own session logs daily")
- Bookmark: https://x.com/Cathryn/status/2069193102586474781

## Also worth a look (not prompted up)

- **Loop engineering building blocks** — `insights/agentic-coding/loop-engineering.md` (Addy Osmani entry): five native loop primitives + on-disk memory spine; more a design reference for existing `loop`/`schedule` usage than a new skill.
- **Self-cleaning codebase** — named anti-patterns encoded as scheduled cleanup skills with auto-merged PRs (`insights/agentic-coding/autonomous-run-patterns.md`, @HarivanshRathi); pairs with `optimize`/`complexity-guard`.
