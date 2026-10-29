# Infrastructure skill pack

A small, independently selected pack for operational work. It does **not** enable
the workflow collection in `manifest.txt`, introduce an agent runtime, or install
provider CLIs. The guidance is locally authored from official references linked
in each skill; moving documentation must be checked against the target version.

## Scope and routing

| Skill | Owns | Does not own |
| --- | --- | --- |
| `nix-infrastructure` | Pinned Nix/NixOS/nix-darwin/Home Manager configuration, evaluation, builds, safe activation and rollback | Every application incident merely because its host uses Nix |
| `hetzner-operations` | Cloud/Robot identity, provider resources, networking, recovery and backup boundaries | Ordinary guest-OS failures with no provider symptom |
| `linux-systemd` | Linux runtime evidence, the correct system/user manager, units, timers and resource pressure | macOS launchd, Quadlet generator authoring or incident-wide coordination |
| `podman-quadlet` | Rootless/rootful Podman units, generator validation, lifecycle and data-aware image rollback | General Compose or Kubernetes authoring |
| `sre-incident-response` | Customer impact, coordinated mitigation, recovery evidence, postmortems and SLO budgeting | Routine application debugging or isolated development-host work |

Load the narrow owner first. Add a handoff when the task crosses surfaces:
incident coordination can use the Linux, provider or container skill for bounded
evidence; declarative configuration changes belong in their Nix source. A
provider name, container mention or Nix development shell alone is not a trigger.

The files are portable guidance, not authorization to mutate infrastructure.
Read-only inspection should precede changes; access, persistent data, costs and
recovery are explicit boundaries. Nix public search results are leads rather than
proof about a locked input. Server backups do not imply attached-volume coverage;
image or generation rollback does not reverse database migrations.

## Install and remove

From the repository root:

```bash
./install.sh agents --manifest infrastructure-manifest.txt
./install.sh claude --manifest infrastructure-manifest.txt
```

The shared target serves compatible harnesses including Pi and Codex. Do not
also install Codex-specific copies when that harness already discovers shared
skills. Avoid `./install.sh all` without a manifest: it selects the independent
workflow collection, not this pack. The installer preserves existing non-symlink
destinations unless `--force` is supplied; it can replace foreign symlinks, so
inspect existing entries before manual installation. A correct selected link is
unchanged on a repeat run. `--copy` produces a snapshot that needs manual updates.

An explicit manifest is preflighted in full before links are created. Missing,
unreadable, invalid or incomplete manifests fail; an empty manifest installs
nothing. Paths in the manifest are skill names, not arbitrary filesystem paths.
Relative manifest filenames resolve against the repository, not the caller's
working directory. Do not combine `--manifest` with explicit skill names.

For Nix-managed installations, disable the owning activation or remove a name
from its selected manifest **as well as** removing its installed links. The Nix
activation preserves all conflicting destinations and does not prune old links
when a manifest shrinks. Editing a manifest alone is not an uninstall.

For a manual symlink installation, inspect and remove only links that resolve to
this checkout's selected source directories. Do not recursively delete a skills
directory or overwrite another installation. Copies require explicit comparison
and removal. Refresh discovery after changing links (`/reload` in Pi; restart
other harnesses if required). Existing sessions may retain already-loaded text.

## Deterministic checks

```bash
python3 -m unittest discover -s tests -p 'test_infrastructure.py' -v
# Also check the stock Bash on macOS:
INSTALLER_BASH=/bin/bash python3 -m unittest discover -s tests -p 'test_infrastructure.py' -v
```

The 12 tests cover structure, metadata, source links, fingerprints, separate
selection, probe panels, installer compatibility, default/named installs,
manifest parsing, no partial pack installation, path traversal, collisions,
explicit copy/force, and idempotence. Installer tests use temporary repositories
and homes, never the operator's actual discovery directories.

Probe panels use JSON-compatible YAML to avoid a parser dependency. Each skill
has six positive cases and four annotated near misses in `tests/probes.yaml`.
`tests/fingerprints.txt` contains literal body excerpts for load instrumentation;
the routing test intentionally does not see them or the skill bodies.
Behavioral prompts and criteria are in `tests/infrastructure-behavior.json`.

## Evaluation snapshot — 2026-10-28

This is an initial, author-designed regression set, **not** a held-out benchmark
or evidence of production reliability. Pi 1.4.0 used native subscription-backed
`openai/gpt-6.1-terra`, minimal thinking, and isolated no-tools/no-session calls.
Extensions, ambient context files, prompt templates and automatic skill loading
were disabled for inference. Model settings and credentials were not rewritten.

### Description-only routing

Each prompt independently selected a first skill or no match from all 19
actually discovered skill descriptions, including the other 14 existing skills.
The full body, expected label and near-miss annotation were hidden from the
model. One run produced:

| Panel | Correct first skill | Target precision / recall / F1 |
| --- | ---: | --- |
| Nix infrastructure | 10/10 | 1.00 / 1.00 / 1.00 |
| Hetzner operations | 10/10 | 1.00 / 1.00 / 1.00 |
| Linux/systemd | 10/10 | 1.00 / 1.00 / 1.00 |
| Podman/Quadlet | 10/10 | 1.00 / 1.00 / 1.00 |
| SRE incident response | 10/10 | 1.00 / 1.00 / 1.00 |

That is 50/50 expected first choices across 30 positives and 20 near misses. It
measures declared routing, not whether an agent really reads a skill during a
normal work session. Separate offline discovery confirmed five unique new skills
and no duplicate copies. Future evaluations should add unseen ambiguous tasks,
other models and actual load instrumentation.

### Safety behavior

Five isolated prompts loaded one complete body each and requested a plan under
unsafe pressure: losing SSH/recovery generations, duplicate provisioning and
volume-backup assumptions, the wrong systemd manager and evidence deletion,
enabling generated units and pruning volumes, and premature incident recovery
with incorrect budget math. Four criteria were set per scenario before its run.

Manual review scored the initial responses 19/20: the SRE response referred to an
"agreed" observation interval without naming its duration or missing baseline.
The skill was tightened to require a duration justified by traffic/failure cadence
or the specific missing baseline. That criterion was clarified before a final
follow-up, which explicitly named the missing normal-traffic and failure-cadence
evidence and kept the incident open. The other four scenarios met all criteria.
Final review met 20/20 **with that documented criterion revision**; the follow-up
is developmental evidence, not a fresh held-out result. No tool calls or
infrastructure changes were made by these evaluations.

### Size budget

Approximate tokens below use characters divided by four, rounded up—not a model
tokenizer. L0 counts only the description; L1 is the complete body after
frontmatter. All five descriptions total approximately 330 tokens, excluding
harness wrappers. There is no automatically loaded L2 reference tier; official
references are retrieved only when needed.

| Skill | L0 estimate | L1 estimate |
| --- | ---: | ---: |
| Nix infrastructure | 69 | 1,016 |
| Hetzner operations | 61 | 990 |
| Linux/systemd | 59 | 973 |
| Podman/Quadlet | 68 | 1,006 |
| SRE incident response | 73 | 1,072 |

## Integration evidence and limits

The host's generated Nix activation was evaluated and tested in isolated homes
under Bash 5.3 and macOS Bash 3.2: exactly the selected shared/Claude links,
correct-link idempotence, preservation of directories and foreign/broken links,
missing/empty/invalid/incomplete manifest skips, and no Codex-specific duplicates.
Home Manager's `run` helper guards directory/link writes; dry-run tests confirmed
that even absent discovery directories are not created.
All five Darwin host configurations evaluated; the unmanaged host omitted the
activation. Nix formatting, syntax and lint checks passed. Fresh Pi discovery
increased from 14 to 19 without enabling the workflow collection or archived
Clerk skills; pre-existing unrelated edits were verified unchanged.

No real Linux systemd, Podman/Quadlet, Hetzner action, SSH cutover, volume restore,
or database rollback was tested on the macOS authoring host. Neither the model
checks nor configuration evaluation substitutes for read-only checks on the
actual target, followed by an authorized, recoverable staged test. There is no
measured before/after incident-resolution or coding-productivity improvement.
