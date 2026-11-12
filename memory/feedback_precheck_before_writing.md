---
name: precheck-before-writing
description: "Before writing a change, run a short pre-check: does the code already try this and fail, what would the smallest version touch and newly expose, is there a pre-existing bug on that path; the same question is cheap before a PR and expensive after"
metadata:
  type: feedback
---
**Before writing a change, we run a pre-check: is it real, does the code already try to do it, and what is the smallest change that fixes the reported cases?** It runs before the work, so it stays short: three answers and one sentence, under ten lines.

**The case:** two PRs were blocked on the same day after only the after-the-fact review had run. Both were born crooked. One fixed a symptom the code was already trying (and failing) to handle, so the fix fought the existing path. The other's "small" version lit up a pre-existing bug on a newly reachable path. Both answers were knowable before a line was written.

**Why:** the same question is cheap before the PR and expensive after it. A diff that exposes a landmine is nearly always a diff that is too big.

**How to apply:**
1. **Does the code already try to do this and fail, or does it not try at all?** These need opposite fixes.
2. **What would the smallest version touch, and what becomes newly reachable?** This is the question that matters most.
3. **Is there a pre-existing bug on that path?** Say it now, while it is cheap.
- Then one sentence: **the smallest change that fixes the reported cases and nothing else.** Without that sentence the pre-check is not finished.
- If the smallest version still exposes something scary, shrink the scope further; do not fix the scary thing in the same PR.
- Grep the phrase or condition you are about to change across the whole surface. "The rule you edited contradicts another rule somewhere else" is the most common review finding. Grep with a script; decide which side is true with a head.
- Size the population the change affects with a real query, and put the number in the body before anyone asks.
- If the thing does not exist yet, it is a design question, not a pre-check.
