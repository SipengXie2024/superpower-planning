---
name: requesting-review
description: Use when completing plan-driven tasks, implementing major features, or before merging to verify work meets requirements.
---

# Requesting Code Review

Dispatch `superpower-planning:code-reviewer` before defects or plan drift compound.

**Core principle:** Review early, review often.

This skill defines when review is required and what context must be sent. The authoritative detailed reviewer contract lives in `skills/requesting-review/code-reviewer.md`. Do not maintain competing detailed review checklists elsewhere.

## When to Request Review

**Mandatory:**
- After each major task in Codex-driven or manual plan execution when review is part of the checkpoint
- After completing a major project step
- Before merge to main
- When implementation may have drifted from the approved plan

**Optional but valuable:**
- When stuck and a fresh technical read would help
- Before refactoring
- After fixing a complex bug
- After architecture-affecting changes

## What Every Review Must Cover

Every review request must ask for:
1. **Plan/spec alignment** — compare the implementation against the approved task, plan, or requirements
2. **Code quality** — error handling, maintainability, naming, structure, and tests
3. **Architecture** — boundaries, coupling, integration, and unnecessary complexity
4. **Documentation and standards** — only where relevant
5. **Severity semantics** — Critical / Important / Minor

## Required Review Context

The review request must be diff-bounded and include:
- `{WHAT_WAS_IMPLEMENTED}`
- `{PLAN_OR_REQUIREMENTS}`
- `{BASE_SHA}`
- `{HEAD_SHA}`
- `{DESCRIPTION}`

When a plan or spec file exists, also provide:
- `PLAN_PATH`
- `SPEC_PATH`
- exact task number or task heading
- `REVIEW_MODE`
- `FOCUS` when a specific check deserves extra attention

Local policy: prefer exact plan/spec file paths and task text over paraphrased summaries. Do not weaken review context to a generic request.

## How to Request

### 1. Get the review range
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main / last reviewed commit
HEAD_SHA=$(git rev-parse HEAD)
```

### 2. Fill the single source-of-truth template

Use `skills/requesting-review/code-reviewer.md` as the request body and replace its placeholders with the current change context.

### 3. Dispatch the reviewer

Dispatch `superpower-planning:code-reviewer` with the filled template. If the environment routes through `agents/code-reviewer.md`, treat that file as a compatibility entrypoint only; the detailed review contract still comes from `skills/requesting-review/code-reviewer.md`.

### Canonical Request Shape

```text
WHAT_WAS_IMPLEMENTED: Task 3 - verification and repair functions
PLAN_OR_REQUIREMENTS: Task 3 from .planning/plan.md
PLAN_PATH: .planning/plan.md
SPEC_PATH: .planning/design.md
BASE_SHA: a7981ec
HEAD_SHA: 3df7661
DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types
REVIEW_MODE: intermediate task review
FOCUS: plan alignment, tests, error handling
```

## How to Interpret Feedback

### Critical
- Must fix before proceeding or merging
- Includes broken functionality, data loss risk, security issues, or severe requirement misses

### Important
- Should fix before proceeding when practical
- Includes architecture gaps, weak tests, bad error handling, or missing requirement edges

### Minor
- Nice to have
- Includes readability, polish, documentation cleanup, or non-blocking refactors

## Acting on Feedback

1. Fix **Critical** issues immediately.
2. Fix **Important** issues before proceeding unless there is strong technical evidence not to.
3. Note **Minor** issues for later if time-sensitive.
4. Push back when the reviewer is wrong; use code, tests, or requirements as evidence.
5. If review finds plan/spec drift, either:
   - fix the implementation to match the plan, or
   - explicitly update the plan/spec if the deviation is justified

## After Review Results

- Append review outcome (approved / changes-requested, issues fixed, issues deferred) to `.planning/progress.md`
- Append durable technical insights to `.planning/findings.md`
- If the review surfaced plan/spec drift, record that explicitly

## Integration with Workflows

**Codex-Driven:**
- Reviewer prompt templates use this skill's rubric for plan/spec-aligned review
- Use review output as a hard gate before marking a task complete

**Executing Plans / Ad-Hoc Development:**
- Review after each major milestone or before merge
- Apply required fixes before continuing

**Claude Code Dynamic Workflows:**
- Use this review contract as the rubric if a workflow needs a single final code review
- For broad fan-out or adversarial review, prefer the native workflow's cross-checking rather than invoking this skill repeatedly

## Red Flags

**Never:**
- Skip review because "it’s simple"
- Ignore Critical issues
- Proceed casually with unfixed Important issues
- Request review without plan/requirements context
- Treat review as style-only; plan alignment matters
