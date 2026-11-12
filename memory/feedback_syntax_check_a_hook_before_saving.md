---
name: syntax-check-a-hook-before-saving
description: "Every hook edit is syntax-checked (bash -n, python3 -m py_compile) and dry-run with fake input before saving; a broken PreToolUse hook doesn't degrade, it blocks every tool in every open session, including the one needed to fix it"
metadata:
  type: feedback
---
**Every hook edit is syntax-checked and dry-run before it is saved: `bash -n` for shell, `python3 -m py_compile` for Python, then one run with fake input that must exit 0.** A broken hook does not degrade, it switches everything off.

**The case:** a one-line text change to a pre-tool hook was made with a script that rebuilt the line, and the closing quote got lost. The hook ran before Bash, Read, Write, Edit, Grep and Glob. Bash exits 2 on a syntax error, and the harness treats exit 2 as a block. No tool in the session could run, including the one needed to fix the hook. And because the hook is read from disk on every call, every parallel session was blocked too.

**Why:** a broken agent charter costs one bad dispatch. A broken hook costs the whole session and its neighbours.

**How to apply:**
- Before saving any edit under the hooks folder:
  - `bash -n <file>` or `python3 -m py_compile <file>`
  - `echo '{"tool_name":"Read","tool_input":{"file_path":"/tmp/x"}}' | bash <hook>; echo $?` must print 0.
  An edit without both steps is not finished.
- Prefer an exact string replacement over a script that rebuilds the line.
- Keep the hooks folder in git, so `git checkout -- hooks/<hook>.sh` reverts it in one command.
- Emergency exit if it has already happened: use a tool that is not in any hook matcher (for example a background-command or monitor tool) to run the check and repair the file, or revert it by hand from a terminal.
- Before adding a hook to a broad matcher (Read, Bash), break it on purpose in a throwaway session to learn the blast radius.
- Stage hook and settings changes in a scratch folder and install them deliberately, not mid-session.
