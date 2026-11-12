---
name: link-cases-the-reader-can-open
description: "Every PR body, finding and measurement carries at least one complete real case the reader can open, with what to look at and the command that re-runs the check, plus innocent cases; a gate that only reads a summary is not a gate"
metadata:
  type: feedback
---
**Every PR body, finding and measurement carries at least one complete real case the reader can open and check: a link, what to look at once it opens, and the command that re-runs the check.** We include innocent cases, not only guilty ones.

**The pattern:** a PR cites real cases as bare IDs. The person approving cannot open them, so the human check collapses into trust in the summary, and that matters more as more of the pipeline is automated.

**Why:** a number the approver cannot verify forces approval on trust. Openable evidence keeps the human check real while the machine does more of the work. And a finding that shows only the cases it caught cannot be refuted: the hundreds of cases where behaviour was fine are what tell the reader whether the fix breaks anything.

**How to apply:**
- Use the URL format the reader already knows (the ticketing system's agent view, the dashboard link), not a bare ID.
- Say **what to look at** once it opens: "scroll to the message with the survey link quoted underneath; that's the one that disappeared." A link without a pointer is homework.
- Give the one command that re-runs the check (`npm test -- path/to/x.test.js`, or the script), so the reader can verify the fix as well as the bug.
- Prefer 2–3 examples spanning different shapes over one canonical case.
- Add a control: a case the change deliberately leaves alone, and the count of untouched cases.
