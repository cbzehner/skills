#!/usr/bin/env bash
# Backfill traces from existing Claude Code session logs.
# Feeds each session through trace-collector.sh via its stdin interface.
#
# Usage:
#   ./backfill.sh              # process all sessions
#   ./backfill.sh --dry-run    # show what would be processed, don't call claude
#   ./backfill.sh --limit 5    # process only 5 sessions (for testing)

set -uo pipefail
# Note: no -e — we handle errors per-session, not globally

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COLLECTOR="$SCRIPT_DIR/trace-collector.sh"
TRACES_DIR="$HOME/.claude/evolver/traces"
PROJECTS_DIR="$HOME/.claude/projects"

DRY_RUN=false
LIMIT=0
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run) DRY_RUN=true; shift ;;
    --limit) LIMIT="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Collect all existing trace session_ids to skip duplicates
EXISTING_IDS=""
if [ -d "$TRACES_DIR" ]; then
  EXISTING_IDS=$(cat "$TRACES_DIR"/*.jsonl 2>/dev/null | jq -r '.session_id' 2>/dev/null | sort -u) || true
fi

processed=0
skipped=0
errors=0
total=0

for session_file in "$PROJECTS_DIR"/*/*.jsonl; do
  [ -f "$session_file" ] || continue
  total=$((total + 1))

  # Extract session_id from filename (UUID before .jsonl)
  filename=$(basename "$session_file" .jsonl)
  session_id="$filename"

  # Skip if already traced
  if echo "$EXISTING_IDS" | grep -qx "$session_id" 2>/dev/null; then
    skipped=$((skipped + 1))
    continue
  fi

  # Check session has user messages (skip empty/tiny sessions)
  user_count=$(jq -c 'select(.type == "user")' "$session_file" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$user_count" -lt 1 ]; then
    skipped=$((skipped + 1))
    continue
  fi

  # Check limit
  if [ "$LIMIT" -gt 0 ] && [ "$processed" -ge "$LIMIT" ]; then
    break
  fi

  if $DRY_RUN; then
    # Extract first user message — handle both string and array content formats
    first_msg=$(jq -r '
      select(.type == "user") | .message.content |
      if type == "string" then .
      elif type == "array" then
        [.[]? | if type == "string" then . elif type == "object" and .type == "text" then .text else empty end] | join(" ")
      else empty end
    ' "$session_file" 2>/dev/null | head -1 | head -c 80) || true
    echo "[$session_id] ($user_count msgs) $first_msg"
    processed=$((processed + 1))
    continue
  fi

  # Feed to trace collector
  echo "Processing $session_id ($user_count user msgs)..."
  if printf '{"session_id":"%s","transcript_path":"%s"}' "$session_id" "$session_file" | "$COLLECTOR" 2>/dev/null; then
    processed=$((processed + 1))
  else
    echo "  ERROR: failed to process $session_id"
    errors=$((errors + 1))
  fi

  # Brief pause to avoid hammering the API
  sleep 1
done

echo ""
echo "Done. Total: $total, Processed: $processed, Skipped: $skipped, Errors: $errors"
if [ -d "$TRACES_DIR" ]; then
  trace_count=$(cat "$TRACES_DIR"/*.jsonl 2>/dev/null | wc -l | tr -d ' ') || true
  echo "Total traces in store: ${trace_count:-0}"
fi
