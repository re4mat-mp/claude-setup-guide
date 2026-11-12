---
name: a-guard-can-be-green-and-blind
description: "A guard's green means 'I found nothing', which looks the same as 'I can't see anything', and a guard whose condition can never occur is dead code with a safety label; test guards by planting the hostile input, not by reading them"
metadata:
  type: feedback
---
**A guard's green means "I found nothing", which looks exactly like "I can't see anything", and a guard that can never fire is dead code wearing a safety label.** We test a guard by planting the hostile input and watching whether it gets through, not by reading the guard.

**The case:** a guard written to prove a known gap was unreachable was wrong twice and green both times. Its unescaping turned the exact character it hunted into harmless letters, and its pattern missed a dozen of several hundred test names: the generated ones, the very population that mattered. Planting the character caught the first; counting what the guard saw against what the test runner reported caught the second. Elsewhere, a line that prepended a default item to a list was pasted *above* an "if the list is empty" guard, so the list could never be empty again. With an empty source, the guard would have let through a dropdown that invalidated several hundred rows.

**Why:** a measuring instrument and its own validation fail for the same reason, and only an executed hostile input breaks the tie.

**How to apply:**
- Plant a battery of hostile forms, one at a time, each a shape the guard claims to catch. Any that pass green show where it is blind.
- Count what the guard examined against an independent count (the runner's total, the row count).
- A guard that meets an input it cannot parse must **fail**, not skip it.
- For each guard, name the concrete input that would fire it and trace whether that input survives to the `if`. Validate first, decorate after.
- Ask what it prints when it does not run, compared with when it runs and passes. If the same, add a tell: assert presence rather than truthiness; add a canary (a known-positive query) when the healthy answer is empty.
- Never let a detector share its pattern with the thing it detects; anchor the check on an independent token.
- Replay a new guard against known-good states and count the false alarms. A guard that cries wolf gets skipped.
