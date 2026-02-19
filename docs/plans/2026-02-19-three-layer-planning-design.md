# Three-Layer Planning Architecture Design

> **For Claude:** REQUIRED SUB-SKILL: Use superpower-planning:executing-plans to implement this plan task-by-task.
> Planning dir: .planning/

**Goal:** Replace the current three-way status tracking (task_plan.md, progress.md Dashboard, Task API) with a clean three-layer architecture where each layer has a single responsibility.

**Architecture:** Remove task_plan.md entirely. Plans always live in docs/plans/ (immutable after writing). Task API handles session-scoped orchestration. progress.md Dashboard is the persistent catch-up entry point with batch sync from Task API at phase boundaries.

**Tech Stack:** Shell scripts (hooks), Markdown (skills/templates)

---

## Context

### Problem

The current system has three overlapping status trackers:

| System | Tracks | Persistence |
|--------|--------|-------------|
| `task_plan.md` Phase Status | Phase completion | Cross-session |
| `progress.md` Task Status Dashboard | Task completion | Cross-session |
| Task API (TaskCreate/TaskUpdate) | Task status + deps + ownership | Session only |

This creates:
- Status drift between systems
- Contradictory instructions in skills (planning-foundation says "don't use TaskCreate", but executing-plans and subagent-driven use it)
- Cognitive burden on agents (which system to update?)

### Solution: Three-Layer Architecture

```
Plan Layer       → docs/plans/*.md     (persistent, immutable, WHAT to do)
Orchestration    → Task API            (session-scoped, WHO does WHAT NOW)
Memory Layer     → progress.md + findings.md  (persistent, WHAT HAPPENED)
```

**Key rules:**
- task_plan.md is eliminated — no more ad-hoc vs formal distinction
- All plans go through docs/plans/
- Status single-direction sync: Task API → progress.md Dashboard (batch, at phase boundaries)
- Session recovery: progress.md Dashboard → recreate Task API tasks

## Detailed Design

### 1. Plan Layer

- Location: `docs/plans/YYYY-MM-DD-<feature>.md`
- Content: goals, architecture, phases/tasks, code snippets, test plans
- Immutable after writing — never updated with status
- Source of truth for "what to build"

### 2. Orchestration Layer (Task API)

- Session-scoped — created fresh each session from plan + progress.md
- On session start: read progress.md Dashboard → create Task API tasks for incomplete items
- During session: Task API drives dispatch, dependencies, ownership
- Native structured fields: status, owner, blocks/blockedBy, metadata

### 3. Memory Layer

**progress.md** — persistent catch-up entry point:
```markdown
## Task Status Dashboard
> Source: docs/plans/YYYY-MM-DD-feature.md

| Task | Status | Agent/Batch | Key Outcome |
|------|--------|-------------|-------------|
| Task 1: ... | complete | agent-1 | Implemented X |
| Task 2: ... | in_progress | agent-2 | WIP |
| Task 3: ... | pending | - | - |
```

**findings.md** — knowledge persistence (unchanged)

### 4. Sync Mechanism

- **Batch sync** at phase/task completion: when a task completes in Task API → update progress.md Dashboard row
- **PostToolUse hook** reminds agent to sync progress.md when files are modified
- **Stop hook** checks progress.md Dashboard for completion status

### 5. Hook Redesign

| Hook | Current | New |
|------|---------|-----|
| SessionStart | Check `task_plan.md` exists | Check `.planning/` directory exists; recover from `progress.md` |
| PreToolUse | `cat .planning/task_plan.md \| head -30` | `cat .planning/progress.md \| head -30` |
| PostToolUse | Remind update `task_plan.md` | Remind update `progress.md` Dashboard |
| Stop | Check `task_plan.md` Phase status | Check `progress.md` Dashboard status |

## Files Changed

### Delete
- `skills/planning-foundation/templates/task_plan.md`

### Update
- `hooks/hooks.json` — all references task_plan.md → progress.md
- `hooks/session-start.sh` — detect `.planning/` dir instead of `task_plan.md`
- `scripts/check-complete.sh` — parse Dashboard table format
- `scripts/init-planning-dir.sh` — remove task_plan.md creation
- `skills/planning-foundation/SKILL.md` — remove all task_plan.md references, update architecture
- `skills/main/SKILL.md` — update session recovery and init reminder
- `skills/writing-plans/SKILL.md` — remove task_plan.md note
- `skills/executing-plans/SKILL.md` — reference progress.md
- `skills/brainstorming/SKILL.md` — remove task_plan.md from .planning/ init
- `skills/debugging/SKILL.md` — update if references task_plan.md
- `skills/tdd/SKILL.md` — update if references task_plan.md
- `skills/verification/SKILL.md` — update if references task_plan.md
- `skills/subagent-driven/SKILL.md` — update task tracking references
- `skills/parallel-agents/SKILL.md` — update if references task_plan.md
- `commands/catchup.md` — update recovery flow
- `README.md` — update if references task_plan.md
