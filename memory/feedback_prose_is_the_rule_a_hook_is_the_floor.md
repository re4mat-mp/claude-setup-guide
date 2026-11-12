---
name: prose-is-the-rule-a-hook-is-the-floor
description: "A rule that matters is written twice: prose that explains why, and a hook that fires whether or not it was read; deny by destination rather than command name, write the hook's ceiling into it, and put the rule where the action is taken"
metadata:
  type: feedback
---
**A rule that matters is written twice: as prose the agent reads, and as a hook that fires whether or not it was read.** Prose explains why and generalises to cases nobody listed; a hook cannot be ignored. The prose is the rule, the hook is the floor under it.

**The case:** a rule against opening PRs as drafts lived in the review skill and was broken four times in one day, because that skill loads at review time, after the PR already exists. It was moved to where the action happens: the authoring agent that runs `gh pr create`. Elsewhere, a review bot's author enforced its constraints in both registers, including a shell-bypass detector. Blocking the write tool does not stop `echo … > protected/file`, `tee` or `sed -i`, so the detector parses out the destination of every redirect and runs it through the same path deny-list, with a comment admitting its ceiling: a determined agent can still escape through `eval`; this catches the obvious cases.

**Why:** prose competes for attention and fails quietly. A hook alone teaches nothing: it blocks the cases its author enumerated and is silent on twenty adjacent ones, and a blocked agent with no explanation routes around it in good faith.

**How to apply:**
- Choose which rules get the pair with one test: is a violation expensive *and* irreversible? Those get a hook; the rest stays prose.
- Deny by **destination** (protected paths), not by command name. Parse the targets of `>`, `>>`, `tee` and `sed -i`.
- Write the hook's ceiling into its code as a comment, so nobody builds on it past its design.
- Make the block message actionable: "writes to X are blocked; the writable location is Y". "Denied" alone produces a retry loop.
- The prose names the hook; the hook's message quotes the prose.
- A rule that forbids an action lives where the action is taken, not in a document read afterwards.
- Don't delete the explanation once the hook exists.
