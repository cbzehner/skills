# Diagrams — authoring, palette, the minifier pitfall

Read this before authoring any SVG.

## The critical pitfall

**Most HTML minifiers lowercase SVG attribute names.** `viewBox` becomes `viewbox`. SVG is case-sensitive, so the browser ignores the lowercased attribute. Inlined diagrams collapse to the SVG default 300×150 with no coordinate mapping. The figure box renders empty.

Affected minifiers (confirmed):

- Zola's `minify_html = true` (the `minify-html` Rust crate)
- Hugo's `minify` config in some configurations
- HTML minifier plugins for Astro, Eleventy, Next.js
- Any pipeline using `html-minifier-terser` with default options

### The fix

**Serve SVGs as `<img src=...>`, not inline.** Static files bypass the HTML minifier entirely, so case-sensitive attributes survive. The trade-off: `<img>`-loaded SVGs cannot inherit the parent page's `currentColor` (because they live in a separate document tree). Hardcode the palette colors inside each SVG.

```html
<!-- Bad: inlined SVG passes through HTML minifier -->
<figure>
  <svg viewBox="0 0 640 280">…</svg>  <!-- becomes viewbox, breaks -->
</figure>

<!-- Good: <img> bypasses HTML minifier -->
<figure>
  <img src="/diagrams/how-it-works/overview.svg" alt="Full-system flow">
</figure>
```

### When inlining is fine

- The site does not minify HTML (most Jekyll, Astro defaults, plain HTML)
- The minifier is configured to preserve case in SVG (rare, requires explicit option)
- You're producing a Standalone single-file deliverable (no minifier in the pipeline)

When in doubt: build the page once, inspect the rendered HTML for `viewBox` (capital B). If it's lowercased, switch to `<img>`.

## Palette extraction

Before drawing, read the site's existing CSS for color custom properties. Don't invent colors.

```bash
grep -oE -- '--[a-z-]+:\s*#[0-9a-fA-F]+|--[a-z-]+:\s*rgb' static/main.css | sort -u
```

Look for: `--bg`, `--fg`, `--accent`, `--border`, `--muted`, or whatever names this site uses. Map them:

- **Background** — diagram canvas
- **Foreground** — strokes, primary text
- **Accent** — emphasis, active states
- **Muted** — captions, secondary text

If the SVG is loaded via `<img>`, hardcode these colors directly into the SVG (e.g. `#f5c518`). If inlined, use `currentColor` and let the parent CSS set `color`.

## Aesthetic match

Read the site's existing pages before drawing. Look for visual signatures:

- **Departure-board / terminal**: monospace, uppercase labels, no shadows, no gradients, hard edges, single accent color. Diagrams should be 1970s-schematic flat.
- **Modern sans-serif / SaaS**: subtle drop shadows, rounded corners, mid-gray strokes, brand accent on key elements.
- **Brutalist / editorial**: heavy borders, large type, off-white background, asymmetry.
- **Hand-drawn / Excalidraw**: jittery strokes, hand-lettered text, intentional roughness.

The diagrams should look like they came out of the same designer's pen as the rest of the site. Pull a screenshot of an existing page side-by-side with the first diagram draft. If they look like cousins, you're done. If the diagram looks airbrushed and the site is brutalist, redraw.

## Authoring template

Start with this scaffold and adapt:

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 280" role="img"
     aria-labelledby="overview-title overview-desc">
  <title id="overview-title">Full-system flow</title>
  <desc id="overview-desc">
    Build pipeline writes static assets; the Worker serves them on fetch;
    the cron writes KV on scheduled ticks.
  </desc>
  <style>
    .b  { fill: none; stroke: #f5c518; stroke-width: 1.5; }
    .t  { fill: #f5c518; font-family: ui-monospace, "Share Tech Mono", monospace; font-size: 11px; letter-spacing: 0.05em; }
    .tl { font-size: 12px; font-weight: 700; letter-spacing: 0.08em; }
    .ts { font-size: 9.5px; opacity: 0.75; }
    .a  { fill: none; stroke: #f5c518; stroke-width: 1.5; marker-end: url(#arr); }
  </style>
  <defs>
    <marker id="arr" viewBox="0 0 10 10" refX="9" refY="5"
            markerWidth="7" markerHeight="7" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="#f5c518"/>
    </marker>
  </defs>

  <!-- nodes -->
  <rect class="b" x="20" y="100" width="120" height="40"/>
  <text class="t tl" x="80" y="125" text-anchor="middle">CLIENT</text>

  <!-- arrows -->
  <line class="a" x1="140" y1="120" x2="200" y2="120"/>
</svg>
```

Adapt class names and palette per site. Keep file size under 3 KB; if it's larger, simplify.

## One hero diagram per section

Each diagram tells the section's story without reading the prose. The reader who only looks at the diagrams should still understand the architecture.

**Pattern:** lead each section with the diagram, then the prose, then the code excerpt. The diagram primes the reader; the prose explains; the code grounds.

Avoid:

- Overloaded diagrams with 15+ boxes (the eye can't follow)
- Multiple diagrams per section without distinct purpose
- Decorative diagrams with no information value

## Accessibility

Every SVG needs:

- `<title>` — brief name (4–8 words)
- `<desc>` — what the diagram shows in plain language (1–2 sentences)
- `aria-labelledby` referencing both
- `role="img"`

When loading via `<img>`, also include a meaningful `alt` attribute that summarizes the diagram.

## File layout

```
static/diagrams/how-it-works/
├── overview.svg
├── api.svg
├── workers.svg
├── pdf-extraction.svg
├── cache.svg
├── day-rollover.svg
└── fallback.svg
```

One filename per anchor, kebab-case, matching the section's anchor ID. The shortcode/component takes a `name` argument and resolves to `<assets>/diagrams/how-it-works/<name>.svg`.

## Common mistakes

- **Drawing the architecture you wish you had**, not the one you have. Diagrams that depict aspirational future state confuse readers when they look at the actual code.
- **Boxes labeled with class names instead of concepts.** "OAuth2TokenInterceptor" doesn't help the reader. "Auth check" does.
- **Arrows without labels.** A request arrow without "GET /api/foo" or "JSON write" leaves the reader guessing.
- **Decorative typography in the SVG.** Use the site's existing font stack. Don't introduce fonts the rest of the site doesn't use.
