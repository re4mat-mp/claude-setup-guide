#!/bin/bash
# gh-guard: PreToolUse hook on Bash. Three rules about how code reaches main.
#
#   1. A review request goes to a person directly (chat), never through GitHub's reviewer field
#      (`--add-reviewer`, `--reviewer`, or the API). A GitHub notification moves nobody's attention.
#   2. `gh pr merge` needs an APPROVED review from a human. The automated reviewers (CodeRabbit, a
#      subagent, the cold review) prepare a merge; they never authorise one. A reviewer whose latest
#      verdict is "changes requested" blocks the merge. Every other way of merging (REST, GraphQL, curl,
#      a gh alias) is refused, so every merge goes through this one check.
#   3. Nothing is pushed straight to main/master in a repo of $GH_GUARD_ORG. Your own repos are not touched.
#
# Set GH_GUARD_ORG to your GitHub organisation (default below). Needs bash, jq and gh.
#
# Reads compound commands on purpose (`cd repo && gh pr merge 12 --squash`): a prefix filter in
# settings.json would never match them, and a guard that silently does nothing is worse than no guard.
#
# This is a seat belt, not a lock: it reads the text of a command before it runs. A script file, or a
# command assembled at run time, is invisible to it. The real lock is GitHub's branch protection.
#
# Contract: prints nothing and exits 0 to allow. Prints a PreToolUse decision to deny/ask.

ORG="${GH_GUARD_ORG:-your-org}"
org_lc=$(printf '%s' "$ORG" | tr 'A-Z' 'a-z')
export LC_ALL=C  # a stray byte in a long heredoc makes BSD tr and sed abort in a UTF-8 locale

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""' 2>/dev/null)
[ -z "$cmd" ] && exit 0
session_cwd=$(printf '%s' "$input" | jq -r '.cwd // ""' 2>/dev/null)

decide() { # $1 = allow|deny|ask, $2 = reason
  printf '%s' "$2" | jq -Rs --arg d "$1" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:$d,permissionDecisionReason:.}}'
  exit 0
}

# ---------- read the command the way the shell will ----------
# Repeated spaces, quotes and backslashes change the text and not what runs: measured 2026-11-05,
# `gh  pr  merge` and `gh "pr" merge` went straight past. A line continuation joins two lines; a plain
# newline stays, because it ends a command.
# awk and tr on purpose, not ${cmd//…}: on the bash 3.2 macOS ships that substitution hung for over 25 s on
# real commands with a long heredoc, and this file runs before every Bash call in every session.
squeeze() { tr -d "\"'\\\\" | tr -s ' \t' ' '; }
joined=$(printf '%s\n' "$cmd" | awk '{ if (sub(/\\$/, "")) printf "%s ", $0; else print }')
flat=$(printf '%s\n' "$joined" | squeeze)

# Nearly every command mentions none of this, and those leave here.
printf '%s\n' "$flat" | grep -qE 'merge|push|reviewer|requestReviews|create|refs/heads|contents/|updateRef' || exit 0

# What a command DOES, as opposed to what it mentions. A quoted sentence is text: `git commit -m "never git
# push to main"`, `grep "gh pr merge" notes.md`. Unless a shell is about to run it, or it holds a $(…).
# It leaves a `_` behind: a flag still has its value, so `--subject "Release 12" 34` keeps 34 as the PR.
# A scan, not a regex: measured 2026-11-05, a regex paired the `"` inside `--jq '"…"'` with a later `"`, swallowed
# the `gh pr merge 34` between them, and the merge read as text. A line with an open quote stops the
# scan and the whole command is read as code: an apostrophe in a heredoc costs a false alarm, never a miss.
DROP_SENTENCES='
length($0) > 20000 { exit 1 }
{
  n = length($0); i = 1
  while (i <= n) {
    c = substr($0, i, 1)
    if (c == "\\") { printf "%s", substr($0, i, 2); i += 2; continue }
    if (c == "\047" || c == "\042") {
      j = i + 1; plain = 1
      while (j <= n) {
        d = substr($0, j, 1)
        if (d == c) break
        if (c == "\042" && d == "\\") { j += 2; continue }
        if (c == "\042" && (d == "$" || d == "`")) plain = 0
        j++
      }
      if (j > n) exit 1
      s = substr($0, i, j - i + 1)
      printf "%s", (plain && s ~ / /) ? "_" : s
      i = j + 1
      continue
    }
    printf "%s", c
    i++
  }
  printf "\n"
}'
code=$flat
if [ "${#joined}" -le 200000 ] && ! printf '%s\n' "$flat" | grep -qE '(^|[ ;&|(/])(bash|sh|zsh|dash|fish|ksh|eval|python[0-9.]*|node|perl|ruby|awk|osascript|ssh|xargs|parallel|watch)([ <]|$)|\$SHELL'; then
  sentences_out=$(printf '%s\n' "$joined" | awk "$DROP_SENTENCES") && code=$(printf '%s\n' "$sentences_out" | squeeze)
fi

# One command per line, for the checks that must not mix a verb from one command with a URL from another.
lines=$(printf '%s\n' "$flat" | tr ';|&' '\n\n\n')
code_lines=$(printf '%s\n' "$code" | tr ';|&' '\n\n\n')

# `gh`, `/opt/homebrew/bin/gh`, `$GH`, `${GH}` or `$(command -v gh)`, then any flags with their values.
PROG='(^|[^[:alnum:]_.-])(gh|\$\{?[A-Za-z_][A-Za-z0-9_]*(:-[^}]*)?\}?)|\)|`'
FLAGS='( +-[^ ]+( +[^- ][^ ]*)?)*'
GH_PR="($PROG)$FLAGS +pr$FLAGS"
GH_MERGE="$GH_PR +merge( |\$|\))"
# A program that talks to an API. `git branch -d fix/merge` is not one.
CLIENT='(^|[ /(])(gh api|curl|wget|http|https|xh)( |$)|python|node|ruby|perl|requests\.|urllib|fetch\('
# A write, however it is spelled: `gh api` turns into a POST on its own as soon as it gets a field.
VERB='(POST|PUT|PATCH|DELETE|post|put|patch|delete)'
WRITE=" -[a-zA-Z]*X ?$VERB|--(method|request)[ =]$VERB|method[=:] ?$VERB| -[a-zA-Z]*d( |[^ ])| -[a-zA-Z]*[fF] ?[^ ]*=|--(field|raw-field|input|data[a-z-]*|post-data|body-data)[ =]|curl[^;&|]* --json |\.(put|post|patch)\(|(^|[ /])(http|https|xh) +$VERB"

has() { printf '%s\n' "$flat" | grep -qE -- "$1"; }
line_writes() { # $1 = a regex for the path: true if one single command names that path, is an API client AND writes
  printf '%s\n' "$lines" | grep -E -- "$1" | grep -E -- "$CLIENT" | grep -qE -- "$WRITE"
}
expand_dir() { # the shell expands these and we never run it, so they are expanded by hand
  case "$1" in
    "~"|'$HOME'|'${HOME}') printf '%s' "$HOME" ;;
    "~/"*) printf '%s' "$HOME/${1#\~/}" ;;
    '$HOME/'*) printf '%s' "$HOME/${1#\$HOME/}" ;;
    '${HOME}/'*) printf '%s' "$HOME/${1#\$\{HOME\}/}" ;;
    *) printf '%s' "$1" ;;
  esac
}

# ---------- rule 1: review requests never go through GitHub ----------
review_by_git=""
printf '%s\n' "$code_lines" | grep -qE -- "$GH_PR +edit.* --add-reviewer" && review_by_git=1
printf '%s\n' "$code_lines" | grep -qE -- "$GH_PR +create.*( --reviewer| -r)" && review_by_git=1
line_writes '/requested_reviewers' && review_by_git=1
has 'graphql|mutation' && has 'requestReviews' && review_by_git=1
if [ -n "$review_by_git" ]; then
  decide deny "A review request goes to a person directly (chat), never through GitHub (--add-reviewer, --reviewer or the API): a GitHub notification moves nobody's attention. Draft the ask (\"PR to check\" + a short title + the link, one PR at a time) and let a human send it. The detail belongs in the PR body."
fi

# Only inside quotes it may be a mention, or a shell this guard does not know about. That one is for the human to read.
QUOTED_ASK="This command names it inside quotes. If it only mentions it, approve. If something runs that text (a shell by full path, awk, osascript), do not."
if printf '%s\n' "$lines" | grep -qE -- "$GH_PR +edit.* --add-reviewer|$GH_PR +create.* --reviewer"; then
  decide ask "A review request through GitHub is refused. $QUOTED_ASK"
fi

# ---------- rule 2a: a merge has one door, the one the approval check stands at ----------
contents_on_main=""
if line_writes "repos/$ORG/[^ ]+/contents/"; then
  printf '%s\n' "$lines" | grep -E "repos/$ORG/[^ ]+/contents/" | grep -E -- "$WRITE" | grep -qE 'branch=(main|master)( |$)' && contents_on_main=1
  printf '%s\n' "$lines" | grep -E "repos/$ORG/[^ ]+/contents/" | grep -E -- "$WRITE" | grep -qvE 'branch=' && contents_on_main=1
fi
if [ -n "$contents_on_main" ] \
  || line_writes '/merges?([ ?)]|$)|/merge-upstream|/git/refs/heads/(main|master)' \
  || { has 'pulls/[^ ]+/merge([ ?);&|]|$)' && has "$WRITE" && has "$CLIENT"; } \
  || { has 'graphql|mutation' && has 'mergePullRequest|enablePullRequestAutoMerge|enqueuePullRequest|mergeBranch|createCommitOnBranch|updateRefs?[ (]'; } \
  || has 'alias (set|import).*(merge|push)|alias\.[^= ]+=[^ ]*(merge|push)'; then
  decide deny "This lands code on a main branch through the API or an alias, which skips the human-approval check. Merges have one door: \`gh pr merge N\`, run by a human or on a human\'s explicit go, or the merge button in the GitHub web UI. If you only meant to READ the state of a merge, use GET: \`gh pr view N --json state,mergeCommit\`."
fi

# ---------- rule 3: nothing lands on main in an org repo except through a PR ----------
# Only a push that can reach main counts, and only where origin is in $ORG: a nightly backup of your own
# config repo pushes to main too, and that must stay silent. Before rule 2b, whose allow would speak for the line.
GIT_WORD='(git[)`]?|\$\{?[A-Za-z_][A-Za-z0-9_]*(:-[^}]*)?\}?)'
GIT_PUSH="(^|[^[:alnum:]_.-])$GIT_WORD(( +-[^ ]+( +[^- ][^ ]*)?)*) +push([ )>].*)?\$"
if printf '%s\n' "$code_lines" | grep -qE -- "$GIT_WORD$FLAGS +push([ )>]|\$)"; then
  # Each push costs two calls to git and each cd one, and the hook has 20 s: a hook that times out renders no
  # decision and the command goes on. Past this it cannot read them one by one, so it says so.
  if [ "$(printf '%s\n' "$code_lines" | grep -cE -- "$GIT_WORD$FLAGS +push([ )>]|\$)")" -gt 100 ] \
    || [ "$(printf '%s\n' "$code_lines" | grep -cE '(^|[ (])(cd|pushd) ')" -gt 300 ]; then
    decide ask "This command names more than 100 pushes or 300 folder changes, too many for this guard to verify inside its time limit. If none of them reaches main in a repo of your org, approve."
  fi
  here=${session_cwd:-$PWD}
  branch_now=""  # the guard runs BEFORE the command: a checkout earlier in the same line has not happened yet
  while IFS= read -r seg; do
    seg=${seg#"${seg%%[![:space:]\(]*}"}
    while :; do case "$seg" in "{ "*|"if "*|"then "*|"do "*|"else "*|"! "*|"command "*|"builtin "*) seg=${seg#* } ;; *) break ;; esac; done
    case "$seg" in *" -c cd "*) seg="cd ${seg##* -c cd }" ;; esac  # `sh -c 'cd x && git push'`
    case "$seg" in
      "cd "*|"pushd "*)
        d=${seg#* }; d=${d%% [0-9]>*}; d=${d%% >*}; d=${d%%)*}; d=${d%"${d##*[![:space:]]}"}
        d=$(expand_dir "$d")
        case "$d" in /*) ;; *) d="$here/$d" ;; esac
        if [ -d "$d" ]; then here=$d; else here=""; fi
        continue
        ;;
      "git checkout "*|"git switch "*)
        case "$seg" in *" -- "*) continue ;; esac  # restores a file, stays on the branch
        creates=""
        set -f
        for word in ${seg#git * }; do
          case "$word" in
            -b|-B|-c|-C|-t|--track|--orphan) creates=1 ;;
            -*) ;;
            *)
              word=${word%%)*}
              # A file being restored keeps the branch. A word it cannot place (`git switch feature-x` made from
              # the remote) makes the branch unknown, so only a push that names main is refused.
              case "$word" in
                main|master) branch_now=$word ;;
                *)
                  if [ -n "$creates" ] || git -C "${here:-.}" show-ref --verify --quiet "refs/heads/$word"; then branch_now=$word
                  elif [ -e "${here:-.}/$word" ]; then :
                  else branch_now="(unknown)"
                  fi
                  ;;
              esac
              break
              ;;
          esac
        done
        set +f
        continue
        ;;
    esac
    [[ "$seg" =~ $GIT_PUSH ]] || continue
    git_flags=${BASH_REMATCH[4]}
    push_args=${BASH_REMATCH[7]}
    where=$here
    if [[ "$git_flags" =~ -C\ +([^\ ]+) ]]; then
      where=$(expand_dir "${BASH_REMATCH[1]}")
      case "$where" in /*) ;; *) where="$here/$where" ;; esac
    fi

    # What is left after the flags: the remote, then what is being pushed.
    positional=()
    pushes_all=""
    tags_only=""
    dry_run=""
    skip_next=""
    set -f
    for word in $push_args; do
      word=${word%%)*}
      [ -z "$word" ] && continue
      [ -n "$skip_next" ] && { skip_next=""; continue; }
      case "$word" in
        '#'*) break ;;
        [0-9]'>'*|[0-9]'<'*|'>'*|'<'*) continue ;;
        *'>'*|*'<'*) word=${word%%[<>]*} ;;
      esac
      case "$word" in
        --all|--mirror) pushes_all=1 ;;
        --tags) tags_only=1 ;;
        --dry-run|-n) dry_run=1 ;;
        -o|--push-option|--repo|--receive-pack|--exec) skip_next=1 ;;
        -*) ;;
        *) positional+=("$word") ;;
      esac
    done
    set +f
    [ -n "$dry_run" ] && continue
    remote=${positional[0]:-origin}

    # A path is a folder on this disk, never GitHub. It is also what a grep for this very text looks like.
    case "$remote" in *://*|*@*:*) ;; */*) continue ;; esac

    # `git -C ""` means "right here", which would let an unresolved `cd $VAR` answer as the guard's own folder.
    url=""
    current=$branch_now
    if [ -n "$where" ]; then
      url=$(git -C "$where" remote get-url --push "$remote" 2>/dev/null)
      [ -z "$current" ] && current=$(git -C "$where" symbolic-ref --short HEAD 2>/dev/null)
    fi
    case "$remote" in *://*|*@*:*) url=$remote ;; esac

    reaches_main=""
    [ -n "$pushes_all" ] && reaches_main=1
    if [ "${#positional[@]}" -le 1 ]; then
      if [ -z "$tags_only" ]; then
        case "$current" in main|master) reaches_main=1 ;; esac
      fi
    else
      for spec in "${positional[@]:1}"; do
        spec=${spec#+}
        [ "$spec" = ":" ] && reaches_main=1
        dst=${spec##*:}
        dst=${dst#refs/heads/}
        case "$dst" in HEAD|@|'$'*|'`'*) dst=$current ;; esac
        case "$dst" in main|master|'*'|'{'*main*) reaches_main=1 ;; esac
      done
    fi
    [ -z "$reaches_main" ] && continue

    case "$(printf '%s' "$url" | tr 'A-Z' 'a-z')" in
      *github.com[:/]"$org_lc"/*)
        decide deny "This pushes straight to main in a repo of $ORG, skipping the PR, the reviewers and the human merge. Push a branch and open a PR."
        ;;
      "")
        decide ask "This push can reach main, and this guard could not work out which repository it goes to. If it is a repo of $ORG, do not approve: push a branch and open a PR. If it is one of your own repos, approve."
        ;;
    esac
  done <<< "$(printf '%s\n' "$code_lines" | grep -E '(^|[ (])(cd|pushd) |git (checkout|switch) |push')"
fi

if ! printf '%s\n' "$code_lines" | grep -qE -- "$GIT_WORD$FLAGS +push([ )>]|\$)" \
  && printf '%s\n' "$lines" | grep -qE -- "$GIT_WORD$FLAGS +push .*(main|master)"; then
  decide ask "A push to main. $QUOTED_ASK"
fi

# ---------- rule 2b: no merge without a human approval ----------
merge_line=$(printf '%s\n' "$code_lines" | grep -E -- "$GH_MERGE" | head -1)
if [ -z "$merge_line" ] && printf '%s\n' "$lines" | grep -qE -- "$GH_MERGE"; then
  decide ask "A merge. $QUOTED_ASK"
fi
if [ -n "$merge_line" ]; then
  merge_args=${merge_line#* merge}

  # ⚠️ ONE merge per command, checked rather than assumed. If there is more than one, or a loop or xargs
  # feeds it, the guard would verify one PR and wave the others through on its approval. So it says so.
  # Count matches, not lines: `gh pr merge 5 --body "$(gh pr merge 6)"` is one line.
  merge_count=$(printf '%s\n' "$code_lines" | grep -oE -- "$GH_MERGE" | wc -l | tr -d ' ')
  if [ "${merge_count:-0}" -gt 1 ] || printf '%s\n' "$code" | grep -qE '(^|[ ;&|(])(xargs|parallel|for|while|until)( |$)|-exec '; then
    decide ask "This command runs \`gh pr merge\` more than once, or in a loop, and this guard can only verify one PR per call — so a second merge would ride through on the first one's approval. Split it: one merge per command, each verified on its own. (One merge at a time is the rule anyway.)"
  fi

  # Help only when it is all there is: `gh pr merge --help && gh pr merge 5` was caught by the count above,
  # and `gh pr merge 5 -t -h` has -h as a title.
  set -f; set -- $merge_args; set +f
  if [ $# -eq 1 ]; then case "$1" in --help|-h) exit 0 ;; esac; fi

  # The first word after the flags is what gets merged: a number, a URL, a branch, or nothing (the current
  # branch). Measured 2026-11-05: `gh pr merge --squash 5` read no number and verified the current branch's PR.
  first=""
  skip_next=""
  set -f
  for word in $merge_args; do
    [ -n "$skip_next" ] && { skip_next=""; continue; }
    case "$word" in
      -t|-b|-F|-A|-R|--subject|--body|--body-file|--author-email|--match-head-commit|--repo) skip_next=1 ;;
      -*) ;;
      *) first=${word%%)*}; break ;;
    esac
  done
  set +f

  # The repo: a PR URL names its own, then the last --repo or -R, then GH_REPO; otherwise the last `cd <dir>` before the merge.
  repo=$(printf '%s' "$merge_line" | grep -oE -- '(--repo|-R)[= ]*(https://github\.com/)?[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+' | tail -1 | grep -oE '[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$')
  [ -z "$repo" ] && repo=$(printf '%s' "$code" | grep -oE 'GH_REPO=[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+' | head -1 | cut -d= -f2)
  case "$first" in
    *github.com/*/pull/*)
      pr_path=${first#*github.com/}
      repo=$(printf '%s' "$pr_path" | cut -d/ -f1,2)
      ;;
  esac
  # ⚠️ The tilde must be expanded by hand. `[ -d "~/code/x" ]` is FALSE — the shell does not
  # expand ~ inside quotes — so `cd ~/code/repo && gh pr merge N` silently skipped the cd and
  # left the guard in ITS OWN cwd. Whatever repo that happened to be then answered for the
  # merge: once that was a personal repo with no such PR, so a fully approved PR
  # was reported as having no human approval. The guard did not fail
  # open, but it failed on the wrong repo, which is its own kind of wrong.
  # Measured 2026-11-05: `cd ORG_REPO && gh pr merge 5 && cd -` verified the wrong repo with a confident allow.
  CD_LINE='^[[:space:](]*((\{|if|then|do|else|!|command|builtin) +)*cd[[:space:]]'
  merge_at=$(printf '%s\n' "$lines" | grep -nE -- "$GH_MERGE" | head -1 | cut -d: -f1)
  dir=$(printf '%s\n' "$lines" | head -n "${merge_at:-1}" | grep -E -- "$CD_LINE" | tail -1 | sed -E 's/^.*cd[[:space:]]+//; s/[[:space:]]*[0-9]?>.*$//; s/[)[:space:]]*$//')
  dir=$(expand_dir "$dir")
  if [ -n "$dir" ] && [ -z "$repo" ]; then
    { [ -d "$dir" ] && cd "$dir" 2>/dev/null; } || decide ask "This guard could not resolve the folder this merge runs in ($dir), so it cannot tell which repository to verify. Check the approval by hand, then approve this call."
  fi

  if [ -n "$repo" ]; then target=(--repo "$repo"); else target=(); fi
  num=""
  case "$first" in
    *github.com/*/pull/*) num=$(printf '%s' "$pr_path" | cut -d/ -f4 | grep -oE '^[0-9]+') ;;
    '') num=$(gh pr view "${target[@]}" --json number --jq .number 2>/dev/null) ;;
    '$'*|'`'*) ;;  # known only when it runs, so it cannot be verified now
    *[!0-9#]*) num=$(gh pr view "$first" "${target[@]}" --json number --jq .number 2>/dev/null) ;;
    *) num=${first#\#} ;;
  esac

  if [ -z "$num" ]; then
    decide ask "This guard could not work out WHICH PR is being merged, so it cannot verify the human approval. Check by hand that a human reviewer has an APPROVED review on it, then approve this call — or re-run with an explicit PR number."
  fi

  if [ -n "$repo" ]; then slug="$repo"; else
    slug=$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null)
  fi
  if [ -z "$slug" ]; then
    decide ask "This guard could not resolve the repository for PR #$num, so it cannot verify the human approval. Verify by hand that a human reviewer approved it, then approve this call."
  fi

  # Read the exit code, not the text. On an HTTP error `gh api` prints the error body to STDOUT and
  # exits 1, so that JSON landed in $approvals, looked like a reviewer, and the guard allowed the merge.
  # Measured 2026-11-03 with a 404: "Human approval verified on PR #1 ... {message: Not Found}".
  reviews=$(gh api "repos/$slug/pulls/$num/reviews" --paginate 2>/dev/null)
  api_status=$?
  if [ "$api_status" -ne 0 ]; then
    decide ask "This guard could not read the reviews of PR #$num in $slug (gh api failed with exit $api_status), so it cannot verify the human approval. Verify by hand that a human reviewer approved it, then approve this call."
  fi

  # Latest verdict per human reviewer; bots (CodeRabbit) can never satisfy this. A comment is not a
  # verdict. Measured 2026-11-05: the old filter kept ANY approval, so one taken back with "changes
  # requested" still returned allow. All pages together, or an old page would still speak for the reviewer. A
  # deleted account comes back with a null user, and that must not abort the whole check.
  verdicts=$(printf '%s' "$reviews" | jq -s 'add // [] | [.[] | select(.user != null) | select(.user.type != "Bot") | select((.user.login | endswith("[bot]")) == false) | select(.state == "APPROVED" or .state == "CHANGES_REQUESTED" or .state == "DISMISSED")] | group_by(.user.login) | map(last)' 2>/dev/null)
  red=$(printf '%s' "$verdicts" | jq -r 'map(select(.state == "CHANGES_REQUESTED") | .user.login) | join(", ")' 2>/dev/null)
  approvals=$(printf '%s' "$verdicts" | jq -r 'map(select(.state == "APPROVED") | .user.login) | join(", ")' 2>/dev/null)

  if [ -n "$red" ]; then
    decide deny "PR #$num in $slug has changes requested by $red, and that is their latest verdict. Do not merge with a reviewer red; fix it or get a new review first."
  fi

  if [ -z "$approvals" ] || [ "$approvals" = "null" ]; then
    decide deny "PR #$num in $slug has NO approving review from a human. The automated greens (CodeRabbit, the subagent reviewer, the cold review) are preparation, not authorisation: a person approves in GitHub before anything is merged. Do not merge and do not offer to merge. Say \"waiting on a human review\", never \"ready\"."
  fi

  # An approval removes this guard's objection. It never skips the normal permission check: an allow here
  # answered for the whole line, `$(...)` and redirects included, which no check can list.
  exit 0
fi

exit 0
