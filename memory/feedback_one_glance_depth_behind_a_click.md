---
name: one-glance-depth-behind-a-click
description: "Everything a person receives should resolve at a glance with depth one step away, never deleted and never in front; correct content can still fail by how much space it takes, and a dashboard describes the present, not its changelog"
metadata:
  type: feedback
---
**Everything a person receives should resolve at a glance, with depth one step away: never deleted, never in front.** This is not "make it shorter". The detail does not get cut, it gets moved. Something can be entirely correct and still fail because of how much space it takes to say it.

**The case:** three times in one day, three correct things failed the same way: a PR with four decisions in one place; a capability table that ate a whole dashboard section (moved inside the cards, it read better); a wall of tiles taking over an entire app screen ("make it smaller, and open a new view on click"). Later, a well-shaped PR body was broken by what got appended to it: a review summary written as three dense paragraphs with no table and no fold.

**Why:** readers decide from the first paragraph whether to keep going. Depth in front means they read nothing; depth deleted means they cannot verify.

**How to apply:**
- The first paragraph carries the whole message; everything below is for whoever wants more.
- Detail goes behind `<details>`, a link or a detail page. It is not deleted.
- Appended sections follow the same shape as the original body.
- When something is a network or a flow (who hands work to whom, what depends on what), draw it with arrows. Relationships read faster drawn than written.
- A surface describes the **present** to its reader. A dashboard or card description is not a changelog: ask "who is this sentence talking to?" If it talks to the next editor (edit dates, "we changed X because"), move it to the ticket or your notes. Keep the fact, drop the voice.
- Text cards on dashboards clip by lines, not characters, and an API cannot tell you; open them to check.
