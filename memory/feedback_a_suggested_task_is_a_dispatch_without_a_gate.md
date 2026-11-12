---
name: a-suggested-task-is-a-dispatch-without-a-gate
description: "A one-click suggested task runs exactly the scope the agent wrote, in a new session that doesn't know the item was parked; write suggestions for parked work with the narrowest useful scope and raise wider sweeps as a question"
metadata:
  type: feedback
---
**A suggested task (the one-click task card some agent tools offer) is a dispatch without a gate: when someone clicks it, the scope the agent wrote is the scope that runs, with nobody in between.** So a suggestion for parked work is written with the narrowest scope that serves.

**The case:** while reviewing a PR, the reviewer found a wording problem in a comment in an already-merged file. The session deliberately kept it out of scope and wrote a suggestion for it, adding "grep the whole repo for the same shape before fixing" to avoid three follow-ups. The suggestion was clicked. A comment fix in one file became a seven-file PR outside the agreed plan, while the first PR in the queue was still unreviewed.

**Why:** a subagent returns its work and the session decides what to do with it. A suggestion hands the work to a fresh session that does not know the item was parked. "Parked as out of scope" and "sweep the whole repo" cannot both be true in the same suggestion. People click suggestions quickly, trusting that the scope was already thought through.

**How to apply:**
- Write a suggestion for parked work with the narrowest useful scope: one file, one symptom.
- Say it explicitly in the suggestion: "parked from <PR> as out of scope", so the session that opens it inherits the context.
- If the real fix needs a repo-wide sweep, raise that as a **question** for the owner, not as an instruction to the executor.
- Count clicked suggestions as PRs in the queue; they compete for the same review attention.
