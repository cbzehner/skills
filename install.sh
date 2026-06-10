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
#   ./install.sh all --copy           # copy instead of symlink
#   ./install.sh all --force          # replace an existing non-symlink destination

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TARGET="all"
MODE="symlink"
FORCE=0
NAMES=()

for arg in "$@"; do
  case "$arg" in
    claude|codex|agents|opencode|all) TARGET="$arg" ;;
    --copy) MODE="copy" ;;
    --force) FORCE=1 ;;
    -h|--help) sed -n '2,14p' "$0" | sed 's/^# *//'; exit 0 ;;
    *) NAMES+=("$arg") ;;
  esac
done

if [ "${#NAMES[@]}" -eq 0 ]; then
  while IFS= read -r line; do
    [ -n "$line" ] && NAMES+=("$line")
  done < "$REPO_DIR/manifest.txt"
fi

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
