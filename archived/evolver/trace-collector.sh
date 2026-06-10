#!/usr/bin/env bash
# Evolver trace collector — Claude Code SessionEnd hook
#
# Hook input (stdin JSON): { session_id, transcript_path, cwd, reason }
# Output: appends one JSON line to ~/.claude/evolver/traces/YYYY-MM-DD.jsonl
#
# Can also be called directly for backfill:
#   echo '{"session_id":"x","transcript_path":"/path/to/session.jsonl"}' | ./trace-collector.sh

COLLECTOR_VERSION=2
set -euo pipefail

TRACES_DIR="$HOME/.claude/evolver/traces"
LOCK_FILE="$HOME/.claude/evolver/.collecting"

# Prevent recursive hook firing — claude -p spawns a session that triggers SessionEnd
# Use a lock file since env vars don't propagate to Claude Code hook subprocesses
if [ -f "$LOCK_FILE" ]; then
  exit 0
fi

mkdir -p "$TRACES_DIR"

# Read hook input from stdin
HOOK_INPUT=$(cat)

SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // empty' 2>/dev/null) || true
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // empty' 2>/dev/null) || true

if [ -z "$SESSION_ID" ]; then
  exit 0
fi

# --- Skip low-signal sessions ---
if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
  exit 0
fi

# Count user and assistant turns
USER_TURNS=$(jq -c 'select(.type == "user")' "$TRANSCRIPT_PATH" 2>/dev/null | wc -l | tr -d ' ') || true
ASSISTANT_TURNS=$(jq -c 'select(.type == "assistant")' "$TRANSCRIPT_PATH" 2>/dev/null | wc -l | tr -d ' ') || true

# Skip trivial sessions: < 2 user turns means no real back-and-forth
if [ "${USER_TURNS:-0}" -lt 2 ]; then
  exit 0
fi

# --- Extract transcript text ---
TRANSCRIPT=$(jq -r '
  select(.type == "user" or .type == "assistant") |
  if .type == "user" then
    "USER: " + (
      if (.message.content | type) == "string" then .message.content
      elif (.message.content | type) == "array" then
        [.message.content[]? |
          if type == "string" then .
          elif type == "object" and .type == "text" then .text
          else empty end
        ] | join("\n")
      else "" end
    )
  elif .type == "assistant" then
    "ASSISTANT: " + (
      [.message.content[]? |
        select(type == "object" and .type == "text") | .text
      ] | join("\n")
    )
  else empty end |
  select(. != "USER: " and . != "ASSISTANT: ")
' "$TRANSCRIPT_PATH" 2>/dev/null) || true

if [ -z "$TRANSCRIPT" ]; then
  exit 0
fi

TRANSCRIPT_CHARS=${#TRANSCRIPT}

# Derive date from transcript file modification time, fallback to today
# macOS native stat uses -f '%Sm', GNU stat uses -c. Try GNU first (nix), fallback to macOS.
DATE=$(date -d "@$(stat -c '%Y' "$TRANSCRIPT_PATH" 2>/dev/null)" +%Y-%m-%d 2>/dev/null) \
  || DATE=$(stat -f '%Sm' -t '%Y-%m-%d' "$TRANSCRIPT_PATH" 2>/dev/null) \
  || DATE=$(date +%Y-%m-%d)
OUTPUT_FILE="$TRACES_DIR/$DATE.jsonl"

# Truncate to keep the summarization call cheap (~8k chars)
TRANSCRIPT=$(printf '%s' "$TRANSCRIPT" | head -c 8000)

# --- Check for active principles to include in prompt ---
PRINCIPLES_CONTEXT=""
PRINCIPLES_FILE="$HOME/.claude/PRINCIPLES.md"
if [ -f "$PRINCIPLES_FILE" ]; then
  PRINCIPLES_CONTEXT="

The following principles were active during this session. Note which (if any) were relevant to the approaches taken or outcome:
<active_principles>
$(head -c 2000 "$PRINCIPLES_FILE")
</active_principles>
Include a \"principle_hits\" field (string[]) listing any principle IDs or short descriptions that were clearly applied, and \"principle_misses\" (string[]) for principles that were relevant but not followed."
fi

# --- Build extraction prompt ---
read -r -d '' COMBINED_PROMPT <<'PROMPT' || true
Extract a structured trace from this session transcript. Focus on:
- The concrete goal (what was the user trying to accomplish?)
- Approaches tried and pivots made (not tool calls or meta-chatter)
- Whether the goal was achieved and why/why not
- Domain tags for categorization

Output ONLY a single JSON object (no markdown fencing, no explanation) with these fields:

- "goal": string — what the session was trying to accomplish (1 sentence)
- "approaches": string[] — approaches tried, in order (1 phrase each, max 5)
- "outcome": "succeeded" | "partial" | "failed" | "abandoned"
- "tags": string[] — 1-3 domain tags from: backend, frontend, architecture, testing, tooling, workflow, infra, debugging, refactoring, documentation

Output raw JSON only. No markdown fencing. No explanation.

PROMPT
COMBINED_PROMPT="$COMBINED_PROMPT$PRINCIPLES_CONTEXT

<transcript>
$TRANSCRIPT
</transcript>"

# Set lock, clean up on exit
touch "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

# Use claude with no tools, capped budget
RAW=$(claude -p "$COMBINED_PROMPT" \
  --model haiku \
  --tools "" \
  --output-format json \
  --max-budget-usd 0.02 \
  < /dev/null 2>/dev/null) || true

rm -f "$LOCK_FILE"

# Extract the result text from claude's JSON envelope
RESULT_TEXT=""
if [ -n "$RAW" ]; then
  RESULT_TEXT=$(echo "$RAW" | jq -r '.result // empty' 2>/dev/null) || true
fi

# Strip markdown fencing if present
if [ -n "$RESULT_TEXT" ]; then
  STRIPPED=$(echo "$RESULT_TEXT" | sed -n '/^```/,/^```/{/^```/d;p;}')
  if [ -n "$STRIPPED" ]; then
    RESULT_TEXT="$STRIPPED"
  fi
fi

# Try to parse the result text as JSON
TRACE=""
if [ -n "$RESULT_TEXT" ]; then
  TRACE=$(echo "$RESULT_TEXT" | jq -e '.' 2>/dev/null) || true
fi

# Fallback: extract goal from first user message
if [ -z "$TRACE" ] || ! echo "$TRACE" | jq -e '.goal' >/dev/null 2>&1; then
  GOAL=$(printf '%s' "$TRANSCRIPT" | grep -m1 '^USER:' | sed 's/^USER: //' | head -c 200) || true
  [ -z "$GOAL" ] && GOAL="unknown"
  TRACE=$(jq -n --arg goal "$GOAL" '{
    "goal": $goal,
    "approaches": [],
    "outcome": "unknown",
    "tags": []
  }')
fi

# Wrap with provenance fields and append
echo "$TRACE" | jq -c \
  --arg sid "$SESSION_ID" \
  --arg date "$DATE" \
  --argjson user_turns "${USER_TURNS:-0}" \
  --argjson assistant_turns "${ASSISTANT_TURNS:-0}" \
  --argjson transcript_chars "${TRANSCRIPT_CHARS:-0}" \
  --argjson collector_version "$COLLECTOR_VERSION" \
'{
  "session_id": $sid,
  "date": $date,
  "goal": .goal,
  "approaches": (.approaches // []),
  "outcome": (.outcome // "unknown"),
  "active_principle_ids": [],
  "principle_hits": (.principle_hits // []),
  "principle_misses": (.principle_misses // []),
  "tags": (.tags // []),
  "meta": {
    "user_turns": $user_turns,
    "assistant_turns": $assistant_turns,
    "transcript_chars": $transcript_chars,
    "collector_version": $collector_version
  }
}' >> "$OUTPUT_FILE"
