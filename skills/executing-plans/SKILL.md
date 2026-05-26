---
name: executing-plans
description: Use when executing a written implementation plan in a separate session with batch execution and an automatic dual-review checkpoint between batches
---

# Executing Plans

## Overview

Load plan, review critically, execute tasks in batches, auto-run dual-review between batches.

**Core principle:** Batch execution with an automatic dual-review checkpoint between batches.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

## The Process

### Step 1: Load and Review Plan
1. Read plan file
2. Review critically - identify any questions or concerns about the plan
3. If concerns: Raise them with user before starting
4. If no concerns: Create tasks via TaskCreate and proceed

### Step 2: Execute Batch
**Default: First 3 tasks**

For each task:
1. Mark as in_progress
2. Follow each step exactly (plan has bite-sized steps)
3. Run verifications as specified
4. **Record discoveries** — After each task, append any unexpected findings, decisions, or technical insights to `.planning/findings.md`
5. Mark as completed

### Step 3: Report and Update Progress
When batch complete:
- Show what was implemented
- Show verification output
- **Update `.planning/progress.md`** (if `.planning/` exists):
  - Mark completed tasks as `complete` in the Task Status Dashboard
  - Append batch summary to the session log section
- **Update `.planning/findings.md`** — Consolidate any discoveries, decisions, or surprises from this batch

### Step 4: Dual-Review the Batch (automatic)

Every batch is reviewed before moving on. This **replaces the old "Ready for feedback" pause** — the dual-review approval gate is now the human checkpoint, so you still decide which fixes land.

1. **Enumerate the batch scope** — the files this batch created or modified. Derive from git: capture the ref/HEAD before Step 2, then `git diff --name-only <pre-batch-ref>` (or the diff since the last reviewed point). This concrete file list is the review scope.
2. Announce: "Batch complete — running dual-review on this batch's changes before continuing."
3. **REQUIRED SUB-SKILL:** Use superpower-planning:dual-review, passing the enumerated scope so it **skips its own scope-confirmation step**. It runs simplify + Codex in parallel (review-only), consolidates findings, gates on your approval for which fixes to apply, then applies approved fixes via a fresh subagent.
4. **Exception:** if the batch is purely trivial (docs / formatting / comments only), you may skip dual-review with a one-line note rather than spending review time — this matches dual-review's own "When NOT to use".

### Step 5: Continue
After the batch's review and any approved fixes land:
- Execute the next batch (return to Step 2)
- Repeat until all tasks complete
- If review revealed the approach needs rethinking, see "When to Revisit Earlier Steps"

### Step 6: Complete Development

After all tasks complete and verified:
- **Read `.planning/progress.md`** to compile a full summary of all batches, test results, and verification evidence before presenting final status
- Announce: "I'm using the finishing-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpower-planning:finishing-branch
- Follow that skill to verify tests, present options, execute choice

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker mid-batch (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Reference skills when plan says to
- After each batch: report, then auto-run dual-review on the batch (its approval gate is the checkpoint — don't wait for a manual review request)
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent
- After each task, record discoveries to `.planning/findings.md`
- After each batch, update both `.planning/progress.md` and `.planning/findings.md`
- Before final report, read `.planning/progress.md` for full summary

## Integration

**Required workflow skills:**
- **superpower-planning:git-worktrees** - RECOMMENDED: Set up isolated workspace unless already on a feature branch
- **superpower-planning:writing-plans** - Creates the plan this skill executes
- **superpower-planning:dual-review** - Auto-invoked after each batch (Step 4) to review that batch's changes; its approval gate is the between-batch checkpoint
- **superpower-planning:finishing-branch** - Complete development after all tasks
