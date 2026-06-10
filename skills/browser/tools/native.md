# Claude Code Native Browser

## Detection
Check session's tool list for browser-prefixed MCP tools (`browser_navigate`, `browser_screenshot`, etc.). No CLI detection — requires **Claude in Chrome** extension (beta, Chrome/Edge).

## Core Workflow
MCP tools (not CLI). Navigate → read content → screenshot → interact (click, fill).

## Auth
Uses the user's existing Chrome login state. No separate auth config needed.

## When to Defer Entirely
<!-- WHY: Avoids loading full routing pipeline for trivial native-browser tasks -->
If native MCP tools are available and the task is simple (navigate + screenshot + read), use them directly **without invoking this skill's routing logic**.

## Strengths / Limitations
Zero install, already authenticated, Playwright-based. Beta, Chrome/Edge only, subset of Playwright capabilities, no video, no headless, limited network inspection.

## Common Failures
| Failure | Fix |
|---------|-----|
| MCP tools not available | Install/enable Claude in Chrome extension |
| Page not accessible | Open Chrome with extension active |
| Auth not working | Log into target site in Chrome first |
