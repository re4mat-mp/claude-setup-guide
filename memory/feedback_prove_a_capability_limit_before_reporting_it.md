---
name: prove-a-capability-limit-before-reporting-it
description: "A capability limit ('X is down', 'X needs auth') is proven with one small call before it is reported; a startup warning or config listing is not a measurement, and a false block gives a reasonable-sounding excuse to skip a rule"
metadata:
  type: feedback
---
**A capability limit is proven with one call before it is reported.** A startup notice, a config listing or a note saying "X requires authentication" or "X is down" describes how things looked once, not now. We run the smallest call that would prove it (a `get`, a `list`, a `--version`) and then either quote the literal error or say we did not test it.

**The case:** sessions repeated over many days that an issue tracker "wasn't authenticated", taken from a startup warning. One `list` call worked the first time. The warning came from a dead duplicate server entry in a local config file, so every new session read it and re-reported the same false block; no correction in notes could fix it until the config entry was removed. Worse, one session changed its plan because of it and skipped a standing rule "because the tool can't be written to".

**Why:** a false block does not just misinform. It hands you a sensible-sounding reason to break a rule, and it creates work for whoever reads it ("authenticate this when you can"). And when an error keeps coming back and you cannot find the false fact written anywhere, the liar is the runtime config, not the notes.

**How to apply:**
- Before writing "I can't do X because Y isn't available", make the call. If it fails, quote the error.
- An unauthenticated connector and a working path (a REST API with a local key, a different connector) coexist all the time. Check the other path.
- A record saying something works is not proof that it works, and a record saying it does not work is not proof either. Check both directions.
- The same goes for model names, rate limits and permissions: verify against a call or the official docs, not recall.
