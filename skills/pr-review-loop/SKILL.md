---
name: pr-review-loop
description: >
  The review loop every pull request goes through before a human is asked to read it: an automated
  reviewer (CodeRabbit) AND a subagent reviewer, fixed and re-pushed until both are green, then a cold
  review last, then a human reads and merges. Use whenever a PR is opened or pushed to, or someone asks
  "is this ready", "can we ship it", "did you check CodeRabbit", "is this good to go", or before
  posting a PR anywhere. Holds the loop, the pre-flight checks, the exact `gh` commands to read review
  comments, the bar for fix vs note, and the failure it prevents: a bot reviews the PR two minutes
  after it opens and nobody ever goes back to look.
---

# PR review loop

Automated reviewers comment asynchronously, a few minutes after each push. They are never ready at the
moment you open the PR. If nobody deliberately comes back, the PR ships past findings that were
sitting right there, sometimes serious ones. That is why this is a loop and not a checklist.

```
pre-flight  →  open (non-draft)  →  subagent review  →  fix  →  push
            →  wait  →  read the automated review  →  fix  →  push
            →  repeat until a round on the current head is clean
            →  cold review on the final head  →  human reads  →  human merges
```

Nothing is announced, posted for review, or merged until the loop closes.

## Before opening: the pre-flight (cheapest findings per minute)

1. **Does another open PR touch the same file?** Two small PRs editing the same block are a common way
   to ship a contradiction.
   ```bash
   gh pr list --state open --author @me --json number,files \
     --jq '.[] | {n:.number, f:[.files[].path]}'
   ```
   Same rule or block: make it one PR. Only textual overlap: two PRs are fine, say so in the body.
   Stacking on an unmerged PR is fine, squash-merge repos included, but once the bottom one is
   squash-merged, rebase with `--onto` from the saved bottom head (`knowledge/github-pr-review.md` §
   Stacked PRs); a plain rebase conflicts with its own landed copy.
2. **Grep the rule you changed across the codebase.** "The rule you edited contradicts another rule
   somewhere else" is one of the most common findings. Grep the phrase and its synonyms and read the
   neighbours side by side. Deciding which one is true is judgment; do not let a bot pick.
3. **Mutation check.** Delete or reword the line you just added, run the tests, and confirm they go red.
   A test that cannot fail is worse than no test, because it is counted as coverage.
4. **Size the population.** How many real cases does this touch? Put the number in the body before a
   reviewer has to ask.
5. **Numbers in the body reproduce on the current head.** Re-run and refresh every count right before
   asking for review.
6. **Open it non-draft.** Many automated reviewers skip draft PRs and do not come back. The "not ready"
   signal belongs in the review request, not in the draft flag.

## The loop

### 1. Subagent review

Run a reviewer subagent (the `breaker` agent) on the diff. Give it **the claim the PR makes and where
you think it is most likely wrong**; a reviewer told where to dig finds more than one told to "review
this". One round, then a short check on the fix commits. Run a third round only if the previous one
found a real behaviour bug.

For a large PR, or one with readers outside the diff (dashboards that read its strings, other callers,
a UI), you can run up to three reviewers in parallel, each with one lens: "data and security", "tests
and mutants", "what breaks outside the diff". On a small PR, one is enough.

### 2. The automated reviewer (CodeRabbit)

```bash
# Has it reviewed the CURRENT head yet? Compare submittedAt with your last push time.
gh pr view <N> --json reviews,commits \
  -q '.reviews[] | "\(.author.login) [\(.state)] \(.submittedAt)"'

# Inline findings: severity is in the first line of each comment.
gh api --paginate repos/<owner>/<repo>/pulls/<N>/comments \
  -q '.[] | "\(.created_at) | \(.path):\(.line // .original_line) | \(.body | split("\n")[0])"'

# Read the ones posted after your last push, in full.
gh api --paginate repos/<owner>/<repo>/pulls/<N>/comments \
  -q '.[] | select(.created_at > "<iso-time-of-last-push>") | .body'

# Read the review BODIES too: nitpicks and "outside diff range" items live only there.
gh api graphql -f query='query { repository(owner:"<owner>", name:"<repo>") {
  pullRequest(number:<N>) { reviews(first:30) { nodes { author { login } body submittedAt } } } } }' \
  --jq '.data.repository.pullRequest.reviews.nodes[] | select(.author.login=="coderabbitai") | .body'
```

- **If the newest review predates your push, it has not seen your fix.** Wait and re-check.
- A thread-only check misses roughly one finding in five; always read the review bodies.
- `@coderabbitai review` is incremental and may skip commits it missed (for example after a rate limit).
  Use `@coderabbitai full review` when the current head is what needs reading, and confirm the reply
  names your commit.
- Automated reviewers often have an hourly quota. Batch fix commits into one push. Never hold a fix
  waiting for quota; carry on and read its review before the merge.
- If it never re-reviews a later push, the workable definition of green is: every finding it raised is
  fixed or answered in writing, and a reasonable wait produced nothing new. Say which one you rely on.

### 3. The bar

Your own review follows **ship fast, not perfect**: block only on real breakage, a new critical
regression, or a security or data-integrity hole. That does not license ignoring the bot. For each
automated finding do exactly one of two things:

- **Fix it**, or
- **Dismiss it with a written reason in the PR thread.** Not silently, and not only in a commit message.

Verify each finding against the current code first; bots sometimes flag lines a later commit changed.

**Green means:** the newest round on the current head raised nothing, or everything it raised is fixed
or answered.

### 4. The cold review, last

After both reviewers are green, send a reviewer that knows nothing you know: **only the repo and the PR
number**, no brief, no scope sentence, none of your reasoning. A reviewer told what you meant reads
what you meant; the human will read what you wrote.

- It runs on the head that will merge, from a clean clone, with the repo's declared runtime version.
- It runs the suite at least once **with no credentials in the environment** (and, where relevant,
  with dummy values exported), because your machine's environment hides failures a reviewer's will not.
- On a risky change (shared data, money, a guard, anything hard to undo), it plants **10 to 20 mutants** on the lines the PR touches (a flipped comparison, a dropped guard, a
  moved boundary) and checks the tests catch them. A surviving mutant that changes behaviour is a
  missing test: add it before asking for human review.
- Its findings follow the same bar: fix, or answer in writing. A fix push means the automated reviewer
  covers the new head again; a small fix gets a quick subagent check, not a second cold review.

### 5. Only then: the human

- Append a `## Review summary` to the PR body: how many rounds, what each layer caught (including what
  you declined and why), the mutant line, the final check state.
- **Ask a person to review explicitly**, one PR at a time, in the channel your team uses for review
  requests. Unrequested reviews come back slowly or never.
- A human reads it and a human merges it. Two green bots are preparation, not authorisation.

## Habits that prevent real mistakes

- **Never edit while the working tree is on someone else's branch.** Check
  `git branch --show-current` first. Use an isolated worktree:
  ```bash
  git worktree add ../wt-<name> <branch>    # edit, test, commit, push in there
  git worktree remove ../wt-<name>          # their tree never moves
  ```
  For read-only inspection, no checkout is needed: `git show <ref>:<path>`,
  `git diff origin/main...origin/<branch>`.
- **Stage files by explicit path**, never `git add -A`; check `git status --short` before each commit.
- **A comment may explain why, never state a count.** Counts go stale inside the commit that adds tests.
- **If someone asks "did you check CodeRabbit?"**, answer with what it actually said. If you did not
  check, say so and go check.
