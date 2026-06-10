---
name: counsel
description: >-
  Route thinking and second-opinion workflows. Use when the user wants
  conversational interrogation, adversarial critique, premortem analysis,
  external model counsel, comparison of approaches, or a high-leverage novel
  addition to an already coherent plan. Also use when the user says "magi" or
  asks to run a multi-model panel.
argument-hint: "[--interview|--adversarial|--panel|--wildcard] [question or plan]"
arguments:
  - request
license: MIT
effort: medium
allowed-tools: Bash Read Glob Grep Task Write
---

# Counsel

Pick exactly one mode first. Load only that reference file, then follow its workflow.

## Routing

| Intent | Mode | Load |
|---|---|---|
| Clarify a draft, decision, or plan through conversation | `--interview` | [references/interview.md](references/interview.md) |
| Evaluate reasoning, surface failure modes, or give a direct verdict | `--adversarial` | [references/adversarial.md](references/adversarial.md) |
| Bring in external model counsel for a decision worth the latency, including "magi" requests | `--panel` | [references/panel.md](references/panel.md) |
| Add one high-leverage novel idea to an already coherent plan | `--wildcard` | [references/wildcard.md](references/wildcard.md) |

## Boundaries

- Interview mode asks one question at a time; it does not give a verdict.
- Adversarial mode gives a verdict; it does not interview unless a blocking ambiguity prevents analysis.
- Panel mode is for decisions worth external latency; do not use it for trivial questions.
- `magi` is trigger vocabulary for panel mode, not a separate active skill. Use `counsel --panel`.
- Wildcard mode is for plans that are already coherent; do not use it to rescue vague requirements.

## Handoffs

- If the user needs a durable PRD, issue, or implementation plan, route to `plan`.
- If repo/product terminology is fuzzy or conflicts with code/docs, route to `domain-model audit`.
- If the user needs findings against a concrete diff, artifact, screenshot, or release candidate, route to `review`.
- If a question uncovers an unexplained failure, route to `diagnose`.

## Output

End with a short mode-specific result:

- `--interview`: resolved decisions and remaining open questions.
- `--adversarial`: verdict, weakest assumptions, and recommended revision.
- `--panel`: synthesis and saved session path when available.
- `--wildcard`: one proposed addition, why it matters, and the smallest next step.
