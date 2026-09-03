# Scout — topic: writing through ChangeCompany

Source: topic sentence from the user ("writing to a table with ChangeCompany is an anti-pattern, no?"), prompted by the Learn page for `Record.ChangeCompany`.
Corpus at triage time: upstream `main` bca8f47, 300 indexed articles (microsoft 17 domains, community 6 domains).
Source fingerprint: 7c1e4a9d02b3
Gates: A = admission (remedial for an LLM?), B = overlap (already in the corpus?), C = portability (survives without the company policy?).

| # | Candidate | Domain (leaf?) | Verdict | Why | Overlap | Proposed slug |
|---|---|---|---|---|---|---|
| 1 | Triggers, field validation and trigger-event subscribers run in the calling company after `ChangeCompany`; a write with `RunTrigger = true` or `Validate` stores the row in the target company but fills it from the caller's setup, and subscriber side effects land in the caller. | events (yes) | **contribute** (verified) | Learn, ChangeCompany Remarks: "Even if you run the ChangeCompany method, triggers still run in the current company, not in the company that you specified." The method name suggests the record becomes a target-company record, so a model calls `Validate`/`Insert(true)` on it. No corpus article states the fact; the only ChangeCompany article is about per-row cache cost. Alternative verified on Learn: `StartSession` has a `Company` parameter (runtime 1.0). Carve-out: reads, and `Insert(false)`/`Modify(false)`/`Delete(false)` into an owned trigger-free hand-off table. | delta of community/knowledge/performance/changecompany-in-loop-drops-caches.md (cost of the call, not its execution context) | changecompany-runs-triggers-in-the-calling-company |
| 2 | Writing through ChangeCompany at all is an anti-pattern | — | reject | Not a BC fact as stated. Learn does not forbid writes; `Insert()`/`Delete()` without `RunTrigger` skip the trigger code, and hand-off tables are a legitimate design. The portable fact is #1. | — | — |
| 3 | `ChangeCompany` per row drops caches | performance (yes) | covered | Already on BCQuality. | community/knowledge/performance/changecompany-in-loop-drops-caches.md | — |

In-flight: `gh pr list --repo microsoft/BCQuality --state open --search` for `changecompany`, `startsession`, `cross-company`, `multi-company` returns only PR #148 (Job Queue reliability; adjacent, not the same fact).

## Shortlist

1. `events/changecompany-runs-triggers-in-the-calling-company` — crisp signal (`ChangeCompany(<name>)` followed by `Validate`/`Insert(true)`/`Modify(true)`/`Delete(true)`), Learn-backed premise, clear carve-out.
