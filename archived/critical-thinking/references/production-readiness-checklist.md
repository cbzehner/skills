# Production Readiness Checklist

Extends `verification-before-completion`. That skill checks "does it run?" This checklist checks "is it finished?"

Use after verification passes but before claiming work is complete.

## Code Completeness Scan

Search the codebase for incomplete markers:

Use Grep (the dedicated tool, not bash grep) to search for these patterns in source files, excluding test directories:

**Stubs and placeholders:**
Pattern: `TODO|FIXME|HACK|XXX|STUB|PLACEHOLDER|TEMP|REMOVEME`

**Unimplemented markers:**
Pattern: `unimplemented!|todo!|NotImplementedError|raise NotImplemented|panic\("not implemented"\)`

**Mock/fake data in non-test code:**
Pattern: `mock_|fake_|dummy_|test_data|hardcoded|localhost:`
Exclude: test directories and test files (by path, not by content)

**Placeholder values:**
Pattern: `YOUR_.*_HERE|CHANGEME|REPLACE_ME|example\.com`

## Evaluation

For each hit:
1. **Is this intentional?** Some TODOs are legitimate future work. Mark them with a tracking issue.
2. **Is this blocking?** Stubs in the critical path must be resolved before shipping.
3. **Is this test-only?** Mock data in test files is fine. Mock data in src/ is not.

## When to Skip

- Exploratory prototypes (not shipping)
- Test files (mocks are expected)
- TODO items with linked issues (tracked, not forgotten)
