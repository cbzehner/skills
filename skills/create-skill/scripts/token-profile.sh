#!/usr/bin/env bash
# Token profile for a skill directory, split by load tier:
# frontmatter (always in the skill listing), SKILL.md (every invocation),
# references/*.md (on demand). Uses tiktoken o200k_base via uv.
set -euo pipefail
DIR="${1:?usage: token-profile.sh <skill-dir>}"
export UV_CACHE_DIR="${UV_CACHE_DIR:-/tmp/uvcache}"
exec uv run --quiet --with tiktoken python3 - "$DIR" <<'EOF'
import glob, os, sys
import tiktoken

enc = tiktoken.get_encoding("o200k_base")
base = os.path.abspath(os.path.expanduser(sys.argv[1]))
skill = os.path.join(base, "SKILL.md")
if not os.path.exists(skill):
    sys.exit(f"no SKILL.md in {base}")

def tokens(path):
    with open(path, encoding="utf-8") as f:
        return len(enc.encode(f.read()))

text = open(skill, encoding="utf-8").read()
parts = text.split("---")
frontmatter = parts[1] if len(parts) > 2 else ""
print(f"{len(enc.encode(frontmatter)):6d}  frontmatter (always loaded in skill listing)")

total = tokens(skill)
print(f"{total:6d}  SKILL.md (loaded every invocation)")
for path in sorted(glob.glob(os.path.join(base, "references", "*.md"))):
    n = tokens(path)
    total += n
    print(f"{n:6d}  references/{os.path.basename(path)} (loaded on demand)")
print(f"{total:6d}  TOTAL")
EOF
