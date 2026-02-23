# Design: Archiving Skill for superpower-planning

**Date:** 2026-02-23
**Status:** Approved

## Problem

The `.planning/` directory accumulates completed plan data with no cleanup or archival mechanism. Valuable findings are easily lost. The current `finishing-branch` Step 6 offers a weak, optional findings persistence that is easily skipped. There is no historical record of past plans, and no systematic way to maintain memory quality over time.

## Solution

Add an `archiving` skill that:

1. Generates a structured archive summary from completed `.planning/` state
2. Stores the archive in `.planning/archive/` (git-ignored, locally persistent)
3. Performs **memory consolidation and maintenance** -- not just adding new findings, but polishing, compressing, and fact-checking existing memory against the current repo state
4. Resets `.planning/` to template state for the next task
5. Provides `/archive` command for quick access
6. Integrates archive retrieval into `brainstorming` and `writing-plans` for historical context

## Architecture

### Archiving Skill Flow (`skills/archiving/SKILL.md`)

```
Step 1: Determine archive name
  - Read .planning/progress.md Task Status Dashboard
  - Extract main task name as default archive name
  - If associated plan file exists (docs/plans/xxx.md), use its name
  - AskUserQuestion to confirm/modify name

Step 2: Generate archive summary
  - Read .planning/progress.md + .planning/findings.md
  - Read .planning/agents/*/findings.md (if exist)
  - Generate structured summary:
      ## Archive: <name>
      ## Date: YYYY-MM-DD
      ## Plan: <plan-file-path or "N/A">
      ## Summary (2-3 sentences)
      ## Key Decisions (from findings)
      ## Lessons Learned (patterns, gotchas)
      ## Key Files Changed

Step 3: Save archive
  - mkdir -p .planning/archive/
  - Write to .planning/archive/YYYY-MM-DD-<name>.md

Step 4: Memory Consolidation & Polish (semi-automatic)
  4a. Explore current facts
    - Read current memory files (~/.claude/projects/.../memory/*)
    - Run git diff --stat (recent changes)
    - Quick Glob/Read of repo key structure (verify paths, patterns in memory are still accurate)

  4b. Extract new findings
    - From .planning/findings.md, extract items worth long-term retention
    - Filter out session-specific temporary information

  4c. Generate Memory optimization suggestions
    LLM generates a unified optimization proposal based on facts:

    New items (from this session's findings)
      - [new finding 1]
      - [new finding 2]

    Compress items (existing memory that can be condensed)
      - [memory item X] -> [compressed version]

    Update items (inconsistent with current repo facts)
      - [outdated memory Y] -> [corrected version based on repo]

    Remove items (no longer applicable)
      - [obsolete memory Z] -- reason: [reason]

  4d. User confirmation
    - AskUserQuestion to show suggestions
    - User selectively adopts

  4e. Write updates
    - Write optimized memory files in one pass
    - Ensure MEMORY.md stays concise (< 200 lines)

Step 5: Reset .planning/
  - Overwrite progress.md and findings.md with template content
  - Delete agents/ subdirectory
  - Preserve archive/ subdirectory

Step 6: Report completion
  - Show archive file path
  - Show which memories were consolidated
  - Show .planning/ has been reset
```

### Archive Retrieval (integrated into existing skills)

**Trigger:** During `brainstorming` Step 1 and `writing-plans` early phase.

```
1. Glob .planning/archive/*.md
2. If archives exist:
   a. Read first few lines of each (title + Summary)
   b. LLM judges which are relevant to current task
   c. If relevant found:
      - Read full content
      - Write relevant Key Decisions and Lessons Learned to .planning/findings.md under "Historical Context"
      - Inform user: "Found relevant historical records: ..."
   d. If none relevant, skip silently
3. If no archives, skip silently
```

**Principles:**
- Lightweight: no match = zero overhead
- Non-blocking: retrieval results are reference info, don't affect main flow
- Progressive: more archives = more future reference value

### Modifications to Existing Files

| File | Change |
|------|--------|
| `scripts/check-complete.sh` | Replace findings persistence reminder with `/archive` suggestion |
| `skills/main/SKILL.md` | Add `archiving` to Available Skills table |
| `skills/brainstorming/SKILL.md` | Add archive retrieval sub-step in Step 1 |
| `skills/writing-plans/SKILL.md` | Add archive retrieval step at start |
| `skills/finishing-branch/SKILL.md` | Add light guidance to use `/archive` in Step 6 |

### New Files

| File | Purpose |
|------|---------|
| `skills/archiving/SKILL.md` | The archiving skill |
| `commands/archive/command.md` | `/archive` slash command |

### `/archive` Command

`commands/archive/command.md` simply invokes `superpower-planning:archiving` skill.

### Design Principles

- **KISS:** Pure skill-driven, no dedicated scripts. LLM follows SKILL.md instructions.
- **Fact-based:** All memory polishing grounded in current repo state, not LLM assumptions.
- **Semi-automatic:** LLM proposes, user confirms. Balance efficiency and control.
- **Non-destructive:** Archive is saved before any cleanup. Archive survives .planning/ reset.
- **Progressive:** Archive retrieval creates a knowledge feedback loop.
