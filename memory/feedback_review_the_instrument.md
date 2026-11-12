---
name: review-the-instrument
description: "What produces work gets reviewed twice, while what produces judgement (agent charters, detectors, indexes, parsers) usually never does; review the instrument too, measure a detector's false positives before automating its remedy, and sweep instruments when a fact changes"
metadata:
  type: feedback
---
**What produces work gets reviewed twice; what produces judgement (agent charters, detectors, indexes, parsers) usually never does. We review the instrument, not only its output.** A mistuned instrument does not fail; it produces a confident wrong answer.

**The case:** one evening turned up four independent findings. Three agent charters ordered false things; one said a tool was switched off nine days after it came back, and an agent obeying it refused to work. An incident detector produced 4 false positives out of 6 alerts, because its "severity" metric was actually the `LIMIT` of its own query, and there was an open proposal to auto-apply its irreversible remedy. Reorganising an index silently hid a third of a page, because a parser knew the old filename. A new charter shipped asking its agent to write a file without giving it a write tool.

**Why:** a work product is visible: a PR is read, a message is sent. An instrument is only seen through its results, and its results look fine; a stale charter produces an obedient agent. And the instrument was written when it was true. Nobody broke it; the world moved.

**How to apply:**
- A changed charter, prompt or detector gets a reviewer like a PR: check each imperative verb against the tools it actually has, and each "don't finish until" against the prohibitions in the same file.
- Measure a detector's false-positive rate on a real firing **before** automating its remedy. An automated runbook inherits its detector's precision. If the remedy is irreversible, this is mandatory.
- When a fact changes, sweep every instrument that copies it in the same turn: charters, hooks, parsers, scheduled tasks.
- A validator that runs on parsed output must also check that parsing produced something.
- Before reading code to answer "what does my change reach?", look for a test that already encodes the definition; run its helper on both versions and diff the output.
