# Spec Review Dispatch Template

Use this when dispatching a reviewer for a newly written spec.

## Required Inputs
- `SPEC_PATH` — path to the written spec document
- `SPEC_SUMMARY` — 2-5 sentence summary of what the spec is trying to build
- `REVIEW_SCOPE` — whether this is first-pass review or re-review after fixes
- `AGENT_PLANNING_DIR` — reviewer planning directory under `.planning/agents/`

## Preferred Inputs
- key constraints
- open questions already resolved with the user
- relevant archive files consulted

## Standard Dispatch Shape

```text
You are reviewing a written spec before implementation planning begins.

SPEC_PATH: .planning/design.md
SPEC_SUMMARY: [brief summary]
REVIEW_SCOPE: first-pass review
AGENT_PLANNING_DIR: .planning/agents/spec-reviewer/

Use the template at `skills/subagent-driven/spec-reviewer-prompt.md`.
Focus on:
- missing requirements
- extra/unneeded scope
- misunderstood requirements
- decomposition problems
- design clarity before planning
```

## Expected Outcome

Reviewer should return one of:
- `Spec compliant`
- `Issues found: ...`

If issues are found, fix the spec and re-dispatch. Maximum 3 rounds before surfacing to the user.
