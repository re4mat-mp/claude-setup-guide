---
name: cold-review-is-the-last-step
description: "After both reviewers are green, a cold agent given only the repo and PR number reviews the exact head that will merge, as the last step before a human; a briefed reviewer inherits our framing and environment, a cold one reads what we wrote"
metadata:
  type: feedback
---
**After both reviewers are green, a cold agent (given only the repo and PR number, no brief) reviews the PR as the last step before a human is asked.** A reviewer we brief inherits our framing and our environment. The human reads only what we wrote and runs it on their own machine. The cold agent is the closest stand-in for that human.

**The pattern:** every automated and briefed reviewer runs in the same environment as the author, so they share the author's blind spots. A failure that only shows on a machine configured differently (for example, one that exports a credential the suite reads) is invisible to all of them until a reviewer in different conditions runs the suite.

**Why:** a cold read finds what a briefed one does not because it reviews what was written, not what was meant. It notices an unclear body, a number that does not reproduce, a test that only passes on our machine.

**How to apply:**
- Order: pre-check → write → briefed subagent review locally → open the PR, bot green → **cold review on the exact head that will merge, against current main** → human. If main moved, update first, then run the cold review.
- The brief is the repo and the PR number. No scope sentence, no local files, no reasoning from the authoring session.
- It runs the suite **once**, the way a reviewer's machine would: clean checkout of the head, the runtime version the repo declares, relevant keys both exported as dummy sentinels and absent.
- It treats every sentence in the PR body as a claim: re-derive each count, execute each proposed alternative, find the edge of each "fails closed".
- It plants mutants on the touched lines (see the mutants note).
- Its findings go through the same bar: fix, or answer in writing. A fix push means the bot covers the new head again; a small follow-up fix gets the briefed reviewer, not a second full cold pass.
- Its verdict goes into the review summary in the PR body.
