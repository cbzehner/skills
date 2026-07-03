---
name: handoff
description: >-
  Write a clipboard-ready prompt to delegate a task to another agent or
  fresh session. Use when the user says "handoff", "write a handoff",
  "delegate this", "give me a prompt for another agent", or wants a
  portable, path-free prompt that another model can pick up cold.
argument-hint: "[short task title]"
arguments:
  - task
license: MIT
effort: medium
allowed-tools: Read Bash Glob Grep
metadata:
  based-on: "OpenClaw handoff skill by Peter Steinberger"
  upstream: "https://github.com/openclaw/agent-skills/tree/main/skills/handoff"
---

# Handoff

Write a standalone prompt another agent can pick up cold. The receiving agent owns the work — your job is to give them clean starting context, not a command-and-control script.

## Use When

- User asks for a "handoff", says "delegate this", or wants "a prompt for another agent".
- Switching models mid-task (e.g. Claude → Codex, Opus → Sonnet, or to a fresh session).
- Routing work to an overnight harness (`gnhf`-style runners) that won't have your conversation context.
- Capturing the right framing for a teammate to drop into their own Claude/Codex session.

## When NOT to Use

- The user wants you to do the work — write the handoff only if they explicitly ask.
- The work is one inline command away — just run it.
- A plan or design doc is the better artifact (route to `plan`, `design`).
- The task needs your current session's filesystem state to make sense — the handoff would be lossy.

## Core Constraint: Portable Anchors Only

The receiving agent does not share your working directory, your symlinks, your worktrees, or your shell. The prompt must work from a fresh repo checkout, a parent directory, or a home directory.

Forbidden in the prompt:

- Absolute paths (`/Users/...`, `~/Developer/...`).
- Repo-relative paths unless the user explicitly says "include the file path".
- Checkout names, worktree directory names, or local branch aliases.
- Implicit references to "the file we were just looking at".

Use these portable anchors instead:

- Repo `owner/name`, branch name, PR/issue URL.
- Module/package name, public symbol name, command name, config key.
- Exact error text, exact log line, exact search string.
- Docs page title, RFC number, ADR title.

## Workflow

### 1. Identify the task

If the user gave a short label, infer the rest from current repo, branch, recent discussion, linked issue/PR, and nearby docs. Do not invent goals the user did not state.

### 2. Gather starting context

Just enough for a fresh agent to orient — repo identity, relevant module/symbol names, known symptoms, constraints, non-goals. Do not perform the receiving agent's independent review for them.

If the handoff intentionally changes model tier or reasoning effort, include the
reasoning as a constraint. For Agent Platform SDLC work, use the counsel panel
matrix: Fable is an escalation reviewer only and should not be handed off above
medium effort; prefer Opus/GPT high or GPT xhigh, narrower task slicing, or human
arbitration over Fable xhigh.

```bash
git rev-parse --show-toplevel 2>/dev/null
git remote -v 2>/dev/null
git branch --show-current 2>/dev/null
gh pr view --json number,title,url,baseRefName,headRefName 2>/dev/null
```

### 3. Write the prompt

Use the template below. First instruction to the receiving agent is **review / discuss / assess** — never a bare command.

### 4. Copy to clipboard

Write the prompt to a temp file first, then `pbcopy` from the file. Avoid inline heredocs with backticks, `$`, or user-supplied text — quoting will bite you.

```bash
TMP="$(mktemp -t handoff.XXXXXX.txt)"
# ... write prompt to $TMP via Write tool ...
pbcopy < "$TMP"
```

On other platforms: `wl-copy`, `xclip`, or `clip.exe`. If none available, print the prompt and say clipboard copy was unavailable.

### 5. Confirm tersely

Final reply: one line. Task title + "copied to clipboard". Do not paste the full prompt back unless the user asks.

## Prompt Template

```text
I want to discuss and possibly work on: <short task title>

Context:
- <portable repo/product anchor — owner/name, package, product>
- <what triggered this task — issue, PR, observed behavior, user report>
- <known current state — branch name, PR URL, issue URL>
- <important constraints, non-goals, ownership boundaries>

Before any implementation:
- Find the right repository from the current directory, a parent directory, or the usual workspace.
- Read the local agent/repo instructions (AGENTS.md, CLAUDE.md, PHILOSOPHY.md, README).
- Inspect relevant code, tests, recent commits, and linked issue/PR state.
- Decide whether this task is still real, whether the proposed direction is good, and whether a smaller fix exists.
- Call out stale assumptions, hidden risks, and reasons to stop or rescope.

Task:
- <what to investigate or implement if the review supports it>
- <expected behavior or decision criteria>
- <non-goals>

Validation:
- <focused tests, commands, or live proof expected>
- <what evidence should be included in the response>
- <what is explicitly not required>

Output:
- Start with review findings and recommendation.
- Then propose a plan or patch summary.
- If code is edited, keep changes scoped and report exact verification commands run.
- Do not push, merge, close issues/PRs, label, or post public comments unless explicitly told.
```

## Quality Bar

- **No invented facts.** Anything you state as fact must come from the conversation, the repo, or a tool call. Mark inferred items "likely" or "unverified."
- **No path leakage.** Re-scan the final prompt. Rewrite any accidental path as a symbol, module, command, URL, or search string.
- **Right-sized context.** Enough for a fresh agent to orient; not a brain dump. If the prompt is over ~80 lines, you are dumping.
- **Review-first framing.** First real instruction to the receiving agent is to review and decide — not to execute.
- **Reversibility.** Tell the receiving agent not to push, merge, close, label, or post public comments unless explicitly authorized.

## Handoffs

- If the user actually wants to think through the problem first → `counsel`.
- If the work needs a structured plan, not a prompt → `plan`.
- If the user wants an overnight bounded run, not a prompt for a teammate → frame the prompt for `gnhf`-style execution (state the stop condition explicitly).
- If you cannot extract a single coherent task from the conversation → ask one clarifying question before writing.

## Examples

**Trigger prompts (should fire this skill):**

1. "write a handoff for the auth migration work so I can finish it tomorrow in a fresh session"
2. "delegate this to codex — give me a prompt I can paste"
3. "make a handoff for someone else to pick up the PR review"

**Anti-trigger prompts (should NOT fire this skill):**

1. "hand off the keys" (literal/idiomatic, not a delegation request)
2. "write a plan for the auth migration" (route to `plan`, not handoff)
