# Integration — per-SSG notes

Per-generator integration patterns. Phase 3 of the workflow detects which one applies; this reference shows the specifics.

## Detection commands

```bash
# Quick triage
test -f config.toml && grep -q "base_url" config.toml && echo zola
test -f config.yaml -o -f config.toml -o -f hugo.yaml && grep -q "baseURL" config.* 2>/dev/null && echo hugo
test -f _config.yml && echo jekyll
test -f astro.config.mjs && echo astro
test -f next.config.js -o -f next.config.mjs && echo next
test -f gatsby-config.js && echo gatsby
test -f .eleventy.js -o -f eleventy.config.js && echo eleventy
```

If none match, fall through to **standalone** mode.

---

## Zola

**Templating**: Tera (Jinja-like).

**Files to create:**

```
content/how-it-works.md            # frontmatter + prose
templates/how-it-works.html        # extends base.html
templates/shortcodes/diagram.html  # SVG shortcode
static/diagrams/how-it-works/*.svg # SVGs (served as static)
static/js/scrollspy.js             # vanilla scrollspy
```

**Content frontmatter:**
```toml
+++
title = "How it works"
description = "..."
template = "how-it-works.html"
insert_anchor_links = "left"

[extra]
commit_sha = "abc1234"
github_repo = "https://github.com/owner/repo"
+++
```

**TOC**: `page.toc` exposes a list of `{id, title, level, children}`. Iterate in the template.

**Critical**: `minify_html = true` in `config.toml` lowercases SVG `viewBox`. Use `<img>` not inline. See `diagrams.md`.

---

## Hugo

**Templating**: Go templates.

**Files to create:**

```
content/how-it-works/index.md      # page bundle
layouts/_default/how-it-works.html # custom layout (or assign via Type)
layouts/shortcodes/diagram.html    # SVG shortcode
assets/diagrams/how-it-works/      # processed
static/diagrams/how-it-works/      # or unprocessed
static/js/scrollspy.js
```

**Content frontmatter:**
```yaml
---
title: "How it works"
layout: how-it-works
params:
  commit_sha: "abc1234"
  github_repo: "https://github.com/owner/repo"
---
```

**TOC**: `{{ .TableOfContents }}` produces ready-rendered HTML. Or iterate `.Fragments.Headings` for full control.

**Shortcode**: `{{< diagram name="overview" caption="..." >}}`.

**Minification**: `minify` in config can affect SVG. Test the rendered HTML for case-preserved `viewBox`.

---

## Jekyll

**Templating**: Liquid.

**Files to create:**

```
how-it-works.md                   # at root or in a collection
_layouts/how-it-works.html        # custom layout
_includes/diagram.html            # SVG include
assets/diagrams/how-it-works/     # SVGs
assets/js/scrollspy.js
```

**Content frontmatter:**
```yaml
---
layout: how-it-works
title: "How it works"
permalink: /how-it-works/
commit_sha: abc1234
github_repo: https://github.com/owner/repo
---
```

**TOC**: Jekyll has no built-in TOC. Use the `jekyll-toc` plugin (adds `{{ content | toc_only }}`), or generate via JS at runtime by reading `h2[id]` from the page.

**Include**: `{% include diagram.html name="overview" caption="..." %}`.

**Minification**: typically no built-in HTML minification. Inlining SVG works.

---

## Astro

**Templating**: JSX-like in `.astro` files.

**Files to create:**

```
src/content/pages/how-it-works.md   # or .mdx for component support
src/layouts/HowItWorks.astro        # custom layout
src/components/Diagram.astro        # SVG component
public/diagrams/how-it-works/       # static SVGs
src/scripts/scrollspy.ts
```

**Content frontmatter:**
```yaml
---
title: "How it works"
layout: ../layouts/HowItWorks.astro
commitSha: abc1234
githubRepo: https://github.com/owner/repo
---
```

**TOC**: Astro's `getHeadings()` on the markdown content imports headings. Use in the layout to render the TOC.

**MDX**: if using `.mdx`, you can use the `<Diagram name="overview" />` component directly in the Markdown. With plain `.md`, fall back to a remark plugin or string-replace shortcode.

**Minification**: `compressHTML: true` in `astro.config` may lowercase. Test.

---

## Next.js (App Router)

**Templating**: React/JSX.

**Files to create:**

```
app/how-it-works/page.tsx          # the page
app/how-it-works/HowItWorks.mdx    # or .mdx for content
components/Diagram.tsx             # SVG component
public/diagrams/how-it-works/      # static SVGs
```

**TOC**: Use `rehype-slug` to add IDs and `rehype-toc` (or extract headings via remark) to generate the list. Render in a sticky aside.

**Code highlighting**: `shiki` or `rehype-pretty-code` is standard.

**MDX setup**: requires `@next/mdx` or similar. The `<Diagram>` JSX component imports the SVG: `import OverviewDiagram from '/public/diagrams/how-it-works/overview.svg'` (with `next/image` or similar SVG loader).

**Minification**: Next.js does not aggressively minify HTML. Inlining is generally safe; loading via `<img>` or `<Image>` is safer.

---

## Eleventy

**Templating**: Nunjucks, Liquid, etc. — pluggable.

**Files to create:**

```
src/how-it-works.njk              # or .md with layout
src/_includes/layouts/how-it-works.njk
src/_includes/diagram.njk
src/diagrams/how-it-works/        # SVGs
```

**TOC**: `eleventy-plugin-toc` is the common choice. Add it to the layout.

**Shortcode**: register a `diagram` shortcode in `.eleventy.js` that reads from a static dir.

**Minification**: depends on the post-build pipeline. Test.

---

## Gatsby

**Templating**: React, MDX.

**Files to create:**

```
src/pages/how-it-works.mdx        # or a content node + page template
src/components/HowItWorksLayout.tsx
src/components/Diagram.tsx
static/diagrams/how-it-works/
```

**TOC**: `gatsby-remark-autolink-headers` and a custom MDX component that reads `tableOfContents` from the page query.

**Minification**: production builds minify HTML; test for `viewBox` preservation.

---

## Plain HTML

If the site is hand-written HTML with no generator:

**Files to create:**

```
how-it-works.html         # the full page
how-it-works.css          # page-specific styles (or appended to existing)
how-it-works.js           # scrollspy
diagrams/how-it-works/    # SVGs
```

Reuse the existing site's `<head>` includes (CSS, fonts, analytics). Hand-write the TOC and reference each `<section id="...">`.

---

## Standalone (no site)

When no SSG is detected and the user picked **Standalone**: produce one self-contained HTML file at the user's chosen path (default: `how-it-works.html` in the repo root).

**Single file structure:**

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>How it works</title>
  <style>
    /* full page CSS inlined here */
  </style>
</head>
<body>
  <article>
    <header><!-- title + lede --></header>
    <nav class="toc"><!-- right rail --></nav>
    <main>
      <section id="overview">
        <h2>Overview</h2>
        <figure><svg>…</svg></figure>  <!-- inlined; no minifier in this path -->
        <p>…</p>
        <pre><code>…</code></pre>
      </section>
      <!-- more sections -->
    </main>
  </article>
  <script>
    // scrollspy inlined
  </script>
</body>
</html>
```

Constraints:

- All CSS, JS, and SVG inlined — single file, no dependencies.
- Choose a palette that works on its own. Default: dark navy background, light foreground, single accent color. Provide it as CSS custom properties at the top.
- File size under ~150 KB for ~2,000 words and 7 diagrams. SVGs should be the bulk.
- Test by `open how-it-works.html` (no server required).

This mode is the right deliverable for backend services, libraries, or any repo without a public site. Host it on GitHub Pages, an internal wiki, or just commit the file and link to it from the README.

---

## Universal: code excerpts pinned to SHA

Whatever the SSG, the code excerpts must be pinned to a commit SHA, not `main`. The pattern:

1. Capture the SHA at write time: `git rev-parse HEAD`.
2. Store it in the page's frontmatter as `commit_sha`.
3. In the page template, render a footer note:
   ```
   Code excerpts are pinned to commit `abc1234`.
   Browse the current source at github.com/owner/repo.
   ```
4. The link to GitHub uses `tree/<sha>` so it points at the snapshot the prose describes.

This trades durability for "freshness". The SHA can be bumped when a section is rewritten to reflect significant code changes — but never silently.
