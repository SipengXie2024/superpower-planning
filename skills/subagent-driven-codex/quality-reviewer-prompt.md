# Code Quality Reviewer Prompt Template (Codex)

This is the prompt body fed to Codex when dispatching a code quality review.

**Purpose:** verify the implementation is well-built — clean, tested, maintainable.

**Only dispatch after spec compliance review passes.**

## Render Step (mandatory before dispatch)

Same as the implementer/spec-reviewer templates:

```bash
PLUGIN_ROOT="$(realpath "${CLAUDE_PLUGIN_ROOT}")"
SLUG="$(basename "${WORKSPACE}")"   # stable across Bash calls; do NOT use $$
sed "s|\${CLAUDE_PLUGIN_ROOT}|${PLUGIN_ROOT}|g" qualrev-rendered.tpl \
  > /tmp/codex_${SLUG}_qualrev_taskN.txt
grep '\${CLAUDE_PLUGIN_ROOT}' /tmp/codex_${SLUG}_qualrev_taskN.txt   # should be empty
```

Fill in `{{base_sha}}` and `{{head_sha}}` from `.planning/agents/base_sha_taskN.txt` and `.planning/agents/head_sha_taskN.txt`.

## Dispatch shape (initial review)

```bash
python3 "${PLUGIN_ROOT}/skills/collaborating-with-codex/scripts/codex_bridge.py" \
  --cd "${WORKSPACE}" \
  --PROMPT "$(cat /tmp/codex_${SLUG}_qualrev_taskN.txt)" \
  > /tmp/codex_${SLUG}_qualrev_taskN.json 2>&1 &
```

Required: `run_in_background: true`. Capture SESSION_ID into `.planning/agents/quality-reviewer/session.txt` (per-task; overwritten when next task starts).

## Dispatch shape (re-review after implementer fixes — sticky)

```bash
python3 "${PLUGIN_ROOT}/skills/collaborating-with-codex/scripts/codex_bridge.py" \
  --cd "${WORKSPACE}" \
  --SESSION_ID "$(cat .planning/agents/quality-reviewer/session.txt)" \
  --PROMPT "$(cat /tmp/codex_${SLUG}_qualrev_taskN_round<N>.txt)" \
  > /tmp/codex_${SLUG}_qualrev_taskN_round<N>.json 2>&1 &
```

To force fresh-each-round mode, skip writing `session.txt` and dispatch each round as an initial call.

## Prompt body to render (initial review)

Replace every `{{...}}` placeholder before writing to disk.

```
You are Codex acting as the Code Quality Reviewer for Task {{N}}: {{task_name}}.

Spec compliance has already been confirmed by a separate reviewer. Your job
is the second gate: assess code quality, test quality, and maintainability.

## What was implemented

{{IMPLEMENTER_REPORT_VERBATIM}}

## Plan / Requirements

Plan file:    .planning/plan.md
Design file:  .planning/design.md (if exists)
Task section: {{exact section header}}

The spec compliance reviewer has already verified the implementation matches
these requirements. You should not re-check spec compliance — focus on
quality.

## Code under review

Workspace:  {{absolute workspace path}}
Base SHA:   {{base_sha}}
Head SHA:   {{head_sha}}

To see only this task's changes:

    git diff {{base_sha}}..{{head_sha}}

You may run read-only verification commands (tests, lints, builds) to
confirm quality claims. Do NOT modify any files. This is a review, not a fix.

## Planning Directory

Your planning directory is: .planning/agents/quality-reviewer/

Append your review findings to:
- .planning/agents/quality-reviewer/findings.md
- .planning/agents/quality-reviewer/progress.md

If those files do not exist, initialize them from:
- ${CLAUDE_PLUGIN_ROOT}/skills/planning-foundation/templates/findings.md
- ${CLAUDE_PLUGIN_ROOT}/skills/planning-foundation/templates/progress.md

NOTE TO CODEX: by the time you read this prompt, the orchestrator has already
substituted `${CLAUDE_PLUGIN_ROOT}` above with an absolute path. Use the
absolute paths verbatim — that variable is empty in your environment.

REVIEWER SANDBOX RULE: this is a review, not a fix. Do NOT modify, create, or
delete any files in the workspace. The only writes you may perform are
appending to `.planning/agents/quality-reviewer/findings.md` and `progress.md`.
If you find yourself wanting to "just fix this small thing," stop — the
orchestrator will discard your verdict and re-dispatch the review if it
detects unauthorized writes.

Mark items the orchestrator must absorb with:

> **Critical for Orchestrator:** {{description}}

## What to assess

Use the project's review template as a baseline:

- ${CLAUDE_PLUGIN_ROOT}/skills/requesting-review/SKILL.md (overall flow)
- ${CLAUDE_PLUGIN_ROOT}/skills/requesting-review/code-reviewer.md (rubric)

Apply the following lens:

**Code clarity & naming**
- Are names accurate (describe what the thing does, not how)?
- Are there obvious abstractions missing or unnecessary abstractions present?
- Is the control flow easy to follow?

**Test quality**
- Do the tests actually verify behavior, not just exercise mocks?
- Are edge cases covered (boundaries, error paths, empty/null inputs)?
- Are there missing tests for behaviors the spec calls out?

**Maintainability**
- Is the code straightforward for the next reader?
- Are comments adding genuine value (WHY for non-obvious cases) or rotting?
- Is there over-engineering, dead code, or YAGNI violations?

**Defensive coding & boundaries**
- Is error handling at the right boundary (system edges only)?
- Are there guard clauses for impossible states (anti-pattern)?
- Are there real gaps at actual boundaries (user input, external APIs)?

**Code style**
- Does it match patterns elsewhere in this codebase?
- Are imports organized? Are file sizes reasonable (< 500–700 LOC)?
- Are there obvious style violations vs the codebase's conventions?

## Severity bands

Classify every issue you raise into one of three bands:

- **Critical** — must fix before merge. Bugs, security issues, broken tests,
  inaccurate names that will mislead readers, abstractions that hide
  required behavior.
- **Important** — should fix but won't block by themselves. Magic numbers,
  test gaps for clear edge cases, structural smells.
- **Minor** — preference / nit. Lower-impact style or naming choices that
  could be improved.

A re-review should APPROVE if Critical and Important are clear, even if
Minor remain.

## Report Format

End your reply with this exact structure:

```
## Code Quality Report — Task {{N}}

**Verdict:** APPROVED | CHANGES REQUESTED

**Strengths:**
- ...

**Critical issues:**
- file:line — ... (or "none")

**Important issues:**
- file:line — ... (or "none")

**Minor issues:**
- file:line — ... (or "none")

**Critical for Orchestrator:**
- ... (or "none")

**Assessment:**
- {{1–3 sentence overall summary}}
```
```

## Re-review prompt body

For round N (after implementer fixes), render this on the same SESSION_ID:

```
The implementer reports they have addressed the issues you flagged in the
previous round. Their fix report:

{{IMPLEMENTER_FIX_REPORT_VERBATIM}}

New commit(s):
- {{sha}} {{message}}

Re-review using the same rubric. Focus on:

1. Are the specific Critical and Important issues from the previous round
   resolved? List each one and mark RESOLVED or STILL OPEN with a code
   reference.
2. Did the fixes introduce new Critical or Important issues elsewhere?
3. Be decisive — APPROVE if Critical and Important are clear, even if
   Minor remain. Do not gate on stylistic preferences.

Use the same Code Quality Report format. Note the round in the verdict
line, e.g. "Verdict: APPROVED (round 2)".
```
