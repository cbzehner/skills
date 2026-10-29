---
name: nix-infrastructure
description: >-
  Guides Nix, NixOS, nix-darwin, and Home Manager configuration changes,
  package or option lookup, flake evaluation, builds, and deployment rollback.
  Use when declarative Nix ownership or pinned-input compatibility matters,
  not merely because an application runs on a Nix host.
license: MIT
metadata:
  author: cbzehner
  version: "0.1.0"
  reviewed: "2026-10-28"
---

# Nix infrastructure

A public option listing is a lead, not evidence about the locked configuration.

## Inputs and result

Establish the target host, architecture, configuration repository, selected
output, and whether the request includes activation. Produce a scoped Nix
change or diagnosis, the checks actually run, and activation/rollback limits.

## Workflow

1. **Identify the owner.** Distinguish NixOS, nix-darwin, standalone Home Manager,
   and Home Manager embedded in a system configuration. Inspect the repository's
   entry points and deployment commands; do not assume `/etc/nixos`, a hostname,
   or that the current machine is the deployment target. On macOS, do not assume
   systemd is available.
2. **Resolve the pinned definitions.** Read `flake.lock`, input relationships,
   modules, and existing option usage. If MCP-NixOS is available, discover its
   tools through the client's tool search and query the appropriate source:
   `nixos`, `home-manager`, or `darwin`. Public results can be newer than the lock.
   Confirm option type/defaults and package/platform support using the pinned
   source or targeted evaluation. If lookup fails, report the failure rather
   than invent an attribute. Prefer explicit store reads; do not use an MCP
   `flake-inputs` action unless its local side effects are understood.
3. **Edit the declarative source.** Preserve unrelated work and mutable secrets.
   Do not edit Nix-store files or generated service/configuration files as the
   permanent fix. Keep credentials out of expressions, build output, and the
   world-readable store. Change only the required input when updating a lock;
   inspect the diff for unrelated revision changes.
4. **Validate without activation first.** Parse/format the touched files, evaluate
   the exact target, then run relevant checks or build that target. Check command
   syntax against the installed CLI. Evaluation, build, and activation are three
   different claims. Flake commands can fetch dependencies or change a lockfile;
   use `--no-write-lock-file` when supported and inspect the working tree afterward.
   Avoid evaluating untrusted flakes or import-from-derivation merely to inspect
   metadata. Bound builds and report missing caches/platform support honestly.
5. **Activate only within scope.** Before a remote networking, firewall, SSH, or
   boot change, identify an independent console/recovery route and retain a
   known-good generation. Do not drop the working SSH session before testing a
   second connection. A successful build does not prove remote access survives.
   Name the actual platform-specific activation and rollback commands from the
   installed tools/repo, rather than substituting `nixos-rebuild` on a Mac.

Rollback restores a generation, not external data: database migrations, volume
contents, credentials, and remote resources need their own recovery plan.

## When NOT to use

- Ordinary application debugging with no Nix packaging/configuration issue.
- Linux service runtime diagnosis where no declarative change is needed; use
  `linux-systemd`. For customer impact, let `sre-incident-response` lead.

## What to skip

Do not update every input, rebuild every host, activate a new generation, or
collect old generations just to answer an option question. Do not bypass a
failed check with an imperative package install unless explicitly requested.

## Handoffs

Use `podman-quadlet` for container-unit semantics and this skill for Nix ownership.
If the target or activation boundary is missing, inspect repository conventions;
ask only when the remaining choice materially affects the change.

## Sources

Original local guidance; references reviewed on the metadata date. Installed
versions and locked source definitions take precedence over these moving docs.

- [Nix manual](https://nix.dev/manual/nix/stable/)
- [NixOS manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager manual](https://nix-community.github.io/home-manager/)
- [nix-darwin manual](https://nix-darwin.github.io/nix-darwin/manual/)
