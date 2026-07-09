---
name: counsel-panel
description: >-
  Multi-AI counsel system that queries Gemini, Codex, Claude (Fable→Opus), and
  Grok advisors in parallel, then synthesizes the answers. Use for second
  opinions, multiple viewpoints, plan review, architecture decisions, debugging
  strategy, API research, code review, tradeoff analysis, or alternative
  perspectives. Trigger when the user asks "what do you think", "ask other
  models", "get advice", "compare approaches", "review this plan", or would
  benefit from external model counsel before acting.
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

The panel Claude seat below is intentionally **Fable @ low** (counsel), distinct
from this matrix’s “medium max for critical review.”

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

#### Canonical panel roster (always these four seats)

| advisor_id | Model | Effort | Transport |
|---|---|---|---|
| codex | `gpt-5.5` | `xhigh` | `codex exec` with explicit model + effort override |
| claude | `claude-fable-5` (alias `fable`) | `low` | host seat or `claude -p`; if Fable unavailable → `claude-opus-4-8` @ `high` |
| grok | `grok-4.5` | `high` | `grok -p` |
| gemini | `gemini-3.1-pro-preview` | n/a | `gemini -p` (no effort flag — model has no effort levels) |

| Host | Local seat | External CLIs (parallel) |
|---|---|---|
| Claude Code | Claude (prefer Fable @ low; see host-seat accounting) | Gemini + Codex + Grok |
| Codex | Codex (prefer `gpt-5.5` @ `xhigh`) | Gemini + Claude + Grok |
| Grok Build | Grok (prefer `grok-4.5` @ `high`) | Gemini + Codex + Claude |
| Gemini CLI | Gemini (`gemini-3.1-pro-preview`, no effort) | Claude + Codex + Grok |

**Host-seat accounting:** The roster is what you *request* for external seats. For the host seat, record the session's **actual** model and effort when known (e.g. Claude Code on Sonnet is still the Claude seat, but normalize as that Sonnet id — do not invent `fable@low` or `opus@high`). If the host model/effort is not introspectable, persist `model: host-runtime` / `effort: unknown` rather than the target roster values. Never claim fixed roster compliance for a seat unless verified.

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

**Gemini transport:** Call Gemini directly. Keep the model explicit. Gemini 3.1 Pro has **no effort levels** — do not invent an effort flag.

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

**Codex transport:** Always pin model + effort. User `~/.codex/config.toml` often defaults to `medium` — panel **must** override to `xhigh`. Prefer a local `codex-adapter.sh` only if it can forward model and effort; otherwise use direct `codex exec` (the archived innovate adapter does not pass them).

```bash
codex exec --sandbox read-only --skip-git-repo-check \
  -m gpt-5.5 -c model_reasoning_effort="xhigh" \
  -- "$(cat <<'PROMPT'
[advisor prompt with any characters safely]
PROMPT
)" < /dev/null
```

**Claude transport (Fable → Opus):** Prefer Fable at low effort. Do **not** use `--fallback-model` alone — effort must change with the model (`low` for Fable, `high` for Opus). Try Fable first; only retry Opus at high when Fable is **unavailable as a model**, not on every error.

**Fable → Opus detector (external Claude seat only):** Trigger the Opus retry when Fable fails with a model-selection / entitlement signal, e.g.:
- JSON `is_error: true` plus message text matching model-not-found, unknown model, not entitled / no access, or model rejected
- Non-zero exit with the same class of message on stderr

Do **not** fallback to Opus on: auth missing (ask user to auth), permission denied / policy blocked (STOP), capacity/429 (retry once then `failed`/`unavailable`), network errors (retry once then `failed`), or content refusal (`failed`). Wrong classification either skips a needed Opus retry or burns a second expensive call.

```bash
# Primary
claude -p --model claude-fable-5 --effort low --output-format json <<'PROMPT'
[advisor prompt with any characters safely]
PROMPT

# Fallback only when Fable is unavailable as a model (see detector above)
claude -p --model claude-opus-4-8 --effort high --output-format json <<'PROMPT'
[advisor prompt with any characters safely]
PROMPT
```

Fable unavailable is **not** a panel failure if Opus high succeeds — mark Claude `ok` with a fallback note (e.g. `claude-opus-4-8@high — fable unavailable`).

**Grok transport:** Pin `grok-4.5` at high effort. Prefer `--permission-mode plan` for read-only counsel parity with Gemini.

```bash
grok -p "$(cat <<'PROMPT'
[advisor prompt with any characters safely]
PROMPT
)" -m grok-4.5 --effort high --permission-mode plan --output-format plain
```

(`--effort` is an alias for `--reasoning-effort`.)

**On Claude Code:** The host **is** the Claude seat. Do not also shell out to `claude -p`. Record the session's actual model/effort (see host-seat accounting). Run a background agent that:
1. Queries Gemini, Codex, and Grok in parallel via Bash (heredocs for prompt safety)
2. Formulates its own response as the Claude advisor
3. Waits for ALL results, then normalizes and synthesizes
4. If Gemini fails with 429/capacity: wait 60s, retry once, then skip
5. If ANY external command fails with "denied by policy": STOP — return only the setup message (see Failure Handling)

**On Codex:** The current session is the Codex seat. Prefer `gpt-5.5` @ `xhigh` when launching; if this host session was started on a different model/effort, record what actually ran. Launch Gemini, Claude (Fable→Opus), and Grok as external CLIs using heredocs. For Claude JSON output (`claude -p ... --output-format json`), check `is_error` before normalizing.

**On Grok Build:** The current session is the Grok seat. Prefer `grok-4.5` @ `high`; record actual host model/effort. Do not re-invoke `grok -p`. Launch Gemini, Codex, and Claude (Fable→Opus) as external CLIs using heredocs.

**On Gemini CLI:** The current session is the Gemini seat (`gemini-3.1-pro-preview`, no effort). Do not re-invoke `gemini -p` for a second Gemini vote. Launch Claude, Codex, and Grok as external CLIs using heredocs.

**Preview model IDs:** If a pinned id (e.g. `gemini-3.1-pro-preview`) is retired or rejected, mark that seat `unavailable` — do **not** silently substitute another model.

**Advisor prompt format:** Include the user's question + gathered context. Ask each advisor to state: assumptions, information gaps, implications (especially irreversible), and evidence basis.

**Capability framing per provider:**
- Gemini: "You have native web search. Cite sources."
- Codex: "You can execute shell commands. Verify claims by running code."
- Claude: (already has project context when host; external CLI gets only the gathered prompt)
- Grok: "You have web search/fetch. Cite sources when used."

### Step 3: Normalize Results

Every advisor response becomes:

```yaml
advisor_id: "gemini|codex|claude|grok"
model: "resolved model id that actually answered"
effort: "resolved effort, or n/a for gemini"
status: "ok|unavailable|blocked|failed"
summary: "1-3 sentence essence of the advisor's position"
assumptions: ["beliefs taken for granted in this response"]
information_gaps: ["what the advisor didn't know or couldn't verify"]
implications: ["consequences if this advice is followed, especially hard-to-reverse ones"]
evidence_basis: ["sources cited, code inspected, commands run, docs referenced"]
content: "full response or unavailability message"
```

Populated only when status is `ok`. Omit for other statuses. Always record resolved `model` + `effort` (e.g. Claude after Fable→Opus fallback).

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
**Advisors**: claude (ok, fable@low), gemini (ok), codex (ok, gpt-5.5@xhigh), grok (ok, grok-4.5@high)
**Decision**: [optional — concrete choice, if one emerged]
**Predictions**: [optional — expected outcomes]
**Confidence**: [optional — high | medium | low]
**Tags**: [optional — scope tags: backend, architecture, testing, etc.]

## Synthesis
[Narrative: agreement, disagreement, recommendation, remaining uncertainty]

## Claude
[Narrative: position, reasoning, assumptions, gaps, evidence; note Fable→Opus fallback if used]

## Gemini
[same]

## Codex
[same, or failure note]

## Grok
[same, or failure note]
```

Always use `## Synthesis`, `## Claude`, `## Gemini`, `## Codex`, `## Grok` headers (grep anchors for seance). Optional header fields only when synthesis produced a clear decision. Write sections as natural prose. Never persist secrets or credentials.

## Failure Handling

| Error Type | Action | Why |
|---|---|---|
| Local permission / sandbox / "denied by policy" | **STOP** — show setup guidance | Host tool policy blocks multi-perspective value; single-advisor fallback is just a normal conversation. Do **not** treat provider content refusal or model entitlement the same way. |
| 429 / capacity | Wait 60s → retry → proceed without that seat | Transient provider load |
| Gemini: "must specify GEMINI_API_KEY" (code 41) | Almost always a flag bug, not missing auth: confirm the invocation has **no `--sandbox`**. Sandbox hides ambient credentials. Only if `gemini -p "ping" --skip-trust --approval-mode plan` *also* fails is auth genuinely absent — then ask the user to log in (`gemini` interactive) or set a real key. Do not hunt for a `~/.gemini/.env`; it may not exist. | |
| Gemini: "not running in a trusted directory" | Ensure `--skip-trust` is present in the invocation. | |
| Fable model unavailable / not entitled | Retry Claude seat with Opus @ high; mark ok with fallback note if Opus succeeds | Effort must change with model; not a full-seat failure |
| Provider content refusal | Mark seat `failed`; continue with remaining advisors | Not a local permission problem |
| Other CLI auth failure | Ask the user to authenticate outside the agent session; mark seat `unavailable` | |
| CLI not found | State the missing CLI; proceed only if at least two advisors remain | |
| Network error | Retry once, then mark unavailable | |
| Pinned model id retired / rejected | Mark seat `unavailable`; no silent model substitution | Preview ids rot |

**Degraded council rules:**
- 4/4 → full synthesis
- 2–3/4 → partial synthesis, note who's missing and why
- 1/4 (host-only) → only if failures are capacity/network; state it's single-advisor
- Local permission blocked → **STOP**. Show setup message: add `"Bash(gemini *)"`, `"Bash(codex *)"`, `"Bash(grok *)"`, and (when Claude is external) `"Bash(claude *)"` to `.claude/settings.local.json` permissions.allow. (Codex hosts: show sandbox/approval guidance instead.)

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
