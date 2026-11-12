---
name: changes-are-forward-only
description: "Every change applies forward: we fix the mechanism that produces the next period and explain the old one, but never rewrite a closed, already-consumed record, because someone already acted on it"
metadata:
  type: feedback
---
**Every change we make applies forward. We don't rewrite the record of a period that is already closed, even when the correction is right.** The fix goes into the mechanism that produces the next period. The finding about the old period is documented and explained, and the record stays as it was.

**The pattern:** a past record turns out to be wrong, and the plan is to correct it in place. By the time the correction runs, people have already acted on the record (graded it, gave feedback on it), and rewriting it now costs more than the error did. Work still in progress is different: correcting that is forward work.

**Why:** a closed record has already been consumed. Someone read it, gave feedback from it, made a decision on it. Rewriting it destroys someone else's real work for a nicer number, and leaves a history that cannot be audited against what actually happened.

**How to apply:**
- On a finding about a closed period, propose **two separate things**: (1) the mechanism fix, effective from the next cycle; (2) a note explaining the old period. Never present the retroactive edit as the fix.
- The test is the record's **state**, not its date. Closed and consumed → don't touch. Old but still pending → that is work to do, and fixing it is forward.
- Changing who reviews something is not re-evaluating it; it moves no score or count.
- Before executing a plan written days ago against live data, re-read the live state. What justified the plan may have changed.
