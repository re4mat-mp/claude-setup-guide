---
name: a-probe-that-can-succeed-is-not-a-probe
description: "A safety probe must be unable to succeed; if resolving an ambiguous result means removing the property that made it safe, that instrument cannot answer the question, so find another one or verify out of band"
metadata:
  type: feedback
---
**A safety probe has to be impossible to succeed. If the only way to resolve an ambiguous result is to remove the property that made the probe safe, that instrument cannot answer the question.** Before testing *whether you can*, ask what happens if the answer is yes. If yes leaves a trace, it is not a test, it is the action.

**The pattern:** a probe built to fail safely (a write that cannot succeed, so the status code reveals the permission) returns something ambiguous, and the obvious way to disambiguate it is to make it a little more real. Each refinement feels like precision; the last one is a real write to production.

**Why:** nobody decides to write to production. You get there by refinement, and each step feels like precision. Some APIs do not expose an integration's capabilities at all, so there is no read-only way to prove a token cannot write. A design that says "the preflight attempts a write and demands a 403" then cannot be built without risking the very damage it is meant to prevent.

**How to apply:**
- Design permission checks so that success is impossible, and keep that property through every iteration.
- When the result is ambiguous, look for a different instrument; don't soften this one.
- If no safe instrument exists, move the guarantee from "prevented" to "verified out of band" (a human checks the settings screen) and write it in those words.
- Applies to API keys, database roles, storage buckets and service accounts alike.
