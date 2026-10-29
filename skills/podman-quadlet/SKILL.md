---
name: podman-quadlet
description: >-
  Authors and diagnoses Podman Quadlet container, network, and volume units,
  including rootless lifecycle, generated services, readiness, and image
  rollback. Use for Quadlet or systemd-managed Podman, not generic Docker
  Compose, Kubernetes, or unrelated systemd services.
license: MIT
metadata:
  author: cbzehner
  version: "0.1.0"
  reviewed: "2026-10-28"
---

# Podman and Quadlet

The Quadlet source is durable; the generated service is diagnostic output.

## Inputs and result

Identify the Linux execution host, owning user, rootless/rootful mode, Podman
and systemd versions, image, persistent data, and desired lifecycle. Produce
source-unit changes with generator validation and a verified recovery plan.

## Workflow

1. **Establish the runtime.** Check installed versions, cgroup v2 support, and
   whether Podman targets a remote machine. On macOS, locate the Linux VM/host;
   do not treat a local directory as its systemd configuration. Rootless and
   rootful Podman have separate state. Use the owning user's manager and storage
   consistently, not `sudo podman` as a shortcut to inspect rootless containers.
2. **Locate the real sources.** Consult the installed Quadlet manual for search
   paths and supported keys. Common roots are `~/.config/containers/systemd/`
   for a user and `/etc/containers/systemd/` for the system; include XDG overrides
   and drop-ins in the inspection. On NixOS, change the owning module or
   declaratively managed source. Do not edit generated `.service` files.
3. **Model dependencies and data.** Distinguish a literal runtime network/volume
   name from a reference to a `.network`/`.volume` Quadlet file; verify the
   generated dependency rather than guessing the generated name. Ordering is
   not readiness. Pin an image version or digest, identify writable mounts,
   UID mappings, ports/bind addresses, and relevant SELinux labels. Prefer
   supported secret references to embedding credentials in unit/environment
   text. Do not add privileged mode or broad host mounts to bypass a failure.
4. **Validate generation before start.** Find the installed Podman generator;
   its path varies by distribution and packaging. Use its supported `--dryrun`
   and `--user` options for the intended scope, with `QUADLET_UNIT_DIRS` pointing
   at an isolated candidate directory when appropriate. Inspect generated units
   and diagnostics; verify with the target systemd where possible. A missing
   service often means the generator rejected an unsupported key, not that
   systemd needs reinstalling. Report when target-host validation is unavailable.
5. **Apply the intended lifecycle.** Define persistence in the source's
   `[Install]` section: typically `WantedBy=default.target` for a user or
   `multi-user.target` for the system. Do not run `systemctl enable` on generated
   transient services. Reload the correct manager, then start/restart only the
   requested unit. User lingering changes boot/logout behavior; inspect it and
   enable it only when persistence beyond login is requested. A rootful unit's
   `User=` is not a substitute for a rootless Quadlet.
6. **Verify and retain rollback.** Check unit state, bounded journal output,
   container health, and an external readiness check. Account for image-pull
   latency in startup timeouts. Preserve the prior image digest and unit source;
   rolling back an image does not roll back a data migration. Test persistent
   data and backup assumptions separately before updates or recovery actions.

## When NOT to use

- Plain systemd units with no Podman generator; use `linux-systemd`.
- Docker Compose or Kubernetes manifests without an explicit Quadlet migration.

## What to skip

No `podman system prune`, volume removal, automatic image updates, container
recreation, or lingering changes as exploratory diagnostics.

## Handoffs

Use `nix-infrastructure` for Nix ownership/activation and `linux-systemd` for
runtime evidence after generation succeeds. Active outages also need
`sre-incident-response` for impact and mitigation criteria.

## Sources

Original local guidance; moving upstream manual reviewed on the metadata date.
Validate keys and generator capabilities against the installed Podman release.

- [Quadlet manual](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
- [Podman documentation](https://docs.podman.io/en/latest/)
