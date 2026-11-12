#!/usr/bin/env python3
"""PreToolUse hook on `Bash`: refuse `pkill -f` and `killall`, which kill by NAME across every session on the machine.

Why it exists: we run several Claude sessions on one laptop in parallel. One session ran
`pkill -f "node --test ..."` to stop its own test suite and also killed the suites of three other sessions,
which then had to be rerun. A rule written in prose ("never pkill -f") did not stop it; this hook does.

- Denies: `pkill` with `-f` / `--full` (also inside a flag cluster like `-9f`), and any `killall`, wherever they sit in
  the command: after `;`, `&&`, `|`, inside `$(...)`, behind `sudo`/`nohup`/`env`/`timeout N`, or inside `bash -c`.
- Leaves alone: `kill <pid>`, `pgrep`, plain `pkill <name>` without -f, and the words inside quotes or arguments
  (`grep 'pkill -f' file`, `echo killall`).
- Fails open: a parse error or any exception lets the command through. This is a deliberate trade-off against the
  usual rule (a guard that can't parse should fail, not skip): a broken hook here would block every Bash command.

Wire it in ~/.claude/settings.json under hooks.PreToolUse, matcher "Bash":
  {"type": "command", "command": "python3 ~/.claude/hooks/pkill-guard.py", "timeout": 10}
"""
import json
import re
import shlex
import sys

SHELLS = {"bash", "sh", "zsh"}
PREFIXES = {"sudo", "nohup", "command", "exec", "time", "nice", "env", "xargs", "caffeinate"}
OPERATORS = {";", "&", "&&", "|", "||", "(", ")", "\n", ";;", "|&"}

HOW = ("Kill only what you started: keep its PID when you start it (`cmd & echo $!`), or stop a background task "
       "with TaskStop; or list candidates with `pgrep -fl '<pattern>'`, check each PID is yours "
       "(`lsof -a -p <pid> -d cwd` shows its folder: your worktree or not), then `kill <pid>`.")


def deny(what):
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": (
            f"{what} kills by name on the whole machine, so it also kills other sessions' processes "
            "(it has already stopped other sessions' test suites). " + HOW),
    }}))


def tokens(cmd):
    # A newline separates commands like `;` does, so it is punctuation here, not whitespace.
    lex = shlex.shlex(cmd, posix=True, punctuation_chars="();<>|&\n")
    lex.whitespace = " \t\r"
    lex.whitespace_split = True
    lex.commenters = ""
    return list(lex)


def found(cmd, depth=0):
    """The first forbidden call in `cmd`, or None."""
    if depth > 3:
        return None
    toks = tokens(cmd)
    at_start = True
    i = 0
    while i < len(toks):
        t = toks[i]
        if t in OPERATORS or t == "$":
            at_start = True
            i += 1
            continue
        if not at_start:
            i += 1
            continue
        if re.match(r"^[A-Za-z_][A-Za-z0-9_]*=", t) or t in PREFIXES:
            i += 1
            continue
        if t == "timeout":
            i += 2 if i + 1 < len(toks) and re.match(r"^\d", toks[i + 1]) else 1
            continue
        at_start = False
        word = t.rsplit("/", 1)[-1]
        args = []
        j = i + 1
        while j < len(toks) and toks[j] not in OPERATORS:
            args.append(toks[j])
            j += 1
        if word == "killall":
            return "`killall`"
        if word == "pkill":
            for a in args:
                if a == "--full" or (re.match(r"^-[A-Za-z0-9]+$", a) and "f" in a[1:]):
                    return "`pkill -f`"
        if word in SHELLS and "-c" in args:
            k = args.index("-c")
            if k + 1 < len(args):
                hit = found(args[k + 1], depth + 1)
                if hit:
                    return hit
        i = j
    return None


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        return
    cmd = (data.get("tool_input") or {}).get("command")
    if not isinstance(cmd, str) or not re.search(r"\b(pkill|killall)\b", cmd):
        return
    try:
        hit = found(cmd)
    except ValueError:
        return
    if hit:
        deny(hit)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
