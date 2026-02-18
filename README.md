# superpower-planning

A unified Claude Code plugin that combines persistent file-based planning with structured execution workflows. Every workflow inherits file-based working memory (`.planning/` directory), so context persists across sessions.

## Installation

```bash
/plugin marketplace add SipengXie2024/superpower-planning
/plugin install superpower-planning@superpower-planning
```

Then restart Claude Code.

## What It Does

This plugin gives Claude Code a disciplined workflow system. Instead of jumping straight into code, it enforces structured phases: brainstorm, plan, execute, verify, review.

All workflows share a `.planning/` directory in your project root containing:
- `progress.md` - Task Status Dashboard + session-level progress log
- `findings.md` - research notes and discoveries
- `task_plan.md` - plan + phase tracking (ad-hoc tasks only, when no `docs/plans/` exists)

## Skills (15)

| Skill | Description |
|-------|-------------|
| **main** | Skill router loaded on every session. Determines which skills to invoke. |
| **planning-foundation** | Creates and manages `.planning/` directory for complex tasks. |
| **brainstorming** | Explores intent, requirements and design before implementation. |
| **writing-plans** | Creates detailed implementation plans before touching code. |
| **executing-plans** | Executes plans in batches with review checkpoints. |
| **tdd** | Test-driven development: write tests before implementation. |
| **systematic-debugging** | Root-cause analysis before proposing fixes. |
| **verification** | Evidence-based completion checks before claiming "done". |
| **requesting-code-review** | Orchestrates code review after feature completion. |
| **receiving-code-review** | Technical rigor when processing review feedback. |
| **parallel-agents** | Dispatches independent tasks to concurrent subagents. |
| **subagent-driven** | Executes plan tasks via subagents in-session. |
| **using-git-worktrees** | Isolated feature work via git worktrees. |
| **finishing-a-development-branch** | Guides merge, PR, or cleanup after implementation. |
| **writing-skills** | Create and test new Claude Code skills. |

## Commands (4)

| Command | Description |
|---------|-------------|
| `/brainstorm` | Start brainstorming before creative work. |
| `/write-plan` | Create an implementation plan. |
| `/execute-plan` | Execute a plan with review checkpoints. |
| `/catchup` | Recover context from previous sessions. |

## Agents (1)

| Agent | Description |
|-------|-------------|
| **code-reviewer** | Multi-perspective code review against plan and standards. |

## Hooks

- **SessionStart** - Automatically loads the main skill router and recovers `.planning/` state on session resume.

## License

MIT
