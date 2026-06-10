# chrome-devtools-axi

AXI-designed browser automation built on top of Chrome DevTools Protocol. Token-efficient TOON output, accessibility-tree based interaction, persistent bridge process, and contextual next-step suggestions.

## Detection

```bash
command -v chrome-devtools-axi 2>/dev/null && chrome-devtools-axi --version
```

## Install

```bash
npm install -g chrome-devtools-axi
```

## Why prefer over agent-browser / Playwright

- **Lower token cost**: TOON output (~40% smaller than JSON)
- **Pre-computed aggregates**: counts and statuses inline so the agent doesn't need follow-up calls
- **Definitive empty states**: explicit "0 elements matched" rather than ambiguous output
- **Ambient context**: packaged CLI can install SessionStart hooks; agent sees current browser state at session start

## When to fall back

- **Recording video**: not supported — use Playwright
- **Non-Chrome browsers** (Firefox, WebKit testing): use Playwright
- **No CDP available** (locked-down environments): use agent-browser or native

## Core workflow

```bash
# Bare invocation shows live tab state, not help
chrome-devtools-axi

# Open or navigate
chrome-devtools-axi open https://example.com

# Snapshot (TOON-formatted accessibility tree with refs)
chrome-devtools-axi snapshot

# Interact via refs
chrome-devtools-axi click @e1
chrome-devtools-axi fill @e2 "text"

# Screenshot
chrome-devtools-axi screenshot --output .agent/evidence/<run-slug>/artifacts/page.png
```

## Auth

By default it manages its own Chrome session through a persistent bridge. To attach to an already-authenticated Chrome, start Chrome with remote debugging and set `CHROME_DEVTOOLS_AXI_BROWSER_URL` to the CDP endpoint.

## Output

All structured output on stdout in TOON format. Errors on stdout in same format. stderr is for diagnostics agents won't read. Exit codes: 0 success, 1 error, 2 usage error.
