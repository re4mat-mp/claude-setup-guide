---
name: github-pr-review
description: "Reviewing someone else's PR: approve vs merge, dual review, the exact gh commands, stacked PRs"
---

# Reviewing someone else's PR

Approving a PR is a sign-off; merging it ships it. They are different actions, often by different
people. Our review is always two passes (the automated reviewer's findings plus an independent
subagent reading the diff), we block only on real breakage, and the review content lives on the PR,
anchored to lines, with a short human summary on top.

---

## Approve, merge, request changes, comment

- **Approve** = your sign-off. It changes no code. On a protected branch it is what unblocks the merge
  button. GitHub does not let authors approve their own PRs, which is why a second person exists.
- **Merge** = pulls the branch into the default branch and usually triggers a deploy. Normally the
  **author** merges, after the required approval, and controls when it ships and when any rollout
  flag flips. That is what makes it safe to approve a PR with a delicate rollout: the risky part stays
  with the author.
- **Request changes** = blocks until resolved. Use it for a real defect.
- **Comment** = feedback without a verdict.
- **When an agent may approve (the one rule, also in `memory/feedback_authority_before_merit.md`):** only
  after a real two-reviewer pass **and** an explicit human go on that specific PR, stating what it did and
  did not check. No standing auto-approve. Merge is the human's decision; an agent runs it only on an
  explicit go for that PR, after confirming the merge method.

## The bar: does it work without breaking anything

- **Block only on:** something that breaks a normal workflow, or a **new** critical or unsafe
  regression this PR introduces.
- **Let slide as a non-blocking note, then approve:** anything cosmetic, and any **pre-existing**
  issue this PR does not make worse. The test is "is it a regression?".
- Do not manufacture blockers on a clean PR. Frame confirmations as questions, not defects. Prefer
  approve-with-a-note over hold-for-a-question when nothing is actually broken.

## The flow

### 1. Fetch the state

```bash
gh pr view N --repo OWNER/REPO --json number,title,author,state,isDraft,mergeable,mergeStateStatus,baseRefName,headRefName,headRefOid,additions,deletions,changedFiles,body,reviewDecision
gh pr checks N --repo OWNER/REPO
gh pr diff N --repo OWNER/REPO
```

Red CI means no approval.

### 2. A green check is not a review

The automated reviewer's status check goes green when the bot **finishes**, including on a PR where
it just filed six findings. "All checks have passed" is about CI, never about review state. Verify
resolution explicitly:

```bash
gh api graphql -f query='{repository(owner:"OWNER",name:"REPO"){pullRequest(number:N){headRefOid reviewThreads(first:50){nodes{isResolved isOutdated path line comments(first:1){nodes{author{login} body}}}}}}}'
```

`isResolved=false` and `isOutdated=false` = still open against the current code. Also check
`reviewDecision`: a bot's review is usually `COMMENTED`, which never satisfies branch protection.
Green can mean "ran, found nothing", "ran, findings are elsewhere" or "never ran"; check which.

### 3. Dual review

Read the automated reviewer's findings **and** dispatch one independent subagent to review the diff
adversarially. Never trust a single pass. One subagent, not a fan-out.

```bash
gh api --paginate repos/OWNER/REPO/pulls/N/comments --jq '.[] | {user:.user.login, path, line, body}'   # inline
gh api --paginate repos/OWNER/REPO/issues/N/comments --jq '.[] | {user:.user.login, body}'              # top-level
gh api repos/OWNER/REPO/pulls/N/reviews  --jq '.[] | {user:.user.login, state, body}'        # formal reviews
```

Give the subagent the code and the claim, not your conclusion, so its read is not anchored on yours.

### 4. Verify the claims against the diff

If the description says something was removed, confirm the diff touches zero lines of it. If a
reviewer raised a concern in the thread, confirm it is resolved in the code, not just answered. Where
it matters, **run** the change: replay the real failing case through both the base and the branch,
and plant a few small mutants on the lines the PR touches to see whether its tests notice.

### 5. Watch for a moving target

Review the head that will merge. Note `headRefOid` when you start and check it again before
approving; a push in between means your review is of an older commit.

A reviewer reading a **shared, live checkout** can report a confident, false finding because the tree
moved under it mid-read (a rebase, a merge, a file briefly dirty during someone's test). Measure on a
pinned snapshot (`git archive <sha>` or `git show <sha>:<path>`), print `git rev-parse HEAD` at the
start and end of the pass, and give a review subagent the exact SHA. If you mutate files to test a
guard, do it in your own copy and leave `git status` clean.

### 6. Write the review

- **The body opens with 2–4 plain sentences**: the verdict first, then what it turns on, then the size
  of what is left. No file paths in that layer. Evidence goes below: `file:line`, the repro, what was
  verified vs inferred, what could not be checked.
- **Review content lives on the PR**, preferably as line-anchored inline comments rather than prose
  about "the zip step". One API call posts the body plus all inline comments and sends a single
  notification:

```bash
gh api repos/OWNER/REPO/pulls/N/reviews -X POST --input review.json
# review.json:
# {"commit_id":"<headRefOid>","event":"COMMENT|APPROVE|REQUEST_CHANGES","body":"...",
#  "comments":[{"path":"src/x.js","line":52,"side":"RIGHT","body":"..."}]}
```

- Simple verdicts:

```bash
gh pr review N --repo OWNER/REPO --approve --body "..."
gh pr review N --repo OWNER/REPO --request-changes --body "..."
gh pr review N --repo OWNER/REPO --comment --body "..."
gh pr view N --repo OWNER/REPO --json reviewDecision,mergeStateStatus   # want APPROVED / CLEAN
```

- **Chat carries the status, not the review.** If the review request came through a chat thread, the
  reply there is one line ("approved", "reviewed, comments on the PR", "merged"). A status reaction on
  the original message is a good at-a-glance marker; check the PR's real state
  (`gh pr view N --json state,mergedAt`) before reacting, since some reactions cannot be removed.
- **Stay on their code.** Findings about your own tooling or other cards are parked, not posted on
  someone else's PR. The goal of a review is to get to an approval.
- **A new live production issue found while reviewing** has no PR to attach to: open an issue with the
  detail, then send one line pointing at it.

### 7. Merging, when it is yours to do

```bash
gh pr merge N --repo OWNER/REPO --squash    # or --merge / --rebase, as the repo convention says
```

Check the PR number and title before pressing. After a merge, confirm any linked tracker item moved
to done.

## Stacked PRs

Split one large change into a chain of small dependent PRs, each showing only its own layer's diff.
When the bottom one merges, the rest re-targets to the default branch.

```bash
gh extension install github/gh-stack
gh stack init branch1 branch2   # create the chain
# commit on each branch as usual
gh stack submit                 # push and open all PRs, linked
```

Useful when a fix has to wait for an earlier PR: stack it instead of bundling it. **The one rule on stacking,
squash-merge repos included:** stacking is fine, but once the bottom PR is squash-merged the branch above it
must be rebased with `--onto` from the saved bottom head (below); a plain rebase conflicts with its own landed
copy.

**Rebasing after the bottom PR is squash-merged.** A squash merge replaces the bottom branch's commits
with one new commit on the default branch, so a plain `git rebase main` tries to re-apply work that
already landed. Use:

```bash
git rev-parse <bottom-branch>        # save this anchor BEFORE the merge; the branch is usually deleted on merge
git rebase --onto origin/main <saved-bottom-head> <my-branch>
```

The middle argument is the **bottom branch's head**, not the merge-base with main (the merge-base
re-applies the whole bottom PR). And the tree that merged may differ from the head you built on
(review rounds add commits): read `git diff <my-base>..origin/main -- <shared files>` before resolving
conflicts, or you lose assertions in shared test files.

## Branch naming

If your team links PRs to a tracker by key, name the branch with the tracker's suggested branch name
(or at least start it with the issue key), so the PR attaches itself and the issue advances when it
merges. Descriptive branch names without the key do not link.
