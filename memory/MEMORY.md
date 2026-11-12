# Memory index: habits

One line per habit. Each file holds the rule, the incident that taught it, why, and how to apply it.
This index must load whole: keep it well under 200 lines and ~20 KB. Long lessons live in `knowledge/lessons.md`.

## Reviewing
- [Two reviewers, looped until green](feedback_two_reviewers_looped_until_green.md) — CodeRabbit + a subagent, until a round on the current head is clean; re-check the PR is open before each push
- [Block only on real breakage](feedback_review_bar_block_only_on_breakage.md) — note and approve the rest; on someone else's PR, stay on their code
- [A green check is not a review](feedback_a_green_check_is_not_a_review.md) — ask the bot, query unresolved threads on the current head

## Sending a cold agent
- [Cold review is the last step](feedback_cold_review_is_the_last_step.md) — only the repo and PR number, one suite run in a reviewer's conditions
- [Plant mutants on the touched lines](feedback_plant_mutants_on_touched_lines.md) — on risky changes, 10–20 small bugs; killed means an assertion failed

## Testing
- [A green run is an observation](feedback_a_green_run_is_an_observation.md) — on risky changes, 3+ runs plus a control that varies the measured thing; state the count
- [Prove it by running it](feedback_prove_it_by_running_it.md) — "done" means ran the real path; every claim checked against code or data
- [Verify at the user's surface](feedback_verify_at_the_users_surface.md) — check where the user looks and where the data is read
- [Show the screen running](feedback_show_the_screen_running.md) — rendered before/after before any go on something people see

## Approaching a change
- [Pre-check before writing](feedback_precheck_before_writing.md) — does it already try, what's the smallest change, what does it newly expose
- [Size a PR by decisions](feedback_size_a_pr_by_decisions.md) — independent decisions, not files
- [Ask the reporter before a prohibition](feedback_ask_the_reporter_before_a_prohibition.md) — grep what humans actually sent; surface the policy edge
- [Prove a capability limit before reporting it](feedback_prove_a_capability_limit_before_reporting_it.md) — one call, then quote the error
- [Four questions before touching anything shared](feedback_four_questions_before_touching_shared.md) — who else uses it, real one, self-healing, what stops
- [Changes are forward-only](feedback_changes_are_forward_only.md) — fix the mechanism, explain the closed period, never rewrite it

## The meta test: test the instrument
- [A guard can be green and blind](feedback_a_guard_can_be_green_and_blind.md) — plant the hostile input; a guard that can't fire is dead
- [A probe that can succeed is not a probe](feedback_a_probe_that_can_succeed_is_not_a_probe.md) — keep the impossibility through every iteration
- [A silent failure needs a tell](feedback_a_silent_failure_needs_a_tell.md) — if failure looks like success, make it visible; no empty successes
- [Review the instrument](feedback_review_the_instrument.md) — charters, detectors and indexes get reviewed too

## Writing for humans
- [Two-layer writing](feedback_two_layer_writing.md) — plain summary on top, dense detail below
- [PR body: before/after and expected impact](feedback_pr_body_before_after_and_impact.md) — real cases, an unchanged row, an MDE-checked estimate
- [Link cases the reader can open](feedback_link_cases_the_reader_can_open.md) — link, what to look at, the re-run command, innocent cases
- [One glance, depth behind a click](feedback_one_glance_depth_behind_a_click.md) — move detail, don't cut it; surfaces describe the present
- [Compare and label options](feedback_compare_and_label_options.md) — a table on the decider's axes; same labels on image and text

## Working with agents
- [Model agents by craft](feedback_model_agents_by_craft.md) — the kind of thinking, not the project or tool
- [Agents earn permissions](feedback_agents_earn_permissions.md) — born read-only or draft-only; the key is traps written in the charter
- [Parallel dispatch, no fan-out](feedback_parallel_dispatch_no_fanout.md) — independent work in one message, capped per batch; no workflows for routine work
- [A suggested task is a dispatch without a gate](feedback_a_suggested_task_is_a_dispatch_without_a_gate.md) — narrowest scope for parked work
- [Authority before merit](feedback_authority_before_merit.md) — "is this mine to decide?" first; approve is not merge
- [A relayed fact carries its source](feedback_relayed_fact_carries_its_source.md) — source and time on the same line, or "second-hand"
- [Sweep a dead fact by concept](feedback_sweep_a_dead_fact_by_concept.md) — grep the idea, read imperative lines first, find the copies

## Guards and safety
- [Prose is the rule, a hook is the floor](feedback_prose_is_the_rule_a_hook_is_the_floor.md) — write it twice; deny by destination
- [Syntax-check a hook before saving](feedback_syntax_check_a_hook_before_saving.md) — `bash -n` / `py_compile` and a dry run, or every tool can lock
- [Prefer API over browser](feedback_prefer_api_over_browser.md) — CLI and connectors first, browser last and said out loud
- [Never inline credentials](feedback_never_inline_credentials.md) — read at runtime; hunt every path a key could leak through
