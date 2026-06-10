# Advisor Prompt Template

## Prompt

```
Here is the current state of a {plan|project}:

---
{context}
---

What is the single smartest and most radically innovative and accretive and
useful and compelling addition you could make at this point?

Rules:
- Propose exactly ONE addition, not a list
- Explain WHY it's high-leverage — what does it unlock?
- Be specific and concrete, not vague ("add AI" is not an answer)
- Consider what's missing, not what's already there
- Think about 10x improvements, not 10% improvements
```

**Why one idea:** Forcing a single proposal prevents brainstorm dumps and
requires the model to prioritize. Three models x one idea = manageable
diversity without overwhelm.

## Advisors

1. **Host-native advisor** (the current host — Claude or Codex depending on environment)
2. **Gemini** (Bash) — `gemini -p "{prompt}" --model gemini-3.1-pro-preview --sandbox -o text`
3. **Codex** (Bash) — `bash codex-adapter.sh "{prompt}"` (prefers companion plugin, falls back to CLI — see [codex-adapter.sh](../codex-adapter.sh))

**Host-as-advisor:** Don't double-count. If you're in Codex, skip the Codex CLI
call — the host IS the Codex advisor. If you're in Claude, skip `claude -p`.

**Note:** Gemini and Codex CLIs require permission allowlisting. If not configured,
the host-native advisor alone is still valuable — one strong proposal beats none.
