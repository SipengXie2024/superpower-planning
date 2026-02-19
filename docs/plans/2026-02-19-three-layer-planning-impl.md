# Three-Layer Planning Architecture — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpower-planning:executing-plans to implement this plan task-by-task.
> Planning dir: .planning/

**Goal:** Remove task_plan.md, make progress.md Dashboard the single persistent catch-up source, and reconcile Task API usage across all skills.

**Architecture:** Delete task_plan.md and all references. Update hooks to use progress.md. Clarify Task API as the legitimate session-scoped orchestration layer (not an anti-pattern). progress.md Dashboard batch-syncs from Task API at phase boundaries.

**Tech Stack:** Shell scripts (bash), Markdown

---

### Task 1: Update hooks and scripts (core plumbing)

**Files:**
- Modify: `hooks/hooks.json`
- Modify: `hooks/session-start.sh`
- Modify: `scripts/check-complete.sh`
- Modify: `scripts/check-complete.sh`
- Modify: `scripts/init-planning-dir.sh`

**Step 1: Update `hooks/hooks.json`**

Change PreToolUse to read progress.md instead of task_plan.md:
```json
"command": "cat .planning/progress.md 2>/dev/null | head -30 || true"
```

Change PostToolUse to reference progress.md:
```json
"command": "if [ -f .planning/progress.md ]; then echo '[superpower-planning] File updated. If this completes a task, update .planning/progress.md Dashboard and sync from Task API.'; fi"
```

**Step 2: Update `hooks/session-start.sh`**

Change the detection logic from `if [ -f ".planning/task_plan.md" ]` to `if [ -d ".planning" ]`.

In the resume branch, replace reading task_plan.md with reading progress.md Dashboard (head -30) as the primary recovery content. Remove the "Plan (.planning/task_plan.md)" section. Replace with "Dashboard (.planning/progress.md)".

In the else branch (no .planning/), the message stays the same — just prompt to initialize.

**Step 3: Update `scripts/check-complete.sh`**

Change the guard from `if [ ! -f .planning/task_plan.md ]` to `if [ ! -f .planning/progress.md ]`.

**Step 4: Update `scripts/check-complete.sh`**

Rewrite to parse progress.md Dashboard table format instead of task_plan.md Phase format.

The Dashboard format is:
```
| Task 1: ... | complete | ... | ... |
| Task 2: ... | in_progress | ... | ... |
| Task 3: ... | pending | ... | ... |
```

New parsing logic:
- Default plan file: `.planning/progress.md`
- Count total tasks: rows in Dashboard table (lines matching `| Task`)
- Count complete: rows containing `| complete |` or `| ✅ complete |`
- Count in_progress: rows containing `| in_progress |` or `| ⏳ in_progress |`
- Count pending: rows containing `| pending |` or `| ⏳ pending |`

**Step 5: Update `scripts/init-planning-dir.sh`**

Remove the entire task_plan.md creation block (lines 36-86). Update the final echo to not mention task_plan.md.

**Step 6: Verify all hook/script changes**

Run: `bash -n hooks/session-start.sh && bash -n scripts/check-complete.sh && bash -n scripts/check-complete.sh && bash -n scripts/init-planning-dir.sh`
Expected: No syntax errors

Run: `cat hooks/hooks.json | python3 -m json.tool > /dev/null`
Expected: Valid JSON

**Step 7: Commit**

```bash
git add hooks/ scripts/
git commit -m "refactor: update hooks and scripts to use progress.md instead of task_plan.md"
```

> **Note:** Log unexpected discoveries to `.planning/findings.md`

---

### Task 2: Update planning-foundation skill

**Files:**
- Modify: `skills/planning-foundation/SKILL.md`
- Delete: `skills/planning-foundation/templates/task_plan.md`

**Step 1: Update `skills/planning-foundation/SKILL.md`**

Changes needed:

1. **Description (line 3):** Remove "(plus task_plan.md for ad-hoc tasks)" → "Creates .planning/ directory with progress.md and findings.md."

2. **Directory tree (lines 15-23):** Remove `task_plan.md` line. Result:
   ```
   .planning/
   ├── findings.md                # aggregated findings
   ├── progress.md                # Task Status Dashboard + session log
   └── agents/                    # per-subagent working dirs
   ```

3. **Remove "When is task_plan.md used?" block (lines 28-30):** Delete entirely.

4. **Quick Start (lines 37-39):** Remove step 4 "Ad-hoc only: Create task_plan.md". Renumber remaining steps.

5. **File Purposes table (line 56):** Remove `task_plan.md` row.

6. **Critical Rule 1 (line 63):** Simplify to: "Never start a complex task without `.planning/`. Plans always go in `docs/plans/`. `progress.md` with Task Status Dashboard tracks execution status."

7. **5-Question Reboot Test (line 138):** Change "Where am I?" answer to just "Task Status Dashboard in progress.md"

8. **Templates section (line 172):** Remove task_plan.md template reference.

9. **Anti-Patterns table (line 187):** Change from:
   ```
   | Use TaskCreate/TaskUpdate for persistence | Use .planning/progress.md Task Status Dashboard (or task_plan.md for ad-hoc) |
   ```
   To:
   ```
   | Use TaskCreate/TaskUpdate as cross-session persistence | Use .planning/progress.md Task Status Dashboard for persistent status. Task API is for session-scoped orchestration only. |
   ```
   This reconciles the contradiction: Task API is legitimate for orchestration, just not for cross-session persistence.

**Step 2: Delete `skills/planning-foundation/templates/task_plan.md`**

```bash
rm skills/planning-foundation/templates/task_plan.md
```

**Step 3: Verify no broken template references**

Run: `grep -r "templates/task_plan" skills/`
Expected: No matches

**Step 4: Commit**

```bash
git add skills/planning-foundation/
git commit -m "refactor: remove task_plan.md from planning-foundation, clarify Task API role"
```

> **Note:** Log unexpected discoveries to `.planning/findings.md`

---

### Task 3: Update main skill and catchup command

**Files:**
- Modify: `skills/main/SKILL.md:42`
- Modify: `commands/catchup.md`

**Step 1: Update `skills/main/SKILL.md`**

Session Recovery section (line 42): Remove step 3 "Read .planning/task_plan.md if it exists". Renumber remaining steps (old 4→3, old 5→4, old 6→5).

Result:
```markdown
## Session Recovery

On session start, check for an existing `.planning/` directory. If found:

1. Read `.planning/progress.md` -- Task Status Dashboard shows current status; session log shows what was done
2. Read `.planning/findings.md` -- recall discoveries and decisions
3. Run `git diff --stat` to see what changed since last session
4. Update planning files with recovered context
5. Continue with the task
```

**Step 2: Update `commands/catchup.md`**

Remove line 10 "Read .planning/task_plan.md if it exists (ad-hoc plans only)". Update numbering.

Result:
```markdown
1. Run the session catchup script
2. Read .planning/progress.md (Task Status Dashboard + session log), .planning/findings.md
3. Run `git diff --stat` to see what changed
4. Update planning files based on recovered context
5. Continue with the task
```

**Step 3: Commit**

```bash
git add skills/main/SKILL.md commands/catchup.md
git commit -m "refactor: remove task_plan.md from session recovery flow"
```

> **Note:** Log unexpected discoveries to `.planning/findings.md`

---

### Task 4: Update writing-plans skill

**Files:**
- Modify: `skills/writing-plans/SKILL.md:103`

**Step 1: Update `skills/writing-plans/SKILL.md`**

Remove the note on line 103 that says `task_plan.md` is NOT created here. It's no longer needed since task_plan.md doesn't exist at all. Replace with a clearer statement:

Old:
```markdown
> **Note:** `task_plan.md` is NOT created here. The permanent plan in `docs/plans/` is the single source of truth. Execution status is tracked via the Task Status Dashboard in `progress.md`.
```

New:
```markdown
> **Note:** The plan in `docs/plans/` is the single source of truth for plan content. Execution status is tracked via the Task Status Dashboard in `progress.md`.
```

**Step 2: Commit**

```bash
git add skills/writing-plans/SKILL.md
git commit -m "refactor: simplify writing-plans note, task_plan.md no longer exists"
```

> **Note:** Log unexpected discoveries to `.planning/findings.md`

---

### Task 5: Update README

**Files:**
- Modify: `README.md:21`

**Step 1: Update `README.md`**

Remove line 21: `- `task_plan.md` - plan + phase tracking (ad-hoc tasks only, when no `docs/plans/` exists)`

The .planning/ description should become:
```markdown
All workflows share a `.planning/` directory in your project root containing:
- `progress.md` - Task Status Dashboard + session-level progress log
- `findings.md` - research notes and discoveries
```

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: update README to reflect task_plan.md removal"
```

> **Note:** Log unexpected discoveries to `.planning/findings.md`

---

### Task 6: Final verification

**Step 1: Verify no remaining task_plan.md references**

Run: `grep -r "task_plan" --include="*.md" --include="*.sh" --include="*.json" --include="*.py" .`
Expected: No matches (or only this plan file itself and the design doc)

**Step 2: Verify all scripts have valid syntax**

Run: `bash -n hooks/session-start.sh && bash -n scripts/check-complete.sh && bash -n scripts/check-complete.sh && bash -n scripts/init-planning-dir.sh && echo "All scripts OK"`

**Step 3: Verify hooks.json is valid JSON**

Run: `cat hooks/hooks.json | python3 -m json.tool > /dev/null && echo "JSON OK"`

**Step 4: Verify template file was deleted**

Run: `ls skills/planning-foundation/templates/task_plan.md 2>&1`
Expected: "No such file or directory"

**Step 5: Update `.planning/progress.md` with final status**

Mark all tasks complete in Dashboard.

> **Note:** Log unexpected discoveries to `.planning/findings.md`
