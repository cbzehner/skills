---
name: linux-systemd
description: >-
  Diagnoses Linux host and systemd service failures, unit dependencies,
  timers, journals, and resource pressure. Use for host/runtime evidence
  or unit changes; not macOS launchd, Quadlet generator authoring, or
  incident-wide coordination.
license: MIT
metadata:
  author: cbzehner
  version: "0.1.0"
  reviewed: "2026-10-28"
---

# Linux and systemd

Capture the failure state before a restart destroys the evidence.

## Inputs and result

Establish the target host, distribution/version, unit or symptom, time window,
manager scope, and allowed changes. Return a bounded diagnosis or unit change,
the supporting observations, and a concrete verification/rollback path.

## Workflow

1. **Choose the correct manager.** Read `/etc/os-release`, check the running init
   system and installed systemd version, and distinguish the system manager
   from a particular user's manager. Use `systemctl --user` only in the intended
   user's context; adding `sudo` can silently select a different manager. A
   Linux container may not run systemd, and a macOS host uses other facilities.
2. **Collect focused evidence.** Inspect `systemctl status`, `systemctl show`,
   `systemctl cat`, and a bounded `journalctl` query for the exact unit and time
   range. Use `--no-pager`, a line limit, and relevant properties where supported.
   A failed `status` command can be evidence, not a broken diagnostic. Record
   exit status, restart counters, timeout/OOM signals, dependencies, and recent
   changes. Redact tokens and personal data; unit environments and logs can
   contain secrets. Do not dump all host logs or all environment variables.
3. **Test a discriminating hypothesis.** Separate process failure, resource
   exhaustion, filesystem permissions, sockets/listeners, DNS, routing, and
   dependency readiness. Check disk space *and inodes* when storage is implicated.
   Correlate timestamps across signals. Avoid equating an active unit with a
   working application or assuming every timeout is a network problem.
4. **Change the owner, not generated output.** Inspect the unit's fragment and
   drop-ins. On NixOS, edit the owning module and follow `nix-infrastructure`;
   do not permanently patch the store or generated unit. Elsewhere, use a scoped
   drop-in/source change with a reversible diff. `After=` controls order, not
   activation or application readiness; use requirement dependencies and the
   service's real readiness mechanism deliberately. Validate unit syntax and
   dependencies with the installed `systemd-analyze verify`, noting missing
   binaries or host-specific dependencies rather than ignoring warnings.
5. **Apply only the requested runtime changes.** `daemon-reload` reloads unit
   definitions; it does not restart a service. Reload, restart, enable, and start
   have different effects. Explain the disruption before a restart and preserve
   evidence first. Recheck manager state, bounded logs, and a user-visible health
   check after the change. Verify rollback against the same signals.

If a command is unavailable or requires privileges not granted, report the
specific missing evidence. Do not substitute a package-manager install, a reboot,
or an unbounded tracing session without authorization.

## When NOT to use

- macOS launchd or an application-level bug with no Linux host/service issue.
- Missing services generated from `.container` files; use `podman-quadlet` first.

## What to skip

No reboot-first diagnosis, log deletion, broad `reset-failed`, process killing,
blind permission changes, or disabling hardening to make the symptom disappear.

## Handoffs

Use `sre-incident-response` when customer impact needs coordinated mitigation.
Use `hetzner-operations` only when evidence reaches the provider control plane.

## Sources

Original local guidance; manuals reviewed on the metadata date. Prefer local
manuals for the installed systemd version; newer directives may not exist there.

- [systemctl](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html)
- [systemd.unit](https://www.freedesktop.org/software/systemd/man/latest/systemd.unit.html)
- [systemd-analyze](https://www.freedesktop.org/software/systemd/man/latest/systemd-analyze.html)
