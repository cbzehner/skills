---
name: domain-launch
description: >-
  Domain naming, availability, purchase, and launch through Cloudflare. Use
  whenever a user wants to name a project, find or check available domains,
  register a domain, configure its Cloudflare DNS, connect it to a deployment,
  or verify the live domain. General DNS debugging belongs to diagnose.
argument-hint: "[project brief, domain, or deployment target]"
license: MIT
effort: medium
compatibility: Requires the Cloudflare API MCP server and a Cloudflare account for authenticated operations.
allowed-tools: Bash(dig:*) Bash(curl:*) mcp__cloudflare-api__* Skill
---

# Domain Launch

Take a project from a naming brief or exact domain to a verified Cloudflare
registration and working deployment.

## When to Use

- The user wants domain ideas grounded in current availability and price.
- The user wants to check or register an exact domain through Cloudflare.
- The user wants to connect a new Cloudflare domain to Pages, Workers, an
  origin, or another named service.
- The user wants proof that the registration, DNS, and HTTPS setup work.

## When NOT to Use

- Use `diagnose` for unexplained DNS, TLS, or propagation failures on an
  existing domain; this skill owns acquisition and planned setup.
- Use `agent-ergonomic-design` when designing a registrar API, CLI, or MCP
  server; this skill operates Cloudflare's existing interface.
- Use `development` when the main task is building or deploying an application
  and the domain is only one part of that managed delivery.
- Do not use this for domain investing, aftermarket brokerage, registrar
  transfers, legal trademark clearance, or portfolio management.

## What to Skip

- Do not build a login, database, API wrapper, or registrar abstraction.
- Do not ask for, print, or store API tokens, payment data, or registrant data.
- Do not use or recommend GoDaddy. Do not fall back to any registrar without
  the user's explicit choice.
- Do not add speculative DNS records, email records, redirects, or hosting
  products that the requested launch does not need.

## Safety Contract

Search is discovery; Check is authority. Cached suggestions may seed a
shortlist, but only Cloudflare's current availability check may support a
purchase decision.

<HARD-GATE>
A purchase request is not purchase approval. Never call a billable registration
operation until the user has seen a fresh quote and then approved one exact
domain, price ceiling, currency, term, and auto-renew choice. Approval is valid
for one purchase attempt only.
</HARD-GATE>

Domain registrations can be non-refundable. Never infer approval from urgency,
an earlier naming preference, or a broad instruction such as "buy the best
one." A price the user reports from an earlier check is context, not a fresh
quote or approval.

## Workflow

### 1. Establish the launch intent

Extract the known inputs:

- Project purpose and audience.
- Exact domain or naming constraints.
- Preferred or excluded extensions.
- Maximum registration and renewal cost, if supplied.
- Deployment target and required hostnames, if setup is requested.

If neither an exact domain nor enough context to generate names exists, ask one
question: what does the project do, who is it for, and which extensions or price
limits matter?

Do not block a read-only search on missing deployment details. Do not guess DNS
records when the deployment target is unknown.

### 2. Preflight Cloudflare access

Use the official Cloudflare API MCP server at
`https://mcp.cloudflare.com/mcp`. If its tools are unavailable, stop before any
account operation and provide this client configuration:

```json
{
  "mcpServers": {
    "cloudflare-api": {
      "type": "http",
      "url": "https://mcp.cloudflare.com/mcp"
    }
  }
}
```

Let the MCP server start Cloudflare OAuth. Never replace OAuth with a request
for the user's API token. If several accounts are visible, ask the user to pick
one before any purchase or configuration.

Before purchase, confirm that the selected account has a default payment
method, default registrant contact, verified email, and accepted registration
agreement. When a prerequisite is missing, stop and point to the exact
Cloudflare dashboard action; do not seek a registrar fallback.

### 3. Discover and check candidates

Use the MCP `search` tool to find the current Registrar API surface before
calling it. Do not rely on endpoint lists or supported extensions copied into
this skill because the beta changes.

Use Registrar Sandbox only for an explicit dry run. Sandbox purchases do not
register real Internet domains and must never be reported as a live launch.

For a naming brief:

1. Generate clear candidate labels from the brief.
2. Use Cloudflare domain search to broaden the list.
3. Deduplicate and batch no more than the current API limit per Check call.
4. Rank only candidates whose current state is known.

For an exact domain, skip broad generation and Check it directly.

Preserve Cloudflare's exact currency and registration and renewal prices. Mark
premium, unavailable, unsupported, disallowed, and unknown results explicitly;
never collapse them into "taken."

### 4. Present a decision-ready shortlist

Return at most five strong available candidates by default:

| Domain | Registration | Renewal | Status or note |
|---|---:|---:|---|

State how many candidates were checked. If none qualify, say so directly and
offer a new search with changed words, extensions, or price limits.

Rank names by fit, clarity, length, spelling, and stated constraints. Do not
claim trademark safety. If the user asks for legal clearance, explain that a
preliminary screen cannot replace legal review and stop before purchase when
the risk is material.

### 5. Quote and obtain purchase approval

Immediately before requesting approval, run Check again for the chosen domain.
Show one compact purchase summary containing:

- Exact fully qualified domain name.
- Registration price, renewal price, currency, and term.
- Standard or premium tier.
- Auto-renew choice.
- Privacy mode when returned.
- The fact that a successful registration is billable and non-refundable.

Ask the user to approve with the exact domain and maximum total, for example:

> Approve `example.dev` for up to USD 15.00 for one year, with auto-renew on.

Do not accept an approval missing the domain or price ceiling. If the user
changes any purchase term, produce a new summary before asking again.

### 6. Register once and resolve the outcome

After approval, run Check once more. Continue only if the domain remains
registrable and its total does not exceed the approved ceiling. A changed
currency, higher price, premium classification, or changed term voids the
approval.

Use the current registration schema discovered through the MCP. Set the
approved auto-renew value explicitly rather than accepting an API default. Keep
the request minimal and use the account's default contact unless the user has
approved a different valid contact through Cloudflare.

Treat synchronous success and accepted asynchronous work as expected outcomes.
Poll the returned workflow or registration status until it succeeds, fails, or
requires user action. Read after an ambiguous mutation; never retry blind. A
timeout or lost response requires checking the registration resource before any
second create call.

### 7. Configure only the requested target

Cloudflare Registrar domains already use Cloudflare authoritative DNS. Wait for
the registration and zone to become active, then inspect the existing zone and
target configuration before making changes.

Prefer a product-specific attachment API when the target is Cloudflare Pages or
Workers. For other targets, derive the smallest required DNS record set from
the named service's current configuration.

Show the DNS change set before applying it. New non-conflicting records covered
by the user's approved setup may proceed. Replacing or deleting an existing
record needs separate explicit approval because it can break a site or email.
Offer DNSSEC only when it is part of the requested setup.

If the target is still unknown, finish registration and ask where the domain
should point. A parked but owned domain is safer than guessed DNS.

### 8. Verify the launch

Verify each claim at the layer that owns it:

1. Registration status is active in Cloudflare.
2. The zone is active and expected DNS records exist in the API.
3. Authoritative DNS returns the expected answers with `dig`.
4. The target product reports the custom domain as active when it has such a
   status.
5. HTTPS returns the expected hostname and status with `curl` once the service
   is meant to be live.

If no application is deployed yet, report DNS as verified and HTTPS as pending;
do not call the launch complete. Surface registrant-email verification or any
other required user action.

Finish with the domain, registration state, auto-renew choice, privacy mode,
DNS changes, verification results, and remaining actions. Never echo contact,
billing, token, or OAuth data.

## Examples

### Name and shortlist

Input: "Find a short `.com` or `.dev` name for an offline-first reading app."

Output: A five-row shortlist based on a live Cloudflare Check, including both
registration and renewal prices. No purchase call.

### Check one domain

Input: "Is `quietcache.dev` available, and what will renewal cost?"

Output: The current registrability, tier, registration price, and renewal
price, with unknown or unsupported states kept distinct.

### Request a purchase

Input: "Buy `quietcache.dev` for me."

Output: A fresh quote and the exact approval sentence the user must send next.
The initial request does not trigger registration.

### Purchase and connect

Input: "Register the approved domain and attach it to my Pages project."

Output: One registration attempt, terminal registration status, the minimal
Pages attachment or DNS changes, and DNS and HTTPS verification.

## Handoffs

- Route an unclear product purpose or audience to `plan` before deep naming
  work; exact-domain checks do not need a product plan.
- Route unexplained post-configuration failures to `diagnose` with the observed
  DNS, TLS, or product status evidence.
- Route browser-only dashboard interaction or visual proof to `browser`.
- Route application build and deployment work to `development`; resume this
  skill once the deployment target can state its required domain configuration.

## Error Handling

| Condition | Response |
|---|---|
| MCP missing or logged out | Stop and provide the official MCP URL or OAuth action. |
| Billing, contact, email, or agreement missing | Stop and point to the required Cloudflare dashboard action. |
| Domain unavailable | Report it and offer checked alternatives. |
| Extension unsupported through the API | Offer the Cloudflare dashboard path; do not switch registrars. |
| Premium registration unsupported | Report the price and limitation; do not buy or redirect automatically. |
| Availability unknown | Retry Check once when appropriate, then report unknown. |
| Price or terms changed after approval | Void approval and request a new one with the new quote. |
| Rate limited | Honor the returned retry timing; do not fan out more checks. |
| Registration response ambiguous | Read registration state before considering another mutation. |
| Workflow requires user action | Stop polling and present the action exactly. |
| DNS record conflict | Show the conflict and require approval before replacement or deletion. |
