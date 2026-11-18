# superpower-planning

A focused Claude Code plugin for keeping a task's state across context resets and sessions. Progress inside a task lives in the session's task note (the context-memory plugin's `notes_write`); what the project learned lives in `.planning/findings.md`. Large-scale agent orchestration is left to Claude Code's native dynamic workflows.

## Installation

```bash
/plugin marketplace add SipengXie2024/superpower-planning
/plugin install superpower-planning@superpower-planning
```

Then restart Claude Code.

## What It Does

1. **Keep task progress in the task note** — goal, constraints, what is done, what is next; compaction carries it forward
2. **Keep what was learned in `.planning/findings.md`** — dated entries for discoveries, decisions, dead ends, root causes and measurements
3. **Review the spec** — refine a design doc through questions before implementation
4. **Implement and debug with discipline** — test-first, root cause before fix, profile before optimizing
5. **Stash, archive, and recover context** — pause unfinished work, archive completed work, and catch up after a gap

`.planning/` in your project root contains:

- `findings.md` — project knowledge that outlives every session
- `stash/` — paused work; each `snapshot.md` carries the task note
- `archive/` — finished work summaries and lessons learned

Plans the user reviews before work starts go through `/html-plan` (when installed) or Claude Code's plan mode.

## Skills (10)

| Skill | Description |
|-------|-------------|
| **planning-foundation** | Says where task state goes: progress in the task note, lasting facts in `.planning/findings.md`. |
| **spec-interview** | Refines design docs through systematic deep questioning. |
| **domain-glossary** | Maintains the project's shared vocabulary (ubiquitous language) in a repo-root `CONTEXT.md`: one canonical term per concept, synonyms banned. |
| **wait-what** | User-invoked repair (`/wait-what`): re-pitch the last message with more context, in controlled plain language, using `CONTEXT.md` terms. |
| **tdd** | Test-driven development: write tests before implementation. |
| **debugging** | Root-cause analysis before proposing fixes. |
| **perf-optimization** | Profiles first, fixes the largest measured bottleneck, then re-profiles. |
| **archiving** | Archives completed plans, consolidates memory, and resets `.planning/` for the next task. |
| **stashing** | Pauses unfinished work into `.planning/stash/` and supports resume with stale-findings checks. |
| **releasing** | Bumps versions, tags, and publishes releases with changelogs. |

## Commands (4)

| Command | Description |
|---------|-------------|
| `/catchup` | Recover context from previous sessions. |
| `/archive` | Archive completed work and consolidate planning memory. |
| `/stash` | Pause unfinished work, saving the task note into `.planning/stash/`. |
| `/resume-stash` | Restore a paused stash into the task note, with stale-findings checks. |

## Hooks

- **SessionStart** — Injects the plugin's conventions and, on resume, the head of `.planning/findings.md`.

## Optional Dependencies

| Tool | Used by | Fallback |
|------|---------|----------|
| `jq` | `release.sh` | `release.sh` exits with error if missing |
| `gh` | `release.sh` | Exits with error if missing |

## Lifecycle Model

`superpower-planning` supports three distinct work states:

- **active** — the current task lives in the task note
- **stashed** — unfinished work is paused in `.planning/stash/` for later resume
- **archived** — finished work is summarized in `.planning/archive/`

In short:

- `archive = done`
- `stash = paused`

When resuming a stash, the workflow explicitly checks whether saved findings are still valid before continuing.

## Claude Code Dynamic Workflows

Dynamic workflows now cover the large orchestration surface that this plugin used to implement manually: parallel subagents, team-style execution, multi-review fan-out, and fresh-session audit prompts. Use native workflows for codebase-wide audits, large migrations, plan stress tests, and cross-checked research.

This plugin remains useful for the durable layer around those runs:

- `findings.md` is long-lived project knowledge that workflows read and write back to
- `archive/` preserves historical context across sessions
- `stash/` supports switching between unfinished projects safely

## License

MIT
