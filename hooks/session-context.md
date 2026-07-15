# superpower-planning: Session Conventions

This plugin provides durable, file-based planning. Its skills appear in your available-skills list; invoke them with the Skill tool when they match the task (brainstorming for design-heavy features, spec-interview to refine specs, tdd for implementation, debugging for bugs, stashing/archiving for lifecycle).

## Persistent planning (`.planning/`)

`.planning/` is persistent working memory that survives context resets and session boundaries.

- **Complex task (multi-step, research, >5 tool calls):** initialize `.planning/` first via `${CLAUDE_PLUGIN_ROOT}/scripts/init-planning-dir.sh` if it doesn't exist.
- **Session recovery:** if `.planning/` exists, read `progress.md` (Task Status Dashboard + session log) and `findings.md` (discoveries, decisions), then run `git diff --stat` before continuing prior work.
- **Persist approved plans:** when plan mode or brainstorming produces an approved plan, write it to `.planning/plan.md`. Track execution status in `.planning/progress.md`; log discoveries and decisions to `.planning/findings.md` as you work. Full conventions: `superpower-planning:planning-foundation`.

## Routing

- Design-heavy or ambiguous work → `superpower-planning:brainstorming` (design doc, spec interview, plan persisted to `.planning/plan.md`). Scoped implementation with a known approach → native plan mode, then persist the approved plan.
- Executing a plan: run it in this session, keeping `.planning/` current. For large, parallel, or cross-checked work, prefer a Claude Code dynamic workflow that reads `.planning/design.md` + `plan.md` + `findings.md` and writes durable results back.
- Code review: use Claude Code's built-in review capabilities (e.g. `/code-review`); point the reviewer at `.planning/plan.md` / `design.md` when plan alignment matters.
- Pausing unfinished work → `superpower-planning:stashing` (`/stash`). Resuming → `/resume-stash` (includes a stale-findings check). Completed work → `superpower-planning:archiving`.
