---
name: organize-your-files
description: "Which file holds what (rules, facts, habits, today, procedures), a state file with a daily close, and a prompt that audits your own notes"
---

# Keep your notes where Claude can use them

A new session knows nothing except what's on disk. So the quality of your setup is mostly a filing question: when
a session starts, does it find the rules, the facts and today's state, each in a place it knows to look?

This is the filing system I use, plus the two prompts that keep it honest: a daily close, and an audit you run
every few weeks.

---

## Five kinds of note, five homes

| Kind | Home | Ask yourself | Example |
|---|---|---|---|
| **Rule** | `CLAUDE.md` | Must it hold in every session? | "Never push to main without my ok" |
| **Fact** | `knowledge/` | Will it still be true next month? | "The nightly backup job: what it reads, how it fails" |
| **Habit** | memory | Is it about how *I* work? | "When comparing two options, a table" |
| **Now** | `HANDOFF.md` | Does it only matter this week? | "The release is blocked on one test, retry Monday" |
| **Procedure** | a skill | Have I explained it three times? | "How to cut a release, step by step" |

`CLAUDE.md` is read in full every time, so it's the expensive one. Memory loads on its own at the start (up to a
size limit: see "Memory that loads whole" in the README). Knowledge files and skills are read only when a task needs them, which is
why they can be long.

**Memory vs. knowledge** is the pair people mix up. Knowledge is about the *project*: anyone who opens the folder
needs it. Memory is about *you*: your preferences, your corrections, and the habits they turned into. Mine are in
[`memory/`](../memory/MEMORY.md), and they're worth stealing as habits, not as facts. The trap: a project fact (a
limit, a deadline) saved only in memory. The knowledge file keeps saying something else, and nobody notices.

---

## Keeping `CLAUDE.md` useful

- **It points, it doesn't explain.** "The release checklist is in `knowledge/releases.md`" is one line. The
  checklist itself is not. If the file stops fitting on a screen, something in it is a fact that wants to move.
- **Each rule says why, and how to comply.** Without the why, Claude misapplies it in the case you didn't foresee.
  Without the how, it's a wish.
- **Rewrite, don't append.** When a rule changes, change the rule. A "(NEW)" or "(changed)" next to the old version
  leaves Claude two rules and no way to choose.
- **One fact, one home.** When two files disagree, fix the wrong one in the same sitting.

```markdown
# CLAUDE.md
## This folder
What I work on here, in one line.
## Rules
- [Rule] — why: [one line] — how: [the concrete way to comply].
## Where things are
- Facts: knowledge/ (start at knowledge/INDEX.md) · Today: HANDOFF.md, read it first
## How I like to work
- One step per message. Explain a change in plain words before making it.
```

---

## A skill points to the knowledge, it doesn't copy it

The description decides whether a skill ever gets used: it says **when** this one applies and not another. The
body is steps, a pointer to the knowledge file that holds the details, and what it must never do on its own.

```markdown
---
name: explain-a-failed-run
description: When I ask why a scheduled job failed or produced nothing.
  Takes a run ID or a log link. Not for changing the job: that's mine.
---
1. Read the run's log and the job's file in knowledge/jobs/.
2. Check the failure modes that file lists. If none matches, say so.
3. Tell me in three lines: what failed, the log line that proves it,
   and whether the job's file is missing this case.
4. If it is, propose the addition in writing. Don't apply it.

Never: rerun the job, edit it, or change its schedule.
```

When the job changes, you update `knowledge/jobs/` once and the skill stays right. Skills live in
`.claude/skills/<name>/SKILL.md` (per project) or `~/.claude/skills/` (everywhere); the desktop app takes them from
its Skills settings.

---

## A state file, and a close

The state file is the one note that's *supposed* to go stale: it's today. Give it a hard size cap. Without one,
every close adds a block on top and nothing ever leaves, and within weeks no one reads it. Before each close, older
blocks move to an archive file.

**The close**, pasted at the end of a working day:

```text
Wrap up today:
- Overwrite HANDOFF.md within its size cap: open items, anything waiting on my ok,
  today's decisions with their reason, and tomorrow's first check. Move older blocks
  to the archive file.
- List what we learned today that outlives this week, each with the home you'd give it
  (CLAUDE.md, knowledge, memory, skill). I'll approve them one by one.
- Turn any correction I made today into a written rule with its why.
- Commit, with a message that says what changed.
```

**The start**, the next morning:

```text
Read HANDOFF.md first. Three lines: what waits on me, what's in flight, what to check today.
Flag it if the file looks older than two days.
```

A state file whose top date is weeks old is the clearest sign the close isn't happening.

---

## The audit prompt

Every few weeks, have Claude review the whole filing system. It only proposes; you approve each change.

```text
Review my notes before changing anything. Read CLAUDE.md, HANDOFF.md, everything in
knowledge/, my skills and my memory. Report, in this order:

1. Contradictions: two files that disagree. Quote both lines and their files. If it's a
   rule about the work itself (a limit, a deadline, an owner), ask me which one holds.
2. Stale: dates presented as current, items "pending" for weeks, links to missing files.
3. Duplicates: one fact in several places, and where it should live. Include facts that
   sit in CLAUDE.md but belong in knowledge/.
4. Gaps: rules I keep repeating in chat, things with no file, tasks that should be a skill.
5. Sizes: each file and its size; does CLAUDE.md still fit on one screen?

Then propose fixes one at a time, biggest first: the file, the change, the reason in one
line. Wait for my ok before each write. Don't touch files outside these, don't change what
a rule says (only where it lives), and never write keys or personal data into a file.
```
