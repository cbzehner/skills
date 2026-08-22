# Mixed lanes

Use mixed models when the user asked for them or when one model would grade its own coverage. Bound concurrency to the number of reports you can verify.

Default mix:

| Lane | Role | Invocation |
|---|---|---|
| Grok explore | Several disjoint subsystems in parallel | Read-only explore agent, one subsystem per agent |
| Claude Opus | One heavier subsystem | `claude -p --model opus --permission-mode auto --disallowed-tools "Edit,Write,NotebookEdit" --output-format text` |
| Codex Sol | One heavier subsystem | `codex exec -m gpt-5.6-sol -s read-only --ephemeral --dangerously-bypass-hook-trust` |

Keep Claude and Codex at one live job each unless you can harvest more. Use `caffeinate -i` on long local CLI runs so the machine does not sleep mid-review.

Write worker prompts and reports outside the target repo. Confirm `git status --porcelain` stays empty after every batch.

If a lane is unavailable, continue with the remaining lanes. Do not invent findings to replace a missing model. Note the gap in the audit log.

Harvest completed workers. Do not interrupt a productive worker only because it is slow. Close a worker after its report is copied into the scratchpad.
