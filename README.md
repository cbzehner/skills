# Skills

Agent skills for Claude Code, Codex, and compatible harnesses — consolidated from the former one-repo-per-skill `skill-*` layout.

Active skills live under `skills/`, controlled by `manifest.txt`. Retired skills live under `archived/` for reference and revival; they are not installed.

## Install

```bash
git clone https://github.com/cbzehner/skills.git
cd skills
./install.sh all
```

Targets and options:

- `./install.sh claude` installs to `~/.claude/skills`
- `./install.sh codex` installs to `~/.codex/skills`
- `./install.sh agents` installs to `~/.agents/skills`
- `./install.sh opencode` installs to `~/.config/opencode/skills`
- `./install.sh claude seance qmd` installs only the named skills
- `--copy` copies instead of symlinking; `--force` replaces non-symlink destinations

Manual install works too: symlink or copy any `skills/<name>` directory into your agent's skills directory.

## Layout

```text
skills/<name>/SKILL.md        # active skills (see manifest.txt)
skills/<name>/references/     # on-demand reference files
skills/<name>/tests/          # trigger-selection probes (probes.yaml) and fingerprints
archived/<name>/              # retired skills, kept for reference
docs/                         # library-level docs (skill graph, plans)
manifest.txt                  # the active set install.sh symlinks by default
```

Each skill is self-contained: `SKILL.md` is its readme, and skills that borrow from external libraries carry their own Credits section.

## Evaluation

Skills are eval-gated using the `create-skill` skill's Step 8 protocol: token profiles by load tier, trigger-selection F1 from the `tests/probes.yaml` probe panels, and behavioral adherence against pre-registered criteria. Baseline results live in probe file header comments.

## Public Notes

This repo is public. Keep private repo names, secrets, customer data, raw logs, cookies, and absolute filesystem paths out of examples and probes — invent realistic stand-ins instead.

## History

Each skill's pre-consolidation history lives in its original archived repo at `github.com/cbzehner/skill-<name>`.

## License

MIT
