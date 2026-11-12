---
name: two-layer-writing
description: "PR bodies, tickets, review comments and status posts have two layers: a short plain-words summary on top that a person could say aloud, and the dense detail below for agents and auditors; one layer can't serve both readers"
metadata:
  type: feedback
---
**PR bodies, tickets, review comments and status posts are written in two layers: a short human summary on top, the detail for agents and auditors underneath.** The top layer is 2–4 sentences in plain words: what broke or got better, who feels it, what changed. It should be readable aloud in a meeting. The bottom layer is dense and complete (files, IDs, numbers, queries) so a fresh session or a reviewer can pick the work up cold.

**The pattern:** dense, number-heavy text reads as machine-generated to the people who have to act on it, and gets a worse reception than the same content in plain words. Stripping the detail instead makes the text useless to the next agent. Two layers serve both.

**Why:** the people approving work need to be able to explain it; the agents continuing it need everything. One layer cannot serve both readers.

**How to apply:**
- Write the human layer **first**, then the detail. Not a summary bolted onto a technical body.
- Test the top by reading it aloud. If it only works written down, rewrite it.
- Titles follow the same rule: plain and behaviour-shaped ("X no longer does Y"), no internal vocabulary.
- A review comment opens with the verdict: "Approved. One thing to fix before merge, and it's the description, not the code." Then the evidence.
- Chat messages and short posts stay thinner than a PR: the top layer plus a link; the detail lives in the PR.
- Anything posted under a person's name should read like that person: one or two lines in their voice on top, technical detail below.
