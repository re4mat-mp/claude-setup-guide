---
name: four-questions-before-touching-shared
description: "Before a go on any change to something shared, answer in plain words: who else uses it, is it being tested on the real one, does it fix itself if it goes wrong, and what stops working while it runs; careful procedures don't answer these on their own"
metadata:
  type: feedback
---
**Before a go on any change to something shared (a database, a production flow, a deploy that reaches other people) we answer four questions in plain words, above any technical detail.**

1. **Who else uses this?** The mother question.
2. **Is it being tested on the real one?** If yes, stop there.
3. **If it goes wrong, does it fix itself, or does someone have to go and rescue it?**
4. **While it runs, what stops working?** If you cannot answer with a number, you don't know yet.

**The pattern:** a change that follows a written, reviewed procedure can still take down another team's system, when the shared thing has tenants nobody on the change thought about. Care in the procedure does not answer "who is on the other side".

**Why:** "be more careful" is not a defense, because careful people followed a careful procedure. These four are the questions a tidy procedure does not answer on its own, and they are the shape of an explanation the approver can actually check.

**How to apply:**
- Put the four answers at the top of the go request, in the words the approver would repeat in a meeting: no command names, error codes or acronyms. Technical detail goes below.
- If the answer to question 1 is "another team", it is no longer a normal change; involve that team before asking for the go.
- If any of the four has no answer yet, that *is* the state of the work. Say so; don't fill it with a tidy guess.
- Never verify against production as the test. Use a staging copy or a dry run.
