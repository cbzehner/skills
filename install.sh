#!/usr/bin/env bash
set -euo pipefail

# Install the active skills (manifest.txt) into common agent skill directories.
# Usage:
#   ./install.sh                      # symlink all manifest skills to Claude, Codex, and generic agents
#   ./install.sh claude               # ~/.claude/skills
#   ./install.sh codex                # ~/.codex/skills
#   ./install.sh agents               # ~/.agents/skills (generic/Pi/Hermes-style harnesses)
#   ./install.sh opencode             # ~/.config/opencode/skills
#   ./install.sh claude seance qmd    # only the named skills
#   ./install.sh agents --manifest infrastructure-manifest.txt  # selected pack
#   ./install.sh all --copy           # copy instead of symlink
#   ./install.sh all --force          # replace an existing non-symlink destination

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TARGET="all"
MODE="symlink"
FORCE=0
MANIFEST="$REPO_DIR/manifest.txt"
EXPLICIT_MANIFEST=0
NAMES=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    claude|codex|agents|opencode|all) TARGET="$1" ;;
    --copy) MODE="copy" ;;
    --force) FORCE=1 ;;
    --manifest)
      if [ "$#" -lt 2 ] || [ -z "$2" ] || [[ "$2" == --* ]]; then
        echo "--manifest requires a file path" >&2
        exit 2
      fi
      MANIFEST="$2"
      [[ "$MANIFEST" == /* ]] || MANIFEST="$REPO_DIR/$MANIFEST"
      EXPLICIT_MANIFEST=1
      shift
      ;;
    -h|--help) sed -n '4,14p' "$0" | sed 's/^# *//'; exit 0 ;;
    --*) echo "unknown option: $1" >&2; exit 2 ;;
    *) NAMES+=("$1") ;;
  esac
  shift
done

if [ "$EXPLICIT_MANIFEST" -eq 1 ] && [ "${#NAMES[@]}" -gt 0 ]; then
  echo "choose --manifest or explicit skill names, not both" >&2
  exit 2
fi

if [ "${#NAMES[@]}" -eq 0 ]; then
  if [ ! -f "$MANIFEST" ] || [ ! -r "$MANIFEST" ]; then
    echo "manifest is not a readable file: $MANIFEST" >&2
    exit 1
  fi
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in ""|\#*) continue ;; esac
    NAMES+=("$line")
  done < "$MANIFEST"
fi

if [ "${#NAMES[@]}" -eq 0 ]; then
  echo "no skills selected: $MANIFEST"
  exit 0
fi

# Reject path traversal and incomplete packs before installing any of their links.
for name in "${NAMES[@]}"; do
  if [[ ! "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || [ "${#name}" -gt 64 ]; then
    echo "invalid skill name: $name" >&2
    exit 2
  fi
  if [ "$EXPLICIT_MANIFEST" -eq 1 ] && [ ! -f "$REPO_DIR/skills/$name/SKILL.md" ]; then
    echo "missing manifest skill: $name" >&2
    exit 1
  fi
done

case "$TARGET" in
  claude) DESTS=("$HOME/.claude/skills") ;;
  codex) DESTS=("$HOME/.codex/skills") ;;
  agents) DESTS=("$HOME/.agents/skills") ;;
  opencode) DESTS=("$HOME/.config/opencode/skills") ;;
  all) DESTS=("$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.agents/skills") ;;
esac

install_one() {
  local dest_dir="$1" name="$2"
  local src="$REPO_DIR/skills/$name"
  local target="$dest_dir/$name"

  if [ ! -d "$src" ]; then
    echo "skip $name: not found under skills/ (archived skills are not installable)" >&2
    return 0
  fi
  mkdir -p "$dest_dir"

  if [ "$MODE" = "symlink" ] && [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
    return 0
  fi

  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ "$FORCE" -eq 1 ] || [ -L "$target" ]; then
      rm -rf "$target"
    else
      echo "skip $target: exists and is not a symlink (use --force to replace)" >&2
      return 0
    fi
  fi

  if [ "$MODE" = "copy" ]; then
    cp -R "$src" "$target"
  else
    ln -s "$src" "$target"
  fi
  echo "installed $name -> $target ($MODE)"
}

for dest in "${DESTS[@]}"; do
  for name in "${NAMES[@]}"; do
    install_one "$dest" "$name"
  done
done
