---
name: git-worktrees
description: Use when starting feature work that needs isolation from current workspace or before executing implementation plans.
---

# Using Git Worktrees

## Overview

Git worktrees create isolated workspaces sharing the same repository, allowing work on multiple branches simultaneously without switching.

**Core principle:** Detect isolation first + prefer Claude Code's native worktree primitive + safety verification = reliable isolation.

**Announce at start:** "I'm using the git-worktrees skill to set up an isolated workspace."

## Detect Existing Isolation First

Before creating anything, check whether you are already in an isolated workspace.

```bash
git_dir=$(git rev-parse --git-dir)
git_common=$(git rev-parse --git-common-dir)
superproject=$(git rev-parse --show-superproject-working-tree 2>/dev/null)
```

Decision rules:
- If `git_dir != git_common` and `superproject` is empty, you are already in a linked worktree. Report the current path and do not create another worktree.
- If `superproject` is non-empty, you are inside a submodule. `GIT_DIR != GIT_COMMON` can also be true there, so do not treat that check alone as proof that you already have an isolated workspace.
- Only continue to directory selection and creation when a new isolated workspace is still needed.

## Native Tool First

**Rule:** Never fight the harness.

- Prefer Claude Code's native worktree primitive when available.
- Let Claude Code own the path and lifecycle when it can create the isolated workspace for you.
- Fall back to raw `git worktree add` only when no native Claude Code path applies and you still need a new workspace.

## Directory Selection Process

Follow this priority order when you need the manual `git worktree add` fallback:

### 1. Check Existing Directories

```bash
# Check in priority order
ls -d .worktrees 2>/dev/null     # Preferred (hidden)
ls -d worktrees 2>/dev/null      # Alternative
```

**If found:** Use that directory. If both exist, `.worktrees` wins.

### 2. Check CLAUDE.md

```bash
grep -i "worktree.*director" CLAUDE.md 2>/dev/null
```

**If preference specified:** Use it without asking.

### 3. Ask User

If no directory exists and no CLAUDE.md preference:

```
No worktree directory found. Where should I create worktrees?

1. .worktrees/ (project-local, hidden)
2. ~/.config/superpower-planning/worktrees/<project-name>/ (global location)

Which would you prefer?
```

## Safety Verification

### For Project-Local Directories (.worktrees or worktrees)

**MUST verify directory is ignored before creating worktree:**

```bash
# Check if directory is ignored (respects local, global, and system gitignore)
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**If NOT ignored:**

Per Jesse's rule "Fix broken things immediately":
1. Add appropriate line to .gitignore
2. Commit the change
3. Proceed with worktree creation

**Why critical:** Prevents accidentally committing worktree contents to repository.

### For Global Directory (~/.config/superpower-planning/worktrees)

No .gitignore verification needed - outside project entirely.

## Creation Steps

### 1. Choose Creation Path

- If Claude Code's native worktree primitive is available, use it first and stop here once the isolated workspace is ready.
- In Claude Code, this means using the native worktree tool rather than `git worktree add` so Claude Code owns the path and lifecycle.
- Only use the manual steps below when that native path is unavailable.

### 2. Detect Project Name

```bash
project=$(basename "$(git rev-parse --show-toplevel)")
```

### 3. Create Worktree

```bash
# Determine full path
case $LOCATION in
  .worktrees|worktrees)
    path="$LOCATION/$BRANCH_NAME"
    ;;
  *)
    path="$HOME/.config/superpower-planning/worktrees/$project/$BRANCH_NAME"
    ;;
esac

# Create worktree with new branch
git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

### 4. Run Project Setup

Auto-detect and run appropriate setup:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/detect-project-setup.sh "$path"
```

### 5. Verify Clean Baseline

Run tests to ensure worktree starts clean:

```bash
TEST_CMD=$(${CLAUDE_PLUGIN_ROOT}/scripts/detect-test-command.sh "$path")
eval "$TEST_CMD"
```

**If tests fail:** Report failures, ask whether to proceed or investigate.

**If tests pass:** Report ready.

### 6. Report Location

```
Worktree ready at <full-path>
Tests passing (<N> tests, 0 failures)
Ready to implement <feature-name>
```

## Quick Reference

| Situation | Action |
|-----------|--------|
| Already in isolated workspace | Reuse it; do not create another |
| Inside submodule | Do not treat `GIT_DIR != GIT_COMMON` alone as worktree proof |
| Native Claude Code worktree path available | Use it before manual git fallback |
| `.worktrees/` exists | Use it (verify ignored) |
| `worktrees/` exists | Use it (verify ignored) |
| Both exist | Use `.worktrees/` |
| Neither exists | Check CLAUDE.md -> Ask user |
| Directory not ignored | Add to .gitignore + commit |
| Tests fail during baseline | Report failures + ask |
| No package.json/Cargo.toml | Skip dependency install |

## Common Mistakes

### Skipping ignore verification

- **Problem:** Worktree contents get tracked, pollute git status
- **Fix:** Always use `git check-ignore` before creating project-local worktree

### Assuming directory location

- **Problem:** Creates inconsistency, violates project conventions
- **Fix:** Follow priority: existing > CLAUDE.md > ask

### Creating before checking current isolation

- **Problem:** Nests unnecessary worktrees or duplicates an already isolated workspace
- **Fix:** Detect whether the current workspace is already isolated before selecting directories or creating anything

### Treating submodules as worktrees

- **Problem:** `GIT_DIR != GIT_COMMON` can be true in submodules too, causing false positives
- **Fix:** Check submodule state before using that comparison as worktree evidence

### Proceeding with failing tests

- **Problem:** Can't distinguish new bugs from pre-existing issues
- **Fix:** Report failures, get explicit permission to proceed

### Hardcoding setup commands

- **Problem:** Breaks on projects using different tools
- **Fix:** Auto-detect from project files (package.json, etc.)

## Example Workflow

```
You: I'm using the git-worktrees skill to set up an isolated workspace.

[Detect current isolation - plain repo, not existing linked worktree]
[Prefer native Claude Code worktree path - unavailable, so continue]
[Check .worktrees/ - exists]
[Verify ignored - git check-ignore confirms .worktrees/ is ignored]
[Create worktree: git worktree add .worktrees/auth -b feature/auth]
[Run npm install]
[Run npm test - 47 passing]

Worktree ready at /Users/jesse/myproject/.worktrees/auth
Tests passing (47 tests, 0 failures)
Ready to implement auth feature
```

## Red Flags

**Never:**
- Create anything before checking whether the current workspace is already isolated
- Mistake a submodule for an existing linked worktree
- Create worktree without verifying it's ignored (project-local)
- Skip baseline test verification
- Proceed with failing tests without asking
- Assume directory location when ambiguous
- Skip CLAUDE.md check

**Always:**
- Prefer Claude Code's native worktree primitive before manual git fallback
- Follow directory priority: existing > CLAUDE.md > ask
- Verify directory is ignored for project-local
- Auto-detect and run project setup
- Verify clean baseline test state

## Integration

**Called by:**
- **superpower-planning:brainstorming** (Phase 4) - when design is approved and implementation follows
- **superpower-planning:executing-plans** - RECOMMENDED when starting on a shared branch
- Any skill needing isolated workspace

**Pairs with:**
- **superpower-planning:finishing-branch** - REQUIRED for cleanup after work complete
