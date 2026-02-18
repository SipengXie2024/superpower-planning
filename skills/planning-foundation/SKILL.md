---
name: planning-foundation
description: Implements persistent file-based planning for complex tasks. Creates .planning/ directory with task_plan.md, findings.md, and progress.md. Use when starting complex multi-step tasks, research projects, or any task requiring >5 tool calls. Foundation layer inherited by all other skills.
user-invocable: true
hooks:
  PreToolUse:
    - matcher: "Write|Edit|Bash|Read|Glob|Grep|WebFetch|WebSearch"
      hooks:
        - type: command
          command: "cat .planning/task_plan.md 2>/dev/null | head -30 || true"
  PostToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "if [ -f .planning/task_plan.md ]; then echo '[superpower-planning] File updated. If this completes a phase, update .planning/task_plan.md status.'; fi"
  Stop:
    - hooks:
        - type: command
          command: |
            SCRIPT_DIR="${CLAUDE_PLUGIN_ROOT:-$(dirname "$0")/..}/scripts"
            if [ -f .planning/task_plan.md ]; then
              sh "$SCRIPT_DIR/check-complete.sh"
            fi
---

# Planning Foundation

Work like Manus: Use persistent markdown files as your "working memory on disk."

Every workflow skill in superpower-planning inherits this foundation. `.planning/` is the "RAM on disk" for the current work session.

## Planning Directory Convention

```
.planning/                     # gitignored, ephemeral working state
├── task_plan.md               # orchestrator's plan + phase tracking
├── findings.md                # aggregated findings
├── progress.md                # overall progress log
└── agents/                    # per-subagent working dirs
    ├── implementer-task-1/
    │   ├── findings.md        # this agent's discoveries
    │   └── progress.md        # this agent's action log
    └── ...
```

Permanent design docs go in `docs/plans/`. `.planning/` is ephemeral session state.

## Quick Start

Before ANY complex task:

1. **Create `.planning/` directory** with init script or manually
2. **Create `task_plan.md`** — Use [templates/task_plan.md](templates/task_plan.md) as reference
3. **Create `findings.md`** — Use [templates/findings.md](templates/findings.md) as reference
4. **Create `progress.md`** — Use [templates/progress.md](templates/progress.md) as reference
5. **Re-read plan before decisions** — Refreshes goals in attention window
6. **Update after each phase** — Mark complete, log errors

## The Core Pattern

```
Context Window = RAM (volatile, limited)
Filesystem = Disk (persistent, unlimited)

-> Anything important gets written to disk.
```

## File Purposes

| File | Purpose | When to Update |
|------|---------|----------------|
| `task_plan.md` | Phases, progress, decisions | After each phase |
| `findings.md` | Research, discoveries | After ANY discovery |
| `progress.md` | Session log, test results | Throughout session |

## Critical Rules

### 1. Create Plan First
Never start a complex task without `.planning/task_plan.md`. Non-negotiable.

### 2. The 2-Action Rule
> "After every 2 view/browser/search operations, IMMEDIATELY save key findings to text files."

This prevents visual/multimodal information from being lost.

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
    next_action != same_action
```
Track what you tried. Mutate the approach.

## The 3-Strike Error Protocol

```
ATTEMPT 1: Diagnose & Fix
  -> Read error carefully
  -> Identify root cause
  -> Apply targeted fix

ATTEMPT 2: Alternative Approach
  -> Same error? Try different method
  -> Different tool? Different library?
  -> NEVER repeat exact same failing action

ATTEMPT 3: Broader Rethink
  -> Question assumptions
  -> Search for solutions
  -> Consider updating the plan

AFTER 3 FAILURES: Escalate to User
  -> Explain what you tried
  -> Share the specific error
  -> Ask for guidance
```

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
| Where am I? | Current phase in task_plan.md |
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
- Subagent orchestration

**Skip for:**
- Simple questions
- Single-file edits
- Quick lookups

## Per-Agent Planning Directories

When dispatching subagents, each gets its own planning dir:

```
.planning/agents/{role}-task-{N}/
├── findings.md    # agent's discoveries
└── progress.md    # agent's action log
```

The orchestrator aggregates agent findings into top-level `.planning/findings.md` and `.planning/progress.md` after each task completes.

## Templates

- [templates/task_plan.md](templates/task_plan.md) — Phase tracking
- [templates/findings.md](templates/findings.md) — Research storage
- [templates/progress.md](templates/progress.md) — Session logging
- [templates/agent-context.md](templates/agent-context.md) — Planning rules to inject into subagent prompts

## Scripts

- `scripts/init-planning-dir.sh` — Initialize `.planning/` directory with all files
- `scripts/check-complete.sh` — Verify all phases complete
- `scripts/session-catchup.py` — Recover context from previous session

## Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| Use TodoWrite for persistence | Create .planning/task_plan.md file |
| State goals once and forget | Re-read plan before decisions |
| Hide errors and retry silently | Log errors to plan file |
| Stuff everything in context | Store large content in files |
| Start executing immediately | Create plan file FIRST |
| Repeat failed actions | Track attempts, mutate approach |
| Let subagent findings disappear | Aggregate into top-level findings.md |
