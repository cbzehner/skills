# Writing — Lynch principles + humanize

Read this before writing any prose for the page. The pass produces the difference between "AI writeup" and "engineer's writeup". HN and Lobsters readers downvote on tone alone.

## Lynch's principles (Refactoring English)

Source: Michael Lynch's book "Refactoring English: Effective Writing for Software Engineers" (refactoringenglish.com) and his blog mtlynch.io.

### 1. Get to the point

The title plus the first three sentences must answer two questions:

1. **Is this article for someone like me?**
2. **How will I benefit from reading it?**

If you reach paragraph two without answering both, the lede is broken. Rewrite.

**Bad lede:**
> The system you're reading about is a static site served by a single Cloudflare Worker. The Worker also handles the API, fetches data hourly, caches in KV, and triggers a daily rebuild. There's a Python pipeline that hands PDFs to an LLM and refuses to write the result if it looks wrong.

The reader doesn't know yet what the *site is for* — only its architecture.

**Good lede:**
> Swim Francisco is a live status board for fourteen places to swim in San Francisco: nine city pools and five open-water spots. One Cloudflare Worker serves the whole site — static pages, API, hourly data refresh, daily rebuild. A small Python pipeline hands pool schedule PDFs to an LLM and refuses to write the result if it looks wrong.

Now the reader knows: it's a swim-spot status board (audience filter), runs on one Worker (the interesting claim), and there's an LLM-PDF story (the hook for §3).

### 2. Make the headings tell the story

A reader who scans only the section headings should walk away with the architecture.

**Bad headings:**
- Performance
- Data Layer
- Background Tasks
- Edge Cases

**Good headings:**
- One combined `/api/conditions` endpoint
- Cloudflare Workers + KV
- LLM PDF extraction (kept honest)
- Day rollover at 00:05 PT

Each headline names the concrete mechanism, not the topic.

### 3. Lead each section with the point

The first sentence after a heading is not for restating the heading. It's for the punch.

**Bad section opener:**
> The hourly cron is what keeps the temps and tides on the board fresh. Each tick fetches the upstream sources, assembles a record per spot, and writes KV.

**Good section opener:**
> The hourly cron keeps temps and tides fresh. Each tick fetches the upstream sources, assembles a record per spot, and writes KV.

The "X is what does Y" construction is throat-clearing. Cut it.

### 4. Strong verbs, plain words

- "use" beats "leverage"
- "use" beats "utilize"
- "many" beats "myriad"
- "show" or "prove" beats "a testament to"
- "help" beats "facilitate"

See the kill-on-sight list below.

### 5. Vary sentence length deliberately

Human writing is lumpy. Mix short punchy sentences with longer ones. Three medium sentences in a row is a tell.

**Lumpy (good):**
> Stations go offline. The bay temperature sensor was dark for most of a week last winter. The page can't just show a dash and shrug — most readers want a number, even one a few hours old.

### 6. Cut aggressively

A paragraph that survives on its own without two of its sentences should ship without those two sentences.

### 7. Eliminate ambiguity

Every claim has one correct interpretation. If a sentence can be read two ways, the reader who picks the wrong one bounces.

## Humanize checklist

Adapted from the `humanize` skill. Apply line by line, not via regex. A word that's fine once is a tell when used three times.

### Kill on sight (overrepresented in LLM text)

| Replace                | With                            |
| ---------------------- | ------------------------------- |
| delve                  | dig into, examine, look at      |
| utilize                | use                             |
| leverage (verb)        | use, take advantage of          |
| facilitate             | help, enable                    |
| elucidate              | explain, clarify                |
| embark                 | start, begin                    |
| multifaceted           | complex, varied                 |
| tapestry               | (delete entirely)               |
| paradigm               | model, approach                 |
| holistic               | whole, complete                 |
| myriad                 | many                            |
| plethora               | many, lots of                   |
| underscore             | highlight, stress               |
| pivotal                | important, key                  |
| resonate               | connect with, hit home          |
| meticulous(ly)         | careful, thorough               |
| a testament to         | shows, proves                   |
| landscape (metaphoric) | field, space, area              |
| realm                  | area, field                     |
| interplay              | interaction, relationship       |
| foster                 | encourage, build                |
| robust                 | (often delete; or "reliable")   |
| seamless               | (often delete; or "no friction")|
| comprehensive          | full, complete                  |

### Filler phrases (delete entirely)

- "It's worth noting that…" / "It's important to note that…"
- "Let's dive into…" / "Let's explore…"
- "Here's the thing…" / "Here's why it matters…"
- "In today's fast-paced world…"
- "Without further ado…"
- "At the end of the day…"
- "It goes without saying…"
- "When it comes to…"
- "In the realm of…"

### Structural patterns to break

- **"Not just X, it's Y"** — most overused LLM rhetorical pattern. Rewrite as a direct statement.
- **Em-dash overload** — one or two per page is fine; five per paragraph is a tell. Vary the fix: comma, period, parenthetical, restructure.
- **Transition word chains** — "However… Furthermore… Additionally… Moreover…" at paragraph openings. Start paragraphs with subjects instead.
- **List symmetry addiction** — exactly 3 or 5 items, all same grammatical structure. Real lists are uneven.
- **Restating the heading in the next sentence** — readers just read the heading. Don't repeat.
- **Hedging chains** — "can," "may," "might," "could potentially," "it's possible that." State facts or admit uncertainty directly.

### Punctuation tells

- **Semicolon overuse.** Treat semicolons as suspicious in ordinary technical and product prose. Use a period or conjunction unless the register really wants one.
- **Colon overuse in headings.** "Topic: The Subtitle Pattern" repeated four times in a row. Vary heading styles.

## The pass itself

1. Read the full draft once before changing anything.
2. Lede pass: rewrite the opening to pass Lynch's two-question test.
3. Heading pass: read only the headings — do they tell the story?
4. Per-section: rewrite the first sentence of each section. Then read the rest looking for: passive voice, throat-clearing, restated headings, kill-on-sight words.
5. Em-dash audit: count every em dash. If a paragraph has more than one, vary at least one.
6. Word-by-word: scan for the kill-on-sight list. Every hit is replaced or cut.
7. Final read aloud (mentally). Does this sound like a specific human, or like a helpful assistant?

## Sanity check

After the pass, the prose should:

- Lose 10–20% of its word count vs. the first draft
- Have at least one short punchy sentence per major section ("It died fast." / "Stations go offline.")
- Pass `grep -iE 'leverage|utilize|delve|plethora|tapestry|robust|seamless|comprehensive'` with zero hits
- Read like a developer wrote it on a Tuesday after work, not like a corporate brochure
