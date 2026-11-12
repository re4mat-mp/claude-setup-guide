---
name: show-the-screen-running
description: "Before asking for a go on anything a person will see, show it running (a real render or a recipe to trigger it); a long body, evidence and green reviewers don't show anyone the screen, and a live look finds errors code reading misses"
metadata:
  type: feedback
---
**Before asking for a go on anything a person will see (a screen, a card, a button, a message someone receives) we show it running.** A long PR body, measured evidence and two green reviewers do not show anyone the screen. A screenshot of the real render does, or a three-line recipe to trigger it on a test case.

**The pattern:** a change to something people see goes through several rounds of code review, and nobody renders it. One look at the real screen finds errors that reading the code cannot: a missing line, emphasis on the wrong word, an empty-input case nobody pictured.

**Why:** running the thing beat reading the thing, on one of the most thoroughly measured PRs of the period. Knowing the code is not the same as knowing the product.

**How to apply:**
- In the PR body, put before | after as **rendered screenshots** of realistic cases near the top; tables and text go folded below. This applies to text-only changes too (a prompt, a wording): render real outputs from main and from the branch on the same cases, side by side.
- A harness that does not render does not count, and a hand-rebuilt HTML copy of the screen is exactly where errors creep in.
- Ask "have you seen this screen before?" It costs nothing.
- One step earlier: anything with more than a couple of dashboard cards gets mocked up in HTML with real numbers before it is built. Moving a block in HTML takes minutes; in a BI tool it takes far longer and risks silent API failures. The mock answers layout questions that cannot be settled by talking.
- When proposing an improvement in chat, show an HTML mockup with labeled options, not prose.
