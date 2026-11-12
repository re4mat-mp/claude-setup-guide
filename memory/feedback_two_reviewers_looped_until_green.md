---
name: two-reviewers-looped-until-green
description: "Every PR gets an automated reviewer (CodeRabbit) and a subagent reviewer, looped until a round on the current head is clean, before any human is asked; the bot reviews minutes after each push, so a one-pass check always ships past it"
metadata:
  type: feedback
---
**Every PR gets two reviewers, CodeRabbit and a subagent reviewer, and we loop until a round on the current head comes back clean before a human is asked to look.** The two catch different things: the bot is good at contradictions between files and sloppy edge cases in tests; the subagent is good at "does this do what the body claims". Neither pass is trusted alone. It runs by default with every PR; nobody needs to authorise it each time.

**The pattern:** a PR is opened with a careful subagent review, and nobody goes back for the bot. Its findings, posted minutes after the PR opened, sit unread for days, and a serious one is among them. When they are finally fixed, the next round finds another in the newly written code.

**Why:** the bot reviews a few minutes after each push, so it is never ready when you open the PR, and every push starts a new round that reviews your fixes too. Only a loop catches that.

**How to apply:**
- `push → subagent review → fix → push → wait a few minutes → read the bot → fix → push → read again`, until a round on the **current head** raises nothing.
- Each finding is either fixed or dismissed **with a written reason in the PR thread**, never silently.
- When the bot has a per-hour quota, batch all fixes into one push; a one-word fix pushed alone costs a whole round.
- Open PRs as ready, not draft: most review bots skip drafts and will not come back on their own. The "don't look yet" signal is simply that nobody has been asked.
- Right before each push, run `gh pr view <N> --json state,headRefOid`. A PR can be approved and merged by its author while you are fixing it, and a push to a merged branch strands the work outside main.
- If the bot is not installed on a repo, say plainly that the PR had one pass, not two.
