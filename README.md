# superpower-planning

A focused Claude Code plugin for persistent file-based planning. It keeps long-lived project context in `.planning/` while leaving large-scale agent orchestration to Claude Code's native dynamic workflows.

## Installation

```bash
/plugin marketplace add SipengXie2024/superpower-planning
/plugin install superpower-planning@superpower-planning
```

Then restart Claude Code.

## What It Does

This plugin keeps the parts of planning that need durable project state:

1. **Brainstorm** — explore intent, constraints, and design before implementation
2. **Review the spec** — refine design docs before planning
3. **Write the implementation plan** — break work into bite-sized, testable tasks
4. **Execute deliberately** — use Claude Code dynamic workflows for large parallel work, Codex CLI for second-model execution, or a manual batch session
5. **Review when needed** — request bounded code review against the plan/spec
6. **Stash, archive, and recover context** — pause unfinished work, archive completed work, and retain persistent working memory across sessions

All planning workflows share a `.planning/` directory in your project root containing:

- `progress.md` — Task Status Dashboard + session-level progress log
- `findings.md` — research notes, discoveries, and important decisions
- `archive/` — completed work summaries, lessons learned, and historical context for future tasks
- `stash/` — paused unfinished work snapshots for later resume

## Skills (18)

| Skill | Description |
|-------|-------------|
| **main** | Skill router loaded on every session. Determines which skills to invoke. |
| **planning-foundation** | Creates and manages `.planning/` directory for complex tasks. |
| **brainstorming** | Explores intent, requirements, decomposition, and design before implementation. |
| **spec-interview** | Refines design docs through systematic deep questioning. Auto-invoked after brainstorming. |
| **writing-plans** | Creates detailed implementation plans before touching code, including execution handoff guidance. |
| **executing-plans** | Executes written plans in a separate/manual batch session with `.planning/` updates and checkpoints. |
| **tdd** | Test-driven development: write tests before implementation. |
| **debugging** | Root-cause analysis before proposing fixes. |
| **requesting-review** | Requests code review with structured context, plan alignment, and severity handling. |
| **receiving-review** | Technical rigor when processing review feedback. |
| **subagent-driven-codex** | Executes plan tasks via **Codex CLI** in-session with Codex implementer and reviewer roles. |
| **collaborating-with-codex** | Bridge to OpenAI Codex CLI for bounded coding work, debugging, analysis, or review. Consultations return a structured handoff while preserving the full answer privately. |
| **collaborating-with-hermes** | Consults Hermes for an independent second opinion and mirrors Codex reasoning/research/review consultations. |
| **perf-optimization** | Profiles first, fixes the largest measured bottleneck, then re-profiles. |
| **git-worktrees** | Thin guidance around Claude Code's native worktree isolation. |
| **archiving** | Archives completed plans, consolidates memory, and resets `.planning/` for the next task. |
| **stashing** | Pauses unfinished work into `.planning/stash/` and supports resume with stale-findings checks. |
| **releasing** | Bumps versions, tags, and publishes releases with changelogs. |

## Commands (7)

| Command | Description |
|---------|-------------|
| `/brainstorm` | Start brainstorming before creative work. |
| `/write-plan` | Create an implementation plan. |
| `/execute-plan` | Execute a reviewed implementation plan using the remaining execution paths. |
| `/catchup` | Recover context from previous sessions. |
| `/archive` | Archive completed work and consolidate planning memory. |
| `/stash` | Pause unfinished work and save the current `.planning/` state for later. |
| `/resume-stash` | Restore a paused stash back into active `.planning/` with stale-findings checks. |

## Agents (1)

| Agent | Description |
|-------|-------------|
| **code-reviewer** | Reviews completed work against the original plan and coding standards. |

## Hooks

- **SessionStart** — Automatically loads the main skill router and recovers `.planning/` state on session resume.
- **Stop** — Checks task completion status and warns about stale planning files.

## Optional Dependencies

| Tool | Used by | Fallback |
|------|---------|----------|
| `jq` | `release.sh` | `release.sh` exits with error if missing |
| `gh` | `release.sh` | Exits with error if missing |
| `codex` CLI | `collaborating-with-codex`, `subagent-driven-codex` | Both skills are unusable without the Codex CLI on PATH |
| `hermes` CLI | `collaborating-with-hermes`, dual consultations | Hermes consultation is unavailable; a surviving Codex consultation still stands |

If an older user-level Hermes skill remains at `~/.claude/skills/collaborating-with-hermes/`, remove or rename it after installing this plugin to avoid duplicate discovery or stale instructions. The plugin never deletes that copy automatically.

## Lifecycle Model

`superpower-planning` supports three distinct work states:

- **active** — the current task lives in `.planning/`
- **stashed** — unfinished work is paused in `.planning/stash/` for later resume
- **archived** — finished work is summarized in `.planning/archive/`

In short:

- `archive = done`
- `stash = paused`

When resuming a stash, the workflow explicitly checks whether saved findings are still valid before continuing.

## Claude Code Dynamic Workflows

Dynamic workflows now cover the large orchestration surface that this plugin used to implement manually: parallel subagents, team-style execution, multi-review fan-out, and fresh-session audit prompts. Use native workflows for codebase-wide audits, large migrations, plan stress tests, and cross-checked research.

This plugin remains useful for the durable layer around those runs:

- `.planning/` is long-lived working memory, not temporary script state
- `archive/` preserves historical context across sessions
- `stash/` supports switching between unfinished projects safely
- specs and plans stay as explicit files that workflows, Codex, or humans can execute against

## License

MIT
