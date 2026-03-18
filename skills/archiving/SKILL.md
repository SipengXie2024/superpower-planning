---
name: archiving
description: Use after completing a plan or when .planning/ has accumulated stale data. Archives completed work, consolidates memory, and resets .planning/ for the next task.
---

# Archiving Completed Plans

## Overview

Archive the current `.planning/` session state into a structured summary, consolidate and polish project memory based on current repo facts, and reset `.planning/` for the next task.

**Announce at start:** "I'm using the archiving skill to archive this session and consolidate memory."

**Prerequisite:** `.planning/progress.md` and `.planning/findings.md` must exist with content beyond the empty template.

## The Process

### Step 1: Determine Archive Name

1. Read `.planning/progress.md` — extract task names from the Task Status Dashboard
2. If a plan file is referenced (e.g., `docs/plans/YYYY-MM-DD-<feature>.md`), use its feature name
3. Otherwise, derive a short name from the main task descriptions
4. Use `AskUserQuestion` to let the user confirm or modify the archive name

### Step 2: Generate Archive Summary

Read all planning files:
- `.planning/progress.md`
- `.planning/findings.md`
- `.planning/agents/*/findings.md` (if any exist)

Generate a structured summary with this format:

```
# Archive: <name>
**Date:** YYYY-MM-DD
**Plan:** <path to plan file, or "N/A">

## Summary
<!-- 2-3 sentences: what was done, what was the outcome -->

## Key Decisions
<!-- From findings.md Technical Decisions table — only decisions with long-term value -->

## Lessons Learned
<!-- Patterns discovered, gotchas, things to remember for similar future work -->

## Key Files Changed
<!-- Important files that were created or significantly modified -->
```

**Keep it concise.** The archive is a reference document, not a full log. Aim for 30-60 lines.

### Step 3: Save Archive

1. Create directory: `mkdir -p .planning/archive/`
2. Determine filename: `.planning/archive/YYYY-MM-DD-<name>.md`. If that file already exists, append a numeric suffix (`-2`, `-3`, etc.) until a unique name is found.
3. Write the summary to the determined filename
4. Report: "Archive saved to .planning/archive/<final-filename>.md"

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

📌 New items (from this session's findings)
  - [new finding 1]
  - [new finding 2]

✂️ Compress (existing memory that can be condensed)
  - [memory item X] → [compressed version]

🔄 Update (inconsistent with current repo facts)
  - [outdated memory Y] → [corrected version]

🗑️ Remove (no longer applicable)
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

1. Delete `.planning/progress.md` and `.planning/findings.md`
2. Remove `.planning/agents/` directory and all contents: `rm -rf .planning/agents/`
3. Run `${CLAUDE_PLUGIN_ROOT}/scripts/init-planning-dir.sh` to recreate `progress.md` and `findings.md` from canonical templates
4. **Preserve** `.planning/archive/` — do NOT delete it

### Step 6: Report Completion

Display a concise completion summary:

```
Archive complete:
- 📦 Archive: .planning/archive/YYYY-MM-DD-<name>.md
- 🧠 Memory: <N> items added, <N> compressed, <N> updated, <N> removed
- 🔄 .planning/ reset to clean state
```

## Edge Cases

**Empty .planning/:** If progress.md and findings.md are still at template state (no real content), warn the user and ask if they still want to archive. An empty archive has no value.

**No memory changes needed:** If there are no new findings worth persisting and existing memory is already accurate, skip Step 4c-4e entirely. Report "Memory already up to date."

**Multiple sessions in one .planning/:** If progress.md shows multiple session headers, include all of them in the archive summary.

## Key Principles

- **Fact-based:** All memory polishing grounded in current repo state, not assumptions
- **Semi-automatic:** LLM proposes, user confirms. Never write memory without approval
- **Non-destructive:** Archive is saved BEFORE any cleanup. Archive survives reset
- **Concise:** Archive summaries are reference docs, not full logs
