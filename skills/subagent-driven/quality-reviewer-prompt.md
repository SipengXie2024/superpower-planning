# Code Quality Reviewer Prompt Template

Use this template when dispatching a code quality reviewer subagent.

**Purpose:** Verify implementation is well-built (clean, tested, maintainable)

**Only dispatch after spec compliance review passes.**

```
Task tool (superpower-planning:requesting-review):
  Use template at requesting-review/code-reviewer.md

  WHAT_WAS_IMPLEMENTED: [from implementer's report]
  PLAN_OR_REQUIREMENTS: Task N from [plan-file]
  BASE_SHA: [commit before task]
  HEAD_SHA: [current commit]
  DESCRIPTION: [task summary]

  Additionally, include:

  ## Planning Directory

  Your review planning directory is: {AGENT_PLANNING_DIR}
  (e.g., .planning/agents/quality-reviewer/)

  Write your review findings to `{AGENT_PLANNING_DIR}/findings.md` as you go.
  Mark critical items with: `> **Critical for Orchestrator:** [description]`

  ## Review Round Context

  You may be invoked multiple times for the same task if issues were found in
  a previous round. The orchestrator tracks review rounds (max 3). If this is
  a re-review, focus on whether the specific issues from the previous round
  have been addressed. Approve if the implementation is sound and maintainable,
  even if it is not perfect. Critical and Important issues warrant rejection;
  Minor issues alone should not block approval.
```

**Code reviewer returns:** Strengths, Issues (Critical/Important/Minor), Assessment
