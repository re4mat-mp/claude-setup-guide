---
name: a-green-check-is-not-a-review
description: "A bot's green status check means a job finished, not that it reviewed your commit; an empty review list looks the same whether the bot was clean, out of quota or not yet run, so ask the bot and query unresolved threads on the current head"
metadata:
  type: feedback
---
**A bot's green status check means a job finished, not that anyone looked at your code.** Green can mean: ran on this commit and found nothing; ran on an earlier commit and yours is unreviewed; ran and posted findings somewhere the check does not reflect; was rate-limited; or never ran. We read the review, not the tick.

**The case:** within one day the same mistake was made in opposite directions on the same PRs. First, the bot's auto-generated summary comment (posted on every PR) was read as a clean review, and a merge was recommended on that basis. Then an old review timestamp was read as "never saw the current code", which was also wrong: the bot reviews incrementally and only publishes a review when it has findings. Meanwhile a real Major finding sat unread on another PR for a day.

**Why:** an empty review list looks identical whether the bot was clean, out of quota or has not run yet. Reporting "clean" on that is signing that the loop ran when it did not.

**How to apply:**
- Ask the bot instead of inferring: comment `@coderabbitai review` and read its answer ("Already reviewed", "rate limited", or findings).
- Query unresolved threads on the current head (`isResolved == false and isOutdated == false`), not "when did it last post".
- Tell clean, out of quota and not yet apart by the **text of the bot's latest comment**, not by the absence of a review. Some bots edit their acknowledgement in place: filter by `updated_at`, not `created_at`.
- Per-commit truth lives in that commit's check-runs or statuses history, not in a combined status that gets overwritten.
- When reporting, name the surface you checked. "No unresolved threads on head abc123" can be corrected; "the bot is green" cannot.
- The same hole exists in any check that reports liveness while you read it as judgement: a linter that skips unchanged files, a suite that silently excludes a directory.
