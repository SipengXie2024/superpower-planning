# Plan Reviewer Prompt Template

Use this template when dispatching a plan reviewer subagent.

**Purpose:** Verify that the implementation plan is aligned with the approved spec, decomposed well, and safe to hand off to execution.

## Standard Dispatch Shape

```text
You are reviewing an implementation plan before execution begins.

SPEC_PATH: .planning/design.md
PLAN_PATH: .planning/plan.md
REVIEW_SCOPE: first-pass review
AGENT_PLANNING_DIR: .planning/agents/plan-reviewer/

Use the instructions below and write findings to `{AGENT_PLANNING_DIR}/findings.md` as you go.
Mark critical items with: `> **Critical for Orchestrator:** [description]`
```

## Full Template

```
Task tool (general-purpose):
  description: "Review implementation plan quality and alignment"
  prompt: |
    You are reviewing an implementation plan before execution begins.

    ## Approved Spec

    SPEC_PATH: {SPEC_PATH}

    ## Implementation Plan

    PLAN_PATH: {PLAN_PATH}

    ## Review Scope

    REVIEW_SCOPE: {REVIEW_SCOPE}

    ## Planning Directory

    Your review planning directory is: {AGENT_PLANNING_DIR}
    Write findings to `{AGENT_PLANNING_DIR}/findings.md` as you go.
    Mark critical items with: `> **Critical for Orchestrator:** [description]`

    ## Your Job

    Review the plan for:

    **Alignment with spec**
    - Does the plan actually implement the approved design?
    - Are any spec requirements missing?
    - Did the plan introduce scope not in the spec?

    **Decomposition quality**
    - Is the work split into appropriately sized tasks?
    - Are file boundaries and responsibilities clear?
    - Does the plan avoid bundling multiple independent subsystems into one track?

    **Execution readiness**
    - Are files, commands, and test steps concrete enough to execute?
    - Are verification steps explicit?
    - Are risky migrations / integration points surfaced?

    **Engineering quality**
    - Does the plan encourage TDD, DRY, YAGNI?
    - Does it avoid over-engineering?
    - Are parallelism groups sensible?

    ## Output

    Report one of:
    - Approved
    - Issues found: [specific issues with section references and suggested fixes]
```
