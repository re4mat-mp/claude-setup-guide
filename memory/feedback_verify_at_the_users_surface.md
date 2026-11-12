---
name: verify-at-the-users-surface
description: "Verify at the surface the user actually looks at, not at the intermediate you edited, and measure where data is read, not only where it is written; an API 200 is evidence about the API, and a false 'done' costs a round trip plus trust"
metadata:
  type: feedback
---
**We verify at the surface the user actually looks at, not at the intermediate we edited, and we measure where data is read, not only where it is written.** An API's 200 is evidence about the API. If we cannot see the real surface, we say which one we verified.

**The case:** three dashboard filters were fixed; the API confirmed the dashboard parameters were updated, and the work was reported done. The user opened the underlying card and the filters were still free-text boxes, because the two surfaces read different configs. Everything verified was true, and for the user nothing had changed. In another case, an assumption about a spreadsheet was declared refuted by reading the script that writes it, but the automation that reads it used a fixed cell range. Acting on that half-measurement would have broken the next day's report without any alarm.

**Why:** people act on "done": they tell someone, close the topic, move on. A false "done" costs a round trip and makes the next one read with suspicion.

**How to apply:**
- Before verifying, name the surface the user uses. It is rarely the one you edited.
- Verify there. If you cannot, say so in the same message: "the config is set; I can't see how it renders, please check".
- "Done" carries no hidden qualifiers. Either the qualifier is in the sentence, or the word is not "done".
- A ledger, panel or status file from hours ago is not now. Re-measure before reporting.
- Before declaring an assumption about data false, list who **reads** that data and measure there too.
- Watch for reads that hide a layer: a channel read that does not show thread replies looks identical to an unanswered message.
