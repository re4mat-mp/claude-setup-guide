---
name: never-inline-credentials
description: "Credentials are never inlined in a prompt, skill, doc, ticket, message or workflow; they are read at runtime from env vars or a secrets store, and reviews hunt for any path by which a key reaches a log, an assertion diff or a generated doc"
metadata:
  type: feedback
---
**Credentials are never inlined: not in a prompt, a skill, a doc, a ticket, a message or a workflow node.** They live in a local secrets store outside any repo, in environment variables, or in the automation platform's credential store, and code reads them at runtime.

**The pattern:** nothing is inlined in the source, and a secret still reaches a log: a test reads a key from the environment, and on failure the assertion diff prints it in full. The class to watch is not only the literal key in a file, but every path by which a key can reach a log, a doc, an error message or a chat.

**Why:** anything an agent can read, an agent can copy, into a PR body, a summary or a message. A key inlined once spreads through every artifact that quotes it, and it cannot be recalled.

**How to apply:**
- Read secrets from env vars or the secrets store, and refer to them by name ("the key in the secrets store"), never by value.
- In reviews, hunt for inlined credentials and for any secret that could reach a log, an assertion message, an error string or a generated doc.
- Run tests both with keys exported as dummy sentinel values and with keys absent, then grep the output for the sentinel.
- Mutation runs and permission probes happen in a clean clone with an empty environment.
- Automation workflows reference the platform's credential store, never keys pasted into node parameters.
- Enforce it, don't just write it: a pre-commit or CI secret scan catches what prose misses.
- Agents never type credentials into fields; they ask the human or use a credential manager that fills them without exposing the value.
