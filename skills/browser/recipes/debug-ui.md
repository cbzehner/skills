# Recipe: Debug UI

**When:** Frontend bug investigation (console errors, network failures, layout issues).
**Tools:** native → agent-browser → Playwright (only for network-level debugging).
**Prereqs:** Page accessible, know URL and bug area.

## Steps (native or agent-browser — exploratory)
1. Navigate to the problematic page:
   ```bash
   agent-browser open http://localhost:3000/buggy-page
   ```
2. Snapshot the page state:
   ```bash
   agent-browser snapshot -i
   ```
3. Look for visual issues in the accessibility tree (missing elements, wrong text, broken structure)
4. Screenshot for reference:
   ```bash
   agent-browser screenshot --annotated
   ```
5. If the bug is interactive, try to reproduce:
   ```bash
   agent-browser click @e1
   agent-browser snapshot -i
   ```
6. Report findings: what elements are present/missing, any visual anomalies, state after interaction

## Steps (Playwright — network debugging)
```javascript
import { chromium } from 'playwright';
const browser = await chromium.launch();
const context = await browser.newContext({
  recordHar: { path: '.agent/evidence/<run-slug>/artifacts/debug.har' }
});
const page = await context.newPage();

// Capture console errors
page.on('console', msg => console.log(`[${msg.type()}] ${msg.text()}`));
page.on('pageerror', err => console.error('PAGE ERROR:', err.message));

// Capture network failures
page.on('requestfailed', req =>
  console.error(`FAILED: ${req.method()} ${req.url()} - ${req.failure().errorText}`)
);

await page.goto('http://localhost:3000/buggy-page');
// ... interact to reproduce the bug
await page.screenshot({ path: '.agent/evidence/<run-slug>/artifacts/debug-screenshot.png' });
await context.close();
await browser.close();
```

## Output
Console errors, failed requests (Playwright), DOM state summary, annotated screenshot, HAR file (if needed). All saved to `.agent/evidence/<run-slug>/artifacts/`.

## Cleanup
`agent-browser close` or `await browser.close()`. Artifacts persist in `.agent/evidence/<run-slug>/artifacts/`.
