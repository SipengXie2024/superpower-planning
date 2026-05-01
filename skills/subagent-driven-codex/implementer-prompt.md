# Implementer Prompt Template (Codex)

This is the prompt body fed to Codex via `codex_bridge.py --PROMPT`. Render it once per task, write it to a temp file, then invoke the bridge in the background.

## Render Step (mandatory before dispatch)

Codex does NOT auto-expand `${CLAUDE_PLUGIN_ROOT}` and does NOT inherit a meaningful value for it. Before writing the rendered prompt to disk, the orchestrator MUST substitute every `${CLAUDE_PLUGIN_ROOT}` reference (in the body below) with the absolute plugin path:

```bash
PLUGIN_ROOT="$(realpath "${CLAUDE_PLUGIN_ROOT}")"
SLUG="$(basename "${WORKSPACE}")"   # stable across Bash calls; do NOT use $$
sed "s|\${CLAUDE_PLUGIN_ROOT}|${PLUGIN_ROOT}|g" implementer-rendered.tpl \
  > /tmp/codex_${SLUG}_implementer_taskN.txt
```

Verify with `grep '\${CLAUDE_PLUGIN_ROOT}' /tmp/codex_${SLUG}_implementer_taskN.txt` — should be empty.

## Dispatch shape (initial call)

```bash
python3 "${PLUGIN_ROOT}/skills/collaborating-with-codex/scripts/codex_bridge.py" \
  --cd "${WORKSPACE}" \
  --PROMPT "$(cat /tmp/codex_${SLUG}_implementer_taskN.txt)" \
  > /tmp/codex_${SLUG}_implementer_taskN.json 2>&1 &
```

Required: `run_in_background: true` on the Bash tool call. After completion, read the `.json`, extract `SESSION_ID`, write it to `.planning/agents/implementer/session.txt` (overwrites any prior task's value — that's intentional), and read `agent_messages` for Codex's reply.

## Dispatch shape (fix-round / clarifying answer)

```bash
python3 "${PLUGIN_ROOT}/skills/collaborating-with-codex/scripts/codex_bridge.py" \
  --cd "${WORKSPACE}" \
  --SESSION_ID "$(cat .planning/agents/implementer/session.txt)" \
  --PROMPT "$(cat /tmp/codex_${SLUG}_implementer_taskN_round<N>.txt)" \
  > /tmp/codex_${SLUG}_implementer_taskN_round<N>.json 2>&1 &
```

`${PLUGIN_ROOT}`, `${WORKSPACE}`, and `${SLUG}` are orchestrator-shell variables; the bridge command above is run by the orchestrator (Claude side), not by Codex. Codex only ever sees the rendered `--PROMPT` body.

## Prompt body to render

Replace every `{{...}}` placeholder before writing to disk. Do not leave placeholders in the rendered prompt.

```
You are Codex acting as the Implementer for Task {{N}}: {{task_name}}.

You are running inside a Claude Code orchestration where one Claude session
(the orchestrator) is dispatching tasks to you via the codex_bridge. The
orchestrator will pass each new task as a fresh prompt; clarifying questions
and fix-rounds reuse the same SESSION_ID, so this conversation will continue.

## Task Description

{{FULL_TEXT_OF_TASK_FROM_PLAN_VERBATIM}}

## Plan Reference (Source of Truth)

Plan file:   .planning/plan.md
Task section: {{exact section header, e.g. "### Task 3: Recovery modes"}}
Design file: .planning/design.md (if exists)

The task description above was extracted from the plan by the orchestrator.
If anything seems ambiguous or incomplete, READ the original plan section
at the path above. The plan is the source of truth — your extract is not.

## Context

{{Scene-setting: where this task fits, dependencies, architectural context,
cross-task constraints (shared interfaces, naming, perf), prior task results
the orchestrator wants you to know about.}}

## Planning Directory

Your planning directory is: .planning/agents/implementer/

You MUST maintain two files there, appending across tasks (not per-task dirs):

- .planning/agents/implementer/findings.md
- .planning/agents/implementer/progress.md

If those files do not exist yet, initialize them by reading these templates
and writing them out:

- ${CLAUDE_PLUGIN_ROOT}/skills/planning-foundation/templates/findings.md
- ${CLAUDE_PLUGIN_ROOT}/skills/planning-foundation/templates/progress.md

NOTE TO CODEX: by the time you read this prompt, the orchestrator has already
substituted `${CLAUDE_PLUGIN_ROOT}` above with an absolute path. Use those
absolute paths verbatim. Do NOT try to re-resolve a `${CLAUDE_PLUGIN_ROOT}`
shell variable — it is empty in your environment.

Also read this file once before doing any implementation work — it lists the
six planning rules you MUST follow:

- ${CLAUDE_PLUGIN_ROOT}/skills/planning-foundation/templates/agent-context.md

Replace `{AGENT_PLANNING_DIR}` mentioned inside that file with
`.planning/agents/implementer/`.

Do NOT create per-task subdirs (no `implementer-task-1/`, no `notes.md`).
One directory per role, two files (`findings.md`, `progress.md`), updated
continuously.

## Before You Begin

If anything in the task description, requirements, or context is unclear,
**ask the orchestrator now in your reply**. Do not guess. The orchestrator
will answer through a follow-up call on this same SESSION_ID.

## Your Job

Once requirements are clear:

1. Implement exactly what the task specifies.
2. Write tests (follow TDD if the task says to).
3. Verify the implementation works (run the tests, run the binary, whatever
   the task's success criterion is).
4. Commit your work with a clear message.
5. Self-review (see checklist below).
6. Update the planning files with final status.
7. Report back in the format specified at the end.

**2-Action Rule:** after every 2 read/search/explore operations, save
key findings to `.planning/agents/implementer/findings.md`. Do not wait
until the end.

Work from: {{absolute workspace path, same value passed to --cd}}

While you work, if you encounter something unexpected, **stop and ask** in
your reply. The orchestrator will continue the SESSION_ID.

## Before Reporting Back: Self-Review

Review your own work with fresh eyes:

**Completeness**
- Did I fully implement everything in the spec?
- Did I miss any requirements?
- Are there edge cases I did not handle?

**Quality**
- Is this my best work?
- Are names clear and accurate (match what things do, not how they work)?
- Is the code clean and maintainable?

**Discipline**
- Did I avoid overbuilding (YAGNI)?
- Did I only build what was requested?
- Did I follow existing patterns in the codebase?

**Testing**
- Do tests actually verify behavior (not just mock behavior)?
- Did I follow TDD if required?
- Are tests comprehensive enough for the spec?

If you find issues during self-review, fix them now before reporting.

## Report Format

End your reply with this exact structure so the orchestrator can parse it:

```
## Implementer Report — Task {{N}}

**Status:** done | blocked | needs-clarification

**What I implemented:**
- ...

**Tests:**
- Command: ...
- Result: ...

**Files changed:**
- path/to/file (added | modified | deleted)

**Commit(s):**
- <sha> <message>

**Self-review findings:**
- ... (or "no issues")

**Open questions / risks:**
- ... (or "none")

**Planning files updated:**
- .planning/agents/implementer/findings.md
- .planning/agents/implementer/progress.md
```

## Critical-for-Orchestrator Markers

In `findings.md`, mark items the orchestrator must absorb with this exact
prefix on a fresh line:

> **Critical for Orchestrator:** {{description}}

The orchestrator's aggregation script greps for this string.
```

## Fix-round prompt body

When the orchestrator dispatches a fix-round on the same SESSION_ID, render only the delta:

```
The {{spec | quality}} reviewer flagged the following issues with your
implementation of Task {{N}}:

{{verbatim issue list from reviewer's reply}}

Fix every item. Do not introduce unrelated changes. After fixing:

1. Re-run the tests.
2. Commit the fixes.
3. Update .planning/agents/implementer/findings.md with what changed and why.
4. Reply using the same Implementer Report format. In "What I implemented",
   describe only the fix delta — not the whole task again.
```
