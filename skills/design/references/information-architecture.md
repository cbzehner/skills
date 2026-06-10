---
name: information-architecture
description: Structures information and navigation. Use for IA, sitemap, menus, labels, content models, taxonomy, search, filters, and page hierarchy.
argument-hint: "[site, product area, or content set]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

# information-architecture

Organize content and navigation so users can form a reliable mental model of the site or product.

## When to Use

- The user asks for IA, sitemap, navigation, menus, labels, taxonomy, page hierarchy, search, filters, or content organization.
- A server-rendered site needs clear page structure.
- Users are likely to ask "where do I find X?" or "what does this label mean?"

## When NOT to Use

- The issue is visual polish on a single page.
- The issue is wording quality inside an already-correct structure; use content design.
- The issue is cross-channel service delivery; use service design.

## What to Skip

- Do not mirror database tables as navigation.
- Do not create clever labels when plain terms would work.
- Do not assume every object deserves a top-level page.

## Workflow

1. Inventory the content and tasks.
   List what users need to find, understand, compare, create, edit, or revisit.

2. Group by user mental model.
   Organize around user goals and stable domain concepts, not internal implementation boundaries.

3. Choose navigation levels.
   Keep global navigation short. Use section navigation, breadcrumbs, filters, and contextual links for depth.

4. Draft labels.
   Prefer concrete nouns and verbs users would say. Avoid branded abstractions unless the brand term is already understood.

5. Define page hierarchy.
   Identify index, detail, create/edit, settings, help, and policy pages. Decide what belongs together and what deserves separation.

6. Specify search and filters.
   Distinguish search from filtering, sorting, saved views, and browsing. Each should have a clear job.

7. Test with scenarios.
   Run 3-5 user tasks through the structure and note where labels or placement cause hesitation.

## Examples

- "Restructure the account area" -> global/account nav, settings groups, destructive actions, billing, members, security.
- "Create a sitemap" -> top-level pages, child pages, utility pages, and cross-links.
- "Fix search/filter UX" -> separate query, facets, sort, empty results, and clear-all behavior.

## Failure Handling

If the domain vocabulary is unclear, preserve existing user-facing terms and list candidates for validation. If two structures are plausible, show both with tradeoffs.
