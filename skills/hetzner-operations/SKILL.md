---
name: hetzner-operations
description: >-
  Guides Hetzner Cloud or Robot resource operations, access recovery,
  networking, firewalls, volumes, and backups. Use for provider-side
  inspection or changes, not ordinary application debugging on a server
  that happens to be hosted at Hetzner.
license: MIT
metadata:
  author: cbzehner
  version: "0.1.0"
  reviewed: "2026-10-28"
---

# Hetzner operations

Cloud and Robot are separate control planes; establish which owns the resource.

## Inputs and result

Identify the product, account/project, resource IDs, environment, and permitted
operation. Produce evidence-backed resource changes or a recovery procedure with
cost, access, data-loss, and verification consequences stated.

## Workflow

1. **Confirm identity without exposing credentials.** Check the installed
   `hcloud` version/help and selected context for Cloud. Account for an exported
   token overriding a stored context; never print a token or dump the context
   configuration. Confirm the project through an expected resource inventory
   and stable IDs, not just a familiar server name. Robot dedicated servers use
   different APIs and credentials; do not assume the Cloud CLI manages them.
2. **Inspect before changing.** Read server state, location/type, public and
   private interfaces, attached networks, firewall assignments, volumes, backups,
   and any pending provider actions relevant to the request. Use bounded,
   resource-specific reads. Check whether Terraform, Nix, or another repository
   owns the resource; prefer its source of truth over an untracked API mutation.
3. **Plan the exact delta.** Verify flags against installed CLI help and current
   official documentation. Keep provider firewalls, host firewalls, routes, DNS,
   and application listeners separate in the diagnosis. For an access change,
   retain the current SSH session, confirm an independent console/rescue route,
   and prepare a second-connection test before removing any existing allow rule.
   Do not open all ports as a diagnostic shortcut.
4. **Respect resource and data boundaries.** Before creation, resizing, paid
   snapshots, backups, load balancers, or other billable operations, confirm
   authorization for the resource and cost. Rebuild, reinstall, deletion,
   detach/format, and rescue operations require an explicit understanding of
   the affected IDs, data, downtime, and recovery path. A server backup is not
   evidence that attached volume data is recoverable; check coverage and restore
   behavior for each resource. Snapshots may be crash-consistent, not
   application-consistent. Never format or mount a device based only on its name.
5. **Execute one bounded operation and verify.** Record the provider action ID
   when available and poll it to a terminal state within a deadline. Acceptance
   by the API is not completion. Re-read affected resources, then verify access
   and the service's user-visible behavior. After a timeout, inspect action and
   resource state before retrying; a duplicate request can create extra resources.

If permissions, identity, or recovery access are uncertain, report that boundary
and continue with safe reads rather than guessing or provisioning replacements.

## When NOT to use

- A service crash on a Hetzner VM with no provider-side symptom; use `linux-systemd`.
- Editing a Nix module or a container unit; use `nix-infrastructure` or
  `podman-quadlet`, adding this skill only for actual provider operations.

## What to skip

No token output, bulk resource deletion, broad firewall resets, automatic
credential rotation, or production resize as an exploratory test.

## Handoffs

For an active outage, `sre-incident-response` owns coordination and mitigation
criteria. This skill supplies the provider-specific evidence and execution limits.

## Sources

Original local guidance; official moving references reviewed on the metadata date.
Recheck product behavior and installed CLI commands before mutations.

- [Hetzner API documentation](https://docs.hetzner.cloud/)
- [Cloud CLI manual](https://github.com/hetznercloud/cli/blob/main/docs/reference/manual/hcloud.md)
- [Cloud CLI setup and contexts](https://github.com/hetznercloud/cli/blob/main/docs/tutorials/setup-hcloud-cli.md)
- [Robot webservice](https://robot.hetzner.com/doc/webservice/en.html)
