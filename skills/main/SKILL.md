---
name: main
description: Skill router and planning initialization. Loaded on every session start. Determines which skills to invoke and ensures .planning/ is initialized for complex tasks.
---

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## How to Access Skills

**In Claude Code:** Use the `Skill` tool. When you invoke a skill, its content is loaded and presented to you -- follow it directly. Never use the Read tool on skill files.

**In other environments:** Check your platform's documentation for how skills are loaded.

# Using Skills

## The Rule

**Invoke relevant or requested skills BEFORE any response or action.** Even a 1% chance a skill might apply means you should invoke the skill to check. If an invoked skill turns out to be wrong for the situation, you don't need to use it.

## Planning Context

When starting a complex task (multi-step, research, >5 tool calls):

1. Check if `.planning/` directory exists in the project root
2. If NOT found, run `${CLAUDE_PLUGIN_ROOT}/scripts/init-planning-dir.sh` to initialize it
3. If FOUND, read the existing planning files to recover context (see Session Recovery below)

The `.planning/` directory is your "RAM on disk" -- persistent working memory that survives context resets.

## Session Recovery

On session start, check for an existing `.planning/` directory. If found:

1. Read `.planning/progress.md` -- Task Status Dashboard shows current status; session log shows what was done
2. Read `.planning/findings.md` -- recall discoveries and decisions
3. Read `.planning/task_plan.md` if it exists -- ad-hoc plans have phase/goal details here
4. Run `git diff --stat` to see what changed since last session
5. Update planning files with recovered context
6. Continue with the task

## Red Flags

These thoughts mean STOP -- you're rationalizing:

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Questions are tasks. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. |
| "I can check git/files quickly" | Files lack conversation context. Check for skills. |
| "Let me gather information first" | Skills tell you HOW to gather information. |
| "This doesn't need a formal skill" | If a skill exists, use it. |
| "I remember this skill" | Skills evolve. Read current version. |
| "This doesn't count as a task" | Action = task. Check for skills. |
| "The skill is overkill" | Simple things become complex. Use it. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |
| "This feels productive" | Undisciplined action wastes time. Skills prevent this. |
| "I know what that means" | Knowing the concept != using the skill. Invoke it. |

## Skill Priority

When multiple skills could apply, use this order:

1. **Process skills first** (brainstorming, debugging) -- these determine HOW to approach the task
2. **Implementation skills second** (executing-plans, tdd) -- these guide execution

"Let's build X" -> brainstorming first, then implementation skills.
"Fix this bug" -> debugging first, then domain-specific skills.

## Skill Types

**Rigid** (TDD, debugging): Follow exactly. Don't adapt away discipline.

**Flexible** (patterns): Adapt principles to context.

The skill itself tells you which.

## Available Skills

| Skill | Purpose |
|-------|---------|
| `superpower-planning:planning-foundation` | Persistent file-based planning with .planning/ directory. Foundation layer inherited by all other skills. |
| `superpower-planning:brainstorming` | Structured brainstorming before implementation. Think before you code. |
| `superpower-planning:writing-plans` | Write detailed implementation plans with phases and checkpoints. |
| `superpower-planning:executing-plans` | Execute plans phase-by-phase with progress tracking and error recovery. |
| `superpower-planning:subagent-driven` | Orchestrate work by dispatching subagents with clear task boundaries. |
| `superpower-planning:parallel-agents` | Run multiple subagents in parallel for independent tasks. |
| `superpower-planning:tdd` | Test-driven development: write tests first, then make them pass. |
| `superpower-planning:debugging` | Systematic debugging: reproduce, isolate, fix, verify. |
| `superpower-planning:git-worktrees` | Use git worktrees for parallel branch work without stashing. |
| `superpower-planning:finishing-branch` | Clean up and finalize a development branch before merge/PR. |
| `superpower-planning:requesting-review` | Prepare and submit code for review with context and rationale. |
| `superpower-planning:receiving-review` | Process review feedback systematically and address all comments. |
| `superpower-planning:verification` | Verify work is complete and correct before declaring done. |
| `superpower-planning:writing-skills` | Create new skills for this plugin following the skill format. |

## User Instructions

Instructions say WHAT, not HOW. "Add X" or "Fix Y" doesn't mean skip workflows.
