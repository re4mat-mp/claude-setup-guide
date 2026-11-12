---
name: parallel-dispatch-no-fanout
description: "Independent dispatches go out together in one message, bounded per batch and legible; routine work never uses a fan-out workflow, after one fanned out to 29 subagents and burned a 5-hour usage window in about 30 minutes"
metadata:
  type: feedback
---
**Independent dispatches go out together, in one message, but bounded and legible: never as a fan-out workflow for routine work.** Before dispatching, ask one question per task: does it need the previous one's output? If not, it goes in the same message as parallel tool calls.

**The case:** three independent requests (update a page, draft a message, create tickets) were done one after another. The queue was imposed by the agent, not by the work, and three two-minute tasks became six minutes of waiting. In the other direction, a routine analysis fired a multi-agent workflow that fanned out to 29 subagents and burned the whole 5-hour usage window in about 30 minutes, with a settings flag silencing the built-in warning.

**Why:** parallel saves the clock; fan-out spends blind. The problem was never spending, it was spending without knowing what each agent was doing. Named agents with known jobs are legible; an unbounded fan-out runs to the end before you see anything.

**How to apply:**
- The same applies to plain tool calls: six writes that don't read each other go out together.
- Cap each batch by model tier: large models ≤3, mid-size ≤5, small ≤10.
- Volume to cheaper models, judgement to strong ones. Small models classify well ("is this page a procedure or not?"); mid-size models find facts but over-flag problems; anything that reaches an owner is judged by the strongest model. A mid-size model's "stale" is a lead, not a verdict.
- A swarm of small models (the `skimmer` agent, on Haiku) works behind one leader that judges what they return.
- For cluster, dedupe and write-up tasks, default to one agent or a small handful. A fan-out workflow only when the scale truly needs it and someone opts in, with a token budget in the prompt.
- Keep the usage warning on, and gate workflows with a hook that asks before running.
