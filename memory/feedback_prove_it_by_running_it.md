---
name: prove-it-by-running-it
description: "'Done' means we ran the real path and saw the result, not that we read the code and it should work; every factual claim in a PR or ticket is checked against code or data, and 'raised with X' is never written without a citable line"
metadata:
  type: feedback
---
**"Done" means "I ran the real path and this came out", not "I read the code and it should work".** If something cannot be run, we say so and name what stayed untested.

**The pattern:** a ticket or a claim is written from the shape of a schema or from memory instead of from the code and a test query. Each statement in it would have fallen to one command: whether a fix already merged, how big the change really is, whether two tables join. And a sentence saying something was "raised with" someone puts words in their mouth.

**Why:** a null column describes the writer, not the limit of what is possible. Reasoning feels like verification and costs nothing, which is exactly why it gets used instead.

**How to apply:**
- Run the system for real against a synthetic case (a test ticket, a fixture), not a mental trace. Running it routinely turns a "green" PR into a list of real defects.
- Check each factual claim in a PR or ticket against code or production data, not memory. Check that identifiers you are about to use actually resolve.
- Before estimating effort, open the file that would change.
- Before writing "no workaround", try the obvious one with a query.
- Never write "raised with X", "agreed with X" or "X owns this" without pointing at the line where it happened. Otherwise write "not yet raised". Ownership expires; re-check it.
- When a run contradicts your earlier verdict, say "I was wrong to call it green" first, then the evidence.
- Keep scope: a bug found while running goes to its own ticket, not into the PR.
