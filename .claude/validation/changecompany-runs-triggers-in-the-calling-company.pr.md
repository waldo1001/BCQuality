## What

Adds one community article to the `events` domain, `community/knowledge/events/changecompany-runs-triggers-in-the-calling-company.md`, with `.good.al` and `.bad.al` samples. The fact: `ChangeCompany` redirects only the data access of a record variable. Triggers, field validation, and the database trigger-event subscribers keep running in the calling company. Switching `RunTrigger` off skips the trigger code but not the subscribers, because the runtime raises the trigger events on every database operation and only passes the flag along. The Best Practice is to run the code in the target company (`StartSession` with the company parameter) and to keep direct cross-company writes for trigger-free hand-off tables the extension owns.

## Why this is a knowledge file (admission test)

Generation is where models fail. In five generation runs of the same task (create a row in another company whose OnInsert reads setup and whose OnAfterInsertEvent subscriber maintains a counter), four wrote to the other company with side effects landing in the calling company: two assumed `ChangeCompany` moves the trigger context, two knew it does not, switched `RunTrigger` off, hand-copied the trigger logic, and left the subscriber double-counting in the calling company. None of the five reached `StartSession`. On review, capable models do catch the defect when the trigger and subscriber are in the same file; the evidence section records that honestly.

## Overlap check

- `community/knowledge/performance/changecompany-in-loop-drops-caches.md` is the only article mentioning `ChangeCompany`. It covers the per-row cache cost of the call and says nothing about execution context, triggers, `RunTrigger`, or subscribers. Delta; cross-referenced from the Description.
- `microsoft/knowledge/performance/pass-false-to-insert-when-trigger-not-needed.md` covers when to pass `false`; it does not discuss trigger events firing regardless, nor cross-company writes.
- No article mentions `StartSession`, `cross-company`, or `Insert(false)` in this sense.
- In-flight: open PRs searched for `changecompany`, `startsession`, `cross-company`, `multi-company`. Only #148 (Job Queue reliability) matches a keyword; it does not state this fact.

## Sources

- Record.ChangeCompany, Remarks: "Even if you run the ChangeCompany method, triggers still run in the current company, not in the company that you specified", and access rights are respected — https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-changecompany-method
- Record.Insert(Boolean), RunTrigger semantics; Record.Delete, RunTrigger defaults to false — https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-insert-boolean-method and https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-delete-method
- Event types, Database trigger events: "automatically raised by the system when it performs database operations", RunTrigger passed as a parameter, order of execution — https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-event-types
- OnAfterInsertEvent, RunTrigger parameter — https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/triggers-auto/events/table/devenv-onafterinsertevent-table-trigger
- Session.StartSession, Company parameter and background-session cost — https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/session/session-startsession-integer-integer-string-table-method
- `bc-version: [all]`: ChangeCompany, Insert(Boolean), the table trigger events and StartSession(var Integer, Integer, Text, var Record) are all runtime 1.0 on their Learn pages.

## Layer and retrieval

Community layer. `microsoft/skills/review/al-events-review.md` already sources the `events` domain across layers, so no skill change is needed; review fixtures untouched.

## Scope

- The detection signal is scoped to writes after `ChangeCompany(<name>)` on tables the extension does not own, or whose triggers read company data, or whose subscribers do not exit on `RunTrigger = false`. Reads, hand-off writes into owned trigger-free tables, and the parameterless `ChangeCompany()` reset are named as not flagged.
- Left out: the per-row cache cost (already covered), `SessionSettings` company switching (client-side, different concern), and Job Queue or Task Scheduler as alternatives to `StartSession` (not needed for the fact; happy to add if wanted).
- The samples use a custom table and subscriber rather than a base-application table so every claim in a sample comment is demonstrated by the sample itself.

## Evidence

# changecompany-runs-triggers-in-the-calling-company
overlap: community/knowledge/performance/changecompany-in-loop-drops-caches.md — delta — neighbour only states "ChangeCompany retargets a record variable to another company's data and drops the in-memory caches"; nothing about triggers, RunTrigger, Validate or subscribers running in the calling company. Cross-referenced from the Description.
in-flight: none — `gh pr list --state open --search` for changecompany, startsession, cross-company, multi-company returns only PR #148 (Job Queue reliability; adjacent, not the same fact)
claim: triggers still run in the current company after ChangeCompany — https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-changecompany-method (Remarks)
claim: access rights in the target company are respected — same page (Remarks)
claim: ChangeCompany() without a name changes back to the current company — same page (Parameters)
claim: Insert(false) / Insert() skips the OnInsert code; RunTrigger defaults to false — https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-insert-boolean-method and https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-delete-method
claim: database trigger events are raised by the runtime on every database operation and pass RunTrigger to the subscriber — https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-event-types (Database trigger events; order of execution) and https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/triggers-auto/events/table/devenv-onafterinsertevent-table-trigger (RunTrigger parameter)
claim: StartSession takes a Company parameter and runs the codeunit in that company; a background session costs as much as a user session to start — https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/session/session-startsession-integer-integer-string-table-method (Parameters, Remarks)
claim (bad sample comment): the OnAfterInsertEvent subscriber fires on Insert(false) in the calling company — inference from the two Learn statements above (events raised on every database operation; triggers run in the current company); no observed run available in this session
bc-version: [all] — ChangeCompany, Insert(Boolean), StartSession(var Integer, Integer, Text, var Record) and the table trigger events are all runtime 1.0 per their Learn pages
precision: Insert(false)/Modify(false)/Delete(false) into an owned hand-off table whose triggers do not read company data and whose subscribers exit on RunTrigger = false; reads after ChangeCompany; ChangeCompany() reset — carved out in Anti Pattern (Detection signal paragraph) and Best Practice
cold review (bad sample, Fable-class default model): caught — "OnAfterInsertEvent is raised even when Insert(false) is used (that is why RunTrigger is a parameter) ... increments Open Requests in the calling company while the request row landed in TargetCompany"
cold review (bad sample, Sonnet): caught — "the subscriber fires unconditionally regardless of RunTrigger/Insert(false) ... ChangeCompany only affects the record variable it's called on, not variables touched inside triggers/events it raises"
cold review (first draft, Insert(true) shape, Fable-class): caught — same reason; also found a real sample bug (FindLast on the Init'ed variable), fixed
generation test (Fable-class): no defect — used StartSession(company) and explained why ChangeCompany was avoided
generation test (Sonnet, run 1): defect — ChangeCompany + Insert(false) + hand-copied setup + manual counter; ignored that the OnAfterInsertEvent subscriber still fires in the calling company (double count). This is the shape of the bad sample.
generation test (Sonnet, run 2): defect, wrong premise — commented "ChangeCompany suppresses the target table's OnInsert trigger (and therefore the OnAfterInsertEvent subscriber)"; Insert(false) + manual counter, double count in the calling company
generation test (Sonnet, run 3, reworded prompt): defect, knowingly — described both facts correctly, then shipped ChangeCompany + Insert(false) + manual counter and called the calling-company side effect "unavoidable from the caller side"; did not consider StartSession
generation test (Haiku): defect, wrong premise — "ChangeCompany switches context so the target company's OnInsert trigger applies its default location"; ChangeCompany + Insert(true)
generation summary: 4 of 5 runs wrote to the other company with side effects in the calling company; 0 of 5 non-Fable runs reached the Best Practice (StartSession with the company parameter); only the Fable-class run avoided the defect
warm review (bad sample): flagged citing community/knowledge/events/changecompany-runs-triggers-in-the-calling-company.md (line 20, double count in the calling company)
warm review (good sample): clean
script: 0 error(s), 0 warning(s) (bcq-validate.sh, 2026-09-03; upstream validator, knowledge index, review fixtures, contributor checks, overlap all green)
verdict: ready, with a stated caveat — deterministic checks and warm review pass; the admission case is generation-side (4 of 5 runs produce the defect, none reach the remedy) while capable models catch the defect on review. Say so in the PR body.

## Checklist

- [x] Frontmatter has exactly the six required keys; `domain` matches the folder
- [x] `## Description` present; no fenced code blocks; under 100 lines; one concern
- [x] Samples referenced by filename from the article and present next to it
- [x] `validate_frontmatter.py`, `Test-KnowledgeIndex.ps1`, `Test-ReviewFixtures.ps1` pass locally
- [x] Only `community/` is touched
- [x] Commit author is linked to the GitHub account; branch rebased on `upstream/main`

🤖 Generated with [Claude Code](https://claude.com/claude-code)
