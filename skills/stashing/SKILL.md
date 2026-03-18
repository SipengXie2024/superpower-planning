---
name: stashing
description: Use when switching to another project, waiting on dependencies, or temporarily setting aside unfinished work. Pauses current .planning/ state into .planning/stash/ for later resume with stale-findings check.
---

# Stashing Unfinished Work

Pause current work without claiming it is done.

**Core principle:** `archive = done`, `stash = paused`.

**Announce at start:** "I'm using the stashing skill to pause this work safely."

## When to Use

Use this skill when:
- current work is unfinished but you need to switch projects
- you are blocked on external input, dependency, or review
- you want to keep `.planning/` clean without losing working context
- the task should be resumable later

Do **not** use this skill for completed work. Use `superpower-planning:archiving` instead.

## The Process

### Step 1: Check stash-worthiness and completion guard

Read:
- `.planning/progress.md`
- `.planning/findings.md`
- `.planning/agents/*/findings.md` if present
- `.planning/agents/*/progress.md` if present

Before asking for a stash name or writing any stash file:

1. If `.planning/progress.md` shows the task is complete, or contains an `ARCHIVE REMINDER` line, do **not** stash it.
2. Instead, redirect to `superpower-planning:archiving`.
3. If top-level planning files are effectively empty/template-only **and** agent files are also empty or absent, warn the user that there is nothing meaningful to stash.

### Step 2: Determine stash name

Derive a short stash name from the active task, then ask the user to confirm or modify it.

Filename format:
- `.planning/stash/YYYY-MM-DD-<name>.md`

If the filename already exists, append `-2`, `-3`, etc.

### Step 3: Generate stash snapshot

Create a concise snapshot with this structure:

```markdown
# Stash: <name>
**Date:** YYYY-MM-DD
**Status:** paused
**Source Plan:** <path or N/A>

## Current Goal
<!-- 1-2 lines -->

## Where We Stopped
<!-- concrete current status -->

## Next Steps
<!-- immediate next 3-5 actions -->

## Key Findings
<!-- only the reusable or high-signal findings -->

## Agent State Summary
<!-- summarize any meaningful findings/progress from .planning/agents/* -->

## Open Questions / Blockers
<!-- what is missing, blocked, or uncertain -->

## Important Files / Branches
<!-- key files, branch names, plan paths -->
```

Keep it compact and actionable. Summarize meaningful agent findings/progress rather than copying full agent files.

### Step 4: Save stash

1. Create `.planning/stash/` if missing
2. Write the snapshot file
3. Report the final saved path

### Step 5: Reset active `.planning/`

After the stash is safely written:

1. Remove active top-level files:
   - `.planning/progress.md`
   - `.planning/findings.md`
2. Remove `.planning/agents/` contents if present
3. Run `${CLAUDE_PLUGIN_ROOT}/scripts/init-planning-dir.sh` to recreate canonical active planning files
4. Preserve:
   - `.planning/archive/`
   - `.planning/stash/`

### Step 6: Resume protocol

When resuming from a stash later:

1. **Check active work first**:
   - check if `.planning/` has **any meaningful content** (unfinished work, completed work, archive reminders, or agent state)
   - if not empty/template-only, warn the user and offer options:
     1. Stash active work first, then resume
     2. Archive active work first, then resume
     3. Overwrite active work (destructive)
   - Do not overwrite without explicit confirmation unless active work is strictly empty/template-only.

2. List available stash files under `.planning/stash/`
3. If multiple exist, use `AskUserQuestion` to let the user choose one
4. Read the selected stash file
5. Restore relevant context into active `.planning/progress.md` and `.planning/findings.md`
6. **Perform stale-findings check** before continuing:
   - compare stash assumptions against current repo state
   - run `git diff --stat`
   - quickly verify referenced files, paths, and branch still exist
   - mark findings as:
     - `still valid`
     - `needs refresh`
     - `obsolete`
7. Explicitly report any stale or questionable findings before execution resumes
8. If drift is large, recommend switching to `superpower-planning:brainstorming` or `superpower-planning:writing-plans` instead of blindly continuing

## Resume Output Format

When resuming, summarize in this format:

```text
Stash resumed: <name>

Findings freshness check:
- still valid: <items>
- needs refresh: <items>
- obsolete: <items>

Recommended next step:
- <single best next action>
```

## Key Principles

- `stash` is for paused unfinished work, not completed work
- stash snapshots should optimize for restart speed, not completeness
- stale-findings check is mandatory on resume
- if resume reveals major drift, suggest re-planning instead of blindly continuing
