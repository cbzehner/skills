# Lifecycle guide

Work only the first missing or stale boundary. Each stage reads the current
artifacts and observes any external fact it relies on. Keep procedures small;
the invariants in `SKILL.md` own advancement.

## Intake

Turn the source conversation or brief into a Proposal. Preserve each
load-bearing claim as confirmed intent, observed fact, assumption, question, or
contradiction. Ask only questions whose answers materially change purpose,
actor, workflow, boundary, or success. Do not decompose or plan implementation.

Exit when the Proposal is clear enough to scope. It is not yet approved.

## Scoping

Use one executable root unless decomposition creates a real delivery or risk
boundary. Otherwise create independently useful vertical leaf Requests; do not
split by database, API, and frontend layers. Map every root criterion to one or
more leaves and keep dependencies explicit.

Have the fixed read-only reviewer check intent preservation, criteria,
exclusions, coverage, dependencies, and independent delivery. Commit only the
exact Proposal and Request files as a presentation boundary, then present its
commit SHA, artifact paths, and graph. Record approval only for that exact
presentation.

## Ready

For one approved leaf, inspect the repository and create the smallest credible
Plan. Map every criterion to both repository-native verification and observable
outcome validation. Route unknown feasibility to `spike`, missing intent to
Scoping, and unexplained failure to `diagnose`.

Have the fixed Plan reviewer inspect the exact Plan. Commit it as a presentation
boundary, present its commit SHA and path, and wait for separate explicit
Operator approval. The Plan cannot change scope.

## Build

Create a dedicated worktree at the recorded base using the target repository's
convention. Give the Build invocation only the approved Request, Plan,
repository instructions, exact base, worktree, and result contract. It
implements the smallest approved change, runs honest checks, creates one clean
local commit, and stops. It does not push, write Development state, perform V&V,
or review itself.

Use `git worktree list --porcelain` to discover the registered path.
Independently check repository identity, clean status, worktree HEAD, and
ancestry from the approved base. Record the exact Candidate only when they pass.

## Publication

After confirming permission, push the Candidate without rewriting history.
Read GitHub before creating a draft PR so one branch has one PR; after any
write, read it again. The provider-reported head must equal the Candidate.

Ambiguous provider results require another read, not a blind retry.

## V&V

Re-establish the approved scope and Plan presentations, Candidate, worktree,
and PR head. Map every stable criterion to fresh evidence. Run applicable
tests, types, lint, builds, migrations, security checks, and CI, then exercise
the approved journey through its public interface. Green checks without
observed outcome validation cannot pass.

Record commands, evidence, gaps, and failure cause honestly. Any new Candidate
invalidates this report. After all leaves merge, repeat outcome validation for
the root Request against the observed default-branch composition.

## Review

Read the exact diff, Request, Plan, V&V report, repository context, and current
provider facts. Inspect alignment, maintainability, architecture, security,
complexity, integration, and repository conventions.

Run `counsel --panel` with a packet bound to the Candidate. Adjudicate its
claims against evidence. Every finding is fixed, explicitly accepted as risk,
deferred with rationale, or rejected with evidence. Accept only an unchanged
Candidate with passing V&V and no unresolved blocking finding.

## Release

Read the live PR immediately before admission. Confirm its head is the reviewed
Candidate, its base is the default branch, and repository-required checks and
reviews permit merge. Present those facts; the Operator performs the initial
merge.

Read GitHub again, fetch the default branch, and use Git to confirm the reported
merge is reachable before recording Release. A rebase creates a new Candidate
and requires fresh V&V and Review.

## Observe

Discover the repository's deployment provider and existing read-only probes.
Before polling, name the environment, expected identity, health and outcome
signals, deadline, and maximum poll count. Establish deployed identity before
interpreting product signals.

Stop at the first terminal result or the bound. No runtime is `not-applicable`;
identity mismatch is `deployment-failed`; identity-matched failure is a
`regression` and routes to `diagnose` and corrective work. Never mutate
production or roll back without separate explicit authority.
