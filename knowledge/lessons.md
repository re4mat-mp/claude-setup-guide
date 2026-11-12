---
name: lessons
description: "Transferable patterns about automation, guards, metrics and verification, each with how to notice you are in it"
---

# Lessons — the transferable layer

Notes about specific tools go out of date. This file is what I learned that would still be true
with different tools: patterns about automation, guards, metrics and verification,
each traced to something that actually happened. Each lesson gives the pattern, **the tell** (how you
notice you are inside it), and what to do.

Most of them are one idea seen from different angles: **a system that fails the same way it succeeds
will fail without anyone noticing.** If you read only three, read *Silence is the alarm*, *A silent
failure needs a tell, not a fix*, and *Replay the real case*.

---

## Failures that look like success

### Silence is the alarm
**Pattern.** Automation fails loud (it throws, someone gets alerted) or silent (it completes, reports
success and does nothing). Only the loud kind is monitored by default; the silent kind is the one
that costs days.
**The tell.** Green runs while a queue grows; "ran successfully, processed 0".
**How to apply.**
- Write down each job's expected volume per run or per day, and alert when it falls outside the band,
  zero included.
- Watch the age of the oldest pending item, not only the queue size.
- Log actions taken, so a quiet day reads as either "nothing to do" or "nothing happened".

### An empty success is a lie
**Pattern.** A handler that returns success with an empty result collapses several different failures
(missing input, invalid data, a uniqueness clash, a real no-op) into the same value the happy path
returns. The only trace is a log line nobody reads.
**The tell.** A result type where "empty" is a valid answer, with no field saying why it is empty.
**How to apply.**
- If a result can be empty, the emptiness carries a reason code.
- The reason lands in a queryable row, not only in a log.
- In review, grep for early returns of an empty success and ask what each one hides.

### A silent failure needs a tell, not a fix
**Pattern.** When a system fails exactly the way it succeeds, the case you found is one of many that
already went unseen. The fix is rarely the bug itself; it is giving the failure a visible signature.
And the instrument (the check, the monitor, the test) is where this hides most often.
**The tell.** Ask "if this fails, does it look different from when it works?" If the answer is no, you
are in it.
**How to apply.**
- Before trusting a green signal, find out what it prints when it fails. If it prints the same, it is
  not a signal.
- The ticket is "give it a tell", not "fix this case".
- Put the rule where it runs (a check, an assertion), not only where it is read.

### A guard can be green and blind
**Pattern.** A guard's green means "found nothing", which is indistinguishable from "could not see
anything". A guard that silently skips inputs it cannot parse will stay green while it misses the
cases it exists for.
**The tell.** The guard has never failed, and nobody has fed it the hostile input on purpose.
**How to apply.**
- Test a guard by planting: one hostile input at a time, each a shape it claims to catch. The ones
  that pass green show where it is blind.
- A guard that cannot parse an input fails instead of skipping it.
- Do not compare a guard against a loose floor it does not derive itself; coverage can drop under it.

### A green check is not a review
**Pattern.** An automated reviewer's status check reports that it ran, not what it found. Green can
mean "ran, found nothing", "ran, findings are elsewhere" or "never ran".
**The tell.** You are about to say "the bot approved it" (or "the bot found nothing") from a status
icon.
**How to apply.**
- Read the review threads and their resolved state, not the check.
- Note the commit the review ran on, and compare it with the head that will merge.

### Configured is not rendered
**Pattern.** A change verified on the layer you edited is not verified on the layer someone uses. An
API that accepts a setting does not mean the screen shows it; a schedule that is configured has not
run until it has had a chance to fire.
**The tell.** Your evidence is a read-back of what you wrote (the API returns the setting; the config
file contains the line).
**How to apply.**
- Name the surface you checked, and check the one the user sees (open the page, read the sent
  message, wait for the next scheduled run).
- Ask which states your instrument can observe at all; a green from a tool that cannot see the failure
  mode is the expensive kind.

### A monitor must not share a failure domain
**Pattern.** A check that lives inside the thing it watches cannot report that the thing died. If the
job is disabled or its credential expires, the monitor goes with it.
**The tell.** The monitor runs in the same workflow, the same schedule, or with the same credential as
what it monitors.
**How to apply.**
- Put the monitor on a different substrate, and check liveness against the scheduler's own record,
  not against an output count (which is also zero on a quiet day).
- Check two conditions: freshness (it ran recently) and sufficiency (it did enough).
- When a credential incident closes, ask which alarms depended on that credential, and re-arm them
  first: the dead credential may have been silencing a different outage.

### Count the vetoes
**Pattern.** A guard that rejects bad output and increments nothing swallows the most valuable signal
in the system: how often, and why, it fires.
**The tell.** You cannot answer "how many times did this guard block something last week, and for what
reason?"
**How to apply.**
- Emit a counter per veto reason.
- Treat a veto rate of zero as suspicious: the guard is either unnecessary or broken.

## Rules and enforcement

### A hard rule needs a gate that cannot forget
**Pattern.** An instruction to a fallible actor (a person, a model) is a suggestion, however many
times it is repeated. A rule that must hold needs something mechanical that enforces it.
**The tell.** The same instruction appears several times in a prompt or a doc, in capitals, and it
still gets broken.
**How to apply.**
- Move hard rules into code: a validation, a check, a database constraint, a hook.
- Keep prompts for judgement and tone, not for invariants.

### Prose is the rule, a hook is the floor
**Pattern.** For rules that matter, write them twice: as prose, which explains why and generalises to
cases you did not list, and as a hook, which fires whether or not anyone read the prose. Neither
replaces the other.
**The tell.** A rule exists only as prose (it gets ignored), or only as a hook (agents route around it
without understanding why).
**How to apply.**
- Deny by destination (paths, hosts, tables), not by command name, and parse redirect targets.
- Write the guard's ceiling in a comment, and make its block message say what to do instead.
- Keep the prose and the hook pointing at each other.

### A saved query read by a machine is an API
**Pattern.** Once an automation reads a saved report by id, that report is a production API with no
version, no schema and no test. Its failure mode is not an error; it is fewer rows or different keys.
**The tell.** Someone is about to "just tidy up" a report, and nobody knows which automations read it.
**How to apply.**
- Name it as load-bearing and list its consumers in its description.
- Give the consumer one assertion: a row-count floor and the expected columns.
- Verify at the endpoint the consumer calls (its export, with its parameters), not at the definition.

## Verifying a claim

### Replay the real case
**Pattern.** A rule that reads correctly is not a rule that works. Run the real failing cases through
the real code path before saying something is fixed, including cases you did not sample, because
that is where a fix inverts.
**The tell.** Your evidence that it works is that you read it and it makes sense.
**How to apply.**
- Run the actual inputs that failed through the actual code, on both the old and the new version.
- Add cases you did not pick by hand (a random sample, the edges).
- Watch for a fixture that passes for the wrong reason.

### The oracle is a hypothesis
**Pattern.** When you write the expected answer yourself, it is the least tested thing in the setup.
A search finds the line that matches, not the branch you are standing on.
**The tell.** The thing under test disagrees with your expected answer, and you are about to call it a
failure without re-reading the source of your expectation.
**How to apply.**
- Verify the expected answer before it becomes the standard; read the whole section, not the matching
  line.
- Run your control case in the real environment too: a case designed to return nothing can return
  nothing for the wrong reason.
- When a disagreement comes with a checkable argument, check the source before touching the assertion.

### Absence needs a wider grep
**Pattern.** Proving something is not there is a claim about a boundary, and it fails silently: zero
results never argue with you.
**The tell.** "There are no other places that do X", based on one search.
**How to apply.**
- Say what surface you searched (which repos, which folders, which naming conventions, which
  instance).
- Search other spellings and other layers (config, data, UI) before asserting absence.
- Scroll to the bottom of lists and dropdowns before concluding something is missing.

### Count the class, not the instance
**Pattern.** A defect that exists because something was written twice has a count. Fixing the
instance you were shown and declaring the class closed fails repeatedly, each time someone else finds
the next copy.
**The tell.** The bug came from duplication (copied logic, a list kept in two places), and your fix
touched one place.
**How to apply.**
- First find the count: grep every copy, in code and in config.
- Fix them all in one change, or remove the duplication.
- Check that your test would catch the next copy too.

### A probe that can succeed is not a probe
**Pattern.** A safe permission test turns into a real write when you resolve its ambiguous result by
removing exactly what made it safe. Each step feels like precision; nobody decides to write to
production.
**The tell.** To "get a clearer answer", you are about to remove a dry-run flag, a no-op payload or a
guard from a test.
**How to apply.**
- Before probing whether you can do something, ask what happens if the answer is yes.
- If disambiguating needs the guard removed, that instrument cannot answer the question; find another.

### Test with the credential that will run it
**Pattern.** Checking that a resource exists with your own access says nothing about whether the
system you are approving can reach it. Without a control that must pass, a broken request and a denied
one look identical.
**The tell.** "I checked, it's there", said by someone whose access is broader than the automation's.
**How to apply.**
- Test with the exact credential the system will use.
- Include a control call that must succeed, so you can tell "denied" from "broken".
- Remember that a handover moves the artifact, not the schedule or the identity that runs it.

### The snapshot is the control group
**Pattern.** A copy taken before touching a live system pays twice: it is the undo, and it is the only
way to answer "was this already broken?" once you start finding anomalies mid-repair.
**The tell.** You are about to change state on something live and have no record of how it was.
**How to apply.**
- Snapshot first (export, GET to a file, a copy of the row).
- Read a function before you invoke it.
- Ask the operator which artifact they touched instead of inferring it.

## Numbers and metrics

### An aggregate is a hypothesis
**Pattern.** A number computed over rows you have not read is a hypothesis. Backfills, boilerplate,
test rows and load timestamps all survive aggregation looking like signal.
**The tell.** You are about to rank or prioritise work on a metric and have not looked at any of the
rows behind it.
**How to apply.**
- Read about twenty raw rows and ask of each: is this even the thing I think I am counting?
- Report the contamination rate next to the metric.
- Filter on when the thing happened, never on when the row was loaded.

### A handed-over number is a hypothesis
**Pattern.** A number that arrives as context (in a brief, a ticket, a sentence in a meeting) has not
been verified by you, and it is load-bearing by definition: you were given it because something is
going to be built on it.
**The tell.** Checking it feels like distrust, so nobody does.
**How to apply.**
- Re-derive it before building on it; it usually costs one query.
- When passing a number on, say which ones you verified and which you inherited.

### Same name, different grain
**Pattern.** Numbers that disagree are often not in conflict: they count different units or see
different windows. The label survives a transformation; the unit does not.
**The tell.** Three sources give three counts of "the same thing", and the conversation is about which
one is wrong.
**How to apply.**
- For each number, finish "one row = one ___", and compare the blanks before the values.
- Check the window each source can actually see (when it started collecting).
- Divide them across several periods: a stable ratio is grain; a wandering one is a bug.

### Redundancy only fixes random error
**Pattern.** Votes, retries and second opinions average away error that varies. A systematic bias
survives them and comes back with a tighter confidence interval around the same wrong answer.
**The tell.** The proposed fix for an unreliable judge or measurement is "ask it three times".
**How to apply.**
- Repeat the identical input first: if it disagrees with itself, you have noise; if it agrees with
  itself and is still wrong, you have bias.
- Only an outside reference (human labels, a different method) finds bias.

## Data and integration design

### Join on keys, not names
**Pattern.** When configuration matches data on a human-readable name, a mistake is not an error: it is
silent zero coverage that looks exactly like "nothing to do today".
**The tell.** A config list of names (suppliers, customers, categories) matched against data with `=`
or `IN`.
**How to apply.**
- Join on a stable id.
- If names are unavoidable, assert that every configured entry matches at least one record.

### Canonical status is where truth dies
**Pattern.** Normalising many upstream vocabularies into one status field loses information: each
provider lies differently in the same field, several real outcomes collapse into one value, and every
rule downstream inherits the lie.
**The tell.** A decision depends on `status = 'X'` where the status is a mapped value from several
providers.
**How to apply.**
- Keep the raw value next to the canonical one.
- Treat the canonical value as a set when a decision depends on it.
- Make an unmapped input fail loudly instead of mapping to a default.

### Materialise is not send
**Pattern.** Split any job that acts on the outside world in two: one step writes rows describing what
should happen, a second step drains them. The split makes the job idempotent, rehearsable, reviewable
and resumable.
**The tell.** One job decides and acts in the same pass, so the only way to test it is in production.
**How to apply.**
- Write intended actions to a table first; enforce dedupe with a unique index on that table.
- Let the sender drain the table, marking each row sent; a dry run is "materialise only".

### Queue head-of-line blocking
**Pattern.** A strict-order queue stops completely when its oldest item cannot be processed, while
looking busy the whole time.
**The tell.** The same item is picked up run after run; throughput is zero; every run is green.
**How to apply.**
- Give the queue three states: pending, done, parked. Parking is cheap, reversible and has an owner.
- Alarm on the age of the oldest pending item.
- Never delete the blocker; park it so the exception stays visible, and give the park list a review
  date.

### One engine plus config
**Pattern.** N near-identical processes, one per entity, are one engine plus a table you have not
written yet. Copy-paste is locally fastest every time; the cost is a fix applied in 16 places, of
which you remember 14.
**The tell.** Flows or scripts that differ only in values (an address, a template, a threshold).
**How to apply.**
- Mark every difference between the variants; those become config columns.
- Write the "add an entity" recipe and test it by adding one.
- Switch the old copies off rather than leaving them idle. If the differences are steps rather than
  values, they are genuinely different processes.

## Working with models and automation

### The model writes the words, not the decision
**Pattern.** A reliable generation system does not ask the model what to do. Code picks the action or
template; the model renders it in the right tone and language, behind mechanical checks (every
identifier must appear in the input data, a list of forbidden phrases, a fixed fallback).
**The tell.** A model's free text decides whether money moves, a ticket closes or a promise is made.
**How to apply.**
- Decide in code; generate only the wording.
- Check generated identifiers against the source data, and ship a fixed fallback when a check fires.

### Automate around the judgment
**Pattern.** Every process has a small core of real judgment and a large ring of repetition around it.
Automate the ring completely; leave the core to a person, and make the automation hand it over well.
**The tell.** The step is irreversible, touches money, access or a relationship, or experienced people
sometimes disagree with the rule.
**How to apply.**
- Mark each step as repetition or judgment, and write the line down.
- At a judgment step, the automation arrives with everything assembled and a recommendation, then
  stops for a human decision, and records who decided.

### Mechanism is durable, posture is perishable
**Pattern.** A document that states a current value starts lying when the value changes, and nothing
tells the reader. How a thing works stays true; what it is set to right now does not.
**The tell.** A number in your doc that someone could change without touching your doc.
**How to apply.**
- Write the mechanism; for the current setting, point at where to read it live.
- If a snapshot genuinely helps, date it and label it perishable in the same sentence.
