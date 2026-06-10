# Visual Evidence

Capture screenshots for UI-facing work. Use the browser skill's tool routing and security rules.

## When Required

Screenshots are required when changed files affect:

- Frontend pages, layouts, components, styles, icons, charts, maps, emails, PDFs, reports, or generated docs.
- Browser flows, responsive behavior, modals, forms, navigation, or visual states.
- Anything the user explicitly asked to screenshot or visually validate.

Skip only for non-visual changes or when blocked by environment/auth. If blocked, document the command, URL, and error.

## Capture

Use repo-native visual tooling first. Otherwise:

1. Start or verify the dev server.
2. Capture desktop and mobile viewports for the changed flow.
3. Include before/after when the change is feature-flagged, stacked, or layout-sensitive.
4. Save screenshots and bulky browser outputs in `.agent/evidence/<run-slug>/artifacts/`.
5. Inspect screenshots before claiming success.

For deterministic flows, prefer Playwright. For exploratory checks, prefer `chrome-devtools-axi` or the browser skill's selected tool.

## Screenshot Report

Summarize:

```markdown
Screenshots:
- Desktop <flow>: `.agent/evidence/<run-slug>/artifacts/desktop-<flow>.png`
- Mobile <flow>: `.agent/evidence/<run-slug>/artifacts/mobile-<flow>.png`

Visual verdict:
- Pass / Needs attention
- Specific differences or regressions
```

## Optional GitHub Attachment Upload

Use this only with `--upload` or explicit approval after the user sees this warning:

**GitHub `user-attachments` URLs are public bearer URLs, even when generated from a private repository. Anyone with the URL can view the image. Do not upload private work screenshots, customer data, secrets, internal dashboards, or authenticated product views unless the user explicitly accepts that public-URL risk.**

Generic pattern:

- Upload images to a GitHub PR/issue comment box by pasting images with Playwright.
- GitHub creates `https://github.com/user-attachments/assets/<id>` URLs.
- Clear the comment box without submitting.
- Use the returned URLs in the PR body.
- Do not commit screenshots to the repository.

One prior project helper used this shape:

- Opened headed Chromium.
- Cached GitHub auth state outside committed files.
- Pasted each PNG into `#new_comment_field`.
- Parsed `github.com/user-attachments/assets/...` URLs from the textarea.
- Printed clean JSON mapping `filename -> URL`.

If the current repo has a helper, use it. If not, do not build this automation during finish-task. Report the local paths and let the user drag-and-drop images, or create a narrow helper in a separate task if repeated use justifies it.

Security rules:

- Never upload screenshots containing secrets, customer private data, auth tokens, or personal information without explicit user approval.
- Never commit `.agent/evidence/`, auth storage state, HAR files, or videos unless the user explicitly wants an evidence fixture committed.
- Treat cached GitHub browser auth state as a credential. Keep it outside committed files and mention its path when a helper creates it.
- Prefer a scratch issue or draft comment target for uploads when feasible; verify the target PR/issue URL before pasting.
- Prefer redaction or local-only evidence for sensitive work.

PR body embedding pattern:

```markdown
<details>
<summary>Flow name - Desktop</summary>

| Before | After |
|---|---|
| <img width="720" alt="before-flow-desktop" src="https://github.com/user-attachments/assets/..." /> | <img width="720" alt="after-flow-desktop" src="https://github.com/user-attachments/assets/..." /> |

</details>
```
