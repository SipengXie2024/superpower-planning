---
name: archiving
description: Use after completing a plan or when .planning/ has accumulated stale data and needs a clean reset for the next task.
---

# Archiving Completed Plans

## Overview

Archive the active project in `.planning/` into a structured archive directory, consolidate and polish project memory based on current repo facts, and reset `.planning/` for the next task.

**Core principle:** The target is the active project (design, plan, findings, progress), not "the session."

**Announce at start:** "I'm using the archiving skill to archive this project and consolidate memory."

**Prerequisite:** `.planning/progress.md` and `.planning/findings.md` must exist with content beyond the empty template.

## The Process

### Step 1: Determine Archive Name

1. Read `.planning/progress.md` — extract task names from the Task Status Dashboard
2. If `.planning/plan.md` exists, derive the feature name from it
3. Otherwise, derive a short name from the main task descriptions
4. Use `AskUserQuestion` to let the user confirm or modify the archive name

### Step 2: Generate Archive Summary

Read all active project files:
- `.planning/design.md` (if exists)
- `.planning/plan.md` (if exists)
- `.planning/progress.md`
- `.planning/findings.md`
- `.planning/agents/*/findings.md` (if any exist)

Generate a concise `summary.md` with this format:

```
# Archive: <name>
**Date:** YYYY-MM-DD

## Summary
<!-- 2-3 sentences: what was done, what was the outcome -->

## Key Decisions
<!-- From findings.md Technical Decisions table — only decisions with long-term value -->

## Lessons Learned
<!-- Patterns discovered, gotchas, things to remember for similar future work -->

## Key Files Changed
<!-- Important files that were created or significantly modified -->
```

**Keep it concise.** The summary is a quick-reference document. Aim for 30-60 lines. The full design, plan, findings, and progress are preserved alongside it.

### Step 3: Save Archive

1. Generate a unique archive directory name:
```bash
mkdir -p .planning/archive
${CLAUDE_PLUGIN_ROOT}/scripts/unique-filename.sh .planning/archive "<name>" ""
```
2. Create the archive directory and save all active project files:
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

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/planning-reset.sh
```

This removes `design.md`, `plan.md`, `progress.md`, `findings.md`, and `agents/`, then recreates clean templates from canonical sources. `archive/` and `stash/` are preserved automatically.

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

**Multiple sessions in one .planning/:** If progress.md shows multiple session headers, include all of them in the archive summary.

**Legacy archives:** Existing single-file archives in `.planning/archive/*.md` remain valid. The archive listing and historical archive checks should handle both formats.

## Key Principles

- **Fact-based:** All memory polishing grounded in current repo state, not assumptions
- **Semi-automatic:** LLM proposes, user confirms. Never write memory without approval
- **Non-destructive:** Archive is saved BEFORE any cleanup. Archive survives reset
- **Complete:** Archive preserves the entire project (design, plan, findings, progress) as a unit
- **Concise:** summary.md is a quick-reference doc, not a full log
