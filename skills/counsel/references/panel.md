---
name: counsel-panel
description: >-
  Multi-AI counsel system that queries Gemini, Codex, and Claude advisors in
  parallel, then synthesizes the answers. Use for second opinions, multiple
  viewpoints, plan review, architecture decisions, debugging strategy, API
  research, code review, tradeoff analysis, or alternative perspectives. Trigger
  when the user asks "what do you think", "ask other models", "get advice",
  "compare approaches", "review this plan", or would benefit from external
  model counsel before acting.
argument-hint: "[prompt or competing plans]"
arguments:
  - prompt
license: MIT
effort: high
allowed-tools: Bash Read Glob Grep Task Write
# Note: Write is scoped to session persistence (~/.claude/magi/sessions/) only
---

# Counsel Panel

## When NOT to Use

- Trivial questions where you already know the answer — panel mode adds 30-60s latency
- Time-sensitive execution where the user wants action, not counsel
- Solo deep reasoning — use `counsel --adversarial` instead

## Modes

### Counsel (default)

One question, one decision. Each advisor gets the same prompt with enough project
context to avoid generic answers.

### Agent-Platform Model Matrix

When reviewing Agent Platform SDLC routing, use this current strategy unless the
repo config says otherwise:

| Stage / Route | Model set | Effort strategy |
|---|---|---|
| Detail | Sonnet 5 | medium by default |
| Routine build | Codex Spark | cap at medium |
| Standard build | GPT 5.5 | high practical default |
| Critical build | GPT 5.5 | xhigh for high-consequence work |
| Routine review | GPT 5.5 | medium |
| Standard review | GPT 5.5 + Opus 4.8 | GPT high/xhigh, Opus high/xhigh |
| Critical review | GPT 5.5 + Fable 5 | GPT xhigh, Fable medium max |

Treat Fable as an escalation reviewer, not a routine worker. Never recommend
unattended Fable effort above medium; Fable low/medium is already comparable to
Opus 4.8 high or GPT 5.5 xhigh for this use case. Prefer better task slicing,
deterministic checks, or human arbitration over Fable xhigh.

### Plan Synthesis

The user has 2-3 competing plans. Each advisor identifies what each plan does
better, what it misses, and proposes a hybrid. Output includes a conflict table:

```markdown
| Decision Point | Plan A | Plan B | Hybrid Choice | Reasoning |
|---|---|---|---|---|
```

## Workflow

### Step 1: Build Advisor Roster

Start with the host-native local advisor, then add external advisors.

**Never double-count the host** — the host runtime IS the local advisor. Don't launch its own CLI as a second advisor.

This is the canonical panel implementation. `magi` is only an alias for this
workflow; do not hand off to the archived `skill-magi` repository.

### Step 1.5: Gather Context (~4000 token budget)

External advisors have no project access. Include in priority order:
1. User's question verbatim
2. Relevant code snippets
3. Error output (if debugging)
4. Project structure (`ls`/tree)
5. Framework context (package.json, Cargo.toml, etc.)

Excerpt relevant sections, not whole files. Never include secrets/credentials. Build one prompt for all advisors.

### Step 2: Query Advisors in Parallel

**Prompt safety:** Never interpolate prompts into shell strings. Always use single-quoted heredocs (`<<'PROMPT'`) to prevent shell expansion.

**Gemini transport:** Call Gemini directly. Keep the model explicit in the command so the invocation is self-contained:

```bash
PATH="/opt/homebrew/bin:$PATH" gemini -p "$(cat <<'PROMPT'
[advisor prompt with any characters safely]
PROMPT
)" --model gemini-3.1-pro-preview --skip-trust --approval-mode plan -o json
```

Flag rationale (each earned through real failures — do not drop or add to this set without re-testing):
- `--skip-trust`: headless `gemini -p` refuses to run in any directory absent from `~/.gemini/trustedFolders.json` ("not running in a trusted directory"). This skill runs in arbitrary repos, so the gate must be passed explicitly.
- `--approval-mode plan`: restricts Gemini to read-only tools (no shell, no file writes). This is the safety boundary that contains the workspace-tool surface `--skip-trust` would otherwise expose to a hostile repo's `.gemini/` config. The advisor only needs to reason and reply, so read-only loses nothing.
- **No `--sandbox`**: sandboxing severs the CLI's access to the host's ambient credentials, producing a misleading "you must specify the GEMINI_API_KEY environment variable" (code 41) even when auth is otherwise working. This was the dominant historical failure mode; do not reintroduce it.

**Codex transport:** Prefer a local `codex-adapter.sh` when available because it prevents stdin hangs in subagent environments. If this counsel skill was installed without the adapter, use direct `codex exec ... < /dev/null` as a fallback and note that the adapter was unavailable.

**On Claude Code:** Run as a single background Agent (general-purpose, opus) that:
1. Queries Gemini and Codex in parallel via Bash (heredocs for prompt safety)
2. Formulates its own response as the Claude advisor
3. Waits for ALL results, then normalizes and synthesizes
4. If Gemini fails with 429/capacity: wait 60s, retry once, then skip
5. If EITHER command fails with "denied by policy": STOP — return only the setup message (see Failure Handling)

**On Codex:** The current session is the local advisor. Launch Gemini and Claude as external CLIs using heredocs. For Claude JSON output (`claude -p ... --output-format json`), check `is_error` before normalizing.

**Advisor prompt format:** Include the user's question + gathered context. Ask each advisor to state: assumptions, information gaps, implications (especially irreversible), and evidence basis.

**Capability framing per provider:**
- Gemini: "You have native web search. Cite sources."
- Codex: "You can execute shell commands. Verify claims by running code."
- Claude: (already has project context)

### Step 3: Normalize Results

Every advisor response becomes:

```yaml
advisor_id: "gemini|codex|claude"
status: "ok|unavailable|blocked|failed"
summary: "1-3 sentence essence of the advisor's position"
assumptions: ["beliefs taken for granted in this response"]
information_gaps: ["what the advisor didn't know or couldn't verify"]
implications: ["consequences if this advice is followed, especially hard-to-reverse ones"]
evidence_basis: ["sources cited, code inspected, commands run, docs referenced"]
content: "full response or unavailability message"
```

Populated only when status is `ok`. Omit for other statuses.

Statuses: `ok` (usable), `unavailable` (not configured), `blocked` (policy denied — see Failure Handling), `failed` (runtime error).

### Step 3.5: Critique Round (--debate only)

When `--debate` is passed, run an anonymized critique round if the local
provider tools are available. Otherwise skip the critique round and state that
panel mode only ran the first-pass advisors.

### Step 4: Synthesize

| Pattern | When | Action |
|---|---|---|
| **Consensus** | Advisors mostly agree | Proceed, but note shared blind spots |
| **Complementary** | Different but compatible | Combine strongest non-overlapping insights |
| **Conflict** | Direct contradiction | Compare evidence quality, prefer simpler/reversible |
| **Gap** | One advisor silent | Note the gap; do not invent agreement |

On conflicts, use normalized fields: incompatible assumptions often explain disagreement; grounded evidence outweighs general reasoning; prefer fewer irreversible consequences.

Answer explicitly: (1) agreement, (2) disagreement, (3) which disagreements matter, (4) best decision for project context, (5) remaining uncertainty.

Use the persistence template below for the report.

### Step 5: Persist Session

Write to `~/.claude/magi/sessions/YYYY-MM-DD-<slug>.md` (create dir if needed).
Slug: first ~50 chars of question, lowercased, spaces to hyphens, non-alphanumeric removed. Include file path in report.

```markdown
# Counsel Panel Session: YYYY-MM-DD
**Question**: [original prompt verbatim]
**Advisors**: claude (ok), gemini (ok), codex (failed)
**Decision**: [optional — concrete choice, if one emerged]
**Predictions**: [optional — expected outcomes]
**Confidence**: [optional — high | medium | low]
**Tags**: [optional — scope tags: backend, architecture, testing, etc.]

## Synthesis
[Narrative: agreement, disagreement, recommendation, remaining uncertainty]

## Claude
[Narrative: position, reasoning, assumptions, gaps, evidence]

## Gemini
[same]

## Codex
[same, or failure note]
```

Always use `## Synthesis`, `## Claude`, `## Gemini`, `## Codex` headers (grep anchors for seance). Optional header fields only when synthesis produced a clear decision. Write sections as natural prose. Never persist secrets or credentials.

## Failure Handling

| Error Type | Action | Why |
|---|---|---|
| Permission denied | **STOP** — show setup guidance | Panel mode's value is multi-perspective. Single-advisor fallback is just a normal conversation |
| 429 / capacity | Wait 60s → retry → proceed without | Gemini has limited capacity |
| Gemini: "must specify GEMINI_API_KEY" (code 41) | Almost always a flag bug, not missing auth: confirm the invocation has **no `--sandbox`**. Sandbox hides ambient credentials. Only if `gemini -p "ping" --skip-trust --approval-mode plan` *also* fails is auth genuinely absent — then ask the user to log in (`gemini` interactive) or set a real key. Do not hunt for a `~/.gemini/.env`; it may not exist. | |
| Gemini: "not running in a trusted directory" | Ensure `--skip-trust` is present in the invocation. | |
| Other CLI auth failure | Ask the user to authenticate outside the agent session | |
| CLI not found | State the missing CLI and proceed only if at least two advisors remain | |
| Network error | Retry once, then mark unavailable | |

**Degraded council rules:**
- 3/3 → full synthesis
- 2/3 → partial synthesis, note who's missing and why
- 1/3 (host-only) → only if failures are capacity/network; state it's single-advisor
- Permission blocked → **STOP**. Show setup message: add `"Bash(gemini *)"` and `"Bash(codex *)"` to `.claude/settings.local.json` permissions.allow. (Codex hosts: show sandbox/approval guidance instead.)

## Usage Examples

When `$ARGUMENTS` is empty, show:

```
Usage:
  counsel --panel "prompt"           # Panel mode
  magi "prompt"                      # Alias for counsel --panel
  magi --debate "prompt"             # Alias with anonymized critique round
```

## References

- `magi` remains an alias for this panel workflow.
