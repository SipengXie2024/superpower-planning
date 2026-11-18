---
name: planning-foundation
description: Keeps a task's state across context resets and session boundaries, with in-session progress in the task note and what the project learned in .planning/findings.md. Use when starting complex multi-step work, a research project, or anything needing more than five tool calls, and when recovering context from an earlier session, including "接着上次", "这个要分几步", "先做个计划". A request not to bother with the directory, because last time it went unread, is still this skill.
---

# Planning Foundation

A task's state has two homes. Progress inside the task lives in the session's task note. What the project learned lives in `.planning/findings.md`, which outlives every session. There is no progress file and no plan file.

## Where Each Kind of State Goes

| State | Home | Lifetime |
|-------|------|----------|
| Goal, the user's constraints in their words, what is done, what is next | task note (context-memory `notes_write`) | this conversation, carried across compaction |
| Discoveries, decisions with their reasons, rejected approaches and why they failed, root causes, measurements with the commands that reproduce them | `.planning/findings.md` | project lifetime, entries appended |
| Paused work | `.planning/stash/YYYY-MM-DD-<name>/snapshot.md` | until resumed |
| Finished work | `.planning/archive/YYYY-MM-DD-<name>/summary.md` | permanent |

Task status and action logs never go into `findings.md`. A plan the user reviews before work starts goes through `/html-plan` when installed, else native plan mode.

```
.planning/                     # gitignored
├── findings.md                # project knowledge, one dated entry per fact
├── agents/<role>/findings.md  # created on demand by delegated roles
├── stash/YYYY-MM-DD-<name>/   # snapshot.md (carries the task note)
└── archive/YYYY-MM-DD-<name>/ # summary.md
```

## If This Session Cannot Write Files

Check once, up front: `.planning/` needs Write, plus Bash for `init-planning-dir.sh`
(or `mkdir -p .planning`) and Read for the templates. If those are missing, name it in
one sentence and move on.

That one check is the whole budget, and it covers every route, not just the obvious
one. Do not run the script to see it fail, do not fall back to `mkdir`, do not search
for a deferred tool that might write, and do not dispatch a subagent to write on your
behalf: a subagent inherits this session's permissions and hits the same wall. Reporting
what each attempt returned is the failure mode, not the workaround.

Keep the working memory in the reply instead: the task note's content and any findings entries, restated as they change so they survive the context. Close with one line saying to save the entries in `.planning/findings.md`, and that you could not write it.

## If There Is No Task-Note Tool

Restate the working state (goal, constraints, done, next) in the reply whenever it changes in substance. Findings still go to `.planning/findings.md`.

## Quick Start

1. **Write the task note** — goal, the user's binding constraints in their own words, what is done, what is next. Rewrite it whenever the task changes in substance: a new requirement, a finished or abandoned step, a key finding, a blocker.
2. **Create `.planning/` when the first lasting fact appears** — run `${CLAUDE_PLUGIN_ROOT}/scripts/init-planning-dir.sh` (creates `findings.md`, adds `.planning/` to `.gitignore`).
3. **Append a findings entry** each time a discovery, decision, dead end, root cause or measurement is established.

## Findings Entries

Each entry has a dated heading naming its topic, then the fact and its evidence or reason. A measurement carries the command and input that reproduce it. Add new entries; edit an existing one only to correct it. A dead end gets an entry with the reason it failed, so no later session retries it.

```markdown
## 2026-11-18: MDBX WriteMap mode
Turned off. Under WriteMap every dirty page counts toward process RSS, and the
benchmark was OOM-killed at 4B keys. Off costs 2% throughput (`cargo bench --profile bench-lto`).
```

## Rules

### 1. Read before deciding
Before a major decision, reread the task note and the findings entries on the topic. It puts the goal and the known dead ends back in view.

### 2. Counts come from commands
Derive any count you record (steps done, tests passing, TODOs left) from command output such as `grep -c` or `wc -l`, not from memory.

### 3. Work through ordinary failures
Diagnose an error, then work through it: retry, fix the request, use another tool or source. When the same check still fails after three rounds of fixes, stop, report what each round tried and what it showed, and ask the user how to proceed. Record a ruled-out approach in `findings.md` with the reason it failed.

## Recovering a Session

- After compaction, the task note is already in context. Read the findings entries it points to.
- In a new session, read `.planning/findings.md` and run `git diff --stat`; `/catchup` scans earlier transcripts for what happened after the last findings write.
- An older version of this plugin kept `progress.md`, `plan.md` and `design.md` in `.planning/`. Read them, move live status into the task note and lasting facts into `findings.md`, and leave the files where they are.

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

## Delegated Roles

Each delegated role writes its discoveries to `.planning/agents/{role}/findings.md` (one directory per role, reused across tasks; never one per task) and reports its status in its final message. Inject [templates/agent-context.md](templates/agent-context.md) into the role's prompt. After each task, `aggregate-agent-findings.sh <role>` merges the lines marked `Critical for Orchestrator` into `.planning/findings.md`.

## Templates

- [templates/findings.md](templates/findings.md) — the file `init-planning-dir.sh` creates
- [templates/agent-context.md](templates/agent-context.md) — planning rules to inject into delegated-role prompts

## Scripts

**Planning lifecycle:**
- `${CLAUDE_PLUGIN_ROOT}/scripts/init-planning-dir.sh` — Create `.planning/findings.md` and gitignore `.planning/`
- `${CLAUDE_PLUGIN_ROOT}/scripts/check-planning-state.sh` — Report what `.planning/` holds on disk: missing | empty | active | complete
- `${CLAUDE_PLUGIN_ROOT}/scripts/snapshot-save.sh` — Copy `agents/` and older-layout files to a target directory (shared by stash/archive)
- `${CLAUDE_PLUGIN_ROOT}/scripts/planning-reset.sh` — Clear those files from `.planning/`, keeping `findings.md`, `archive/` and `stash/`

**Stash/archive:**
- `${CLAUDE_PLUGIN_ROOT}/scripts/stash-list.sh` — List available stashes
- `${CLAUDE_PLUGIN_ROOT}/scripts/stash-restore.sh` — Restore `agents/` and print the stash files to read
- `${CLAUDE_PLUGIN_ROOT}/scripts/archive-search.sh` — Search archives by keyword
- `${CLAUDE_PLUGIN_ROOT}/scripts/unique-filename.sh` — Generate unique dated filename/dirname

**Agent orchestration:**
- `${CLAUDE_PLUGIN_ROOT}/scripts/aggregate-agent-findings.sh` — Merge delegated-role "Critical for Orchestrator" items into `.planning/findings.md`

**Project detection:**
- `${CLAUDE_PLUGIN_ROOT}/scripts/detect-base-branch.sh` — Detect main/master/develop
- `${CLAUDE_PLUGIN_ROOT}/scripts/detect-test-command.sh` — Detect project test command
- `${CLAUDE_PLUGIN_ROOT}/scripts/detect-project-setup.sh` — Detect and run project setup

**Other:**
- `${CLAUDE_PLUGIN_ROOT}/scripts/release.sh` — Version bump, tag, GitHub Release
- `${CLAUDE_PLUGIN_ROOT}/scripts/session-catchup.py` — Recover context from earlier sessions (manual utility, requires Python)
