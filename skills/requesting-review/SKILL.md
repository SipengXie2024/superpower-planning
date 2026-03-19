---
name: requesting-review
description: Use when completing plan-driven tasks, implementing major features, or before merging to verify work meets requirements.
---

# Requesting Code Review

Dispatch `superpower-planning:code-reviewer` subagent to catch issues before they cascade.

**Core principle:** Review early, review often.

## When to Request Review

**Mandatory:**
- After each task in subagent-driven development
- After completing a major project step
- Before merge to main
- When implementation may have drifted from the approved plan

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing a complex bug
- After making architecture-affecting changes

## Review Priorities

Every requested review should explicitly cover:
1. **Plan alignment** — does the implementation match the approved plan/spec?
2. **Code quality** — error handling, maintainability, naming, structure, tests
3. **Architecture** — boundaries, coupling, integration, unnecessary complexity
4. **Documentation and standards** — comments/docs/conventions where relevant
5. **Severity semantics** — Critical / Important / Minor

## Standard Dispatch Template

Use the detailed template at `skills/requesting-review/code-reviewer.md`, but gather the following inputs first.

### Required Inputs
- `{WHAT_WAS_IMPLEMENTED}` — what was just built
- `{PLAN_OR_REQUIREMENTS}` — task text, plan section, or approved requirements
- `{BASE_SHA}` — start of the diff range
- `{HEAD_SHA}` — end of the diff range
- `{DESCRIPTION}` — brief summary of the change set

### Recommended Inputs
- plan file path
- spec file path
- task number / task heading
- whether this is an intermediate task review or final implementation review

## How to Request

### 1. Get git SHAs
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main / last reviewed commit
HEAD_SHA=$(git rev-parse HEAD)
```

### 2. Dispatch code-reviewer subagent

Use Task tool with `superpower-planning:code-reviewer` and fill the template at `skills/requesting-review/code-reviewer.md`.

### 3. Minimum Dispatch Shape

```text
WHAT_WAS_IMPLEMENTED: [brief statement]
PLAN_OR_REQUIREMENTS: [exact task text / plan section / requirements]
BASE_SHA: [sha]
HEAD_SHA: [sha]
DESCRIPTION: [brief summary]
```

### 4. Preferred Dispatch Shape

```text
WHAT_WAS_IMPLEMENTED: Task 3 - verification and repair functions
PLAN_OR_REQUIREMENTS: Task 3 from docs/plans/deployment-plan.md
PLAN_PATH: docs/plans/deployment-plan.md
SPEC_PATH: docs/plans/deployment-design.md
BASE_SHA: a7981ec
HEAD_SHA: 3df7661
DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types
REVIEW_MODE: intermediate task review
FOCUS: plan alignment, tests, error handling
```

## How to Interpret Feedback

### Critical
- Must fix before proceeding or merging
- Includes broken functionality, data loss risk, security issues, severe requirement misses

### Important
- Should fix before proceeding when practical
- Includes architecture gaps, weak tests, bad error handling, missing requirement edges

### Minor
- Nice to have
- Includes readability, polish, documentation cleanup, non-blocking refactors

## Acting on Feedback

1. Fix **Critical** issues immediately
2. Fix **Important** issues before proceeding unless you have a strong technical reason not to
3. Note **Minor** issues for later if time-sensitive
4. If reviewer is wrong, push back with reasoning and evidence
5. If reviewer identifies plan drift, either:
   - fix implementation to match the plan, or
   - explicitly update the plan/spec if the deviation is justified

## After Review Results

- **Append review outcome** (approved / changes-requested, issues fixed, issues deferred) to `.planning/progress.md` session log
- **Append technical insights** (patterns learned, architectural feedback worth remembering) to `.planning/findings.md` under `## Code Review Findings`
- If the review surfaced plan/spec drift, record that explicitly in `.planning/findings.md`

## Example

```text
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch superpower-planning:code-reviewer subagent]
  WHAT_WAS_IMPLEMENTED: Verification and repair functions for conversation index
  PLAN_OR_REQUIREMENTS: Task 2 from docs/plans/deployment-plan.md
  PLAN_PATH: docs/plans/deployment-plan.md
  SPEC_PATH: docs/plans/deployment-design.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types
  REVIEW_MODE: intermediate task review
  FOCUS: plan alignment, tests, error handling

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed with fixes

You: [Fix progress indicators]
[Continue to Task 3]
```

## Integration with Workflows

**Subagent-Driven:**
- Review after each task
- Use review output as a hard quality gate before marking task complete

**Executing Plans:**
- Review after each batch or major milestone
- Apply fixes before continuing

**Ad-Hoc Development:**
- Review before merge
- Review when stuck

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues casually
- Ask for review without giving plan/requirements context
- Treat code review as style-only; plan alignment matters too

**If reviewer seems wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification
- Update plan/spec if the implementation is intentionally better than the original plan

See template at: `skills/requesting-review/code-reviewer.md`
