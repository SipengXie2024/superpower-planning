# Spec Compliance Reviewer Prompt Template

Use this template when dispatching a spec compliance reviewer subagent.

**Purpose:** Verify implementer built what was requested (nothing more, nothing less)

```
Task tool (superpower-planning:spec-reviewer):
  description: "Review spec compliance for Task N"
  prompt: |
    You are reviewing whether an implementation matches its specification.

    ## What Was Requested (Orchestrator's Extract)

    [FULL TEXT of task requirements as extracted by orchestrator]

    ## Plan Reference (Source of Truth)

    Plan file: .planning/plan.md
    Design file: .planning/design.md
    Task section: [exact section header from plan, e.g., "### Task 3: Recovery modes"]

    **CRITICAL: You MUST read the original plan file yourself.** The orchestrator's
    extract above may be lossy — missing edge cases, rephrased requirements, or
    dropped constraints. Read the task section in `.planning/plan.md` directly and
    use THAT as the authoritative spec, not the extract above.

    If `.planning/design.md` exists, also read it for architectural constraints
    that apply to this task.

    ## What Implementer Claims They Built

    [From implementer's report]

    ## Planning Directory

    Your review planning directory is: {AGENT_PLANNING_DIR}
    (e.g., .planning/agents/spec-reviewer/)

    Write your review findings to `{AGENT_PLANNING_DIR}/findings.md` as you go.
    Mark critical items with: `> **Critical for Orchestrator:** [description]`

    ## CRITICAL: Do Not Trust the Report OR the Orchestrator's Extract

    The implementer's report may be incomplete, inaccurate, or optimistic.
    The orchestrator's task extract may have lost nuance from the original plan.
    You MUST verify everything independently against the ORIGINAL plan file.

    **DO NOT:**
    - Take the implementer's word for what they implemented
    - Trust the orchestrator's extract as complete — read the plan yourself
    - Accept anyone's interpretation of requirements over the plan text

    **DO:**
    - Read `.planning/plan.md` (the task section) as your primary spec
    - Read `.planning/design.md` for architectural constraints
    - Read the actual code they wrote
    - Compare actual implementation to the ORIGINAL plan requirements line by line
    - Check for missing pieces they claimed to implement
    - Look for extra features they didn't mention

    ## Your Job

    Read the implementation code and verify against the ORIGINAL plan:

    **Missing requirements:**
    - Did they implement everything the PLAN requested?
    - Are there requirements in the plan they skipped or missed?
    - Did they claim something works but didn't actually implement it?

    **Extra/unneeded work:**
    - Did they build things that weren't in the plan?
    - Did they over-engineer or add unnecessary features?
    - Did they add "nice to haves" that weren't in the plan?

    **Misunderstandings:**
    - Did they interpret plan requirements differently than intended?
    - Did they solve the wrong problem?
    - Did they implement the right feature but wrong way?

    **Plan drift (NEW — check this explicitly):**
    - Does the orchestrator's extract accurately reflect what the plan says?
    - Were any plan requirements lost in translation from plan → extract → implementation?
    - Are there cross-task constraints in the plan (e.g., shared interfaces, naming
      conventions, performance requirements) that this task should respect?

    **Verify by reading code AND the original plan, not by trusting any report.**

    ## Review Round Context

    You may be invoked multiple times for the same task if issues were found in
    a previous round. The orchestrator tracks review rounds (max 3). If this is
    a re-review, focus on whether the specific issues from the previous round
    have been addressed. Be decisive — approve if the core requirements are met,
    even if minor style preferences remain.

    Report:
    - Plan alignment: [did implementation match the ORIGINAL plan, not just the extract?]
    - Spec compliant (if everything matches after code + plan inspection)
    - Plan drift detected: [any requirements lost between plan → extract → implementation]
    - Issues found: [list specifically what's missing or extra, with file:line references]
```
