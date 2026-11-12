---
name: prefer-api-over-browser
description: "Use an external system's API, CLI or connector first and the browser only as a last resort, said out loud; browser routes are slow, permission-heavy and touch surfaces others see, and 'the API seems lossy' must be proven first"
metadata:
  type: feedback
---
**When reading or acting on an external system, we use its API, CLI or connector first. The browser is a last resort, and we say so when we fall back.** APIs are faster and cleaner, do not depend on a logged-in browser, and do not risk clicking outward-facing things.

**The case:** a session browsed GitHub through Chrome while `gh` and a local clone were already available. In another session, the browser route was approved and then cut off mid-task: every browser action was a permission prompt, and the approved route had become the wrong one. That detour had been taken because the API "seemed" to lose data. The inferred limitation turned out to be wrong, and the browser detour caused the only real damage of the session.

**Why:** a browser route is slow, fragile and noisy for the human approving each step, and it acts on surfaces other people see.

**How to apply:**
- GitHub → `gh api`, `gh pr`, `gh search` and local `git`. Never a browser.
- Ticketing, docs, chat, BI, calendar and email → their connectors or REST APIs.
- If a connector is not authorised, look for another path (a REST API with a local key) before falling back, and prove the failure with one call.
- Permission to use the browser is not a preference for it. If a task needs more than a few browser steps, do the API version, or state the step count up front so the choice is informed.
- Before blaming the API for being lossy, verify with one write and one read.
