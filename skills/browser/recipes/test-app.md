# Recipe: Test App

**When:** Write, run, or fix E2E tests.
**Tools:** Playwright → agent-browser (no test runner, no assertions, no parallel — tell user about tradeoff).
**Prereqs:** Dev server running and reachable.

## Steps (Playwright)
1. Check if `playwright.config.js` or `playwright.config.ts` exists
   - If not, create a minimal config:
     ```javascript
     import { defineConfig } from '@playwright/test';
     export default defineConfig({
       testDir: './tests',
       use: { baseURL: 'http://localhost:3000' },
     });
     ```
2. Write test file in `tests/` directory:
   ```javascript
   import { test, expect } from '@playwright/test';
   test('descriptive test name', async ({ page }) => {
     await page.goto('/');
     await expect(page.locator('h1')).toContainText('Expected');
     // ... interactions and assertions
   });
   ```
3. Run tests:
   ```bash
   npx playwright test
   ```
4. On failure, capture screenshot and report:
   ```bash
   npx playwright test --trace on
   npx playwright show-trace test-results/*/trace.zip
   ```
5. Report results: pass/fail count, failure details, screenshots of failures.

## Steps (agent-browser fallback)
1. Open the target page:
   ```bash
   agent-browser open http://localhost:3000
   ```
2. Snapshot to see the page state:
   ```bash
   agent-browser snapshot -i
   ```
3. Interact and verify manually:
   ```bash
   agent-browser click @e1
   agent-browser snapshot -i
   agent-browser get text @e2
   ```
4. Compare extracted text/state against expected values. Report pass/fail per check.
5. Screenshot on failure:
   ```bash
   agent-browser screenshot --annotated
   ```

## Output
Test results (pass/fail), failure screenshots in `.agent/evidence/<run-slug>/artifacts/`, traces (`--trace on`), video (`video: 'retain-on-failure'`).

## Cleanup
Playwright handles cleanup automatically. agent-browser: `agent-browser close`. Artifacts persist for review.
