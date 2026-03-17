# superpower-planning

A unified Claude Code plugin that combines persistent file-based planning with structured execution workflows. Every workflow inherits file-based working memory (`.planning/` directory), so context persists across sessions.

## Installation

```bash
/plugin marketplace add SipengXie2024/superpower-planning
/plugin install superpower-planning@superpower-planning
```

Then restart Claude Code.

## What It Does

This plugin gives Claude Code a disciplined workflow system. Instead of jumping straight into code, it enforces structured phases:

1. **Brainstorm** — explore intent, constraints, and design before implementation
2. **Review the spec** — newly written specs go through a reviewer loop before planning
3. **Write the implementation plan** — break work into bite-sized, testable tasks
4. **Review the plan** — plans go through a reviewer loop before execution handoff
5. **Execute with the right strategy** — subagent-driven, team-driven, or parallel session
6. **Verify and review** — check correctness before declaring done
7. **Archive and recover context** — consolidate findings and retain persistent working memory across sessions

All workflows share a `.planning/` directory in your project root containing:
- `progress.md` — Task Status Dashboard + session-level progress log
- `findings.md` — research notes, discoveries, and important decisions
- `archive/` — completed work summaries, lessons learned, and historical context for future tasks

## Skills (19)

| Skill | Description |
|-------|-------------|
| **main** | Skill router loaded on every session. Determines which skills to invoke. |
| **planning-foundation** | Creates and manages `.planning/` directory for complex tasks. |
| **brainstorming** | Explores intent, requirements, decomposition, and design before implementation. |
| **spec-interview** | Refines design docs through systematic deep questioning. Auto-invoked after brainstorming. |
| **writing-plans** | Creates detailed implementation plans before touching code, including plan review loop and execution handoff. |
| **executing-plans** | Executes plans in batches with review checkpoints in a separate session. |
| **tdd** | Test-driven development: write tests before implementation. |
| **debugging** | Root-cause analysis before proposing fixes. |
| **verification** | Evidence-based completion checks before claiming "done". |
| **requesting-review** | Requests code review with structured context, plan alignment, and severity handling. |
| **receiving-review** | Technical rigor when processing review feedback. |
| **parallel-agents** | Dispatches independent tasks to concurrent subagents. |
| **subagent-driven** | Executes plan tasks via subagents in-session (sequential) with two-stage review. |
| **team-driven** | Executes plan tasks via Agent Team for parallel execution and context resilience. |
| **git-worktrees** | Isolated feature work via git worktrees. |
| **finishing-branch** | Guides merge, PR, or cleanup after implementation. |
| **archiving** | Archives completed plans, consolidates memory, and resets `.planning/` for the next task. |
| **releasing** | Bumps versions, tags, and publishes releases with changelogs. |
| **writing-skills** | Creates and tests new Claude Code skills. |

## Commands (5)

| Command | Description |
|---------|-------------|
| `/brainstorm` | Start brainstorming before creative work. |
| `/write-plan` | Create an implementation plan. |
| `/execute-plan` | Execute a reviewed implementation plan using the best execution strategy. |
| `/catchup` | Recover context from previous sessions. |
| `/archive` | Archive completed work and consolidate planning memory. |

## Agents (1)

| Agent | Description |
|-------|-------------|
| **code-reviewer** | Reviews completed work against the original plan, code quality standards, architecture, docs, and severity thresholds. |

## Hooks

- **SessionStart** — Automatically loads the main skill router and recovers `.planning/` state on session resume.

## Why This Fork Exists

`superpower-planning` keeps the persistent planning and archival workflow as a first-class concept:
- `.planning/` is long-lived working memory, not a temporary scratchpad
- `archive/` preserves historical context across sessions
- execution routing remains explicit: **Subagent-Driven**, **Team-Driven**, or **Parallel Session**
- specs and plans are now both guarded by review loops before execution proceeds

## License

MIT
