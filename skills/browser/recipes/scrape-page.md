# Recipe: Scrape Page

**When:** Extract structured data from a web page (tables, prices, text, lists).
**Tools:** agent-browser (token-efficient) → native → Playwright (use `locator().textContent()`, NOT `page.content()`).
**Prereqs:** URL accessible. Auth content → handle auth first (SKILL.md).

## Steps (agent-browser)
1. Navigate to the target page:
   ```bash
   agent-browser open https://target-url.com
   ```
2. Snapshot to get the accessibility tree:
   ```bash
   agent-browser snapshot -i
   ```
3. Identify target elements from the snapshot (tables, lists, text blocks)
4. Extract data from each element:
   ```bash
   agent-browser get text @e1
   agent-browser get text @e2
   ```
5. For tables or repeated elements, extract each row/item individually
6. Structure the data as JSON, markdown table, or whatever format the user requested

## Steps (Playwright fallback)
Use targeted extraction — never full `page.content()`:
```javascript
import { chromium } from 'playwright';
const browser = await chromium.launch();
const page = await browser.newPage();
await page.goto('https://target-url.com');

const rows = await page.locator('table tr').allTextContents();
const price = await page.locator('.price').textContent();

await browser.close();
```

## Pagination
If data spans multiple pages:
1. Extract current page data
2. Re-snapshot and look for pagination controls:
   ```bash
   agent-browser snapshot -i
   ```
3. Click next:
   ```bash
   agent-browser click @eN
   ```
4. Re-snapshot and extract
5. Repeat until no more pages or user-specified limit reached

Show a preview of the first few items before extracting large datasets.

## Output
Structured data in user's requested format (JSON, markdown table, plain text).

## Cleanup
Close browser session. `agent-browser close` or `await browser.close()`.
