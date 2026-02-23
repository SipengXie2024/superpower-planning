# Archiving Skill Implementation Plan

> **For Claude:** Execute this plan using the skill chosen during Execution Handoff (see end of plan).
> Planning dir: .planning/

**Goal:** Add an archiving skill that archives completed `.planning/` state, consolidates memory, and provides historical archive retrieval in brainstorming/writing-plans.

**Architecture:** Pure skill-driven approach — all logic lives in SKILL.md instructions, no dedicated scripts. A new `archiving` skill handles the full archive-consolidate-reset flow. Archive retrieval is added as lightweight sub-steps in existing brainstorming and writing-plans skills. `check-complete.sh` hook is updated to suggest `/archive`.

**Tech Stack:** Markdown skill files, shell script (check-complete.sh), Claude Code commands system

---

### Task 1: Create Archiving Skill

**Files:**
- Create: `skills/archiving/SKILL.md`

**Step 1: Write the archiving skill**

Create `skills/archiving/SKILL.md` with this exact content:

```markdown
---
name: archiving
description: "Archive completed plans, consolidate and polish memory, and reset .planning/ for the next task. Use after completing a plan or when .planning/ has accumulated stale data."
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
2. Write the summary to `.planning/archive/YYYY-MM-DD-<name>.md`
3. Report: "Archive saved to .planning/archive/YYYY-MM-DD-<name>.md"

### Step 4: Memory Consolidation & Polish

This step performs a **fact-based memory maintenance pass** — not just adding new findings, but optimizing existing memory against current repo state.

**4a. Explore current facts**
- Read all memory files: Glob `~/.claude/projects/*/memory/*` for the current project
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

1. Overwrite `.planning/progress.md` with the canonical template from `planning-foundation/templates/progress.md`
   - Replace `[DATE]` with current date
2. Overwrite `.planning/findings.md` with the canonical template from `planning-foundation/templates/findings.md`
3. Remove `.planning/agents/` directory and all contents: `rm -rf .planning/agents/`
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
```

**Step 2: Verify the file was created correctly**

Run: `cat skills/archiving/SKILL.md | head -5`
Expected: Shows the YAML frontmatter with `name: archiving`

**Step 3: Commit**

```bash
git add skills/archiving/SKILL.md
git commit -m "feat: add archiving skill for plan archive and memory consolidation"
```

> **Note:** Log unexpected discoveries, technical decisions, and implementation insights to `.planning/findings.md` after each task.

---

### Task 2: Create /archive Command

**Files:**
- Create: `commands/archive.md`

**Step 1: Write the command file**

Create `commands/archive.md` with this exact content:

```markdown
---
description: "Archive completed plans, consolidate memory, and reset .planning/ for the next task."
disable-model-invocation: true
---

Invoke the superpower-planning:archiving skill and follow it exactly as presented to you
```

**Step 2: Verify consistency with existing commands**

Run: `ls commands/` and compare format with `brainstorm.md`, `write-plan.md`, etc.
Expected: `archive.md` follows the same pattern (YAML frontmatter + single invoke instruction)

**Step 3: Commit**

```bash
git add commands/archive.md
git commit -m "feat: add /archive command for quick access to archiving skill"
```

> **Note:** Log unexpected discoveries, technical decisions, and implementation insights to `.planning/findings.md` after each task.

---

### Task 3: Update main/SKILL.md — Add Archiving to Skill Table

**Files:**
- Modify: `skills/main/SKILL.md:78-93` (Available Skills table)

**Step 1: Add archiving entry to the skill table**

In `skills/main/SKILL.md`, locate the `## Available Skills` table. Add a new row after the `finishing-branch` entry:

```markdown
| `superpower-planning:archiving` | Archive completed plans, consolidate memory, and reset .planning/ for the next task. |
```

The row should be inserted between `finishing-branch` and `requesting-review` in the table, since archiving logically follows finishing a branch.

**Step 2: Verify the table is still well-formatted**

Run: `grep -c 'superpower-planning:' skills/main/SKILL.md`
Expected: Count increases by 1 (from 15 to 16)

**Step 3: Commit**

```bash
git add skills/main/SKILL.md
git commit -m "feat: register archiving skill in main skill router"
```

> **Note:** Log unexpected discoveries, technical decisions, and implementation insights to `.planning/findings.md` after each task.

---

### Task 4: Update check-complete.sh — Suggest /archive

**Files:**
- Modify: `scripts/check-complete.sh:32-39`

**Step 1: Replace findings persistence reminder with archive suggestion**

In `scripts/check-complete.sh`, replace the block inside the all-complete condition:

Old code (lines 34-39):
```bash
    # Remind main agent to offer findings persistence
    if [ -f ".planning/findings.md" ]; then
        LINES=$(wc -l < ".planning/findings.md" | tr -d ' ')
        if [ "$LINES" -gt 5 ]; then
            echo "[superpower-planning] .planning/findings.md has content ($LINES lines). Ask the user if they want to persist key findings to Claude's memory system (auto memory files)."
        fi
    fi
```

New code:
```bash
    echo "[superpower-planning] Consider running /archive to archive this session's planning, consolidate memory, and reset .planning/ for the next task."
```

**Step 2: Verify the script still works**

Run: `bash scripts/check-complete.sh .planning/progress.md`
Expected: Output includes task status (no syntax errors)

**Step 3: Commit**

```bash
git add scripts/check-complete.sh
git commit -m "fix: suggest /archive instead of manual findings persistence in check-complete"
```

> **Note:** Log unexpected discoveries, technical decisions, and implementation insights to `.planning/findings.md` after each task.

---

### Task 5: Add Archive Retrieval to Brainstorming Skill

**Files:**
- Modify: `skills/brainstorming/SKILL.md:24-27` (Checklist section)

**Step 1: Add archive retrieval sub-step**

In `skills/brainstorming/SKILL.md`, modify Checklist item 1 to include archive retrieval. Change:

```markdown
1. **Explore project context** — check files, docs, recent commits. **Save initial findings** (project structure, relevant patterns, constraints discovered) to `.planning/findings.md`
```

To:

```markdown
1. **Explore project context** — check files, docs, recent commits. **Save initial findings** (project structure, relevant patterns, constraints discovered) to `.planning/findings.md`. Also check `.planning/archive/*.md` for relevant historical archives — if found, read related archives and note relevant Key Decisions and Lessons Learned in `.planning/findings.md` under a `## Historical Context` section.
```

**Step 2: Verify the change reads correctly**

Read `skills/brainstorming/SKILL.md` and confirm Checklist item 1 now mentions archive retrieval.

**Step 3: Commit**

```bash
git add skills/brainstorming/SKILL.md
git commit -m "feat: add archive retrieval to brainstorming context exploration"
```

> **Note:** Log unexpected discoveries, technical decisions, and implementation insights to `.planning/findings.md` after each task.

---

### Task 6: Add Archive Retrieval to Writing-Plans Skill

**Files:**
- Modify: `skills/writing-plans/SKILL.md` (after the Plan Document Header section, before Task Structure)

**Step 1: Add archive retrieval section**

In `skills/writing-plans/SKILL.md`, add a new section after `## Plan Document Header` (after line 46, before `## Task Structure`):

```markdown
## Historical Archive Check

Before writing the plan, check for relevant historical archives:

1. Glob `.planning/archive/*.md`
2. If archives exist, read the first 10 lines of each (title + summary)
3. If any are relevant to the current task, read fully and incorporate relevant lessons into the plan
4. If none are relevant or no archives exist, skip silently
```

**Step 2: Verify the section placement**

Read `skills/writing-plans/SKILL.md` and confirm the new section appears between "Plan Document Header" and "Task Structure".

**Step 3: Commit**

```bash
git add skills/writing-plans/SKILL.md
git commit -m "feat: add archive retrieval to writing-plans for historical context"
```

> **Note:** Log unexpected discoveries, technical decisions, and implementation insights to `.planning/findings.md` after each task.

---

### Task 7: Update finishing-branch — Add /archive Guidance

**Files:**
- Modify: `skills/finishing-branch/SKILL.md:193-201` (Step 6: Persist Findings)

**Step 1: Add /archive recommendation to Step 6**

In `skills/finishing-branch/SKILL.md`, at the end of Step 6 (after line 201), add:

```markdown

**Alternative:** Instead of manually persisting findings, suggest the user run `/archive` for comprehensive archive + memory consolidation + .planning/ reset.
```

**Step 2: Verify the addition**

Read `skills/finishing-branch/SKILL.md` and confirm the new text appears at the end of Step 6.

**Step 3: Commit**

```bash
git add skills/finishing-branch/SKILL.md
git commit -m "feat: add /archive guidance to finishing-branch Step 6"
```

> **Note:** Log unexpected discoveries, technical decisions, and implementation insights to `.planning/findings.md` after each task.

---

### Parallelism Groups

- **Group A** (parallel): Task 1, Task 2, Task 3, Task 4
  - All create/modify different files with no dependencies between them
- **Group B** (parallel, after Group A): Task 5, Task 6, Task 7
  - All modify different files with no dependencies between them
  - Depend on Task 1 existing (for conceptual consistency), but no file dependency

**Parallelism score:** 4/7 tasks can run in parallel in the first group

---

### Execution Handoff

> **For Claude:** Use the execution skill chosen below.

Choose execution mode:
1. **Subagent-Driven** — Fresh subagent per task, sequential. Good for these light markdown-editing tasks.
2. **Team-Driven** — Parallel implementers. 4/7 tasks can parallelize in Group A.
3. **Parallel Session** — Separate session with human checkpoints.

**Recommendation:** These are all light file-creation/editing tasks. Subagent-Driven is sufficient, but Team-Driven could speed up Group A (4 parallel tasks). Either works well.
