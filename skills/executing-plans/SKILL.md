---
name: executing-plans
description: Use when executing a written implementation plan in a separate or manual session with batch checkpoints and .planning updates.
---

# Executing Plans

## Overview

Load a written plan, review it critically, execute tasks in manageable batches, and keep `.planning/` current. This is the manual fallback path when Claude Code dynamic workflows are unavailable or the user wants explicit checkpoints.

**Core principle:** Follow the plan exactly, verify each batch with evidence, and stop at checkpoints rather than silently drifting.

**Announce at start:** "I'm using the executing-plans skill to implement this plan in batches."

## The Process

### Step 1: Load and Review Plan

1. Read `.planning/plan.md`
2. Read `.planning/design.md` and `.planning/findings.md` if they exist
3. Review critically for missing files, ambiguous requirements, unsafe branch state, and unclear verification commands
4. If concerns block execution, raise them with the user before starting
5. If no blocking concerns, create session-scoped tasks if the task tool is available, and proceed

### Step 2: Execute Batch

Default batch size: first 3 plan tasks, or fewer if tasks are large or tightly coupled.

For each task:

1. Mark it `in_progress` in `.planning/progress.md`
2. Follow the plan steps exactly
3. Run the verification command specified by the plan
4. Record unexpected discoveries, decisions, or technical insights in `.planning/findings.md`
5. Record verification output and status in `.planning/progress.md`
6. Mark the task `complete` only when the task's checks have actually passed

### Step 3: Batch Checkpoint

When a batch completes:

- Show what was implemented
- Show verification commands and key output
- Update `.planning/progress.md` Task Status Dashboard and session log
- Update `.planning/findings.md` with durable discoveries
- Ask the user whether to continue, revise the plan, request a review, or stop

If the user wants a review, invoke `superpower-planning:requesting-review` with a concrete diff range and the relevant plan task text.

### Step 4: Continue

After the checkpoint:

- Execute the next batch
- Repeat until all tasks complete
- If the user changes direction, update the plan before continuing
- If the approach needs broad cross-checking, recommend switching to a Claude Code dynamic workflow

### Step 5: Complete Development

After all tasks complete:

1. Re-read `.planning/plan.md`
2. Check every task row in `.planning/progress.md`
3. Run the final verification command(s) specified by the plan
4. Record final evidence in `.planning/progress.md`
5. Present a concise completion summary, remaining risks, and recommended next action (archive, PR, or keep branch)

Do not perform branch merge, PR creation, or destructive cleanup unless the user explicitly asks in the current session.

## When to Stop and Ask for Help

STOP executing immediately when:

- A blocker appears mid-batch
- A verification command fails and the root cause is not obvious
- The plan has critical gaps preventing the next task
- You do not understand an instruction
- The implementation would require changing the approved design

Ask for clarification rather than guessing.

## When to Revisit Earlier Steps

Return to plan review when:

- The user updates the plan
- A batch reveals a fundamental approach issue
- The task list no longer matches the codebase
- Verification evidence contradicts an assumption in the plan

## Remember

- Review the plan critically before editing
- Follow plan steps exactly
- Do not skip verification commands
- After each task, record discoveries to `.planning/findings.md`
- After each batch, update both `.planning/progress.md` and `.planning/findings.md`
- Before final report, read `.planning/progress.md` for the full status
- Never start implementation on `main`/`master` without explicit user consent

## Integration

**Related skills:**

- `superpower-planning:git-worktrees` — recommended when starting from a shared or risky branch
- `superpower-planning:writing-plans` — creates the plan this skill executes
- `superpower-planning:requesting-review` — optional checkpoint or pre-merge review
- `superpower-planning:receiving-review` — process review feedback
- `superpower-planning:archiving` — archive the completed planning state when the work is done
