---
name: finishing-branch
description: Use when implementation is complete, all tests pass, and integration strategy needs to be decided - merge, PR, keep, or discard
---

# Finishing a Development Branch

## Overview

Guide completion of development work by presenting clear options and handling chosen workflow.

**Core principle:** Verify tests -> Present options -> Execute choice -> Clean up only when the chosen option requires it.

**Announce at start:** "I'm using the finishing-branch skill to complete this work."

## The Process

### Step 1: Verify Tests

**Before presenting options, verify tests pass:**

```bash
# Auto-detect and run project's test suite
TEST_CMD=$(${CLAUDE_PLUGIN_ROOT}/scripts/detect-test-command.sh)
eval "$TEST_CMD"
```

**If tests fail:**
```
Tests failing (<N> failures). Must fix before completing:

[Show failures]

Cannot proceed with merge/PR until tests pass.
```

Stop. Don't proceed to Step 2.

**If tests pass:** Continue to Step 2.

### Step 2: Determine Base Branch

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/detect-base-branch.sh
```

Or ask: "This branch split from main - is that correct?"

### Step 3: Present Options

Present exactly these 4 options:

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

**Don't add explanation** - keep options concise.

### Step 4: Execute Choice

#### Option 1: Merge Locally

For local merge flows, keep the safety order explicit: tests were already verified in Step 1, then the merge must succeed, then the merged result must pass verification, and only then may cleanup happen.

Before switching branches, capture the feature branch name and any matching worktree path so cleanup targets stay bound to the feature branch. For worktree-based feature flows, complete the merge from the worktree that already owns `<base-branch>` rather than trying to check out `<base-branch>` inside the feature worktree.

```bash
FEATURE_BRANCH=<feature-branch>
FEATURE_WORKTREE=$(git worktree list | grep "$FEATURE_BRANCH" | awk '{print $1}')
BASE_BRANCH=<base-branch>
BASE_WORKTREE=$(git worktree list --porcelain | awk -v b="refs/heads/$BASE_BRANCH" '
  /^worktree / { w=$2 }
  /^branch / && $2==b { print w; exit }
')

if test -z "$BASE_WORKTREE"; then
  BASE_WORKTREE=$(cd "$(git rev-parse --git-common-dir)/.." && pwd)
fi

# Return to the worktree that should own the base branch before touching it
cd "$BASE_WORKTREE"
git checkout "$BASE_BRANCH"

# Pull latest
git pull

# Merge feature branch
git merge "$FEATURE_BRANCH"

# Verify tests on merged result
<test command>
```

If the merge fails or merged-result verification fails, stop. Do not remove the worktree or delete the branch.

If the merge succeeds and merged-result verification passes:
```bash
# Remove the feature worktree first if it exists; only then delete the merged branch
if test -n "$FEATURE_WORKTREE"; then
  git worktree remove "$FEATURE_WORKTREE"
fi

git branch -d "$FEATURE_BRANCH"
```

Then: Cleanup is complete for this path unless additional local cleanup is needed.

#### Option 2: Push and Create PR

```bash
# Push branch
git push -u origin <feature-branch>

# Create PR
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<2-3 bullets of what changed>

## Test Plan
- [ ] <verification steps>
EOF
)"
```

Then: Keep branch and worktree as-is for PR revisions. No cleanup.

#### Option 3: Keep As-Is

Report: "Keeping branch <name>. Worktree preserved at <path>."

Keep branch and worktree as-is. No cleanup.

#### Option 4: Discard

**Confirm first:**
```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

Wait for exact confirmation.

If confirmed:
```bash
FEATURE_BRANCH=<feature-branch>
FEATURE_WORKTREE=$(git worktree list | grep "$FEATURE_BRANCH" | awk '{print $1}')
BASE_BRANCH=<base-branch>
BASE_WORKTREE=$(git worktree list --porcelain | awk -v b="refs/heads/$BASE_BRANCH" '
  /^worktree / { w=$2 }
  /^branch / && $2==b { print w; exit }
')

if test -z "$BASE_WORKTREE"; then
  BASE_WORKTREE=$(cd "$(git rev-parse --git-common-dir)/.." && pwd)
fi

# Return to the worktree that should own the base branch before deleting the feature worktree/branch
cd "$BASE_WORKTREE"

if test -n "$FEATURE_WORKTREE"; then
  git worktree remove "$FEATURE_WORKTREE"
fi

git branch -D "$FEATURE_BRANCH"
```

Then: Cleanup is complete for this discard path unless additional local cleanup is needed.

### Step 5: Cleanup Worktree

Only run cleanup for options that truly require it.

- **Option 1:** If a feature worktree exists, remove it after merge success and merged-result verification, then delete the merged branch. Do not try to delete a branch that is still attached to a linked worktree.
- **Option 4:** If a feature worktree exists, remove it from the main repository worktree after typed `discard` confirmation, then force-delete the feature branch.
- **Options 2 and 3:** Non-cleanup paths. Keep the branch and worktree.

If no feature worktree exists, skip cleanup. Do not assume every branch path has a removable worktree.

## Quick Reference

| Option | Merge | Push | Keep Worktree | Cleanup Branch |
|--------|-------|------|---------------|----------------|
| 1. Merge locally | yes | - | - | yes |
| 2. Create PR | - | yes | yes | - |
| 3. Keep as-is | - | - | yes | - |
| 4. Discard | - | - | - | yes (force) |

## Common Mistakes

**Skipping test verification**
- **Problem:** Merge broken code, create failing PR
- **Fix:** Always verify tests before offering options

**Open-ended questions**
- **Problem:** "What should I do next?" -> ambiguous
- **Fix:** Present exactly 4 structured options

**Automatic worktree cleanup**
- **Problem:** Remove worktree when might need it (Option 2, 3)
- **Fix:** Only cleanup for Options 1 and 4

**No confirmation for discard**
- **Problem:** Accidentally delete work
- **Fix:** Require typed "discard" confirmation

## Red Flags

**Never:**
- Proceed with failing tests
- Merge without verifying tests on result
- Delete work without confirmation
- Force-push without explicit request

**Always:**
- Verify tests before offering options
- Present exactly 4 options
- Get typed confirmation for Option 4
- Clean up worktree for Options 1 & 4 only

### Step 6: Archive Reminder and Persist Findings

After cleanup, if `.planning/findings.md` or `.planning/progress.md` has meaningful content:

1. **Read** `.planning/findings.md`
2. **Prompt the user explicitly** via `AskUserQuestion`:

```text
Implementation is finished. Before we move on, do you want me to archive this project now?

1. Yes — run /archive now (recommended)
2. Not now — remind me next time work resumes
3. Skip archiving for this task
```

3. If the user chooses **1**: invoke `superpower-planning:archiving`
4. If the user chooses **2**:
   - Add a clear reminder line at the top of `.planning/progress.md`, for example:
     `ARCHIVE REMINDER: This task is complete. Run /archive before starting unrelated work.`
   - Report that the reminder was saved
5. If the user chooses **3**: continue without archiving

If the user does **not** archive and `.planning/findings.md` still has meaningful content:

6. Report that long-term memory consolidation belongs to `superpower-planning:archiving`
7. Encourage the user to run `/archive` later rather than persisting project findings through this skill

**Default bias:** Prefer `/archive` over ad-hoc memory writes when a meaningful project has just finished.

## Integration

**Called by:**
- **superpower-planning:executing-plans** (Step 5) - After all batches complete

**Pairs with:**
- **superpower-planning:git-worktrees** - Cleans up worktree created by that skill
