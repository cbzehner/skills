# Categorization Guide

## User Interest Categories

- **CS developments**: PLT, systems, algorithms, novel research
- **Agentic coding**: AI-assisted development, agent workflow techniques, LLM tooling, prompt engineering
- **Business & technology**: Startup automation, SaaS, developer tools, product strategy
- **Engineering leadership**: Team management, hiring, technical decision-making, org design

## Per-Bookmark Decisions

For each bookmark, determine:
1. **Category**: `cs-developments`, `agentic-coding`, `business-tech`, `engineering-leadership`, or `skip`
2. **Reuse class** — how this item can change future behavior, if at all:
   - `ignore` — generic advice, hype, outrage bait, meme, or nothing durable
   - `note` — a useful one-off idea worth remembering
   - `prompt` — a reusable prompt framing
   - `workflow` — a repeatable process worth writing down
   - `skill` — a repeatable behavior with a clear trigger (candidate for `/create-skill` — suggest, don't build)
   - `script` — a deterministic operation worth automating

   Decision rule: **if it doesn't change future behavior, it isn't a skill or workflow yet — file it as `note` or `ignore`.**
3. **Key insight**: One-line summary of what's valuable
4. **Actionable?**: Is there something concrete to try, adopt, or investigate?
5. **Source**: Author + handle + link for attribution
6. **Duplicate?**: Search existing insight files for the URL, tweet ID, title, and author before writing

Items classed `ignore` are **not silently dropped.** Record them in the run's ignore ledger with a one-line reason (see Summary), so a later pass can audit what was discarded and why.

## Entry Quality Rules

- **Capture the claim, not a teaser.** The entry must be useful without re-fetching the source: include the specific numbers, named techniques, or concrete steps that made the bookmark worth saving. "Extends context engineering to include architectural constraints" is a teaser; "compact formats cost up to 740% more tokens because models cycle through familiar patterns" is an insight.
- **"Read `<link>`" is not an action item.** Either read and summarize the link during this run (enrichment), or file the item as a plain `note` without a checkbox. Action items are reserved for concrete try/adopt/change steps the user could complete without the source.
- **Reserve `#actionable` for entries with a "Worked if" line.** If you can't state an observable success signal, it isn't actionable — tag it `#tool` or `#pattern` or leave it untagged.
- **Build source links from `author_handle`, never the display name** (`https://x.com/<handle>/status/<id>`; if the handle is unknown, use `https://x.com/i/status/<id>`). Display names contain spaces and produce broken URLs.

## Vault Entry Format

For each category, append new entries to the corresponding file in `$INSIGHTS_DIR/<category>/`. Use this format:

```markdown
## [Short Title] — @author (@handle)
_Source: [link] | Date processed: YYYY-MM-DD_

Key insight summary.

**Action items** (if any):
- [ ] Concrete next step

**Worked if** (only for #actionable / #pattern items): <observable result that proves the idea paid off>
**Anti-pattern** (only for #actionable / #pattern items): <the failure mode this is meant to avoid>
```

Group related bookmarks into the same note if they cover the same topic. Create new files per topic rather than one giant file per category. Use descriptive filenames like `rust-async-runtimes.md` or `ai-code-review-patterns.md`. When a topic file exceeds ~15 entries, split it into narrower subtopics instead of appending further — a 50-entry file is a category in disguise.

Use `[[wikilinks]]` to connect related notes across categories. Tag notes with `#actionable`, `#tool`, `#pattern`, or `#question` as appropriate.

## Idempotency Rules

- If the same URL or tweet ID already exists, skip the bookmark unless the new export has materially better text.
- If a different bookmark repeats the same idea, merge it into the existing topic note as an additional source instead of creating a new note.
- Preserve source attribution for every imported idea; never collapse multiple sources into an unattributed synthesis.
- Do not move the export to `processed/` until duplicate checks and vault writes have completed.
