---
name: review-bar-block-only-on-breakage
description: "When we review, we block only on real breakage or a new critical regression, and on someone else's PR the comment stays on their code; over-blocking makes real blocks easier to ignore"
metadata:
  type: feedback
---
**When we review, we block only on real breakage, and on someone else's PR the review stays on their code.** Block on: the change is wrong (not just imperfect), a new critical regression, a security or data-integrity hole. Everything else (cosmetic, pre-existing, "I'd do it differently") gets a one-line note and an approve. A review listing twelve medium concerns is a failed review.

**The pattern to avoid:** a reviewer holds a PR, the author fixes everything, and on the re-review the reviewer opens a new front on a theoretical risk nobody has measured. Each finding may be defensible; holding twice spends the credibility that made the first hold land.

**Why:** when outputs pass through a human approval before reaching anyone, that approval is the safety net, and findings matter in proportion to what slips past it. Over-blocking costs the author time and trains everyone to discount real blocks.

**How to apply:**
- Litmus test: *is it a regression?* Pre-existing and not worsened → note, approve.
- Exception: a pre-existing bug the diff **newly exposes** to real traffic is breakage. Block, and name the smaller version of the change that avoids that path.
- Weight highest what the human approver cannot see when they click: bugs in the gating logic itself, invisible side effects.
- Round two verifies **the fix**, not the whole surface again. A new theoretical risk found then is a note after the approve, not a second hold.
- On a colleague's PR, the comment carries only what the author can act on: their code, tests, migration, spec. Damage to your own downstream reports is measured locally and parked as your follow-up. A coordination line the author controls ("tell me when the migration runs") is fine.
- Open the review with a one- or two-line verdict a person could say aloud; detail below.
