# superpower-planning: Session Conventions

This plugin keeps what a project learns across sessions in `.planning/findings.md`. Its skills appear in your available-skills list; invoke them with the Skill tool when they match the task (spec-interview to refine a spec, tdd for implementation, debugging for bugs, perf-optimization for speed work, stashing/archiving for lifecycle).

## Where state lives

- **Task progress** lives in the session's task note (the context-memory `notes_write` tool), which compaction carries forward. There is no progress file and no plan file. If the session has no task-note tool, restate the working state in the reply as it changes.
- **`.planning/findings.md`** is the knowledge that outlives the session. Append a dated entry, headed by its topic, after a discovery, a decision with its reason, a rejected approach and why it failed, a root cause, or a measurement with the command that reproduces it. Task status and action logs stay out of it.
- Create it with `${CLAUDE_PLUGIN_ROOT}/scripts/init-planning-dir.sh` the first time something worth keeping is learned. Full conventions: `superpower-planning:planning-foundation`.
- **Session recovery:** the task note carries the current task; read `.planning/findings.md` and run `git diff --stat`. A `progress.md`, `plan.md` or `design.md` left in `.planning/` by an older version of this plugin holds the same kind of state: read it, move live status into the task note and lasting facts into `findings.md`.

## Routing

- A plan the user reviews before work starts → `/html-plan` when installed, else native plan mode.
- Large, parallel, or cross-checked work → a Claude Code dynamic workflow that reads `findings.md` and writes durable results back.
- Code review: use Claude Code's built-in review capabilities (e.g. `/code-review`).
- Pausing unfinished work → `superpower-planning:stashing` (`/stash`). Resuming → `/resume-stash` (includes a stale-findings check). Completed work → `superpower-planning:archiving`.
- Terminology: if a repo-root `CONTEXT.md` exists, it is the project's ubiquitous language — use its canonical terms (never its `_Avoid_` words) in conversation, docs, and code. To add or change terms → `superpower-planning:domain-glossary`.
