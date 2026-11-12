---
name: pr-body-before-after-and-impact
description: "A PR body leads with a one-paragraph summary, then before/after on real cases (including one that doesn't change), then a small expected-impact table checked against the minimum detectable effect; mechanism folds below"
metadata:
  type: feedback
---
**A PR body leads with a one-paragraph summary, then a before-and-after on real cases, then an expected-impact block; mechanism and technical detail fold below.** Before/after says what changed; the impact block says what it should move. They belong together near the top, because that is what the approver checks.

**The pattern:** the before/after sits deep in the body, written in technical terms, and the approver has to ask where it went. Separately, predicted impacts are often smaller than the minimum detectable effect for the volume involved, so they can never be confirmed or refuted.

**Why:** an approver reading only the first screen should know what changed, on which cases, and how we will know it worked.

**How to apply:**
- Before/after rows are concrete cases, not descriptions of the change. The "before" is what the code **actually returned** when run; say whether a row came from a real output or a replay. Include a row that **doesn't** change: it proves the scope is bounded. Visible changes get rendered screenshots.
- Expected impact, as a small table: one category (never "the whole product"), one metric, today's number, the estimate, a re-check date.
- Before writing the estimate, compute the minimum detectable effect with the real n: `MDE ≈ sqrt(7.85 · 2p(1-p) / n)`. If MDE > estimate, write "not detectable; needs n = X", or switch to a **mechanism** metric (did the module load? n = 1 is enough).
- "No measurable change" is an acceptable, honest entry.
- Every number in the body must reproduce on the current head: re-run them right before the review ask.
- Appended sections (review summary, post-merge notes) take the same shape: one visible line, detail in `<details>`.
- On the re-check date, compare the estimate against what actually happened.
