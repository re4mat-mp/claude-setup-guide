---
name: size-a-pr-by-decisions
description: "A PR's size is the number of independent decisions it contains, not the number of files; more than one decision means more than one PR, because the PR gets blocked on its weakest decision and takes the good ones down with it"
metadata:
  type: feedback
---
**A PR's size is the number of independent decisions in it, not the number of files.** A decision is anything that could be reverted on its own, or that someone could disagree with on its own. More than one means more than one PR.

**The case:** a PR touched three files and contained four decisions, one per tier of a detection chain. The size test had been applied and even written in the body ("this is really two things"), and it shipped as one anyway, argued as "one function, one file, one test file". Both review blockers landed in the tiers that should have been separate PRs. The second tier alone fixed every reported case with no new heuristic, cache or timeout, and would have merged clean.

**Why:** splitting was not tidiness, it was the fastest path to production. A PR that is small by file count but holds several decisions gets blocked on the weakest one.

**How to apply:**
- Count decisions before opening. Signals there are several: "and" in the title; a tier, step or branch added "while I'm here"; tests that need fixtures of different shapes; a change that is two kinds at once (tone and capability, policy and behaviour).
- Don't add protections to the PR that fixes the thing. A regression pin or a loader extension is its own small PR.
- Before opening, check whether another open PR touches the same file: `gh pr list --state open --author @me --json number,files`. Same rule or block → one PR. Textual overlap only → two is fine, but name the conflict in the body.
- Stacking a dependent PR is fine, squash-merge repos included, but once the bottom PR is squash-merged, rebase the branch above with `--onto` from the saved bottom head; a plain rebase conflicts with its own landed copy (`knowledge/github-pr-review.md` § Stacked PRs).
