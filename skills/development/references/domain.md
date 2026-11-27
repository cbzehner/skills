# Development domain language

- **Operator** — owns product intent, scope approval, accepted risk, and the
  initial merge and rollback authority.
- **Proposal** — mutable, reviewable root intent. Intake records source,
  problem, outcome, criteria, exclusions, decisions, assumptions, and open
  questions. Scoping adds the proposed graph before presentation.
- **Request** — an explicitly approved statement of intent bound to exact
  artifact paths at a state-repository presentation commit.
- **Root Request** — the complete outcome and user journey ultimately validated
  after its delivered leaves compose.
- **Leaf Request** — one independently deliverable part. It owns one Plan,
  worktree, Candidate lineage, V&V result, Review, and pull request.
- **Plan** — the approved implementation and evidence approach for one leaf. It
  cannot change the Request.
- **Attempt result** — one bounded Build invocation's claim about provenance,
  base, changed surfaces, checks attempted, Candidate, and unresolved work.
- **Candidate** — the exact commit proposed as one leaf's implementation.
- **V&V report** — verification and outcome-validation evidence bound to an
  approved Request revision and Candidate, or to an exact root composition.
- **Review** — maintainability and advancement judgment over one V&V-passing
  Candidate. Counsel is advisory input.
- **Release** — admission of the exact reviewed Candidate to the default branch,
  proven by provider read-back.
- **Observation** — bounded post-deploy evidence binding the merge to deployed
  identity, health, outcome, classification, and stop reason.

Do not introduce WorkItem, Run, Claim, worker, queue, schedule, or effect-journal
entities until work must wait or recover independently of the primary session.
