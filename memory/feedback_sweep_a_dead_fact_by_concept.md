---
name: sweep-a-dead-fact-by-concept
description: "When a fact changes, grep the concept in several phrasings rather than the sentence you saw, read the imperative lines first, and check for copies; a phrase grep that returns zero looks identical to a clean file"
metadata:
  type: feedback
---
**When a fact changes, we sweep for the concept in several phrasings, not for the sentence we already saw, and we read the lines written as instructions first.** A phrase grep that returns zero looks identical to a clean file.

**The case:** a rule changed, and its notes file was corrected in the description, the title and a table row. A grep for the old phrase returned zero, correctly. But the "How to apply" line, the only line written as a direct order, still prescribed the dead mechanism in different words. In another file, a block said "on hold" seven lines above its own closing marker, so anyone entering mid-block read a live instruction. In code, a review took eleven rounds because single facts lived in two places: a helper existed twice, an error case was fixed in one copy only, a count was corrected in one file and left stale in another, and a test pin that already existed in a sibling file was rewritten worse.

**Why:** this changes behaviour. A stale description steers recall into the dead rule, and an imperative line gets executed, not read. A duplicated fact fixed once leaves the other copy asserting the opposite, in green.

**How to apply:**
1. Grep an alternation of the concept, not the phrase: `copy|paste|ready to send|hand over` rather than the sentence you saw.
2. Expect legitimate hits and **read** them: negations, quotes, history. A count cannot tell "denies it" from "orders it".
3. Read imperative lines first: frontmatter description → title → how-to-apply → tables → any "what doesn't change" list.
4. Put the closing note where the instruction is, not at the foot of the block.
5. Start with the files that always load (root instructions, the memory index), then agents, skills, hooks and scheduled tasks; a hook runs before anyone reads it.
6. In code, when fixing a fact, grep for its copies in constants, error messages, comments and tests.
