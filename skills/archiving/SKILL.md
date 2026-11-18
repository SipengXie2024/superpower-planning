---
name: archiving
description: Snapshots a finished .planning/ directory into a dated archive, consolidates what was learned into project memory, and resets .planning/ for the next task. Use when a plan is done, when starting unrelated work in the same repo, or when .planning/ holds stale state from earlier work, including "归档", "这个做完了", "清一下 planning".
---

# Archiving Completed Plans

## Overview

Archive the active project in `.planning/` into a structured archive directory, consolidate and polish project memory based on current repo facts, and reset `.planning/` for the next task.

**Core principle:** The target is the finished task: its task note and the findings it produced, not "the session." `findings.md` stays live in `.planning/`; the archive records what this task added to it.

**Say what you are doing, in the user's terms, not the skill's name:** "Filing this finished work away and folding what it taught into project memory."

**Prerequisite:** the task note or `.planning/findings.md` holds this task's work.

## The Process

### Step 0: Check what this session can actually run

Check once, up front, whether this session has Bash and Write/Edit. The archive
scripts (`check-planning-state.sh`, `unique-filename.sh`, `snapshot-save.sh`,
`planning-reset.sh`), the `summary.md` write and the memory edits all need them; name
what is missing in one sentence rather than walking the steps to discover it. That budget covers every route, not just the obvious one: a subagent dispatched to do it inherits this session's permissions and hits the same wall, so do not send one, and do not report what any attempt returned.

Deliver the archive as text instead: the Step 2 `summary.md` content, from whatever
you can still read of `.planning/`, plus the Step 4c memory suggestions if the
findings carry any. Add one line saying it belongs in `.planning/archive/<name>/`,
that you could not write it, and that `.planning/` still holds the live files.

### Step 1: Determine Archive Name

1. Derive a short name from the task note's goal
2. With no task note, derive it from the findings entries this task added, or from an older-layout `progress.md` or `plan.md` if `.planning/` still has one
4. Use `AskUserQuestion` to let the user confirm or modify the archive name

### Step 2: Generate Archive Summary

Read:
- the task note
- `.planning/findings.md`, especially the entries this task added
- `.planning/agents/*/findings.md` (if any exist)
- older-layout `progress.md`, `plan.md`, `design.md` (if any exist)

Generate a concise `summary.md` with this format:

```
# Archive: <name>
**Date:** YYYY-MM-DD

## Summary
<!-- 2-3 sentences: what was done, what was the outcome -->

## Key Decisions
<!-- From the findings entries this task added — only decisions with long-term value -->

## Lessons Learned
<!-- Patterns discovered, gotchas, things to remember for similar future work -->

## Key Files Changed
<!-- Important files that were created or significantly modified -->

## Findings Written by This Task
<!-- headings of the findings.md entries, so the archive points at them -->
```

**Keep it concise.** The summary is a quick-reference document. Aim for 30-60 lines. The findings themselves stay in `.planning/findings.md`.

### Step 3: Save Archive

1. Generate a unique archive directory name:
```bash
mkdir -p .planning/archive
${CLAUDE_PLUGIN_ROOT}/scripts/unique-filename.sh .planning/archive "<name>" ""
```
2. Create the archive directory and copy `agents/` and any older-layout files into it:
```bash
mkdir -p "<returned-path>"
${CLAUDE_PLUGIN_ROOT}/scripts/snapshot-save.sh "<returned-path>"
```
3. Write `summary.md` to the archive directory
4. Report: "Archive saved to .planning/archive/<name>/"

### Step 4: Memory Consolidation & Polish

This step performs a **fact-based memory maintenance pass** — not just adding new findings, but optimizing existing memory against current repo state.

**4a. Explore current facts**
- Locate the current project's memory directory: find the auto-memory path that matches this project's working directory under `~/.claude/projects/`. Read `MEMORY.md` and any topic files in that directory only — do NOT glob across all projects.
- Run `git diff --stat` to see recent changes
- Quick Glob/Read of key repo files to verify paths and patterns mentioned in memory are still accurate

**4b. Extract new findings**
- From `.planning/findings.md`, identify items worth long-term retention:
  - Technical decisions with lasting rationale
  - Debugging lessons and root causes
  - Architectural patterns discovered
  - Dependency constraints or compatibility notes
- Filter OUT session-specific items:
  - Task completion status
  - Temporary workarounds
  - Intermediate test results

**4c. Generate unified optimization proposal**

Present to user in this format:

```
Memory Optimization Suggestions:

New items (from this session's findings)
  - [new finding 1]
  - [new finding 2]

Compress (existing memory that can be condensed)
  - [memory item X] -> [compressed version]

Update (inconsistent with current repo facts)
  - [outdated memory Y] -> [corrected version]

Remove (no longer applicable)
  - [obsolete memory Z] — reason: [why]
```

If there are no suggestions in a category, omit that category entirely.

**4d. User confirmation**
- Use `AskUserQuestion` to present the suggestions
- User can approve all, or describe which to skip

**4e. Execute writes**
- Apply approved changes to memory files using Edit/Write tools
- Ensure `MEMORY.md` stays under 200 lines — move detailed content to topic files
- For topic files that don't exist yet, create them and link from `MEMORY.md`

### Step 5: Reset .planning/

This step is destructive. Before running it, use `AskUserQuestion` to get explicit confirmation. Confirm the archive from Step 3 is on disk first, and surface that the reset removes `agents/` and any older-layout files (`progress.md`, `plan.md`, `design.md`). `findings.md` stays. Do not proceed if the user declines.

Once confirmed:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/planning-reset.sh
```

`findings.md`, `archive/` and `stash/` are preserved automatically.

### Step 6: Report Completion

Display a concise completion summary:

```
Archive complete:
- Archive: .planning/archive/<name>/
- Memory: <N> items added, <N> compressed, <N> updated, <N> removed
- .planning/ reset to clean state
```

## Edge Cases

**Empty .planning/:** Run `${CLAUDE_PLUGIN_ROOT}/scripts/check-planning-state.sh` — if it returns `empty`, warn the user and ask if they still want to archive. An empty archive has no value.

**No memory changes needed:** If there are no new findings worth persisting and existing memory is already accurate, skip Step 4c-4e entirely. Report "Memory already up to date."

**Older-layout progress.md with several sessions:** If it shows multiple session headers, include all of them in the archive summary.

**Legacy archives:** Existing single-file archives in `.planning/archive/*.md` remain valid. The archive listing and historical archive checks should handle both formats.

## Key Principles

- **Fact-based:** All memory polishing grounded in current repo state, not assumptions
- **Semi-automatic:** LLM proposes, user confirms. Never write memory without approval
- **Non-destructive:** Archive is saved BEFORE any cleanup. Archive survives reset
- **Complete:** The archive keeps the summary, the task's findings headings and any older-layout files together; the findings stay searchable in `findings.md`
- **Concise:** summary.md is a quick-reference doc, not a full log
