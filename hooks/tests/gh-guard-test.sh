#!/bin/bash
# Tests for gh-guard.sh. No network and no real GitHub: a stub `gh` on PATH answers the review lookups.
# Usage: bash gh-guard-test.sh [path/to/gh-guard.sh]
set -u
HOOK=${1:-"$(cd "$(dirname "$0")/.." && pwd)/gh-guard.sh"}  # the hook next to this folder, not the one installed
command -v jq >/dev/null || { echo "jq is required"; exit 2; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
export GH_GUARD_ORG=example-org
export STUB_REVIEWS='[]'

# A stub gh: `gh api .../reviews` prints $STUB_REVIEWS (or fails when it is "FAIL"); `gh repo view` prints the slug.
mkdir -p "$work/bin"
cat > "$work/bin/gh" <<'STUB'
#!/bin/bash
case "$*" in
  *"/reviews"*) [ "$STUB_REVIEWS" = "FAIL" ] && { echo '{"message":"Not Found"}'; exit 1; }; printf '%s' "$STUB_REVIEWS" ;;
  "repo view"*) echo "example-org/app" ;;
  "pr view"*) echo 7 ;;
esac
STUB
chmod +x "$work/bin/gh"
export PATH="$work/bin:$PATH"

# Two local repos: one whose origin is in the org, one that is personal.
for name in org personal; do
  git init -q -b main "$work/$name"
  git -C "$work/$name" commit -q --allow-empty -m init
  git -C "$work/$name" branch feature
done
git -C "$work/org" remote add origin git@github.com:example-org/app.git
git -C "$work/personal" remote add origin git@github.com:someone/notes.git

pass=0; fail=0
check() { # $1 expected allow|deny|ask, $2 command, $3 cwd (optional)
  local out got
  out=$(jq -n --arg c "$2" --arg d "${3:-$work}" '{tool_name:"Bash",tool_input:{command:$c},cwd:$d}' | bash "$HOOK")
  got=$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecision // empty' 2>/dev/null)
  got=${got:-allow}
  if [ "$got" = "$1" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL want=$1 got=$got :: $2"; fi
}

approved='[{"user":{"login":"alice","type":"User"},"state":"APPROVED"}]'
mixed='[{"user":{"login":"alice","type":"User"},"state":"APPROVED"},{"user":{"login":"bob","type":"User"},"state":"CHANGES_REQUESTED"}]'
bot_only='[{"user":{"login":"coderabbitai[bot]","type":"Bot"},"state":"APPROVED"}]'
taken_back='[{"user":{"login":"alice","type":"User"},"state":"APPROVED"},{"user":{"login":"alice","type":"User"},"state":"CHANGES_REQUESTED"}]'

# Ordinary commands pass untouched
check allow 'ls -la'
check ask   'git commit -m "never run gh pr merge without a review"'   # a quoted mention: the human decides
check allow 'git commit -m "fix the date parser"'
check allow 'gh pr view 7 --json state,mergeCommit'
check allow 'gh pr merge --help'

# Rule 1: review requests never go through GitHub
check deny  'gh pr edit 7 --add-reviewer alice'
check deny  'gh pr create --title "Fix" --body x --reviewer alice'
check deny  'gh api -X POST repos/example-org/app/pulls/7/requested_reviewers -f reviewers[]=alice'

# Rule 2a: one door for merges
check deny  'gh api -X PUT repos/example-org/app/pulls/7/merge'
check deny  "gh api graphql -f query='mutation { mergePullRequest(input:{pullRequestId:\"x\"}) { clientMutationId } }'"
check deny  "gh alias set mm 'pr merge'"

# Rule 2b: a human approval, read from the reviews
STUB_REVIEWS=$approved   check allow "cd $work/org && gh pr merge 7 --squash"
STUB_REVIEWS='[]'        check deny  "cd $work/org && gh pr merge 7 --squash"
STUB_REVIEWS=$bot_only   check deny  "cd $work/org && gh pr merge 7 --squash"
STUB_REVIEWS=$taken_back check deny  "cd $work/org && gh pr merge 7 --squash"
STUB_REVIEWS=FAIL        check ask   "cd $work/org && gh pr merge 7 --squash"
STUB_REVIEWS=$mixed      check deny  "cd $work/org && gh pr merge 7 --squash"   # one approves, another still requests changes
STUB_REVIEWS=$approved   check ask   "gh pr merge 7 && gh pr merge 8"
STUB_REVIEWS=$approved   check ask   "cd /no/such/folder && gh pr merge 7"
STUB_REVIEWS='[]'        check deny  "cd $work/org && gh  \"pr\"  merge 7"   # extra spaces and quotes do not hide a merge

# Rule 3: no push straight to main in the org
check deny  "cd $work/org && git push origin main"
check deny  "git -C $work/org push"
check allow "cd $work/org && git push origin feature"
check allow "cd $work/personal && git push origin main"
check allow "cd $work/org && git push --dry-run origin main"

echo "gh-guard: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
