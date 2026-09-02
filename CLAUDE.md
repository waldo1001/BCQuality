# BCQuality contributor workspace

This is **waldo1001's fork of microsoft/BCQuality**, used only to contribute to the upstream
`/community/` layer. The fork's `main` is `upstream/main` plus the toolkit commit(s) that add
this file and `.claude/`. `main` is never the source of a PR.

- `origin`   = https://github.com/waldo1001/BCQuality.git (the fork; `main` is pushed here)
- `upstream` = https://github.com/microsoft/BCQuality.git (never pushed to; PRs target its `main`)
- Candidate source: `/Users/waldo/SourceCode/iFacto/iFactoAcademy/iFacto Playbook/BCQuality/custom/knowledge/`

## How contributions are isolated

Every contribution is a **git worktree** under `.claude/worktrees/<slug>` on a branch
`community/<domain>/<slug>` cut from `upstream/main`. You always work from this checkout, so the
skills stay loaded; the worktree's diff against `upstream/main` can only contain the contribution,
never the toolkit. `.claude/worktrees/` is git-ignored.

```
.                                   main = upstream/main + toolkit   (skills live here)
└── .claude/worktrees/<slug>/       community/<domain>/<slug> = upstream/main + the article
```

## Hard rules (CI and maintainers enforce these)

1. Never author on `main`. `bcq-start.sh <domain> <slug>` creates the worktree and branch.
2. A PR touches `community/` only. `custom/` is auto-closed upstream; new top-level entries are flagged; `microsoft/` and `skills/` need maintainer review (separate PR).
3. Knowledge frontmatter has **exactly six keys** (`bc-version`, `domain`, `keywords`, `technologies`, `countries`, `application-area`). No `author`, no `title`. Attribution is the git author.
4. No fenced code blocks in knowledge files. Code lives in `<slug>.good.al` / `<slug>.bad.al` siblings, each referenced by filename from the article.
5. `domain` must equal the folder name. Prefer a domain with a review leaf in `microsoft/skills/review/al-<domain>-review.md`, otherwise `al-code-review` never sources the article.
6. Under 100 lines, one concern per file, and it must pass the admission test: *would a capable LLM get this wrong without the file?* Prove it with the cold/warm review, on a neutralised sample.
7. Community articles carry `> Contributions welcome — open a PR to refine or extend this article.` under the H1.
8. Commit subject: `knowledge(<domain>): <what the rule says>` for one article, `knowledge: <summary>` for several, `skill(<id>): ...` for action skills.
9. Opening a PR against microsoft/BCQuality needs an explicit yes from the user. Pushing a contribution branch to the fork is part of that step, not before.

## The toolkit

| Skill | Job |
|---|---|
| `/bcq-contribute` | End-to-end: update fork → scout → start worktree → author → validate → PR → status |
| `/bcq-update-fork` | Merge `upstream/main` into `main`, push the fork, rebase open worktrees |
| `/bcq-scout` | Triage candidates (a source folder, a topic, or review feedback) through three gates |
| `/bcq-author` | Write one community article plus samples in a worktree, or port one from a custom layer |
| `/bcq-author-skill` | Write a community action skill following the DO contract |
| `/bcq-validate` | Upstream CI locally, contributor guards, and the cold/warm review proof |
| `/bcq-pr` | Commit, push the branch, open the PR (with confirmation) |
| `/bcq-status` | Follow up PRs, clean up merged worktrees, keep the ledger |

Scripts in `.claude/scripts/` do the deterministic work; skills do the judgment. Always read
`skills/read.md` and `skills/write.md` from the live checkout before authoring; they are the
contract, this file only summarises it.
