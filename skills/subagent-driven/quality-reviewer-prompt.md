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
```

**Code reviewer returns:** Strengths, Issues (Critical/Important/Minor), Assessment
