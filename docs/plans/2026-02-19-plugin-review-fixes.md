# Plugin Review Fixes Implementation Plan

> **For Claude:** Use the execution skill chosen during handoff to implement this plan task-by-task.
> Planning dir: .planning/

**Goal:** Fix DRY violations, stale references, token waste, and logical inconsistencies found in the superpower-planning plugin code review.

**Architecture:** Pure documentation/config edits across skill files, scripts, and hooks. No new features — only fixing what's broken and removing duplication. Changes are independent at the task level, enabling parallel execution.

**Tech Stack:** Markdown, Bash scripts, Python, JSON

---

### Task 1: Fix stale `task_plan.md` references in `session-catchup.py`

**Files:**
- Modify: `scripts/session-catchup.py:236`
- Modify: `scripts/session-catchup.py:329`

**Step 1: Fix OpenCode workaround message (line 236)**

Replace:
```python
print("\nWorkaround: Manually read .planning/task_plan.md, .planning/progress.md, and .planning/findings.md to catch up.")
```

With:
```python
print("\nWorkaround: Manually read .planning/progress.md and .planning/findings.md to catch up.")
```

**Step 2: Fix RECOMMENDED section (line 329)**

Replace:
```python
print("2. Read: .planning/task_plan.md, .planning/progress.md, .planning/findings.md")
```

With:
```python
print("2. Read: .planning/progress.md, .planning/findings.md")
```

**Step 3: Verify no other `task_plan.md` references remain**

Run: `grep -r 'task_plan' scripts/ skills/ commands/ hooks/ README.md`
Expected: No matches

**Step 4: Commit**

```bash
git add scripts/session-catchup.py
git commit -m "fix: remove stale task_plan.md references from session-catchup.py"
```

> **Note:** Log unexpected discoveries to `.planning/findings.md`

---

### Task 2: Fix stale skill name reference in `finishing-branch`

**Files:**
- Modify: `skills/finishing-branch/SKILL.md:199`

**Step 1: Fix `using-git-worktrees` reference**

Replace:
```markdown
- **superpower-planning:using-git-worktrees** - Cleans up worktree created by that skill
```

With:
```markdown
- **superpower-planning:git-worktrees** - Cleans up worktree created by that skill
```

**Step 2: Fix announce message (line 14)**

Replace:
```markdown
**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."
```

With:
```markdown
**Announce at start:** "I'm using the finishing-branch skill to complete this work."
```

**Step 3: Fix `git-worktrees` announce message**

Modify: `skills/git-worktrees/SKILL.md:14`

Replace:
```markdown
**Announce at start:** "I'm using the using-git-worktrees skill to set up an isolated workspace."
```

With:
```markdown
**Announce at start:** "I'm using the git-worktrees skill to set up an isolated workspace."
```

**Step 4: Verify no other `using-git-worktrees` references remain**

Run: `grep -r 'using-git-worktrees' skills/ commands/ agents/`
Expected: No matches

**Step 5: Commit**

```bash
git add skills/finishing-branch/SKILL.md skills/git-worktrees/SKILL.md
git commit -m "fix: correct stale skill name references (using-git-worktrees → git-worktrees)"
```

> **Note:** Log unexpected discoveries to `.planning/findings.md`

---

### Task 3: DRY — Make prompt templates reference `agent-context.md` instead of inlining planning rules

**Files:**
- Modify: `skills/subagent-driven/implementer-prompt.md:24-51`
- Modify: `skills/team-driven/implementer-teammate-prompt.md:32-58`

**Step 1: Replace inlined planning rules in `implementer-prompt.md`**

Replace lines 24-51 (the full `## Planning Directory` section with 6 inlined rules) with:

```markdown
    ## Planning Directory

    Your planning directory is: {AGENT_PLANNING_DIR}
    (e.g., .planning/agents/implementer-task-N/)

    **IMPORTANT:** Include the content of `planning-foundation/templates/agent-context.md`
    here when constructing the prompt. Replace `{AGENT_PLANNING_DIR}` with the actual path.
```

**Step 2: Replace inlined planning rules in `implementer-teammate-prompt.md`**

Replace lines 22-58 (the full `## Planning Directory` section with 6 inlined rules) with:

```markdown
    ## Planning Directory

    For each task you receive, create a planning directory at:
    `.planning/agents/{your-name}-task-{N}/`

    Example: if you are `implementer-1` and receive Task 3:
    ```bash
    mkdir -p .planning/agents/implementer-1-task-3/
    ```

    **IMPORTANT:** Include the content of `planning-foundation/templates/agent-context.md`
    here when constructing the prompt. Replace `{AGENT_PLANNING_DIR}` with the actual path.
```

**Step 3: Verify `agent-context.md` is the single source**

Run: `cat skills/planning-foundation/templates/agent-context.md`
Expected: Contains the canonical 6 planning rules

**Step 4: Commit**

```bash
git add skills/subagent-driven/implementer-prompt.md skills/team-driven/implementer-teammate-prompt.md
git commit -m "refactor: DRY planning rules — reference agent-context.md instead of inlining"
```

> **Note:** Log unexpected discoveries to `.planning/findings.md`

---

### Task 4: Merge two code-reviewer definitions into one

**Files:**
- Modify: `agents/code-reviewer.md`
- Reference: `skills/requesting-review/code-reviewer.md` (keep as-is, this is the canonical template)

**Step 1: Replace `agents/code-reviewer.md` body with reference**

Keep the YAML frontmatter but replace the body. New content:

```markdown
---
name: code-reviewer
description: |
  Use this agent when a major project step has been completed and needs to be reviewed against the original plan and coding standards.
model: inherit
---

You are a Senior Code Reviewer. Follow the review template and output format defined in
`skills/requesting-review/code-reviewer.md`.

When invoked, use git diff to review code changes. Categorize issues by severity
(Critical/Important/Minor), acknowledge strengths, and give a clear merge verdict.

See the full review checklist, output format, and example at:
`skills/requesting-review/code-reviewer.md`
```

**Step 2: Verify `requesting-review/code-reviewer.md` has complete review criteria**

Read: `skills/requesting-review/code-reviewer.md`
Expected: Contains Code Quality, Architecture, Testing, Requirements, Production Readiness checklists + output format + example

**Step 3: Commit**

```bash
git add agents/code-reviewer.md
git commit -m "refactor: merge code-reviewer agent to reference requesting-review template (single source)"
```

> **Note:** Log unexpected discoveries to `.planning/findings.md`

---

### Task 5: Narrow hooks to reduce token waste

**Files:**
- Modify: `hooks/hooks.json`

**Step 1: Narrow PreToolUse matcher from 8 tools to 2**

Replace:
```json
    "PreToolUse": [
      {
        "matcher": "Write|Edit|Bash|Read|Glob|Grep|WebFetch|WebSearch",
        "hooks": [
          {
            "type": "command",
            "command": "cat .planning/progress.md 2>/dev/null | head -30 || true"
          }
        ]
      }
    ],
```

With:
```json
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "cat .planning/progress.md 2>/dev/null | head -15 || true"
          }
        ]
      }
    ],
```

Rationale: Only Bash is a high-context-loss tool. Also reduce from 30 to 15 lines (dashboard only).

**Step 2: Make PostToolUse more targeted**

Replace:
```json
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "if [ -f .planning/progress.md ]; then echo '[superpower-planning] File updated. If this completes a task, update .planning/progress.md Dashboard and sync from Task API.'; fi"
          }
        ]
      }
    ],
```

With:
```json
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "FILE=$(cat /dev/stdin 2>/dev/null | python3 -c \"import sys,json;print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))\" 2>/dev/null); if [ -f .planning/progress.md ] && echo \"$FILE\" | grep -qv '.planning/'; then echo '[superpower-planning] If this completes a task, update .planning/progress.md Dashboard.'; fi"
          }
        ]
      }
    ],
```

Wait — this is getting too complex. Simpler approach: just remove PostToolUse entirely, since skills already instruct agents to update progress.

Replace the entire PostToolUse section with nothing (remove it):

```json
    "PostToolUse": [],
```

**Step 3: Verify hooks.json is valid JSON**

Run: `python3 -c "import json; json.load(open('hooks/hooks.json')); print('OK')"`
Expected: OK

**Step 4: Commit**

```bash
git add hooks/hooks.json
git commit -m "perf: narrow PreToolUse hook to Bash only, remove noisy PostToolUse hook"
```

> **Note:** Log unexpected discoveries to `.planning/findings.md`

---

### Task 6: Compress `main/SKILL.md` Red Flags table

**Files:**
- Modify: `skills/main/SKILL.md:46-63`

**Step 1: Replace verbose Red Flags table with compressed version**

Replace lines 46-63 (from `## Red Flags` through end of table) with:

```markdown
## Red Flags

If you're thinking "this doesn't need a skill" — it does. Check BEFORE any action.

Common rationalizations that mean STOP and check for skills:
- "Too simple / overkill" — Simple things become complex. Use the skill.
- "Need context first / let me explore" — Skills tell you HOW to gather context.
- "I remember this skill" — Skills evolve. Read the current version.
- "Just one thing first" — Check BEFORE doing anything.
```

**Step 2: Verify the compressed version preserves key messages**

Read: `skills/main/SKILL.md`
Expected: Red Flags section now ~8 lines instead of ~16

**Step 3: Commit**

```bash
git add skills/main/SKILL.md
git commit -m "perf: compress main skill Red Flags table to save per-session tokens"
```

> **Note:** Log unexpected discoveries to `.planning/findings.md`

---

### Task 7: Fix `finishing-branch` Option 2 worktree contradiction

**Files:**
- Modify: `skills/finishing-branch/SKILL.md:106`

**Step 1: Remove contradictory cleanup line for Option 2**

Replace:
```markdown
Then: Cleanup worktree (Step 5)

#### Option 3: Keep As-Is
```

With:
```markdown
Then: Keep worktree (may need for PR revisions)

#### Option 3: Keep As-Is
```

**Step 2: Verify Quick Reference table and Red Flags are consistent**

Read lines 153-191 of `skills/finishing-branch/SKILL.md`
Expected: Option 2 = Keep Worktree: yes, and Red Flags says "Options 1 & 4 only"

**Step 3: Commit**

```bash
git add skills/finishing-branch/SKILL.md
git commit -m "fix: resolve Option 2 worktree cleanup contradiction in finishing-branch"
```

> **Note:** Log unexpected discoveries to `.planning/findings.md`

---

### Task 8: Fix plan header to be execution-mode-agnostic

**Files:**
- Modify: `skills/writing-plans/SKILL.md:36`

**Step 1: Replace hardcoded execution skill reference**

Replace:
```markdown
> **For Claude:** REQUIRED SUB-SKILL: Use superpower-planning:executing-plans to implement this plan task-by-task.
> Planning dir: .planning/
```

With:
```markdown
> **For Claude:** Execute this plan using the skill chosen during Execution Handoff (see end of plan).
> Planning dir: .planning/
```

**Step 2: Commit**

```bash
git add skills/writing-plans/SKILL.md
git commit -m "fix: make plan header execution-mode-agnostic"
```

> **Note:** Log unexpected discoveries to `.planning/findings.md`

---

### Task 9: Fix git-worktrees REQUIRED → RECOMMENDED

**Files:**
- Modify: `skills/executing-plans/SKILL.md:89`
- Modify: `skills/subagent-driven/SKILL.md:296`
- Modify: `skills/team-driven/SKILL.md:285`

**Step 1: Change REQUIRED to RECOMMENDED in executing-plans**

Replace:
```markdown
- **superpower-planning:git-worktrees** - REQUIRED: Set up isolated workspace before starting
```

With:
```markdown
- **superpower-planning:git-worktrees** - RECOMMENDED: Set up isolated workspace unless already on a feature branch
```

**Step 2: Same change in subagent-driven**

Replace:
```markdown
- **superpower-planning:git-worktrees** - REQUIRED: Set up isolated workspace before starting
```

With:
```markdown
- **superpower-planning:git-worktrees** - RECOMMENDED: Set up isolated workspace unless already on a feature branch
```

**Step 3: Same change in team-driven**

Replace:
```markdown
- **superpower-planning:git-worktrees** — REQUIRED: Set up isolated workspace before starting
```

With:
```markdown
- **superpower-planning:git-worktrees** — RECOMMENDED: Set up isolated workspace unless already on a feature branch
```

**Step 4: Commit**

```bash
git add skills/executing-plans/SKILL.md skills/subagent-driven/SKILL.md skills/team-driven/SKILL.md
git commit -m "fix: change git-worktrees from REQUIRED to RECOMMENDED (align with brainstorming's optional choice)"
```

> **Note:** Log unexpected discoveries to `.planning/findings.md`

---

### Task 10: Fix planning-init threshold inconsistency and remove redundant script

**Files:**
- Modify: `hooks/session-start.sh:52`
- Delete: `scripts/check-planning-complete.sh`
- Modify: `hooks/hooks.json` (Stop hook)

**Step 1: Fix threshold in session-start.sh**

Replace:
```bash
planning_message+="Before starting ANY task that involves multiple steps, research, or more than 3 tool calls, you MUST first initialize the planning directory:\\n\\n"
```

With:
```bash
planning_message+="Before starting ANY task that involves multiple steps, research, or more than 5 tool calls, you MUST first initialize the planning directory:\\n\\n"
```

**Step 2: Update Stop hook to call `check-complete.sh` directly**

In `hooks/hooks.json`, replace:
```json
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/check-planning-complete.sh"
          }
        ]
      }
    ]
```

With:
```json
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/check-complete.sh"
          }
        ]
      }
    ]
```

**Step 3: Delete redundant wrapper script**

Run: `rm scripts/check-planning-complete.sh`

**Step 4: Verify `check-complete.sh` handles missing file**

Read: `scripts/check-complete.sh:8-10`
Expected: Already has `if [ ! -f "$PROGRESS_FILE" ]; then ... exit 0; fi`

**Step 5: Commit**

```bash
git add hooks/session-start.sh hooks/hooks.json
git rm scripts/check-planning-complete.sh
git commit -m "fix: unify planning-init threshold to >5, remove redundant check-planning-complete.sh"
```

> **Note:** Log unexpected discoveries to `.planning/findings.md`

---

### Task 11: Make `init-planning-dir.sh` copy from canonical templates

**Files:**
- Modify: `scripts/init-planning-dir.sh`

**Step 1: Replace hardcoded findings.md content with template copy**

Replace lines 34-54 (the `if [ ! -f ... ]; then cat > ... << 'EOF' ... EOF` block for findings.md) with:

```bash
# Create findings.md if it doesn't exist
if [ ! -f "${PLANNING_DIR}/findings.md" ]; then
    TEMPLATE_DIR="${SCRIPT_DIR}/../skills/planning-foundation/templates"
    if [ -f "${TEMPLATE_DIR}/findings.md" ]; then
        cp "${TEMPLATE_DIR}/findings.md" "${PLANNING_DIR}/findings.md"
    else
        # Fallback: minimal findings file
        echo "# Findings & Decisions" > "${PLANNING_DIR}/findings.md"
    fi
    echo "Created findings.md"
else
    echo "findings.md already exists, skipping"
fi
```

**Step 2: Replace hardcoded progress.md content with template copy + date substitution**

Replace lines 61-104 (the progress.md heredoc block) with:

```bash
# Create progress.md if it doesn't exist
if [ ! -f "${PLANNING_DIR}/progress.md" ]; then
    TEMPLATE_DIR="${SCRIPT_DIR}/../skills/planning-foundation/templates"
    if [ -f "${TEMPLATE_DIR}/progress.md" ]; then
        sed "s/\[DATE\]/$DATE/g" "${TEMPLATE_DIR}/progress.md" > "${PLANNING_DIR}/progress.md"
    else
        # Fallback: minimal progress file
        cat > "${PLANNING_DIR}/progress.md" << EOF
# Progress Log

## Task Status Dashboard
| Task | Status | Agent/Batch | Key Outcome |
|------|--------|-------------|-------------|

## Session: $DATE
EOF
    fi
    echo "Created progress.md"
else
    echo "progress.md already exists, skipping"
fi
```

**Step 3: Add SCRIPT_DIR variable near top of file**

Add after `set -e` (line 10):

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
```

**Step 4: Test the script**

Run: `rm -rf /tmp/test-planning && mkdir /tmp/test-planning && bash scripts/init-planning-dir.sh /tmp/test-planning && cat /tmp/test-planning/.planning/findings.md && cat /tmp/test-planning/.planning/progress.md`
Expected: Files match canonical templates with DATE substituted

**Step 5: Commit**

```bash
git add scripts/init-planning-dir.sh
git commit -m "refactor: init-planning-dir.sh copies from canonical templates instead of hardcoding"
```

> **Note:** Log unexpected discoveries to `.planning/findings.md`

---

### Parallelism Groups

- **Group A** (parallel): Task 1, Task 2, Task 6, Task 7, Task 8
- **Group B** (parallel, after none): Task 3, Task 4, Task 9
- **Group C** (after Group A Task 5 for hooks changes): Task 5, Task 10
- **Group D** (after none): Task 11

All groups can actually run in parallel since no tasks edit the same files. The only exception is Tasks 5 and 10 both edit `hooks/hooks.json` — these must be sequential.

**Revised parallelism:**
- **Group A** (parallel): Task 1, Task 2, Task 3, Task 4, Task 6, Task 7, Task 8, Task 9, Task 11
- **Group B** (sequential, after Group A): Task 5, Task 10 (both touch `hooks/hooks.json`)

**Parallelism score:** 9/11 tasks can run in parallel in the first group
