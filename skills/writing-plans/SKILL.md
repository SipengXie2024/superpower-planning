---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** Optionally runs in a dedicated worktree (user chooses during brainstorming).

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`

## Scope Check

If the spec covers multiple independent subsystems, stop and suggest splitting it into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## File Structure First

Before defining tasks, map out which files will be created or modified and what each one is responsible for.

- Design units with clear boundaries and well-defined interfaces
- Each file should have one clear responsibility
- Prefer smaller, focused files over large files that do too much
- Files that change together should live together
- Split by responsibility, not by technical layer
- In existing codebases, follow established patterns, but if a file you are already touching has become unwieldy, a targeted split is reasonable

This file-structure pass should happen before task decomposition.

## Historical Archive Check

Before writing the plan, check for relevant historical archives:

1. Glob `.planning/archive/*.md`
2. If archives exist, read the first 10 lines of each (title + summary)
3. If any are relevant to the current task, read fully and incorporate relevant lessons into the plan
4. If none are relevant or no archives exist, skip silently

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

> **For Claude:** Execute this plan using the skill chosen during Execution Handoff (see end of plan).
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

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```

> **Note:** Log unexpected discoveries, technical decisions, and implementation insights to `.planning/findings.md` after each task.
````

## Auto-Create `.planning/` Directory

When writing a plan, **automatically create** the `.planning/` directory if it does not already exist by running:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/init-planning-dir.sh
```

This creates `progress.md` and `findings.md`. The canonical template is at `planning-foundation/templates/progress.md`. Subagent planning directories (`agents/`) are created by each subagent when needed.

> **Note:** The plan in `docs/plans/` is the single source of truth for plan content. Execution status is tracked via the Task Status Dashboard in `progress.md`.

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

## Plan Review Loop

After writing the complete plan:

1. Dispatch a single plan reviewer subagent using `skills/writing-plans/plan-reviewer-prompt.md`
2. Use a low-freedom dispatch shape with: spec path, plan path, review scope, and planning dir
3. If issues are found: fix them, then re-dispatch reviewer for the whole plan
4. If approved: proceed to execution handoff
5. Maximum 3 review iterations; if still unresolved, surface to the user

The reviewer should focus on:
- plan alignment with the approved spec
- file decomposition quality
- task granularity
- missing verification steps
- over-scoping or under-scoping

## Remember
- Exact file paths always
- Complete code in plan (not "add validation")
- Exact commands with expected output
- Reference relevant skills with @ syntax
- DRY, YAGNI, TDD, frequent commits
- Each task reminds: "Log discoveries, decisions, and insights to `.planning/findings.md`"
- Always include parallelism groups analysis
- Lock file boundaries and responsibilities before task decomposition

## Execution Handoff

After saving the plan and passing the plan review loop, you MUST present exactly these three options using `AskUserQuestion`. Do NOT omit, replace, or invent options. All three MUST always be shown regardless of your analysis.

**Use `AskUserQuestion` with these exact options:**

**1. Subagent-Driven (this session, sequential)** — Fresh subagent per task, two-stage review, serial execution. Best for light tasks with serial dependencies.

**2. Team-Driven (this session, parallel)** — Agent Team with parallel implementers + dedicated reviewer. Best when tasks are heavy or parallelizable. Also prevents context-limit crashes on complex tasks.

**3. Parallel Session (separate session)** — Open new session with executing-plans, batch execution with human checkpoints.

Include your recommendation in the question text based on the logic below, but never remove options.

**Recommendation logic (add "(Recommended)" to the best option's label):**
- High parallelism score + heavy tasks → recommend Team-Driven
- Light serial tasks → recommend Subagent-Driven
- User wants manual checkpoints → recommend Parallel Session

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use `superpower-planning:subagent-driven`
- Stay in this session
- Fresh subagent per task + code review

**If Team-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use `superpower-planning:team-driven`
- Stay in this session
- Agent Team with parallel implementers + dedicated reviewer

**If Parallel Session chosen:**
- Guide them to open new session in worktree
- **REQUIRED SUB-SKILL:** New session uses `superpower-planning:executing-plans`
