---
name: plant-mutants-on-touched-lines
description: "On a risky change, the cold reviewer plants 10-20 small bugs on the lines a PR touches and checks a test fails with an assertion for each; a green suite proves tests pass, a killed mutant proves they would catch a bug"
metadata:
  type: feedback
---
**On a risky change (shared data, money, a guard, anything hard to undo), the cold reviewer plants 10–20 mutants on the lines the PR touches and checks that the tests notice them.** A small, low-risk change gets the test run and the normal review. A green suite proves the tests pass; a killed mutant proves they would catch a bug. A test that cannot fail is worse than no test, because it gets counted as coverage.

**The case:** a PR passed the briefed reviewer, the bot and a cold review. A mutation run afterwards planted a few dozen small bugs and about half survived, almost all of them in lookup tables the new tests claimed to pin. The tests were passing for a different reason. On another PR, a newly "pinned" rule was deleted outright and the whole suite stayed green: every test called the function directly and none exercised the path it was wired into.

**Why:** a green run says nothing about whether a test bites. Mutation does, cheaply, on exactly the lines at risk.

**How to apply:**
- A mutant is one small, plausible bug: flip `>=` to `>`, drop a list item, delete a guard or early `return`, `||` → `&&`, remove a call. Mutate what the new tests claim to pin.
- Only in your own clean clone of the head, with no keys in the environment. Never in the author's checkout.
- One at a time, through an exact-text anchor that appears once. **Confirm the file actually changed** (hash before and after): a no-op mutant reads exactly like a pinned rule. Run the test files that load the changed file, restore, end with `git status` clean.
- Killed = a test failed **with an assertion**. A crash, load error or timeout is inconclusive: rerun once, then report it as inconclusive.
- Every survivor gets a kind: a missing test (give the input that flips the behaviour) or behaviour-neutral (one line why). A behaviour-flipping survivor is a test the author adds before the human ask.
- If no test file loads the changed file, that is the finding; say it in one line.
- Report `Mutants: N planted · K killed · S survived · I inconclusive`, then one row per mutant.
- One battery per PR, in the cold review only; overlapping batteries multiply suite time.
