---
name: git-worktrees
description: Detect existing git worktree isolation and set up an isolated branch checkout (native EnterWorktree or manual git worktree add), distinguishing worktrees from submodules. Use when starting feature work that needs isolation, parallel branches, or a separate workspace, or before executing implementation plans.
---

# Using Git Worktrees

## Overview

Prefer Claude Code's native worktree support. This skill is now a thin safety guide, not a custom worktree orchestration layer.

**Core principle:** Detect existing isolation first, use Claude Code's native worktree primitive when possible, and avoid manual git worktree management unless the native path is unavailable.

**Announce at start:** "I'm using the git-worktrees skill to set up or verify isolated workspace state."

## Detect Existing Isolation First

Before creating anything, check whether the current checkout is already isolated:

```bash
git_dir=$(git rev-parse --git-dir)
git_common=$(git rev-parse --git-common-dir)
superproject=$(git rev-parse --show-superproject-working-tree 2>/dev/null)
```

Decision rules:

- If `git_dir != git_common` and `superproject` is empty, you are already in a linked worktree. Report the current path and do not create another one.
- If `superproject` is non-empty, you are inside a submodule. Do not treat `git_dir != git_common` alone as proof of worktree isolation.
- If the repository has no git metadata, do not create a worktree.

**Ground every claim in real state.** Never repeat the user's description of the working tree ("half-done changes", "a typo on line 12") as established fact — run `git status` and read the actual file/line before describing what is there. If reality differs from the claim, say so. Address the user directly; do not narrate which detection block or skill step you ran.

## Native Claude Code Path

Use the native Claude Code worktree flow whenever available:

- CLI: start a new isolated session with `claude --worktree <name>`
- In-session: ask Claude to work in a worktree — it creates one with the `EnterWorktree` tool
- For agent isolation: ask Claude Code to use worktrees for agents when spawning agents or workflows that edit files

Let Claude Code own the path, branch naming, copying of gitignored files, and cleanup behavior where possible.

## Manual Fallback

Only use manual `git worktree add` when the native Claude Code path is unavailable and the user still wants an isolated checkout.

When doing so:

1. Prefer an existing `.worktrees/` or `worktrees/` directory if present.
2. If no directory exists, ask the user where to create worktrees.
3. For project-local directories, verify they are ignored before creation:

```bash
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

4. If the intended project-local directory is not ignored, add it to `.gitignore` before creating the worktree.
5. Create the worktree:

```bash
git worktree add "<path>" -b "<branch-name>"
```

6. Report the path and branch. Run setup/tests only when the user asks or the surrounding workflow requires a clean baseline.

## Quick Reference

| Situation | Action |
|-----------|--------|
| Already in linked worktree | Reuse it; do not create another |
| Inside submodule | Do not infer worktree isolation from `git_dir != git_common` |
| Native Claude Code worktree available | Use it first |
| Manual project-local worktree | Verify ignored path before creation |
| No git repo | Do not create a worktree |
| Ambiguous location | Ask the user |

## Red Flags

Never:

- Create anything before checking current isolation
- Mistake a submodule for a linked worktree
- Create a project-local worktree directory that is not ignored
- Delete a worktree or branch unless the user explicitly asks
- Assume every implementation task needs a worktree

## Integration

Called by:

- `superpower-planning:brainstorming` when the user wants implementation isolation after design approval
- `superpower-planning:executing-plans` when starting from a shared or risky branch
- `superpower-planning:subagent-driven-codex` when Codex should operate in an isolated checkout
