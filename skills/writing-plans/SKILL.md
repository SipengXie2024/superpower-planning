---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** This should be run in a dedicated worktree (created by brainstorming skill).

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpower-planning:executing-plans to implement this plan task-by-task.
> Planning dir: .planning/

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

**Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

**Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

**Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```

> **Note:** Log unexpected discoveries to `.planning/findings.md`
````

## Auto-Create `.planning/` Directory

When writing a plan, **automatically create** the `.planning/` directory structure if it does not already exist:

```
.planning/
  progress.md       # Task Status Dashboard + session log
  findings.md       # Unexpected discoveries and notes
```

> **Note:** The plan in `docs/plans/` is the single source of truth for plan content. Execution status is tracked via the Task Status Dashboard in `progress.md`.

Initialize `.planning/progress.md`:
```markdown
# Progress

## Task Status Dashboard
<!-- Quick-scan execution status. Update after each task/batch completes. -->
| Task | Status | Agent/Batch | Key Outcome |
|------|--------|-------------|-------------|

## Session Log

## Test Results
| Test | Result | Timestamp |
|------|--------|-----------|

## Verification Evidence
| Claim | Command | Result | Timestamp |
|-------|---------|--------|-----------|
```

Initialize `.planning/findings.md` (if not already present):
```markdown
# Findings
> Discoveries, surprises, and notes from design exploration and implementation.
```

## Parallelism Groups

**Every plan MUST include a parallelism analysis** after the task list. Identify which tasks can run in parallel (no shared files, no sequential dependencies) and group them:

````markdown
### Parallelism Groups

- **Group A** (parallel): Task 1, Task 2, Task 3
- **Group B** (after Group A): Task 4, Task 5
- **Group C** (after Group B): Task 6

**Parallelism score:** 3/6 tasks can run in parallel in the first group
````

**Tips for maximizing parallelism:**
- Split work along file boundaries (each task edits different files)
- Split work along module boundaries (each task touches a different subsystem)
- Extract shared setup into an early serial task, then parallelize the rest
- If a task can be split into independent subtasks, split it

The parallelism score helps the user choose the right execution mode.

## Remember
- Exact file paths always
- Complete code in plan (not "add validation")
- Exact commands with expected output
- Reference relevant skills with @ syntax
- DRY, YAGNI, TDD, frequent commits
- Each task reminds: "Log unexpected discoveries to `.planning/findings.md`"
- Always include parallelism groups analysis

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/plans/<filename>.md`. Three execution options:**

**1. Subagent-Driven (this session, sequential)** — Fresh subagent per task, two-stage review, serial execution. Best for light tasks with serial dependencies.

**2. Team-Driven (this session, parallel)** — Agent Team with parallel implementers + dedicated reviewer. Best when tasks are heavy or parallelizable. Also prevents context-limit crashes on complex tasks.

**3. Parallel Session (separate session)** — Open new session with executing-plans, batch execution with human checkpoints.

**Which approach?"**

**Recommendation logic:**
- High parallelism score + heavy tasks → recommend Team-Driven
- Light serial tasks → recommend Subagent-Driven
- User wants manual checkpoints → recommend Parallel Session

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpower-planning:subagent-driven
- Stay in this session
- Fresh subagent per task + code review

**If Team-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpower-planning:team-driven
- Stay in this session
- Agent Team with parallel implementers + dedicated reviewer

**If Parallel Session chosen:**
- Guide them to open new session in worktree
- **REQUIRED SUB-SKILL:** New session uses superpower-planning:executing-plans
