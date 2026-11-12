---
name: model-agents-by-craft
description: "Model an agent by its craft (the kind of thinking it does), not by project or tool; dispatch follows the description, so a situation-shaped or narrow agent goes unused while tool quirks and project state belong in files the agent reads"
metadata:
  type: feedback
---
**We model an agent by its craft (the kind of thinking it does), not by project or by tool.** The agent file holds who it is, what it cannot do and its tool allowlist. Tool quirks and project state are files the agent reads at start ("read `knowledge/x.md`, read this `RESUME.md`"), so when a tool fixes a bug the agent inherits the fix for free.

**The pattern:** two well-written agents on the same model, one shaped by craft ("be skeptical of this diff"), one by situation ("an incident is happening"). The craft-shaped one gets dispatched constantly; the situation-shaped one almost never. Agents split by business area have the same problem: a real request crosses areas, so nobody owns it, while the verb (triage, draft, look up) is stable.

**Why:** dispatch follows the description. A narrow frame kills an agent regardless of quality, and per-project agents multiply: six that know the project and none that knows how to write a PR.

**How to apply:**
- When creating or reviewing an agent, ask "what kind of thinking is this?", not "which project?" or "which tool?".
- If its description only fires in one specific situation, widen it to the craft.
- Keep facts out of the agent body; point it at the knowledge files.
- Tools are instruments of the craft, never its ceiling.
- Count dispatches. An agent at zero after two weeks has a framing problem.
- If a craft is exercised every day but its agent is never dispatched, that is the problem to fix.
