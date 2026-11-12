---
name: ask-the-reporter-before-a-prohibition
description: "Before shipping a rule that prohibits something, grep what humans actually did for that shape and ask the person who reported the problem about exceptions; reporters describe the case that annoyed them, not the whole rule"
metadata:
  type: feedback
---
**Before shipping a rule that prohibits something, we talk to the person who reported the problem, and we grep what was actually done for the shape we are about to ban.** A reporter describes the case that annoyed them, not the whole rule. The edges only appear if you ask.

**The pattern:** a complaint gets fixed with a blanket "never do X". The same people who complained turn out to need X in a legitimate exception, and the new rule blocks their correct answer. The question that would have caught it is one message to the reporter.

**Why:** behind it was not a bug but a policy gap. Nobody had written down whether the exception was real, so the prompt decided by omission, which is the worst way to decide.

**How to apply:**
1. Before the PR, grep the replies humans actually **sent** for the form you are prohibiting. If someone already used it correctly, that is the edge.
2. Message the reporter, short and genuinely asking: "this thing we're about to forbid, are there exceptions? I saw you do it here." It is not validation of the fix; it is surfacing the policy.
3. The answer goes into the PR, so the next recurrence is attributable.
4. A feedback item that matches the shape but contradicts the new rule is **not** marked fixed. Flipping it buries the evidence that the fix is too wide.
5. Mine both versions of every case: the rejected draft shows what is wrong, the human-corrected reply shows what right looks like. The delta is the fix.
6. A policy nobody owns gets asked about openly, not invented in a prompt.
