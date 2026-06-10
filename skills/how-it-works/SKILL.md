---
name: how-it-works
description: Build a polished, on-site /how-it-works page that explains a codebase's micro-systems in the site's own visual style. Use when the user wants an architecture explainer, a HN-shareable writeup, a build-journal page, or to "explain how X works" as a standalone artifact. Produces prose with real code excerpts (pinned to a SHA), hand-authored SVG diagrams in the site's palette, a sticky TOC, and humanized writing. Falls back to a single self-contained HTML file when no static site is detected.
license: MIT
effort: high
allowed-tools: Read Write Edit Bash Glob Grep WebFetch WebSearch Skill Agent
---

# /how-it-works

Build an on-site explainer page that turns a codebase into a long-scroll technical reference, in the site's own aesthetic. The output is shareable (HN, Lobsters, internal docs) because it looks like the rest of the product, not a generic Markdown blog post.

## When This Skill Fires

- "Add a /how-it-works page to my site"
- "Build me an architecture explainer for this repo"
- "I want a HN-shareable writeup of how this works"
- "Document the system in a way I can link to"
- "Explain the internals of this codebase as a single page"

## When Not to Fire

- **A traditional README or contributing guide** — those go in the repo, not the deployed site
- **API reference docs** — generated tools (TypeDoc, rustdoc) do this better
- **A blog post** — if the user wants a *post*, not a *page*, write Markdown directly
- **In-line code documentation** — comments, JSDoc, or docstrings, not a page

## Inputs Required

Before starting, confirm or detect:

1. **Target codebase root** — the repo to explain. Default: current working directory.
2. **Target site location** — where the page will live. Three modes:
   - **Same-repo site**: e.g. a Zola/Hugo/Jekyll/Astro/Next.js site in this repo. Page integrates with existing templates and CSS.
   - **External site**: a separate site repo. Skill produces files for that repo with placeholder paths.
   - **Standalone**: no site exists. Produce one self-contained HTML file with inlined CSS, SVG, and minimal JS that can be served from anywhere.
3. **Audience** — engineers (deep technical), broader (mixed), internal (assume context). Affects depth, jargon, what to explain vs. assume.

If any of these are unclear, ask once with multiple-choice. Don't guess for #2 — it shapes the whole build.

## The Workflow

The full path runs through six phases. Each phase has a clear deliverable and an exit gate. Don't skip phases; you can compress them.

### Phase 1 — Brainstorm scope (mandatory, ~10 min)

Use `superpowers:brainstorming`. Decide and write down:

- **Section list** (target 5–7). Lead the user toward concrete *micro-systems* (one specific mechanism per section) rather than abstract topics. "Cache and serving" beats "Performance"; "PDF parsing" beats "Data layer".
- **Format**: prose-only / prose + code excerpts / code-first. Default: prose + 1–2 short real code excerpts per section, pinned to a commit SHA.
- **Diagrams**: hand-authored SVG / build-time Mermaid / mixed. Default: hand-authored SVG, one hero diagram per section.
- **TOC position**: right-rail or left-rail. Default: right-rail when the home page already uses left for navigation/filters; left-rail otherwise.
- **Code excerpt link target**: pinned SHA or `main`. Default: pinned SHA + footer note linking to current source.

Offer the visual companion if the user hesitates on TOC position or section ordering.

**Exit**: written design spec at the repo's spec convention (e.g. `docs/specs/YYYY-MM-DD-how-it-works-design.md`), committed.

### Phase 2 — Source the content (~20 min)

Two parallel tasks:

1. **Code reading**. Read the actual source for each section. Note the file path and line numbers of the most distinctive excerpts. Do not write prose without reading the code first — synthesized pseudocode reads as evasive. Keep excerpts short (10–25 lines).
2. **Anecdote mining** (optional but high-value). If the codebase has been worked on with Claude Code, run `seance` to surface session history for: bug-fix moments, refactor decisions, abandoned approaches, ops incidents, external communications. These become the asides that make the page feel human.

If the user maintains a project journal, runbook, or NAPKIN.md, mine that too.

**Exit**: a written list of section → key files → key excerpt line ranges → anecdotes.

### Phase 3 — Detect the site (~5 min)

Identify the site's:

- **Generator**: Zola, Hugo, Jekyll, Astro, Next.js, plain HTML (see `references/integration.md`).
- **Templating language**: Tera, Liquid, Jinja, JSX, etc.
- **Existing palette**: read the site's main CSS for color custom properties (`--bg`, `--fg`, `--accent` or equivalent). The diagrams and page styling must use these tokens, not invent new ones.
- **Typography**: read existing CSS for font-family. The page should use the site's existing fonts.
- **Existing aesthetic patterns**: scan templates and CSS for strong visual signatures (departure-board, brutalist, hand-drawn, terminal-monochrome). These inform diagram language.
- **Spec/docs convention**: where do design docs live in this repo? (`docs/specs/`, `docs/rfcs/`, `notes/`, root). Match it.
- **Commit convention**: read `git log --oneline -20` to detect Conventional Commits, type-prefix style, etc. Match it.

If no site is detected and the user picked **Standalone** in Phase 0, skip per-SSG integration and prepare a single-file HTML deliverable.

**Exit**: written notes on palette, typography, generator, conventions.

### Phase 4 — Build the skeleton (~30 min)

Produce, in this order:

1. **Content file** with frontmatter for: title, description, template/layout, commit_sha (Phase 2), github_repo. Sections as Markdown `## Headings` (auto-generates anchor IDs in most generators).
2. **Page template/layout** that extends the site's base template, renders the prose, and emits a TOC from headings. Most SSGs expose a `page.toc` or equivalent.
3. **Diagram shortcode/component** that renders one hero SVG from `static/diagrams/how-it-works/<name>.svg` (or the SSG's equivalent assets directory). See `references/diagrams.md` for the **critical SVG-rendering pitfall** — most HTML minifiers lowercase `viewBox`, breaking inlined SVGs. Use `<img src=...>` if the site minifies HTML.
4. **CSS additions** for: page layout (TOC rail + prose), section headings, code blocks, asides, diagrams, scrollspy `is-active` state, mobile collapse. Use the site's existing custom properties — don't introduce new colors.
5. **Scrollspy JS** (~30 lines vanilla) using `IntersectionObserver` to highlight the active TOC item.
6. **Navigation entry points**: footer link, plus a subtle home-page link (avoid banners).

For Standalone mode: collapse all of the above into one HTML file with `<style>`, `<script>`, and inline SVG.

**Exit**: site builds. Page renders at `/how-it-works/` (or equivalent). All seven diagrams visible. TOC works. Build commands all pass (`zola check`, `hugo`, `next build`, etc.) and any test suite is unaffected.

### Phase 5 — Author the diagrams (~30 min)

Read `references/diagrams.md` before drawing anything. Critical points:

- Match the site's aesthetic. If the site is terminal-style monospace, the diagrams are too. If it's modern sans-serif with rounded corners, ditto.
- Use the palette's tokens. A color hardcoded once at the top of each SVG (necessary if the site minifies HTML and you load via `<img>`) is fine; a divergent color is not.
- One hero diagram per section. Each diagram tells the section's story without reading the prose.
- Ship as static files in `static/diagrams/how-it-works/`. Include `<title>` and `<desc>` for screen readers.

**Exit**: 5–7 SVG files render correctly in the browser, the file sizes are sensible (under ~3 KB each), and a screenshot of any one of them looks like the site.

### Phase 6 — Write and humanize (~45 min)

Write each section to the spec from Phase 2. Then apply the writing pass in `references/writing.md` — Michael Lynch's principles plus the humanize checklist. This is not optional. Default LLM prose has a flavor that erodes credibility on HN and Lobsters specifically; the humanize pass is the difference between "AI writeup" and "engineer's writeup".

The pass focuses on:

1. **Lede**: title + first three sentences answer "is this for me?" and "what do I get?".
2. **Section openers**: lead with the point, not the setup. No throat-clearing.
3. **Active verbs, plain words**: kill "leverage", "utilize", "delve", "plethora" on sight.
4. **Em-dash variation**: comma, period, parenthetical, restructure.
5. **Heading skim test**: reading only the headings should communicate the architecture.

**Exit**: word count near the target (default ~2,000 words for a 5–7 section page); rebuild is clean; visual check in browser is acceptable.

## Project Memory Conventions

Respect existing repo conventions discovered in Phase 3:

- Spec / design doc location (`docs/specs/`, `docs/rfcs/`, etc.)
- Commit message style (Conventional Commits, semantic prefixes)
- Test commands and CI gates
- CLAUDE.md / AGENTS.md guidance, if any

If the user has Claude Code memory entries about commit conventions or doc locations, those override skill defaults.

## Deliverables Checklist

At completion, the following exist and pass:

- [ ] Design spec committed to the repo's spec dir
- [ ] `/how-it-works/` page (or equivalent route) built and routable
- [ ] 5–7 hero SVG diagrams render correctly in the browser
- [ ] Right-rail TOC with working scrollspy highlights the active section
- [ ] Footer link to `/how-it-works/` from the rest of the site
- [ ] Subtle home-page entry-point link
- [ ] Code excerpts pinned to a specific commit SHA, with footer note linking to current source
- [ ] Build commands pass (SSG build, link check, type check)
- [ ] Test suites pass
- [ ] Page passes the headings-only skim test
- [ ] No "leverage", "utilize", "delve", "plethora", "tapestry" in the prose

## Common Failure Modes

- **HTML minifier breaks inlined SVGs.** Lowercases `viewBox` to `viewbox`. Browser ignores the attribute, SVG renders at default 300×150. **Fix:** load SVGs via `<img src=...>` instead of inlining; or disable HTML minification for this page. See `references/diagrams.md`.
- **Diagrams look generic.** Common when authored without reading the existing site CSS. Always read existing styles first; copy the visual signature.
- **Prose reads as AI-generated.** Skipping Phase 6 produces a writeup that scans poorly on HN. Always run humanize + Lynch.
- **Section count creep.** 5–7 is the sweet spot. Past 8, readers stop. Past 9, the page is a different kind of artifact (a book chapter), and you should split.
- **Pinned SHA gets stale.** When code excerpts diverge meaningfully from `main`, update the pin. Don't pretend the page is a living doc — it's not.

## References

- [`references/writing.md`](references/writing.md) — Michael Lynch's principles, humanize checklist, before/after examples
- [`references/diagrams.md`](references/diagrams.md) — SVG authoring guide, the minifier pitfall, palette extraction, accessibility
- [`references/integration.md`](references/integration.md) — per-SSG notes (Zola, Hugo, Jekyll, Astro, Next.js, plain HTML, standalone)

## Worked Example Guidance

When publishing an example, use a public repository with permission to reference its code and assets. Keep examples generic in this skill body so the workflow stays reusable across private, work, and personal projects.
