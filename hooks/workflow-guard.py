#!/usr/bin/env python3
"""
PreToolUse hook on the `Workflow` tool: ask for confirmation before EVERY multi-agent workflow.

Why it exists: a single session once fired a workflow that fanned out to 29 subagents and burned the whole
5-hour usage limit in about 30 minutes, with no prompt, because the usage warning had been dismissed earlier.

The hook forces an "ask" before every workflow (including ones a skill starts on its own) and shows a static
fan-out risk estimate (agent() / parallel() / pipeline() calls, loops, whether a budget cap exists), so the
decision is informed, not blind.

Wire it in ~/.claude/settings.json under hooks.PreToolUse, matcher "Workflow":
  {"type": "command", "command": "python3 ~/.claude/hooks/workflow-guard.py", "timeout": 10}
"""
import sys
import json
import re


def emit(reason):
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "ask",
            "permissionDecisionReason": reason,
        }
    }))
    sys.exit(0)


PRIOR = ("A prior workflow hit the 5-hour usage cap in ~30 min "
         "(29 agents). ")

try:
    data = json.load(sys.stdin)
except Exception:
    emit("WORKFLOW ABOUT TO RUN. " + PRIOR +
         "Could not parse the call — confirm manually before proceeding.")

ti = data.get("tool_input", {}) or {}
script = ti.get("script", "") or ""
name = ti.get("name", "") or ""
script_path = ti.get("scriptPath", "") or ""

# A named/saved workflow or a scriptPath: the fan-out is not visible here.
if not script and (name or script_path):
    ref = name or script_path
    emit(f"WORKFLOW ABOUT TO RUN (saved: {ref}). " + PRIOR +
         "Fan-out not visible from here — confirm you intend to run it.")

# Inline script: estimate fan-out risk statically.
agent_calls = len(re.findall(r'\bagent\s*\(', script))
parallels = len(re.findall(r'\bparallel\s*\(', script))
pipelines = len(re.findall(r'\bpipeline\s*\(', script))
loops = len(re.findall(r'\b(while|for)\s*\(', script))
has_budget = bool(re.search(r'budget\.(total|remaining|spent)', script))

fanout = parallels + pipelines
high = (fanout > 0 and not has_budget) or agent_calls > 8 or loops > 0
risk = "HIGH" if high else "moderate"

lines = [
    f"WORKFLOW ABOUT TO RUN — {risk} cost risk.",
    PRIOR.strip(),
    (f"Static scan: agent()={agent_calls}, parallel()={parallels}, "
     f"pipeline()={pipelines}, loops={loops}, "
     f"budget cap={'YES' if has_budget else 'NONE'}."),
]
if fanout and not has_budget:
    lines.append("Fan-out with NO budget cap — real agent count is data-driven "
                 "and can be far higher than the agent() count above. "
                 "Add '+Nk' to the prompt to bound it, or run a single Agent instead.")
lines.append("Confirm you want to spend usage on this.")

emit(" ".join(lines))
