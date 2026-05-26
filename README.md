# superpower-planning

A unified Claude Code plugin that combines persistent file-based planning with structured execution workflows. Every workflow inherits file-based working memory (`.planning/` directory), so context persists across sessions.

## Installation

```bash
/plugin marketplace add SipengXie2024/superpower-planning
/plugin install superpower-planning@superpower-planning
```

Then restart Claude Code.

### Optional companion plugin

`dual-review` prefers the `code-simplifier:code-simplifier` agent for its internal "simplify" review lens. If that plugin is installed, `dual-review` uses it directly; otherwise it falls back to a `general-purpose` subagent with an inlined simplify-style prompt. Install it for slightly sharper reuse/quality findings:

```bash
/plugin install code-simplifier
```

## What It Does

This plugin gives Claude Code a disciplined workflow system. Instead of jumping straight into code, it enforces structured phases:

1. **Brainstorm** — explore intent, constraints, and design before implementation
2. **Review the spec** — newly written specs go through a reviewer loop before planning
3. **Write the implementation plan** — break work into bite-sized, testable tasks
4. **Review the plan** — plans go through a reviewer loop before execution handoff
5. **Execute with the right strategy** — subagent-driven, team-driven, or parallel session
6. **Verify and review** — check correctness before declaring done
7. **Stash, archive, and recover context** — pause unfinished work, archive completed work, and retain persistent working memory across sessions

All workflows share a `.planning/` directory in your project root containing:
- `progress.md` — Task Status Dashboard + session-level progress log
- `findings.md` — research notes, discoveries, and important decisions
- `archive/` — completed work summaries, lessons learned, and historical context for future tasks
- `stash/` — paused unfinished work snapshots for later resume

## Skills (24)

| Skill | Description |
|-------|-------------|
| **main** | Skill router loaded on every session. Determines which skills to invoke. |
| **planning-foundation** | Creates and manages `.planning/` directory for complex tasks. |
| **lightweight-execute** | Fast structured execution for clear, medium-scope tasks without the full planning/review ceremony. |
| **brainstorming** | Explores intent, requirements, decomposition, and design before implementation. |
| **spec-interview** | Refines design docs through systematic deep questioning. Auto-invoked after brainstorming. |
| **writing-plans** | Creates detailed implementation plans before touching code, including plan review loop and execution handoff. |
| **executing-plans** | Executes plans in batches in a separate session, auto-running dual-review between batches. |
| **tdd** | Test-driven development: write tests before implementation. |
| **debugging** | Root-cause analysis before proposing fixes. |
| **verification** | Evidence-based completion checks before claiming "done". |
| **requesting-review** | Requests code review with structured context, plan alignment, and severity handling. |
| **receiving-review** | Technical rigor when processing review feedback. |
| **dual-review** | Runs an internal simplify lens and Codex in parallel review-only, consolidates findings, then gates edits on explicit user approval. |
| **session-handoff-audit** | Generates a self-contained audit prompt for a fresh session to independently verify implementation state against design specs. |
| **parallel-agents** | Dispatches independent tasks to concurrent subagents. |
| **subagent-driven** | Executes plan tasks via Claude subagents in-session (sequential) with two-stage review. |
| **subagent-driven-codex** | Executes plan tasks via **Codex CLI** in-session (sequential) with the same two-stage review. Every implementer and reviewer role goes through the bridge script. |
| **team-driven** | Executes plan tasks via Agent Team for parallel execution and context resilience. |
| **collaborating-with-codex** | Bridge to OpenAI Codex CLI for delegating bounded coding work, debugging, or analysis. Provides the `codex_bridge.py` script used by `subagent-driven-codex`. |
| **git-worktrees** | Isolated feature work via git worktrees. |
| **finishing-branch** | Guides merge, PR, cleanup, and archive reminder after implementation. |
| **archiving** | Archives completed plans, consolidates memory, and resets `.planning/` for the next task. |
| **stashing** | Pauses unfinished work into `.planning/stash/` and supports resume with stale-findings checks. |
| **releasing** | Bumps versions, tags, and publishes releases with changelogs. |

## Commands (7)

| Command | Description |
|---------|-------------|
| `/brainstorm` | Start brainstorming before creative work. |
| `/write-plan` | Create an implementation plan. |
| `/execute-plan` | Execute a reviewed implementation plan using the best execution strategy. |
| `/catchup` | Recover context from previous sessions. |
| `/archive` | Archive completed work and consolidate planning memory. |
| `/stash` | Pause unfinished work and save the current `.planning/` state for later. |
| `/resume-stash` | Restore a paused stash back into active `.planning/` with stale-findings checks. |

## Agents (1)

| Agent | Description |
|-------|-------------|
| **code-reviewer** | Reviews completed work against the original plan, code quality standards, architecture, docs, and severity thresholds. |

## Hooks

- **SessionStart** — Automatically loads the main skill router and recovers `.planning/` state on session resume.
- **PreToolUse (Bash)** — Shows planning dashboard before build/test/commit commands (requires `jq`).
- **Stop** — Checks task completion status and warns about stale planning files.

## Optional Dependencies

| Tool | Used by | Fallback |
|------|---------|----------|
| `jq` | PreToolUse dashboard hook, `release.sh` | Dashboard hook silently degrades; `release.sh` exits with error |
| `gh` | `release.sh` | Exits with error if missing |
| `codex` CLI | `collaborating-with-codex`, `subagent-driven-codex` | Both skills are unusable without the Codex CLI on PATH |

## Lifecycle Model

`superpower-planning` now supports three distinct work states:

- **active** — the current task lives in `.planning/`
- **stashed** — unfinished work is paused in `.planning/stash/` for later resume
- **archived** — finished work is summarized in `.planning/archive/`

In short:
- `archive = done`
- `stash = paused`

When resuming a stash, the workflow explicitly checks whether saved findings are still valid before continuing.

## Why This Fork Exists

`superpower-planning` keeps the persistent planning and archival workflow as a first-class concept:
- `.planning/` is long-lived working memory, not a temporary scratchpad
- `archive/` preserves historical context across sessions
- `stash/` supports switching between unfinished projects safely
- execution routing remains explicit: **Subagent-Driven** (Claude), **Subagent-Driven Codex** (Codex CLI), **Team-Driven**, or **Parallel Session**
- specs and plans are now both guarded by review loops before execution proceeds

## License

MIT
