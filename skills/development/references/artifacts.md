# Artifact contracts

Development artifacts are Markdown with small YAML identity envelopes. The
primary session is their only writer. Bodies describe behavior and durable
contracts, not current file paths, line numbers, or code excerpts.

The conventional layout is:

```text
~/Library/Application Support/Development/
  state/repositories/<repo-key>/work/<handle>/
    proposal.md
    requests/root.md
    approvals/scope.md
    leaves/<leaf>/
      request.md
      plan.md
      plan-approval.md
      attempts/<timestamp>.md
      candidate.md
      publication.md
      vv.md
      review.md
      release.md
      observation.md
```

`DEVELOPMENT_HOME` overrides the root. Commit meaningful boundaries to the
small state repository; do not commit transcripts or polling noise. Place
source worktrees according to the target repository's convention and record
their absolute paths. Git's worktree registry is authoritative.

## Core artifacts

- **Proposal** preserves source, problem, outcome, criteria, exclusions,
  decisions, assumptions, and open questions. Scoping adds the proposed
  Request graph and criterion coverage. It has no execution authority.
- **Request** preserves approved intent. A leaf names its problem, outcome,
  stable acceptance-criterion IDs, exclusions, dependencies, and independent
  delivery. A root preserves the complete approved graph.
- **Plan** chooses the smallest implementation and evidence approach without
  changing its Request. It maps each criterion to verification and outcome
  validation.
- **Approval** records a presentation commit, exact artifact paths, UTC time,
  and Operator words. Scope and Plan approvals are separate and immutable. A
  listed path that differs from its presentation commit makes the approval
  stale; create a new presentation and approval instead of editing the old one.
- **Attempt result** records requested and observed model provenance, exact
  base, changes, checks attempted, unresolved work, and Candidate claim.
- **Candidate** records the exact commit, base, worktree, approved scope and
  Plan presentation commits, and the Git commands used to establish identity
  and cleanliness.
- **V&V report** names the approved scope presentation and Candidate SHA (or
  root composition SHA), maps every criterion to fresh evidence, records gaps,
  and gives a verdict. `pass` requires complete coverage and no gaps.
- **Review** names the current Candidate, findings and dispositions, accepted
  risks, counsel session, and verdict. `accepted` permits no unresolved
  blocking finding.
- **Publication, Release, and Observation** preserve relevant provider
  read-backs. Observation also records environment, expected and deployed
  identity, deadline, poll cap, samples, classification, and stop reason.

Use the bundled Proposal, Request, Plan, and Approval templates as starting
shapes. Add detail only when it serves the current Request or evidence.

Acceptance criteria use stable identifiers:

```markdown
- [ ] AC-1: A returning user can apply a saved search after reload.
```

Valid terminal Observation classifications are `healthy`, `not-applicable`,
`blocked`, `deployment-failed`, and `regression`.
