# What's in this repo, and what I left out

This guide started as a longer export of my working setup. Before making it public I cut it down to the part that
is mine and works for anyone. Here's the cut, so you know what you're looking at.

## In

| What | Why it's here |
|---|---|
| `README.md` | The guide itself: the ideas, how to try them, and the reasoning behind each one |
| `CLAUDE.md` | A template of my global instructions, rewritten so it isn't tied to any company or tool stack |
| `agents/` (5) | Split by craft, so they work on any project |
| `hooks/` (3) + tests | The guards I trust most. The merge guard has a 25-case test suite that runs offline, so you can see it work before wiring anything in |
| `skills/pr-review-loop`, `skills/see-the-data` | The two procedures that don't depend on any particular system |
| `memory/` (35 habits + index) | The most reusable part: one habit per file, each with the case that taught it |
| `knowledge/` (lessons, PR review, security, organizing your files) | Patterns that stay true with any tool, and how to keep your own notes in order |
| `assets/open-the-box.gif` | The animation at the top of the README: every count and name on it is in this repo |
| `docs/` | The pages GitHub Pages serves: the interactive "Open the box" and "The factory". Each has a plain-text version for people and for AI |
| The factory's real job | Shown as a pattern with an invented job and invented numbers. Its real code and data stay private |

## Out

| What | Why it's out |
|---|---|
| Notes about specific internal systems (the traps of each tool, admin APIs, data sources) | They describe systems that aren't mine to publish. The habit of writing them is in the README; the notes themselves stay private |
| A glossary and a design-system note | Too specific to be useful to anyone else |
| A skill for finding answers across several tools | Too tied to one particular set of tools |
| A skill for hardening a colleague's automation, and a spreadsheet-scripting note | Good, but too tied to the tools I happen to use. Maybe later, rewritten |
| Anything personal | This is a guide, not a diary |

## How it was checked

- Every file was read for names of companies, people, systems, IDs and internal URLs before publishing.
- A secret scanner (gitleaks) and a pattern search for keys and tokens: nothing found.
- A separate reviewer agent read the whole repo, file by file, looking for anything internal or private.
- The merge guard's tests pass (25 cases, three runs), and a bug planted on purpose turns them red.
