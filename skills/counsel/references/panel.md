---
name: counsel-panel
description: >-
  Multi-AI counsel system that queries Gemini, Codex, and Claude advisors
  in parallel, then synthesizes the answers. Use for second opinions, multiple
  viewpoints, plan review, architecture decisions, debugging strategy, API
  research, code review, tradeoff analysis, or alternative perspectives. Trigger
  when the user asks "what do you think", "ask other models", "get advice",
  "compare approaches", "review this plan", or would benefit from external model
  counsel before acting.
argument-hint: "[--full] [--debate] [--with gemini|codex|claude] [prompt or competing plans]"
arguments:
  - prompt
license: MIT
effort: high
allowed-tools: Bash Read Glob Grep Task Write
# Note: Write is scoped to the temporary prompt file (<work_dir>/prompt.txt) and session persistence (~/.claude/magi/sessions/) only
---

# Counsel Panel

## When NOT to Use

- Trivial questions where you already know the answer — panel mode adds ~1–3 min latency (higher with Astra at `high`)
- Time-sensitive execution where the user wants action, not counsel
- Solo deep reasoning — use `counsel --adversarial` instead

## Modes

### Counsel (default)

One question, one decision. Each advisor gets the same prompt with enough project
context to avoid generic answers.

### Plan Synthesis

The user has 2-3 competing plans. Each advisor identifies what each plan does
better, what it misses, and proposes a hybrid. Output includes a conflict table:

```markdown
| Decision Point | Plan A | Plan B | Hybrid Choice | Reasoning |
|---|---|---|---|---|
```

## Stakes-Based Sizing

Do not fire all three seats by default. Match seat count to stakes:

| Stakes | Invocation | Seats | Use when |
|---|---|---|---|
| **Small / reversible** | `counsel --adversarial` | 1 (host only) | Routine tradeoffs, sanity checks — skip panel latency |
| **Medium (default)** | `counsel --panel` | 2 (host + 1 external family) | Normal second opinions, bounded design choices |
| **High / irreversible** | `counsel --panel --full` or `magi` | 3 (Claude + Codex + Gemini) | Architecture kickoffs, security/data migrations, stuck debugging deadlocks, or when the prompt names two external families |

For a **2-seat panel**, pick the external family that best complements the host (or honor `--with <advisor_id>`; if `--with` names the host's own family, ignore it and pick a different family; `--full` overrides `--with`):
- On **Claude** host: pick **Codex** (`gpt-6.2-astra` for concrete edge-case/invariant stress-testing) or **Gemini** (`gemini-4-neon` for alternative framing, product/UX, or broad synthesis).
- On **Codex** host: pick **Claude** (`claude-fable-5-2`) or **Gemini** (`gemini-4-neon`).
- On **Gemini** host: pick **Claude** (`claude-fable-5-2`) or **Codex** (`gpt-6.2-astra`).

## Workflow

### Step 1: Build Advisor Roster

Start with the host-native local advisor, then add external advisors according to the selected panel size (1 external for default `--panel`, 2 external for `--panel --full` / `magi`).

**Never double-count the host** — the host runtime IS the local advisor. Don't launch its own CLI as a second advisor.

This is the canonical panel implementation. `magi` is only an alias for the
full 3-seat workflow; do not hand off to the archived `skill-magi` repository.

#### Canonical 3-family roster

Grok is not part of the council roster; the three seats cover Anthropic, OpenAI, and Google.

| advisor_id | Model | Effort | Transport |
|---|---|---|---|
| claude | `claude-fable-5-2` | `medium` | host seat or `claude -p` |
| codex | `gpt-6.2-astra` | `high` | `codex exec` with explicit model + effort override |
| gemini | `gemini-4-neon` | `default` (CLI/API default; no effort flag) | `gemini -p` (API-key mode via `GEMINI_API_KEY`) |

| Host | Local seat | External CLIs (2-seat default / 3-seat `--full`) |
|---|---|---|
| Claude Code / Pi (Claude) | Claude (see host-seat accounting) | 1 of Codex or Gemini / both Codex + Gemini |
| Codex | Codex (see host-seat accounting) | 1 of Claude or Gemini / both Claude + Gemini |
| Gemini CLI | Gemini (see host-seat accounting) | 1 of Claude or Codex / both Claude + Codex |
| `agy` | Active model's family (check before choosing externals — `agy` can run Gemini or Claude) | 1 other family / both other families |

**Host-seat accounting:** The roster is what you *request* for external seats. For the host seat, record the session's **actual** model and effort when known (e.g. Claude Code on Opus is still the Claude seat, but normalize as that Opus id — do not invent `claude-fable-5-2@medium`). If the host model/effort is not introspectable, persist `model: host-runtime` / `effort: unknown` rather than the target roster values. Never claim fixed roster compliance for a seat unless verified.

### Step 1.5: Gather Context (~4000 token budget)

External advisors have no project access. Include in priority order:
1. User's question verbatim
2. Relevant code snippets
3. Error output (if debugging)
4. Project structure (`ls`/tree)
5. Framework context (package.json, Cargo.toml, etc.)

Excerpt relevant sections, not whole files. Never include secrets/credentials. Build one prompt for all advisors.

### Step 2: Query Advisors in Parallel

**Prompt and workspace safety:** Never embed untrusted user text or repository excerpts into generated shell source (even a quoted heredoc breaks if the excerpt contains the delimiter). Instead, create and print a clean temporary directory **outside** the repository under review with an empty `run/` child (`work_dir="$(mktemp -d)" && mkdir "$work_dir/run" && printf '%s\n' "$work_dir"`), use that literal `<work_dir>` path across subsequent tool calls (shell variables do not persist between separate Bash calls), write the assembled prompt once to `<work_dir>/prompt.txt` via the host's file-write tool, and pass it to every external CLI via stdin redirection (`< "<work_dir>/prompt.txt"`) while running from the empty `<work_dir>/run` directory. Running from `<work_dir>/run` prevents any external CLI from loading untrusted project `.gemini/`, `.claude/`, or MCP configs from the reviewed repository. Clean up `<work_dir>` after collecting responses.

**Gemini transport:** Verify `<work_dir>/run` is empty and outside the reviewed repo, confirm Gemini CLI will use API-key mode with a paid `GEMINI_API_KEY` (host policy: do not use consumer Antigravity OAuth for headless third-party orchestration; if API-key mode cannot be confirmed, mark the Gemini seat `unavailable`), then invoke `gemini-4-neon` from `<work_dir>/run` with `--skip-trust` for that empty directory only. `gemini -p` has no effort flag; record effort as `default` (or `unknown`).

```bash
(
  cd "<work_dir>/run" &&
  PATH="/opt/homebrew/bin:$PATH" gemini -p "" \
    --model gemini-4-neon --skip-trust --approval-mode plan -o json < "<work_dir>/prompt.txt"
)
```

Flag rationale:
- Running in `<work_dir>/run` (an empty temp directory outside the reviewed repo): isolates the invocation so `--skip-trust` never trusts an arbitrary repository's `.gemini/` settings or project MCP servers.
- `--skip-trust`: headless `gemini -p` refuses directories absent from `~/.gemini/trustedFolders.json` (including a fresh `mktemp -d` directory). Passing it inside the verified empty `<work_dir>/run` satisfies the check without trusting the reviewed repo.
- `--approval-mode plan`: restricts Gemini to read-only tools.
- **No `--sandbox`**: sandboxing can block access to ambient credentials on macOS; running in `<work_dir>/run` with `--approval-mode plan` isolates the reviewed repo without breaking credential resolution.

**Codex transport:** Always pin model + effort explicitly (`gpt-6.2-astra` at `high`) and read the prompt from stdin (`-`).

```bash
codex exec --sandbox read-only --skip-git-repo-check -C "<work_dir>/run" \
  -m gpt-6.2-astra -c model_reasoning_effort="high" - < "<work_dir>/prompt.txt"
```

**Claude transport:** Pin Fable 5.2 at medium effort from `<work_dir>/run` with strict MCP isolation and stdin redirection.

```bash
(
  cd "<work_dir>/run" &&
  claude -p --model claude-fable-5-2 --effort medium \
    --strict-mcp-config --no-session-persistence --output-format json < "<work_dir>/prompt.txt"
)
```

**On Claude Code:** The host **is** the Claude seat. Do not also shell out to `claude -p`. Record the session's actual model/effort (see host-seat accounting). Run a background agent that:
1. Queries the selected external advisor(s) in parallel via Bash using `"<work_dir>/prompt.txt"`
2. Formulates its own response as the Claude advisor
3. Waits for ALL requested results, then normalizes and synthesizes
4. If Gemini fails with 429/capacity: wait 60s, retry once, then skip
5. If ANY external command fails with "denied by policy": STOP — return only the setup message (see Failure Handling)

**On Pi (Claude orchestrator):** The interactive Pi session **is** the Claude seat. Do **not** delegate the Claude vote to a Pi subagent (Pi's scoped subagents are OpenAI/Google, not Claude). Formulate your own Claude response directly in the parent session, and run the selected external CLI command(s) via `bash` in parallel using `"<work_dir>/prompt.txt"`.

**On Codex:** The current session is the Codex seat. Record the session's actual model/effort. Launch the selected external CLI(s) (Claude and/or Gemini) using `"<work_dir>/prompt.txt"`. For Claude JSON output (`claude -p ... --output-format json`), check `is_error` before normalizing.

**On Gemini CLI / `agy`:** Check the active model family first (`agy` can run Claude or Gemini models). Count the host under its actual model family so Claude is never double-counted, and launch only external advisor(s) from the other family/families using `"<work_dir>/prompt.txt"`.

**Pinned model IDs:** If a pinned id (e.g. `gemini-4-neon`) is retired or rejected, mark that seat `unavailable` — do **not** silently substitute another model.

**Advisor prompt format:** Include the user's question + gathered context. Ask each advisor to state: assumptions, information gaps, implications (especially irreversible), and evidence basis.

**Capability framing per provider:**
- Gemini: "You have native web search. Cite sources."
- Codex: "You can execute shell commands. Verify claims by running code."
- Claude: (already has project context when host; external CLI gets only the gathered prompt)

### Step 3: Normalize Results

Every advisor response becomes:

```yaml
advisor_id: "gemini|codex|claude"
model: "resolved model id that actually answered"
effort: "resolved effort, or default/unknown for gemini"
status: "ok|unavailable|blocked|failed"
summary: "1-3 sentence essence of the advisor's position"
assumptions: ["beliefs taken for granted in this response"]
information_gaps: ["what the advisor didn't know or couldn't verify"]
implications: ["consequences if this advice is followed, especially hard-to-reverse ones"]
evidence_basis: ["sources cited, code inspected, commands run, docs referenced"]
content: "full response or unavailability message"
```

Populated only when status is `ok`. Omit for other statuses. Always record resolved `model` + `effort`.

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
**Advisors**: [populate only from seats actually queried, e.g. claude (ok, claude-fable-5-2@medium), codex (ok, gpt-6.2-astra@high), gemini (not requested)]
**Decision**: [optional — concrete choice, if one emerged]
**Predictions**: [optional — expected outcomes]
**Confidence**: [optional — high | medium | low]
**Tags**: [optional — scope tags: backend, architecture, testing, etc.]

## Synthesis
[Narrative: agreement, disagreement, recommendation, remaining uncertainty]

## Claude
[Narrative: position, reasoning, assumptions, gaps, evidence — or "Not requested (2-seat panel)."]

## Gemini
[same, or "Not requested (2-seat panel)."]

## Codex
[same, or failure note / "Not requested (2-seat panel)."]

```

Always use `## Synthesis`, `## Claude`, `## Gemini`, and `## Codex` headers (grep anchors for seance). Optional header fields only when synthesis produced a clear decision. Write sections as natural prose. Never persist secrets or credentials.

## Failure Handling

| Error Type | Action | Why |
|---|---|---|
| Local permission / sandbox / "denied by policy" | **STOP** — show setup guidance | Host tool policy blocks multi-perspective value; single-advisor fallback is just a normal conversation. Do **not** treat provider content refusal or model entitlement the same way. |
| 429 / capacity | Wait 60s → retry → proceed without that seat | Transient provider load |
| Gemini: "must specify GEMINI_API_KEY" (code 41) | Confirm `--sandbox` is not passed and that Gemini CLI is configured for API-key mode with a paid `GEMINI_API_KEY` (do not fall back to consumer Antigravity OAuth for headless third-party orchestration). If auth is still absent, mark the Gemini seat `unavailable` and ask the user to configure their API key outside the session. | |
| Gemini: "not running in a trusted directory" | Confirm the command `cd`s into the clean empty `<work_dir>/run` outside the reviewed repo and passes `--skip-trust` for that invocation only. | |
| Fable model unavailable / not entitled | Mark the Claude seat `unavailable`; do not substitute another model | Pinned model unavailable |
| Provider content refusal | Mark seat `failed`; continue with remaining advisors | Not a local permission problem |
| Other CLI auth failure | Ask the user to authenticate outside the agent session; mark seat `unavailable` | |
| CLI not found | State the missing CLI; proceed only if at least two advisors remain | |
| Network error | Retry once, then mark unavailable | |
| Pinned model id retired / rejected | Mark seat `unavailable`; no silent model substitution | Model IDs change |

**Degraded council rules:**
- Full requested quorum (2/2 on default `--panel`, or 3/3 on `--full` / `magi`) → full synthesis
- 2-seat panel with external seat failed (429/network/unavailable):
  - If `--with` explicitly named that advisor, report the failure and offer the other external family before sending excerpts to a different provider.
  - On an unpinned 2-seat panel, offer the other external family (especially when switching to metered Gemini). If the failure was missing credentials/auth (`unavailable`) and no replacement is run, stop and ask the user to authenticate outside the session; if the failure was capacity/network and no replacement is run, proceed host-only and state it is single-advisor.
- 2/3 on `--full` → partial synthesis, note who's missing and why
- 1 seat (host-only) → only when external failures are capacity/network (not missing auth or local policy); state clearly that it is single-advisor
- Local permission blocked → **STOP**. On Claude Code, show setup message: add `"Bash(gemini *)"`, `"Bash(codex *)"`, and (when Claude is external) `"Bash(claude *)"` to `.claude/settings.local.json` permissions.allow. On Pi or Codex hosts, show the host's shell/sandbox approval guidance instead.

## Usage Examples

When `$ARGUMENTS` is empty, show:

```
Usage:
  counsel --panel "prompt"           # 2-seat panel (host + 1 external family)
  counsel --panel --with gemini "…"  # 2-seat panel with explicit external seat
  counsel --panel --full "prompt"    # 3-seat panel (Claude + Codex + Gemini)
  magi "prompt"                      # Alias for 3-seat panel
  magi --debate "prompt"             # 3-seat panel with anonymized critique round
```

## References

- `magi` remains an alias for the full 3-seat panel workflow (`counsel --panel --full`).
