## What

Adds one community knowledge article in the `testing` domain with a good and a bad AL sample:

- `community/knowledge/testing/enumextension-in-test-app-injects-interface-doubles.md`
- `…/enumextension-in-test-app-injects-interface-doubles.good.al`
- `…/enumextension-in-test-app-injects-interface-doubles.bad.al`

The fact: when behaviour is dispatched through an enum whose values carry `Implementation = <Interface> = <Codeunit>`, the value on the record decides which codeunit runs, so setter injection has nothing to hook into. The seam is an `enumextension` in the **test app** that adds a test-only value pointing at a double; the production consumer runs unchanged. That requires the production enum to declare `Extensible = true` (default is false).

## Why this is a knowledge file (admission test)

Asked to test record-driven dispatch, models leave the enum closed and drive the consumer through the real implementation, add a test-mode flag, or ship a `Mock` value in the production enum. A cold review of the neutralised bad sample by a fresh model missed the closed enum entirely and even doubted that assigning an enum value to an interface variable is valid AL. The existing interfaces articles cover setter injection and the dispatch pattern, not the test-app seam.

## Overlap check

- `microsoft/knowledge/interfaces/assign-codeunit-to-interface-for-testability.md` — setter injection when the consumer owns the dependency. This article covers the case where the enum value on the record selects the implementation and no setter exists; it cross-references that file in its Description.
- `microsoft/knowledge/interfaces/prefer-interface-over-case-branching.md` — the dispatch pattern itself, no testing angle; linked under See also.
- No article in any layer mentions `enumextension` as a test seam (`grep -ril enumextension` hits only the TableRelation article).

## Evidence

- Cold review (neutralised bad sample, no article): missed the closed enum; top finding was a false claim that enum-to-interface assignment is invalid.
- Warm review (article as the only rule): bad sample flagged at line 2, severity minor, citing the article path; good sample clean.
- Local CI: `validate_frontmatter.py` 0 errors, `Test-KnowledgeIndex.ps1` passed (274 articles), `Test-ReviewFixtures.ps1` passed (32 cases, 16 leaves).
- Fact verified on Microsoft Learn: Implementation property (runtime 5.0), `Extensible = true` required for enumextension, extension values carry their own Implementation (AS0067 examples).

## Checklist

- [x] Frontmatter has exactly the six required keys; `domain` matches the folder
- [x] `## Description` present; no fenced code blocks; under 100 lines; one concern
- [x] Samples referenced by filename from the article and present next to it
- [x] `validate_frontmatter.py`, `Test-KnowledgeIndex.ps1`, `Test-ReviewFixtures.ps1` pass locally
- [x] Only `community/` is touched

🤖 Generated with [Claude Code](https://claude.com/claude-code)
