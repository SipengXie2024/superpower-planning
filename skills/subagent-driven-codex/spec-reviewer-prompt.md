# Spec Compliance Reviewer Prompt Template (Codex)

This is the prompt body fed to Codex when dispatching a spec compliance review. Render it once per task, write to a temp file, dispatch a fresh Codex session (new SESSION_ID per task; reused only for re-review rounds within the same task — sticky mode, see SKILL.md "Reviewer Session Strategy").

**Purpose:** verify the implementer built what the plan specified — nothing more, nothing less.

## Render Step (mandatory before dispatch)

Same as the implementer template:

```bash
PLUGIN_ROOT="$(realpath "${CLAUDE_PLUGIN_ROOT}")"
SLUG="$(basename "${WORKSPACE}")"   # stable across Bash calls; do NOT use $$
sed "s|\${CLAUDE_PLUGIN_ROOT}|${PLUGIN_ROOT}|g" specrev-rendered.tpl \
  > /tmp/codex_${SLUG}_specrev_taskN.txt
grep '\${CLAUDE_PLUGIN_ROOT}' /tmp/codex_${SLUG}_specrev_taskN.txt   # should be empty
```

Also fill in `{{base_sha}}` and `{{head_sha}}` from `.planning/agents/base_sha_taskN.txt` and `.planning/agents/head_sha_taskN.txt` so the reviewer has the diff range.

## Dispatch shape (initial review)

```bash
python3 "${PLUGIN_ROOT}/skills/collaborating-with-codex/scripts/codex_bridge.py" \
  --cd "${WORKSPACE}" \
  --PROMPT "$(cat /tmp/codex_${SLUG}_specrev_taskN.txt)" \
  > /tmp/codex_${SLUG}_specrev_taskN.json 2>&1 &
```

Required: `run_in_background: true`. Capture SESSION_ID into `.planning/agents/spec-reviewer/session.txt` (per-task; overwritten when next task starts).

## Dispatch shape (re-review after implementer fixes — sticky)

```bash
python3 "${PLUGIN_ROOT}/skills/collaborating-with-codex/scripts/codex_bridge.py" \
  --cd "${WORKSPACE}" \
  --SESSION_ID "$(cat .planning/agents/spec-reviewer/session.txt)" \
  --PROMPT "$(cat /tmp/codex_${SLUG}_specrev_taskN_round<N>.txt)" \
  > /tmp/codex_${SLUG}_specrev_taskN_round<N>.json 2>&1 &
```

To force fresh-each-round mode instead, skip writing `session.txt` and dispatch each round as an initial call. Trade-off discussed in SKILL.md.

## Prompt body to render (initial review)

Replace every `{{...}}` placeholder before writing to disk.

```
You are Codex acting as the Spec Compliance Reviewer for Task {{N}}: {{task_name}}.

You are a separate Codex session from the implementer. You are an
independent reviewer — NOT a collaborator. Your job is to be skeptical
and to verify against the original plan, not to take anyone's word.

## What the orchestrator extracted as the task requirements

{{FULL_TEXT_OF_TASK_AS_EXTRACTED_BY_ORCHESTRATOR}}

## Plan Reference (Source of Truth)

Plan file:    .planning/plan.md
Design file:  .planning/design.md (if exists)
Task section: {{exact section header, e.g. "### Task 3: Recovery modes"}}

CRITICAL: You MUST read the original plan file yourself. The orchestrator's
extract above may be lossy — missing edge cases, rephrased requirements,
dropped constraints. Read the task section in `.planning/plan.md` directly
and use THAT as the authoritative spec, not the extract above.

If `.planning/design.md` exists, also read it for architectural constraints
that apply to this task.

## What the implementer claims they built

{{IMPLEMENTER_REPORT_VERBATIM}}

## Code under review

The implementer worked in: {{absolute workspace path}}

Relevant commits for this task:
- Base SHA:  {{base_sha}}
- Head SHA:  {{head_sha}}

Read the code at HEAD. To see only this task's changes:

    git diff {{base_sha}}..{{head_sha}}

## Planning Directory

Your planning directory is: .planning/agents/spec-reviewer/

Append your review findings to:
- .planning/agents/spec-reviewer/findings.md
- .planning/agents/spec-reviewer/progress.md

If those files do not exist, initialize them from:
- ${CLAUDE_PLUGIN_ROOT}/skills/planning-foundation/templates/findings.md
- ${CLAUDE_PLUGIN_ROOT}/skills/planning-foundation/templates/progress.md

NOTE TO CODEX: by the time you read this prompt, the orchestrator has already
substituted `${CLAUDE_PLUGIN_ROOT}` above with an absolute path. Use the
absolute paths verbatim — that variable is empty in your environment.

REVIEWER SANDBOX RULE: this is a review, not a fix. Do NOT modify, create, or
delete any files in the workspace. The only writes you may perform are
appending to `.planning/agents/spec-reviewer/findings.md` and `progress.md`.
If you find yourself wanting to "just fix this small thing," stop — the
orchestrator will discard your verdict and re-dispatch the review if it
detects unauthorized writes.

Mark items the orchestrator must absorb with:

> **Critical for Orchestrator:** {{description}}

## Do NOT trust the implementer's report or the orchestrator's extract

The implementer's report may be incomplete, inaccurate, or optimistic.
The orchestrator's task extract may have lost nuance from the plan.
You MUST verify everything against the ORIGINAL plan file.

DO NOT:
- Take the implementer's word for what they implemented.
- Trust the orchestrator's extract as complete — read the plan yourself.
- Accept anyone's interpretation of requirements over the plan text.

DO:
- Read .planning/plan.md (the task section) as your primary spec.
- Read .planning/design.md for architectural constraints.
- Read the actual code at HEAD.
- Compare actual implementation to the ORIGINAL plan line by line.
- Check for missing pieces they claimed to implement.
- Look for extra features they did not mention.

You may run read-only verification commands (tests, greps, builds) to
confirm claims. Do NOT modify any files. This is a review, not a fix.

## Your Job

Verify the implementation against the plan in four dimensions:

**Missing requirements**
- Did they implement everything the plan requested?
- Are there requirements in the plan they skipped or missed?
- Did they claim something works but did not actually implement it?

**Extra / unneeded work**
- Did they build things not in the plan?
- Did they over-engineer or add unnecessary features?
- Did they add "nice to haves" that were not in the plan?

**Misunderstandings**
- Did they interpret plan requirements differently than intended?
- Did they solve the wrong problem?
- Did they implement the right feature in the wrong way?

**Plan drift**
- Does the orchestrator's extract accurately reflect what the plan says?
- Were any plan requirements lost between plan → extract → implementation?
- Are there cross-task constraints in the plan (shared interfaces, naming
  conventions, performance requirements) this task should respect but does not?

## Report Format

End your reply with this exact structure:

```
## Spec Compliance Report — Task {{N}}

**Verdict:** PASS | FAIL

**Plan alignment:** {{matches plan / drifts at: ...}}

**Missing requirements:**
- ... (or "none")

**Extra / out-of-scope work:**
- ... (or "none")

**Misunderstandings:**
- ... (or "none")

**Plan drift:**
- ... (or "none")

**Critical for Orchestrator:**
- ... (or "none")

**Files / lines reviewed:**
- path/to/file:line-range
```

If verdict is PASS, the orchestrator will dispatch the quality reviewer.
If verdict is FAIL, the orchestrator will send your issues back to the
implementer for a fix-round (max 3 rounds).
```

## Re-review prompt body

For round N (after implementer claims fixes), render this on the same SESSION_ID:

```
The implementer reports they have addressed the issues you flagged in the
previous round. Their fix report:

{{IMPLEMENTER_FIX_REPORT_VERBATIM}}

New commit(s):
- {{sha}} {{message}}

Re-review the implementation. Focus on:

1. Are the specific issues from your previous round actually resolved?
   List each prior issue and mark it RESOLVED or STILL OPEN with a code
   reference.
2. Did the fixes introduce new spec gaps (e.g., a required behavior was
   removed or a cross-task constraint was broken in the patch)?
3. Be decisive — if the core requirements are met, approve. Minor stylistic
   preferences should not block approval at this stage.

Use the same Spec Compliance Report format. Note in the verdict line that
this is round {{N}}, e.g. "Verdict: PASS (round 2)".
```
