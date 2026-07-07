#!/usr/bin/env bash
# Token profile for a skill directory, split by load tier:
# frontmatter (always in the skill listing), SKILL.md (every invocation),
# references/*.md (on demand). Uses tiktoken o200k_base when available and
# falls back to a rough byte-based estimate when local tokenization is missing.
set -euo pipefail
DIR="${1:?usage: token-profile.sh <skill-dir>}"
export UV_CACHE_DIR="${UV_CACHE_DIR:-/tmp/uvcache}"
if command -v uv >/dev/null 2>&1; then
  runner=(uv run --quiet --with tiktoken python3)
else
  runner=(python3)
fi
exec "${runner[@]}" - "$DIR" <<'EOF'
import glob, os, sys
try:
    import tiktoken
except Exception:
    tiktoken = None

enc = tiktoken.get_encoding("o200k_base") if tiktoken else None
base = os.path.abspath(os.path.expanduser(sys.argv[1]))
skill = os.path.join(base, "SKILL.md")
if not os.path.exists(skill):
    sys.exit(f"no SKILL.md in {base}")

def count_text(text):
    if enc:
        return len(enc.encode(text))
    return max(1, (len(text.encode("utf-8")) + 3) // 4)

def tokens(path):
    with open(path, encoding="utf-8") as f:
        return count_text(f.read())

text = open(skill, encoding="utf-8").read()
parts = text.split("---")
frontmatter = parts[1] if len(parts) > 2 else ""
suffix = "" if enc else " (approx)"
print(f"{count_text(frontmatter):6d}  frontmatter (always loaded in skill listing){suffix}")

total = tokens(skill)
print(f"{total:6d}  SKILL.md (loaded every invocation){suffix}")
for path in sorted(glob.glob(os.path.join(base, "references", "*.md"))):
    n = tokens(path)
    total += n
    print(f"{n:6d}  references/{os.path.basename(path)} (loaded on demand){suffix}")
print(f"{total:6d}  TOTAL{suffix}")
EOF
