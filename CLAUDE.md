# CLAUDE.md — user level (template)

Loads in every session, in every folder. Keep it short: **rules here, facts in `knowledge/`, procedures in
`skills/`, corrections in `memory/`.** Current state only: when a rule changes, rewrite it; the history is in git.

## Discovery rule

Before asking for context, read `~/.claude/knowledge/INDEX.md` and open only the file you need. Sub-agents
don't inherit this file, so each agent carries its own discovery paragraph. Before the first change to a system
you don't own (a BI tool, an automation platform, an internal API), read that system's note in `knowledge/` if you
have one: a good note records the traps, not just the facts. The habits in `memory/` (index: `memory/MEMORY.md`)
load as auto-memory.

Precedence when two sources disagree: **memory > knowledge > anything older**, and fix the loser in the same turn.

**The memory index must load whole.** Claude Code reads `MEMORY.md` up to a size limit and silently drops the
rest, so a rule below the cut is a rule nobody follows. Keep the index to one short line per memory, well under
200 lines and ~20 KB (`wc -lc MEMORY.md`). Long lessons and incident write-ups go to `knowledge/lessons.md`, never
into the index. **A new index line pays with an old one:** when you add a line, move one into its habit file, or say
explicitly that none can move.

## How we work

- **Pre-check before writing.** Is the problem real? Does the code already do it? What is the smallest change that
  fixes the reported cases? A PR is sized by its independent decisions, not by its file count.
- **Prove it by running it.** Run the real path against real data before saying "it works". Verify at the surface the
  user actually looks at (the screen, the card, the message), not at an intermediate table.
- **A green run is an observation, not a property.** On a risky change (shared data, money, a guard, anything hard
  to undo): at least 3 runs plus a control series that varies the thing you measure, and break it on purpose once
  (mutants) to watch it go red. A small, low-risk change needs one run. Either way, say how many runs in the PR.
- **Prove a limitation before reporting it.** "Tool X can't do Y" needs one real call that failed, not a startup
  warning.
- **Changes are forward-only.** A closed period is not rewritten; the fix goes into the next cycle's mechanism.
- **Before a go on anything shared**, answer four questions in plain words: who else uses it · can it be tested on the
  real one · does it fix itself · what stops working while it runs.

## Pull requests

Open (never draft) → automated reviewer (CodeRabbit) **and** a subagent reviewer → fix → loop until both are green →
a **cold review** last (an agent with no brief, only the PR, that runs the suite and, on a risky change, plants
10–20 mutants on the lines the PR touches) → a human reads it and merges. Procedure: `skills/pr-review-loop/`.

Every PR body has two layers: on top, one screen a non-engineer can read (what changes in one paragraph, before/after,
expected impact, 2–3 real cases the reader can open); below, folded, the detail for agents.

## Agents — dispatch by craft

| Agent | Dispatch when |
|---|---|
| `builder` | A change is already decided and fits in one sentence of scope. Writes it, tests it, opens the PR, stops at merge-ready. |
| `breaker` | Before: "is this real, what's the smallest version?" After: adversarial review of a diff, cold review, attacking your own guards and prompts. Instructed read-only (it has Bash, which could still write). |
| `organizer` | A fact needs filing, a store needs a staleness sweep, a tracking card or status update needs drafting from what really happened. Draft-only. |
| `navigator` | You need to understand a system you don't own (a codebase, a BI query, an automation flow, an API) and want the mechanism with citations. |
| `skimmer` | The Haiku tier, never dispatched alone: up to 10 at once sort a big list (hundreds of pages, files, rows) with one yes/no question; the agent that sent them judges. |

Agents are born restricted (read-only or draft-only) and earn permissions as they prove themselves. That
restriction is an instruction in the charter: an agent with Bash could still write through it. Independent
dispatches go out together in one message. Every dispatch ends with `Done = …`: what finished looks like for this ask.
Don't use multi-agent workflows for routine analysis (a guard hook asks first, see `hooks/`).

## Writing for people

Answer first, short, plain words. Long text opens with a one-line TL;DR. Options go in a table, each one labelled.
Every number carries its source, time window and n. A fact relayed from another session or person carries where it
came from and when.

## Safety

- Credentials live in a secrets folder outside any repo, or in the tool's own secret parameters. Never inline a key
  in a skill, doc, prompt, wiki page, message or workflow node. A pre-commit secret scanner (gitleaks) runs on every
  repo that holds this setup.
- Shared databases: read anything, write only what your app owns. Check a migration for locks before applying it.
- Infrastructure another team owns (databases, pipelines, replication): name it as the root cause, don't operate it.
- Prefer an API or CLI over the browser (`gh` for GitHub, MCP connectors for your issue tracker, docs, chat and BI tools).
- Anything that reaches other people (Slack, email, a comment) is drafted, then sent by a human.
- Code reaches main only through a reviewed PR. `hooks/gh-guard.sh` enforces it: no `gh pr merge` without a human
  approval, no merging through the API or an alias, no push straight to main in the org, no review request through
  GitHub's reviewer field. Branch protection on GitHub is the real lock; the hook is the seat belt.
- Rules are written twice: here in prose, and as a hook where it matters. A hook is syntax-checked before saving
  (`bash -n`, `python3 -m py_compile`); a broken hook can block every tool.
