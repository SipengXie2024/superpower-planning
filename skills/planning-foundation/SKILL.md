---
name: planning-foundation
description: Use when starting complex multi-step tasks, research projects, or anything needing >5 tool calls. Provides the persistent .planning/ directory used as on-disk working memory across sessions.
---

# Planning Foundation

Work like Manus: Use persistent markdown files as your "working memory on disk."

Every planning skill in superpower-planning inherits this foundation. `.planning/` is the "RAM on disk" for the current work session.

## Planning Directory Convention

```
.planning/                     # gitignored, ephemeral working state
├── design.md                  # design spec (created by brainstorming)
├── plan.md                    # implementation plan (created by writing-plans)
├── findings.md                # aggregated findings
├── progress.md                # Task Status Dashboard + session log
├── agents/                    # created on demand by delegated roles
│   ├── implementer/           # one dir per role, reused across tasks
│   │   ├── findings.md        # this agent's discoveries (appended across tasks)
│   │   └── progress.md        # this agent's action log (appended across tasks)
│   ├── spec-reviewer/
│   └── ...
├── stash/                     # paused projects (directory per entry)
│   └── YYYY-MM-DD-<name>/
│       ├── design.md, plan.md, findings.md, progress.md
│       └── agents/
└── archive/                   # completed projects (directory per entry)
    └── YYYY-MM-DD-<name>/
        ├── design.md, plan.md, findings.md, progress.md
        └── summary.md
```

All project documents live in `.planning/`. The `agents/` directory is NOT created at init — delegated roles create their own subdirectory when dispatched.

Lifecycle directories:
- `.planning/stash/` — paused projects (each entry is a subdirectory with all active files)
- `.planning/archive/` — completed projects (each entry is a subdirectory with all active files + summary.md)

## Quick Start

Before ANY complex task:

1. **Create `.planning/` directory** — run `${CLAUDE_PLUGIN_ROOT}/scripts/init-planning-dir.sh`, or `mkdir -p .planning` if the script is unavailable
2. **Create `progress.md`** — Use [templates/progress.md](templates/progress.md) (includes Task Status Dashboard)
3. **Create `findings.md`** — Use [templates/findings.md](templates/findings.md) as reference
4. **Re-read plan before decisions** — Refreshes goals in attention window
5. **Update after each phase** — Mark complete, log errors

## The Core Pattern

```
Context Window = RAM (volatile, limited)
Filesystem = Disk (persistent, unlimited)

-> Anything important gets written to disk.
```

## File Purposes

| File | Purpose | What Goes Here | When to Update |
|------|---------|----------------|----------------|
| `design.md` | Design spec: architecture and requirements | Created by brainstorming skill. Architecture, components, data flow, error handling, testing strategy | After design approval or spec review |
| `plan.md` | Implementation plan: bite-sized tasks | Created by writing-plans skill. File structure, task steps, parallelism groups, verification commands | After plan approval or plan review |
| `findings.md` | Knowledge base: discoveries, decisions, surprises | Code patterns, architecture insights, technical decisions + rationale, rejected alternatives, unexpected behavior, edge cases, dependency constraints, debugging root causes | After ANY discovery or decision |
| `progress.md` | Operations log: status, actions, evidence | Task Status Dashboard rows, phase status changes, actions taken (files modified), error log + retries, test results, verification evidence, batch/phase summaries | After ANY status change, action, or error |

## Critical Rules

### 1. Create Planning Dir First
Never start a complex task without `.planning/`. All project documents (design, plan, findings, progress) live in `.planning/`. Execution status is tracked via the Task Status Dashboard in `progress.md`.

### 2. The 2-Action Dispatch Rule
> "After every 2 read/search/explore operations, IMMEDIATELY save to the appropriate file by content type."

**Dispatch by content type:**

| Content type | Target file | Examples |
|---|---|---|
| Discoveries, decisions, surprises | `findings.md` | Code patterns, constraints, approach chosen and why, edge cases |
| Status, actions, errors, results | `progress.md` | Task marked complete, files modified, error + retry, test pass/fail |

This prevents both knowledge AND progress from being lost.

### 3. Read Before Decide
Before major decisions, read the plan file. This keeps goals in your attention window.

### 4. Update After Act
After completing any phase:
- Mark phase status: `in_progress` -> `complete`
- Log any errors encountered
- Note files created/modified

### 5. Log ALL Errors
Every error goes in the plan file. This builds knowledge and prevents repetition.

```markdown
## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
| FileNotFoundError | 1 | Created default config |
| API timeout | 2 | Added retry logic |
```

### 6. Never Repeat Failures
```
if action_failed:
    log what you tried and observed
    escalate to user for direction
```
Do NOT independently try alternative approaches. Log the failure and follow the Error Escalation Protocol.

## Error Escalation Protocol

```
ATTEMPT 1: Diagnose & Fix
  -> Read error carefully
  -> Identify root cause
  -> Apply targeted fix

ATTEMPT 1 FAILED: Escalate to User
  -> Show: what failed, what you tried, what you observed
  -> Ask: is this a bug? a plan gap? an environment issue?
  -> Align on direction BEFORE proceeding

AFTER ALIGNMENT (based on user's judgment):
  -> Bug           → use systematic debugging skill
  -> Plan gap      → update plan with user
  -> Environment   → fix environment
  -> Architecture  → broader rethink with user
```

**Why escalate early:** The plan was carefully designed. Self-directed alternative approaches bypass plan intent and create workarounds. Always align with the user before changing direction.

## Read vs Write Decision Matrix

| Situation | Action | Reason |
|-----------|--------|--------|
| Just wrote a file | DON'T read | Content still in context |
| Viewed image/PDF | Write findings NOW | Multimodal -> text before lost |
| Browser returned data | Write to file | Screenshots don't persist |
| Starting new phase | Read plan/findings | Re-orient if context stale |
| Error occurred | Read relevant file | Need current state to fix |
| Resuming after gap | Read all planning files | Recover state |

## The 5-Question Reboot Test

If you can answer these, your context management is solid:

| Question | Answer Source |
|----------|---------------|
| Where am I? | Task Status Dashboard in progress.md |
| Where am I going? | Remaining phases |
| What's the goal? | Goal statement in plan |
| What have I learned? | findings.md |
| What have I done? | progress.md |

## When to Use This Pattern

**Use for:**
- Multi-step tasks (3+ steps)
- Research tasks
- Building/creating projects
- Tasks spanning many tool calls
- Delegated execution or dynamic-workflow orchestration

**Skip for:**
- Simple questions
- Single-file edits
- Quick lookups

## Per-Agent Planning Directories

When dispatching delegated roles such as Codex implementers/reviewers, each gets its own planning dir:

```
.planning/agents/{role}/
├── findings.md    # agent's discoveries (appended across tasks)
└── progress.md    # agent's action log (appended across tasks)
```

**Do NOT create per-task directories** like `implementer-task-1/`. One directory per role, updated continuously.

The orchestrator aggregates delegated-role findings into top-level `.planning/findings.md` and `.planning/progress.md` after each task completes.

## Templates

- [templates/findings.md](templates/findings.md) — Research storage
- [templates/progress.md](templates/progress.md) — Session logging
- [templates/agent-context.md](templates/agent-context.md) — Planning rules to inject into delegated-role prompts

## Scripts

**Planning lifecycle:**
- `${CLAUDE_PLUGIN_ROOT}/scripts/init-planning-dir.sh` — Initialize `.planning/` with findings.md and progress.md
- `${CLAUDE_PLUGIN_ROOT}/scripts/planning-reset.sh` — Reset active state, preserve archive/ and stash/
- `${CLAUDE_PLUGIN_ROOT}/scripts/check-planning-state.sh` — Check state: missing | empty | active | complete
- `${CLAUDE_PLUGIN_ROOT}/scripts/check-complete.sh` — Verify all tasks complete
- `${CLAUDE_PLUGIN_ROOT}/scripts/snapshot-save.sh` — Copy active project files to a target directory (shared by stash/archive)

**Stash/archive:**
- `${CLAUDE_PLUGIN_ROOT}/scripts/stash-list.sh` — List available stashes (directory + legacy format)
- `${CLAUDE_PLUGIN_ROOT}/scripts/stash-restore.sh` — Restore stash to active .planning/ state
- `${CLAUDE_PLUGIN_ROOT}/scripts/archive-search.sh` — Search archives by keyword
- `${CLAUDE_PLUGIN_ROOT}/scripts/unique-filename.sh` — Generate unique dated filename/dirname

**Agent orchestration:**
- `${CLAUDE_PLUGIN_ROOT}/scripts/aggregate-agent-findings.sh` — Merge delegated-role "Critical for Orchestrator" items into top-level files

**Project detection:**
- `${CLAUDE_PLUGIN_ROOT}/scripts/detect-base-branch.sh` — Detect main/master/develop
- `${CLAUDE_PLUGIN_ROOT}/scripts/detect-test-command.sh` — Detect project test command
- `${CLAUDE_PLUGIN_ROOT}/scripts/detect-project-setup.sh` — Detect and run project setup

**Other:**
- `${CLAUDE_PLUGIN_ROOT}/scripts/release.sh` — Version bump, tag, GitHub Release
- `${CLAUDE_PLUGIN_ROOT}/scripts/session-catchup.py` — Recover context from previous session (manual utility, requires Python)

## Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| Use TaskCreate/TaskUpdate as cross-session persistence | Use .planning/progress.md Task Status Dashboard for persistent status. Task API is for session-scoped orchestration only. |
| State goals once and forget | Re-read plan before decisions |
| Hide errors and retry silently | Log errors to plan file |
| Stuff everything in context | Store large content in files |
| Start executing immediately | Create plan file FIRST |
| Repeat failed actions or independently try alternatives | Log failure, escalate to user for direction |
| Let delegated findings disappear | Aggregate into top-level findings.md |
