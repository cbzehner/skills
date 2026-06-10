# agent-browser

## Detection
```bash
command -v agent-browser 2>/dev/null && agent-browser --version
```
If command exists but version fails, Chrome may not be installed. Run `agent-browser install`.

## Install
```bash
npm i -g agent-browser && agent-browser install
```
Also available via `brew install agent-browser` or `cargo install agent-browser`.

## Core Workflow
The fundamental pattern is: navigate -> snapshot -> interact -> re-snapshot.

```bash
# 1. Open a page
agent-browser open https://example.com

# 2. Snapshot to see interactive elements with refs
agent-browser snapshot -i
# Returns accessibility tree with @e1, @e2, etc.

# 3. Interact using refs
agent-browser click @e1
agent-browser fill @e2 "text to type"
agent-browser select @e3 "option value"

# 4. Re-snapshot after any DOM change
agent-browser snapshot -i
```

**Critical: Refs are invalidated when the page changes.** Always re-snapshot after clicking links, submitting forms, or triggering dynamic content.

## Element Selection
Prefer refs (`@e1`) → semantic locators (`role=button[name="Submit"]`) → CSS/XPath as last resort.

## Screenshots
```bash
agent-browser screenshot                    # Standard
agent-browser screenshot --annotated        # With element labels
agent-browser screenshot --full-page        # Entire scrollable page
```
Save to .agent/evidence/<run-slug>/artifacts/ directory.

## Data Extraction
```bash
agent-browser get text @e1          # Text content of element
agent-browser get url               # Current page URL
agent-browser get title             # Page title
```

## Auth
`agent-browser auth import` (from Chrome) | `--cdp-url ws://localhost:9222` (CDP) | Sessions persist by default.

## Output Format
Accessibility tree with element refs (82% less context than HTML):
```
[page] Example Site
  [button @e1] Sign In
  [textbox @e2] Email
```

## Strengths / Limitations
Token-efficient (82% less context), fast (Rust binary), AI-optimized refs. Chrome-only, no test runner, no video, no network inspection, no parallel sessions on same Chrome.

## Common Failures
| Failure | Cause | Fix |
|---------|-------|-----|
| "Chrome not found" | `agent-browser install` was skipped | Run `agent-browser install` |
| Stale refs after click | Page changed, refs invalidated | Always re-snapshot after interactions |
| Timeout on slow page | Default 25s timeout | Set `AGENT_BROWSER_DEFAULT_TIMEOUT` env var or use explicit waits |
| Profile lock | Trying to use active Chrome profile | Use `--cdp-url` to connect to running Chrome instead |
