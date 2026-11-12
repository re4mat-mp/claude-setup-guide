---
name: see-the-data
description: >
  Turn data into ONE self-contained HTML page you can open in a browser: a visual explainer, a few
  charts, or a 5-8 slide HTML presentation. Use this instead of building a BI dashboard or a
  small app when the goal is to UNDERSTAND some data once, or to EXPLAIN it to someone. Triggers:
  "help me understand this data", "make me a chart of", "show me what's going on with", "visualise
  this CSV / sheet / query", "explain these numbers to my team", "make a small presentation about",
  "one-pager on", "what does this trend look like", "I need slides for Monday about".
  Pulls the numbers (a saved query, CSV, spreadsheet, pasted table), checks them, and builds the
  page. NOT for a dashboard many people will open every week with live data (build a real dashboard
  for that).
---

# See the data

Most of the time you do not need a dashboard. You need to *see* the data once, or show it to three
people in a meeting. Building a dashboard or a small app for that takes an afternoon and
leaves behind something nobody maintains. Asking Claude for one HTML page takes ten minutes and gives
you something you can read, send and throw away.

## When a page beats a dashboard, and when to graduate

| Use a page (this skill) | Build a real dashboard |
|---|---|
| You want to understand something once | The same question gets asked every week |
| You are explaining it in a meeting or a message | Many people need to open it on their own |
| The data is a snapshot (a query, an export, a sheet) | It must show live data without anyone re-running it |
| You are still figuring out which question matters | You already know the 3-5 numbers that matter |
| A few viewers | Many viewers, or it feeds an alert or an automation |

A good path: make the page first. If people keep asking you to "re-run that page", that is the signal
to graduate it to a dashboard, and by then you know exactly which charts belong on it.

## How to ask (copy, paste, edit)

Give Claude three things: **the question you want answered, where the data lives, and who will read
the page.** Examples:

**Understanding a queue**
> I want to understand why our support queue grew last month. Pull opened and closed requests per
> week for the last 12 weeks from this export, split by category. Build me one HTML page with a weekly
> line chart, the top 3 categories by growth, and two sentences on what changed. State the source and
> the time window under every number.

**Explaining to the team**
> Make a 6-slide HTML presentation for Monday's team meeting about our ticket backlog. Use this CSV
> [attach]. One idea per slide: where we are, how we got here, which category drives it, what we will
> try. Light theme, big numbers, no tables if a chart can say it.

**Data / analysis, a first look**
> Here is a sheet with last quarter's sign-ups [link]. I have not looked at it yet. Give me a one-page
> visual explainer: what the columns are, how many rows, the 4 most interesting patterns as charts, and
> anything that looks like dirty data. Do not guess what a column means; ask me.

**Comparing options**
> Build a page comparing option A (weekly batch) and option B (daily batch) for the report
> run, using the numbers in this thread. Label them A and B everywhere, in the charts and the text.

**Turning a query into something readable**
> Run this saved query [link] and turn the result into a page my manager can read in one minute:
> the headline number at the top, one chart, and the caveats at the bottom.

## What Claude does (the method)

1. **Clarify the question in one line** before touching data. If the request is a topic ("look at
   sign-ups"), ask what decision the page should help with.
2. **Pull the data from the source** (run the query, read the CSV or sheet). Keep the query or
   file next to the page so any number can be re-derived.
3. **Check the numbers before drawing anything.**
   - Re-check 2-3 numbers against the source a second way (a total from a different card, a row count,
     a known figure from last month). If a result surprises you, assume the query is wrong first.
   - A zero or an empty chart needs a reason. A misspelled name, a stale table or a filter on the wrong
     column all return a clean, confident zero.
   - State the grain (per user? per order? per request?) and the denominator. Users and orders
     are not the same count.
4. **Pick the form**: one explainer page (default), a few charts on one page, or a 5-8 slide deck.
5. **Build one self-contained `.html` file**: everything inline, no external fonts, no external data
   calls. It must open by double-click, offline.
6. **Look at it before handing it over**: open it, check nothing is clipped, nothing overlaps, and every
   number on screen matches the checked numbers.

## The rules for the page

**Numbers**
- **Every number carries its source and time window**, right under it or in a footnote:
  *"Source: saved query 'Open requests by week', 1 Aug to 31 Oct."*
- **Every number says what it means** in plain words. Not "60% other" but "60% of the 40 requests picked
  *Other* in the reason dropdown, so we cannot group them."
- **Never invent a number.** If something could not be computed, the page says so.
- If two sources disagree, show both and say which one you trust and why.

**Design**
- **Native system font** (`-apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, Roboto,
  sans-serif`). Never a web font: shared previews often block external hosts, and the page silently
  falls back to something ugly.
- **Light theme only**, fixed. No dark mode that reacts to the viewer's system setting: a slide that
  turns black mid-meeting is worse than no slide.
- **Charts over tables.** A table only when people need to look up exact values.
- **One idea per slide, or per section.** A slide carries the claim and one piece of evidence (about
  50 words); the explanation goes in speaker notes, not on the slide.
- **Type big enough.** If a slide feels empty, cut words; never shrink the text.
- **Headlines that argue, not label.** "Refund requests doubled after the pricing change" beats
  "Refund requests".
- **Options are labelled A, B, C** in the chart, in the text and in the question you ask the reader.
- **Colour carries meaning only.** Red/orange means a problem, green means done. Always put text beside
  a colour so colour never carries the meaning alone.
- **Tabular numbers** (`font-variant-numeric: tabular-nums`) in any column of digits.

A palette that is colour-blind-safe for up to seven series is Okabe-Ito: orange `#E69F00`, sky blue `#56B4E9`,
green `#009E73`, yellow `#F0E442`, blue `#0072B2`, vermillion `#D55E00`, purple `#CC79A7`. For scatter plots and
maps, stay at four series or fewer. Keep the page itself quiet: white or off-white ground, near-black text, one grey
for secondary text and hairlines.

**Before showing a deck to people**: open it at 1024, 1280 and 1440 px wide and check that no slide
clips its content at the bottom.

## Where the page lives

- **A page with work data stays local or in a private share.** Open it from your laptop, or share
  it privately with the people who need it. Never publish it to a public link.
- Customer names, company names, amounts tied to a named customer, and anything personal stay out of
  any page that leaves your machine. Aggregate or anonymise first.
- Save the page next to the query or the data file it came from, so next month you can re-run the
  query and rebuild it.
- If you need a PowerPoint, build the HTML page first and export; expect the export to lose a little.
