---
name: security
description: "How we treat secrets, permissions, guards, hooks, shared databases and testing"
---

# Security — how we treat secrets, permissions and shared systems

Secrets live in one place outside any repo and are referenced by name, never pasted. Permissions and
guards are weaker than they look, so we test them instead of trusting their wording. Anything shared
(a database, a production system) is read freely and written to carefully, and nothing is ever
"verified" by writing to production. Hooks and permission settings are changed by a human hand.

---

## 1. Secrets

- **Secrets live in a secrets folder outside any repo** (or in the vault your team uses), one file
  per key, `chmod 600`, gitignored, and in the tool's own secret parameters (an automation platform's credential store, a hosting platform's environment variables).
- **Never inline a secret** in a skill, a doc, a prompt, a wiki page, a chat message, a commit, a
  test fixture, or a workflow node's plain text. Reference it by name and read it at run time.
- **Read a secret inside a script** (`open()`), not with `$(cat file)` on the command line, where it
  lands in shell history, process listings and transcripts.
- **One credential per app or automation.** A shared key gets revoked for everyone when one app
  misbehaves, and the audit trail cannot tell the apps apart. When testing an automation's write by
  hand, use that automation's credential, not the one already loaded in your session.
- **If a secret appears in a node's or a config's parameters, it will end up in a repo** the day
  someone exports it. Scrub exports before they go anywhere.
- **Rotation is a sweep.** Before rotating a key, list every place it is pasted (local files,
  credentials stored inside other tools, nodes that share it) and every alarm that depends on it. A
  rotation that updates one copy silently breaks the rest, and if the broken copy was a monitor, you
  have silenced your own alarm.
- **CI secret masking is not protection.** Log masking hides the literal value; any encoding
  (spacing characters out, base64) prints it in full. Scope the credential instead of relying on the
  mask.
- **Credentials already committed** cannot be cleaned by editing the working tree: they are in
  history. Fixing that means rotating and rewriting history. At minimum, never add new ones.

## 2. A pre-commit secret scanner

- Every repo that holds configuration or notes runs **gitleaks as a pre-commit hook**, with the full
  default ruleset (`[extend] useDefault = true`).
- **Allowlist by context, never by a global pattern.** Allow a specific documenting line (for
  example "credential id: `...`", which is an identifier, not a secret) or a literal redaction
  placeholder. Never allowlist a whole key format.
- 🚨 **An allowlist justified by a property of the repo dies when that property changes, and it fails
  open.** Example: a key format allowlisted "because those files are encrypted" stays allowlisted the
  day encryption is turned off, and the scan keeps passing green on real keys. When you change how a
  repo is protected, re-read every allowlist whose reason was that protection.
- Scan new files before committing even when the scanner is installed; it takes seconds.

## 3. Agent permissions are weaker than their wording

- 🚨 **MCP permissions have no argument scoping.** A rule like `Tool(param:value)` parses without
  error and does **not** match, so it fails in the worst way: silently, looking applied. Allowing
  `slack_send_message` for one channel allows **every** send, including DMs to colleagues. Treat
  every MCP allow as "every argument". Test a scoped rule before trusting it.
- **Scheduled agents in an interactive permission mode hang** waiting for an approval nobody will
  give, and hold their concurrency slot while they wait. Give routines only pre-approved commands.
- **A file `deny` rule is best-effort.** It blocks the obvious `cat file` and some wrappers, and lets
  others through (a Python `open()`, a glob, a variable holding the path). It is a speed bump, not a
  wall. The only OS-level lock is the sandbox's filesystem deny.
- **A permission classifier may refuse to read a credential file** even with a human's go in the
  chat. Do not route around it: add an explicit rule from an interactive session, or answer the
  question another way (the warehouse often has the data).

## 4. Guards: deny by destination, and write the ceiling down

- **Deny by destination, not by command name.** Enumerating dangerous verbs is a losing game;
  enumerating protected paths, hosts or tables is a finite one. Parse the redirect targets (`>`,
  `>>`, `tee`, `sed -i`) or a write deny-list is decorative.
- **Write a rule twice:** once as prose (it explains why and generalises), once as a hook (it fires
  whether or not the agent read the prose). Pick the rules that get both by asking: would a violation
  be expensive **and** irreversible?
- **Write the guard's ceiling into a comment** ("a determined agent can still escape through `eval`;
  this catches the obvious cases"). An unqualified guard gets trusted past its design.
- **Make the block message actionable**: "writes to X are blocked; the writable location is Y". A bare
  "denied" produces a retry loop.
- **Test a guard by planting the hostile input and watching it pass or fail.** A guard's green means
  "found nothing", which looks identical to "could not see anything".

## 5. Hooks and settings need a human's hand

- **A broken hook does not degrade; it blocks everything.** A missing quote in a hook that runs before
  every tool call stopped every tool in every open session, including the tool needed to fix it.
- Before saving any hook: `bash -n hook.sh` (or `python3 -m py_compile hook.py`), then run it once
  with a fake payload and check the exit code is 0. Prefer an exact-string edit over a script that
  rebuilds the line.
- **Changes to hooks and to the agent's own permission settings are made by a human.** The agent
  prepares the change in a scratch copy, syntax-checks and tests it with fake and real payloads, shows
  the normalised diff, and hands over one copy-and-run command that backs up the original first. The
  agent then verifies that the change landed. An auto-mode classifier refusing self-modification is
  working as intended; do not route around it.
- Keep the configuration folder in version control so a bad hook is one `git checkout` away.

## 6. Shared databases: read anything, write only what you own

An app's schema often lives on a database instance **shared with other apps**. There is no isolation
between tenants beyond good behaviour, and one tenant's migration that takes a lock can lock every
other app out until it finishes.

- **Read anything; write only to what your app owns.** Never touch another tenant's tables.
- **What hurts neighbours is a long, heavy transaction** (it saturates the instance, holds a
  connection, pins vacuum for everyone), not a lock on your own table. Total duration and concurrency
  protect the neighbours; `lock_timeout` protects you.
- **Never run DDL or a migration you have not checked for locks and duration.** Every transaction
  carries its own limits (`statement_timeout`, `lock_timeout`, and a transaction-level timeout where
  available). `statement_timeout` is per statement: three statements at 30 s is a 90 s ceiling.
- 🚨 **`SET LOCAL` outside a transaction block is a silent no-op**: the statements run with no limit.
  A SQL editor that runs the highlighted selection is one drag away from this. The guard must be an
  assertion that refuses to continue (`DO $$ ... RAISE EXCEPTION ... $$`), not the `SET` itself.
- 🚨 **A client-side HTTP timeout does not cancel the server-side statement.** The script gives up;
  the query keeps running with no ceiling. Put the limit inside the transaction on the server.
- **Never run migrations through an admin "run query" endpoint** that executes as the superuser with
  no statement timeout and wraps the whole body in one transaction. Use the SQL editor with explicit
  limits.
- **`CREATE ... IF NOT EXISTS` checks the name, not validity.** A failed concurrent index build leaves
  an invalid index that enforces nothing, and `IF NOT EXISTS` adopts it and reports success. Check
  `pg_index.indisvalid`.
- **One session at a time** on a migration. An abort (`statement` or `lock` timeout) is the guard
  working: retry when the instance is quiet; never raise the limit to force it through.

## 7. Production and testing

- 🚨 **Never "verify against production" with a write.** A verification step that writes to production
  repeats the very change it was meant to check. Verify with reads, on staging, or on a copy.
- **Test with fake data in a sandbox.** Synthetic tickets, disposable staging records, a throwaway
  database. Real customer data does not go into test fixtures, prompts or screenshots that leave the
  system.
- **A permission probe that can succeed is a real write.** If disambiguating a "can I write?" test
  means removing the part that made it safe (a no-op payload, a dry-run flag), the probe cannot answer
  that question. Ask "what happens if the answer is yes?" before probing.
- **Test with the credential that will run it.** Your own access says nothing about what the
  automation's credential can reach. Ship a control that must pass, because a broken request and a
  denied one look identical.
- **Authorisation lives at the data layer.** Who may see what is enforced where data is fetched,
  bound to a session identity. A prompt saying "do not show X" is not access control.
- **Record the actor from the token, not from a parameter.** A write that validates a token and then
  records an actor id passed in by the caller has a client-supplied audit trail.
- **Bots act under their own name.** An automation that acts as the human who invoked it makes its
  history unreconstructable.
