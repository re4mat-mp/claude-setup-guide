---
name: a-green-run-is-an-observation
description: "One green test run is an observation, not a property; on a risky change, run at least three times plus a control series that varies the thing being measured, and write how many runs in the PR, because reviewers approve on the numbers we report"
metadata:
  type: feedback
---
**One green run is an observation, not a property of the suite.** Any suite that spawns processes, mutates a working tree or runs files in parallel can pass once and fail later. On a risky change (shared data, money, a guard, anything hard to undo) we run it at least three times plus a control series, and we write how many runs in the PR. For a small, low-risk change, one run is enough, and the PR says so.

**The case:** three consecutive commits each reported "N tests, 0 fail" from a single run. Re-run later, the branch failed four times out of four: new tests that spawned a CLI raced against another test mutating the same checkout under the parallel runner. Two hours went into wrong hypotheses before the one measurement that decided it. Then a "control" was run on the head that already serialised the suite, which measured the absence of the symptom exactly where the symptom was suppressed. A second control silently failed to apply its config change and was just another parallel run.

**Why:** reviewers approve on the numbers we report. A count without a denominator travels as a guarantee.

**How to apply:**
- Three or more runs, plus one series where you **vary the thing being measured** (for example, same head with and without `--test-concurrency=1`). Green in series and red in parallel is the signature of a race.
- Verify the control actually changed something before reading its result.
- Write the method, not just the result: "412 tests, 0 fail, 4 of 4 runs; same head, serial vs parallel".
- For an intermittent failure, stop theorising and isolate by difference: base, branch in series, branch in parallel.
- Before calling a pre-registered check a PASS, compute the worst value it can reach with the n you have. If it cannot fail, write "not tested".
- One explained symptom can still have two causes.
- The building session does the repeated runs; a cold reviewer runs once.
