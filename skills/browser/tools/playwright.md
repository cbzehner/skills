# Playwright

## Detection
```bash
npx playwright --version 2>/dev/null
```
**Preflight — verify browser binaries exist:**
```bash
npx playwright install --dry-run 2>/dev/null
```
If the CLI exists but browsers are missing, run `npx playwright install`.

## Install
```bash
npm i -D @playwright/test && npx playwright install
```
Installs Chromium, Firefox, and WebKit browsers.

## Core Workflow

### Quick one-off script
```javascript
// save as script.mjs, run with: node script.mjs
import { chromium } from 'playwright';
const browser = await chromium.launch();
const page = await browser.newPage();
await page.goto('https://example.com');
await page.screenshot({ path: '.agent/evidence/<run-slug>/artifacts/screenshot.png' });
await browser.close();
```

### Test files
```javascript
// tests/example.spec.js
import { test, expect } from '@playwright/test';
test('page loads', async ({ page }) => {
  await page.goto('http://localhost:3000');
  await expect(page).toHaveTitle(/My App/);
});
```

Run: `npx playwright test`

### Record interactions
```bash
npx playwright codegen https://example.com
```
Opens a browser and generates test code from your actions.

## Screenshots
```javascript
await page.screenshot({ path: '.agent/evidence/<run-slug>/artifacts/screenshot.png' });            // Viewport
await page.screenshot({ path: '.agent/evidence/<run-slug>/artifacts/full.png', fullPage: true });  // Full page
await page.locator('.element').screenshot({ path: '.agent/evidence/<run-slug>/artifacts/el.png' }); // Element
```

## Video Recording
```javascript
// In playwright.config.js or per-test
const context = await browser.newContext({
  recordVideo: { dir: '.agent/evidence/<run-slug>/artifacts/videos/' }
});
// ... do interactions ...
await context.close(); // Video saved on close
```

Or in config:
```javascript
// playwright.config.js
export default { use: { video: 'on-first-retry' } };  // or 'on', 'retain-on-failure'
```

## Network Inspection
```javascript
// Listen to all requests
page.on('request', req => console.log(req.method(), req.url()));
page.on('response', res => console.log(res.status(), res.url()));

// Intercept/mock
await page.route('**/api/**', route => route.fulfill({ body: '{"mock":true}' }));

// HAR recording
const context = await browser.newContext({ recordHar: { path: '.agent/evidence/<run-slug>/artifacts/trace.har' } });
```

## Console Capture
```javascript
page.on('console', msg => console.log(`[${msg.type()}] ${msg.text()}`));
page.on('pageerror', err => console.error('Page error:', err.message));
```

## Auth
```javascript
// Save auth state
await context.storageState({ path: '.agent/evidence/<run-slug>/artifacts/auth.json' });
// Reuse auth state
const context = await browser.newContext({ storageState: '.agent/evidence/<run-slug>/artifacts/auth.json' });
// CDP connection
const browser = await chromium.connectOverCDP('http://localhost:9222');
```

## Trace Viewer
```bash
# Record traces
npx playwright test --trace on

# View traces (screenshots, DOM snapshots, network, console at each step)
npx playwright show-trace trace.zip
```

## Output Format
Test results (stdout), screenshots (PNG), videos (WebM), traces (ZIP), HAR (JSON). Avoid `page.content()` — use `locator().textContent()` for token efficiency.

## Strengths / Limitations
Multi-browser, test runner, video, network interception, traces, mobile emulation, mature ecosystem. Heavier than agent-browser (Node.js), raw HTML is token-expensive (use targeted extraction via `locator().textContent()`).

## Common Failures
| Failure | Cause | Fix |
|---------|-------|-----|
| "Executable doesn't exist" | Browser binaries not installed | `npx playwright install` |
| Test timeout | Page too slow or selector not found | Increase timeout in config, check selector |
| Port conflict | Dev server port already in use | Use a different port or kill existing process |
| Stale locator | DOM changed between locate and action | Use web-first assertions (`expect(locator)`) which auto-retry |
| Video not saved | Context not closed | Always `await context.close()` to flush video |
