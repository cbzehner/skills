# Recipe: Record Session

**When:** Capture video or screenshot sequence of a user flow.
**Tools:** Playwright (video, WebM) → agent-browser (sequential screenshots — tell user these are different deliverables).
**Prereqs:** Target accessible, `.agent/evidence/<run-slug>/artifacts/` writable.

## Steps (Playwright — video)
```javascript
import { chromium } from 'playwright';
const browser = await chromium.launch();
const context = await browser.newContext({
  recordVideo: {
    dir: '.agent/evidence/<run-slug>/artifacts/videos/',
    size: { width: 1280, height: 720 }
  }
});
const page = await context.newPage();

// Walk through the flow
await page.goto('http://localhost:3000');
await page.waitForLoadState('networkidle');
await page.click('text=Sign In');
await page.fill('#email', 'user@example.com');
// ... more steps

// CRITICAL: close context to save video
await context.close();
await browser.close();
// Video is now at .agent/evidence/<run-slug>/artifacts/videos/*.webm
```

## Steps (agent-browser — screenshot sequence)
```bash
mkdir -p .agent/evidence/<run-slug>/artifacts/session-recording

agent-browser open http://localhost:3000
agent-browser screenshot
# Save as .agent/evidence/<run-slug>/artifacts/session-recording/01-landing.png

agent-browser click @e1  # e.g. Sign In button
agent-browser snapshot -i
agent-browser screenshot
# Save as .agent/evidence/<run-slug>/artifacts/session-recording/02-login-form.png

agent-browser fill @e2 "user@example.com"
agent-browser click @e3  # Submit
agent-browser snapshot -i
agent-browser screenshot
# Save as .agent/evidence/<run-slug>/artifacts/session-recording/03-dashboard.png
```

Name files with numbered prefixes and descriptive suffixes.

## Output
Playwright: `.agent/evidence/<run-slug>/artifacts/videos/*.webm`. agent-browser: `.agent/evidence/<run-slug>/artifacts/session-recording/NN-description.png`.

## Failure Modes
| Failure | Fix |
|---------|-----|
| Video not saved | `await context.close()` before `browser.close()` |
| Video is black/empty | Add `waitForLoadState('networkidle')` before interactions |
| Screenshot misses transient state | Add waits between steps |

## Cleanup
**Critical:** `await context.close()` before `browser.close()` (video saves on context close). Artifacts persist for user review.
