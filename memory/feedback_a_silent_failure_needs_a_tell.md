---
name: a-silent-failure-needs-a-tell
description: "When something fails exactly the way it looks when it works, the fix is rarely the case you found but giving the failure a visible tell; ask 'if this fails, can I tell it apart from success?' of the instrument, and never return an empty success"
metadata:
  type: feedback
---
**When something fails exactly the way it looks when it works, the fix is rarely the bug: it is giving the failure a tell.** There is one question: *if this fails, can I tell it apart from when it works?* We ask it of the instrument, not only of the system.

**The case:** in one day, six unrelated cases had the same shape: a review bot's "success" status that hid four flavours of "didn't review"; a guard that ran green while covering one of four spellings; a number copied from an earlier commit that was simply stale; an assumption "refuted" by measuring the writer of a dataset when it lived in the reader; a global hook counter that could not tell one session from the whole machine; a two-case coincidence written up as a rule. Separately, a handler returned `Success` with an empty list in four different failure modes (missing data, invalid input, a uniqueness violation, a real no-op), with one log line as the only trace. A sibling handler silently dropped unknown input keys, sent an empty update, and reported "Done!".

**Why:** an instrument that cannot report its own failure turns everything downstream into unverified work that looks verified. And knowing the rule is not following it: the session fixing the green-check problem read a "review completed" status and reported "clean" that same afternoon.

**How to apply:**
- Before trusting a green signal, ask what it prints on failure. If it prints the same, it is not a signal.
- When you find one, the ticket is "give it a tell", not "fix this case". The case you found is one of many that already passed unseen.
- If a result can be empty, attach a reason code and land it in a queryable row, not only a log.
- Reject unknown inputs. Partial success reported as success is worse than a failure.
- Write the rule where it executes (a check, a test, a hook), not only where it is read.
