---
name: browser
description: >-
  Unified browser automation for opening, visiting, browsing, interacting with,
  testing, scraping, screenshotting, visually inspecting, or debugging web pages
  and local frontends. Use when the user asks to use a browser, Chrome, DevTools,
  Playwright, agent-browser, chrome-devtools-axi, inspect a URL, click/fill a
  page, check a site, capture a screenshot/video, compare visual output, scrape
  page content, debug console/network/UI issues, or verify an app in practice.
  Detects installed tools, routes by capability, handles auth, and cleans up.
argument-hint: "[url or task description]"
arguments:
  - url_or_task
license: MIT
allowed-tools: Bash Read Glob Grep
# Note: Write/Edit intentionally excluded - this skill executes and reports, it does not modify project files
---

# Browser

## Trigger

Activate when the user asks to: navigate/interact with a web page, test a UI, take screenshots or video, scrape data, debug a frontend, or visually compare pages across branches.

## Detection & Preflight

On the first browser task in a session, run these probes to determine what is available. Cache results for the session.

```bash
command -v chrome-devtools-axi 2>/dev/null && chrome-devtools-axi --version
command -v agent-browser 2>/dev/null && agent-browser --version
npx playwright --version 2>/dev/null
npx playwright install --dry-run 2>/dev/null
# Native: check if host exposes browser MCP tools
```

<!-- WHY: CLI can exist without browser binaries — command -v alone gives false positives -->
**Do not trust `command -v` alone** — run version/dry-run checks to confirm usability. Re-detect if user installs tools mid-session.

### Preflight (before every recipe)

- **Localhost target?** `curl -s -o /dev/null -w "%{http_code}" http://localhost:PORT`
- **Evidence bundle?** Ensure `.agent/evidence/<run-slug>/artifacts/` exists when saving screenshots, traces, videos, logs, or HARs.
- **Screenshot-diff?** Verify git working tree is clean

## Reconnaissance (mandatory by default)

<!-- WHY: Without this, model clicks elements without verifying page state -->
Before any DOM interaction: look before you touch.

1. **Wait for load** — use `networkidle` to let async content settle
2. **Snapshot** — screenshot or accessibility snapshot before first interaction, save bulky files under `.agent/evidence/<run-slug>/artifacts/`
3. **Verify targets exist** — confirm elements are present before acting (agent-browser: check refs, Playwright: `expect(locator).toBeVisible()`)

**On failure:** capture page state (screenshot, console errors, URL), report expected vs. found. Do not retry blindly.

**Skip with** `--skip-recon` for simple non-interactive automation (e.g., single screenshot of a stable page).

## Capability-Driven Routing

Route by what the task **requires**, not by task label. Identify the needed capabilities from this table, then pick the tool that covers the most.

| Capability | Best tool |
|---|---|
| Deterministic scripted flow (tests, assertions) | Playwright |
| Exploratory interaction | chrome-devtools-axi / agent-browser / native |
| Token-efficient page reading | chrome-devtools-axi (TOON output, ~40% smaller than JSON) / agent-browser (accessibility tree) |
| Video recording / network inspection / multi-browser | Playwright |
| Zero-setup, already authenticated | native / chrome-devtools-axi connected to an existing CDP browser |
| Structured data extraction | chrome-devtools-axi (TOON, pre-computed aggregates) / agent-browser |
| Screenshot capture | chrome-devtools-axi / agent-browser (speed) / Playwright (full-page/element) |

**Tie-breaking:** chrome-devtools-axi > native > agent-browser > Playwright when the task is exploratory and text-heavy; choose Playwright first for deterministic tests, video, or cross-browser checks. When falling back, tell the user what capabilities change — do not present tools as interchangeable.

## Auth Modes

<!-- WHY: Ordered fallback prevents trying complex approaches first or asking for passwords -->
Try in order, stop at first success:

1. **Native session** — user's existing login state, zero config
2. **CDP** (`--cdp-url`) — connect to running Chrome, avoids profile locking
3. **Dedicated profile** — separate automation profile with saved storage state
4. **Cookie import** — export/import cookies (expire over time)
5. **Manual checkpoint** — headed browser, user logs in, save state. Last resort.

**Never:** ask for passwords, store credentials in plaintext, bypass MFA programmatically.

## Failure Policy

<!-- WHY: Prevents silent retries and zombie browser processes -->
On failure: capture error (screenshot, console, exit code) → clean up browser processes → report clearly → diagnose before retrying (timeout? anti-bot? auth? dependency?). If tool-specific, suggest an alternative tool.

**Timeouts:** 30s default. Use explicit waits (`networkidle`) for slow pages rather than increasing global timeout.

## Security & Privacy

<!-- WHY: Browser-specific risks (HAR with auth headers, authenticated scraping) aren't covered by general security guidance -->
- Browser artifacts go under `.agent/evidence/<run-slug>/artifacts/`; the parent evidence bundle may also contain `manifest.json`, `checks.ndjson`, `index.html`, and `summary.md`.
- Add `.agent/evidence/` to `.gitignore` unless the user explicitly wants to commit a fixture.
- Never log/store passwords, tokens, or session cookies. Warn before saving HAR files with auth headers.
- Do not silently scrape authenticated content — tell the user what you're accessing and why
- Never upload artifacts to external services without explicit approval

## No Tools Found

Report what was checked. Recommend based on context (wait for user approval before installing):
- **Default (best benchmarks):** `npm install -g chrome-devtools-axi`
- **Alternative:** `npm i -g agent-browser && agent-browser install`
- **Testing/video:** also `npm i -D @playwright/test && npx playwright install`
- **Python-only:** `uv add browser-use`

## References

- Tool reference cards: [tools/chrome-devtools-axi.md](tools/chrome-devtools-axi.md), [tools/agent-browser.md](tools/agent-browser.md), [tools/playwright.md](tools/playwright.md), [tools/native.md](tools/native.md)
- Recipes: [recipes/test-app.md](recipes/test-app.md), [recipes/screenshot-diff.md](recipes/screenshot-diff.md), [recipes/scrape-page.md](recipes/scrape-page.md), [recipes/debug-ui.md](recipes/debug-ui.md), [recipes/record-session.md](recipes/record-session.md)

Read tool cards and recipes on demand when executing a task. Do not load them all upfront.
