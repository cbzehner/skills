#!/usr/bin/env bash
# Approximate usage stats for a skill from local agent transcripts:
# Claude Code (~/.claude/projects) and Codex (~/.codex/sessions).
# Session-level greps, not telemetry — treat as directional.
# Can take a minute on large transcript histories.
#
# Skill descriptions appear in every session's skill listing, so bare name
# mentions overcount badly (especially in Codex logs). Invocations use
# explicit markers; body loading is detected via fingerprints — distinctive
# SKILL.md body phrases listed one per line in <skill-dir>/tests/fingerprints.txt.
set -euo pipefail
NAME="${1:?usage: usage-stats.sh <skill-name>}"
SKILL_DIR="$HOME/.claude/skills/$NAME"
FINGERPRINTS="$SKILL_DIR/tests/fingerprints.txt"

count_sessions() { # <dir> <extended-regex>
  [ -d "$1" ] || { echo 0; return; }
  grep -rlE "$2" "$1" --include='*.jsonl' 2>/dev/null | wc -l | tr -d ' '
}

count_sessions_fixed() { # <dir> <fixed-string>
  [ -d "$1" ] || { echo 0; return; }
  grep -rlF "$2" "$1" --include='*.jsonl' 2>/dev/null | wc -l | tr -d ' '
}

count_rereads() { # <dir> <fixed-string> — sessions hitting the string 2+ times
  [ -d "$1" ] || { echo 0; return; }
  grep -rcF "$2" "$1" --include='*.jsonl' 2>/dev/null | awk -F: '$NF > 1' | wc -l | tr -d ' '
}

report() { # <label> <transcript-dir> <invoke-regex or "">
  local label="$1" dir="$2" invoke="$3"
  echo "## $label"
  if [ ! -d "$dir" ]; then
    echo "(no transcripts found at $dir)"
    return
  fi
  if [ -n "$invoke" ]; then
    echo "sessions invoking the skill: $(count_sessions "$dir" "$invoke")"
  else
    echo "(no reliable invocation marker in this harness — listings mention every skill's path; trust the fingerprints)"
  fi
  if [ -f "$FINGERPRINTS" ]; then
    echo "sessions where the body actually loaded (fingerprints):"
    while IFS= read -r fp; do
      [ -n "$fp" ] || continue
      echo "  $(count_sessions_fixed "$dir" "$fp")  \"$fp\""
    done < "$FINGERPRINTS"
  fi
  if [ -d "$SKILL_DIR/references" ]; then
    echo "reference files: sessions-read / sessions-re-read (2+ reads in one session signals structure problems):"
    for f in "$SKILL_DIR"/references/*.md; do
      [ -e "$f" ] || continue
      local b
      b=$(basename "$f")
      echo "  $(count_sessions_fixed "$dir" "$NAME/references/$b") / $(count_rereads "$dir" "$NAME/references/$b")  $b"
    done
  fi
}

report "Claude Code (~/.claude/projects)" "$HOME/.claude/projects" "Launching skill: $NAME|\"skill\": ?\"$NAME\""
echo
report "Codex (~/.codex/sessions)" "$HOME/.codex/sessions" ""
