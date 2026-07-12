---
name: main
description: Skill router and planning initialization. Loaded on every session start. Determines which skills to invoke and ensures .planning/ is initialized for complex tasks.
---

<EXTREMELY-IMPORTANT>
If there is even a 1% chance a skill applies to your task, you MUST invoke it. No exceptions, no rationalizations.
</EXTREMELY-IMPORTANT>

## How to Access Skills

**In Claude Code:** Use the `Skill` tool. When you invoke a skill, its content is loaded and presented to you -- follow it directly. Never use the Read tool on skill files.

**In other environments:** Check your platform's documentation for how skills are loaded.

# Using Skills

## The Rule

Invoke relevant or requested skills BEFORE any response or action. Even a 1% chance a skill might apply means you should invoke the skill to check. If an invoked skill turns out to be wrong for the situation, you don't need to use it.

When multiple skills could apply: process skills first (brainstorming, debugging), then implementation support skills (executing-plans, tdd, requesting-review).

## Planning Context

When starting a complex task (multi-step, research, >5 tool calls):

1. Check if `.planning/` directory exists in the project root
2. If NOT found, run `${CLAUDE_PLUGIN_ROOT}/scripts/init-planning-dir.sh` to initialize it
3. If FOUND, read the existing planning files to recover context (see Session Recovery below)

The `.planning/` directory is your "RAM on disk" -- persistent working memory that survives context resets and Claude Code session boundaries.

## Session Recovery

On session start, check for an existing `.planning/` directory. If found:

1. Read `.planning/progress.md` -- Task Status Dashboard shows current status; session log shows what was done
2. Read `.planning/findings.md` -- recall discoveries and decisions
3. Run `git diff --stat` to see what changed since last session
4. Update planning files with recovered context
5. Continue with the task

## Planning Approach Routing

Work through these checks in order; stop at the first that matches.

1. **User named a mode** (e.g., "let's brainstorm", "/plan") OR you are already inside plan mode / brainstorming → use that mode, skip the rest.
2. **Trivial task** (typo, single-line fix) → just do it. No planning, no `AskUserQuestion`.
3. **Clear small implementation task** → implement directly in the current session. If it turns out to be multi-step, initialize `.planning/` mid-task and continue.
4. **Non-trivial task** (multi-step, architectural decisions, multi-file changes) → do NOT auto-call `EnterPlanMode` or `brainstorming`. Present the choice via `AskUserQuestion` with these three options:
   - **Quick Planning (Plan Mode)** — lightweight read-only exploration. Best for medium-scope tasks with a known approach, quick alignment before implementation.
   - **Structured Brainstorming** — full brainstorming pipeline (design doc, spec interview, implementation plan). Best for complex features, creative design decisions, multi-file refactors.
   - **Stash Current Work** — pause unfinished work safely, save current `.planning/` context into `.planning/stash/`, switch away cleanly. Best when changing projects or waiting on external input.

After the user picks, invoke the matching skill/mode; do not pre-commit to one before they answer.

**After Plan Mode completes:** If the approved plan reveals complex work (3+ tasks, multiple files), suggest transitioning to brainstorming/writing-plans for a formal implementation plan. Plan mode output can inform writing-plans — reference it, don't re-derive.

## Execution Routing

When the user requests plan execution (e.g., "execute the plan", "implement it", "start building"), do NOT route to removed manual orchestration skills. Instead:

1. If no plan exists at `.planning/plan.md`, invoke `superpower-planning:writing-plans` first.
2. If a plan exists, present the execution strategy choice via `AskUserQuestion`:
   - **Claude Code Dynamic Workflow** — recommended for large, parallel, or cross-checked work. Ask Claude to run a workflow for this plan (include the word "workflow" in the request so Claude writes one), or turn on `/effort ultracode` for automatic workflow orchestration.
   - **Codex-Driven** — `superpower-planning:subagent-driven-codex`, for sequential second-model implementation/review through Codex CLI.
   - **Manual Batch Session** — `superpower-planning:executing-plans`, for a separate/manual session that executes plan batches and stops at checkpoints.
3. Recommend based on: high parallelism + heavy tasks → Dynamic Workflow; need second-model executor → Codex-Driven; user wants manual checkpoints or workflow is unavailable → Manual Batch Session.

## Available Skills

| Skill | Purpose |
|-------|---------|
| `superpower-planning:planning-foundation` | Persistent file-based planning with `.planning/` directory. Foundation layer inherited by all other skills. |
| `superpower-planning:brainstorming` | Structured brainstorming before implementation. Think before you code. |
| `superpower-planning:spec-interview` | Refine design docs through systematic deep questioning. Auto-invoked after brainstorming. |
| `superpower-planning:writing-plans` | Write detailed implementation plans with phases, commands, and execution handoff. |
| `superpower-planning:executing-plans` | Execute written plans in a separate/manual batch session with `.planning/` updates and checkpoints. |
| `superpower-planning:subagent-driven-codex` | Execute plans in this session by delegating implementer/reviewer roles to Codex CLI via the bridge script. |
| `superpower-planning:collaborating-with-codex` | Bridge to OpenAI Codex CLI for bounded coding work, debugging, code analysis, or review. |
| `superpower-planning:collaborating-with-hermes` | Consult Hermes for independent analysis, research, code review, or a second opinion; pair it with Codex consultations. |
| `superpower-planning:perf-optimization` | Profile first, shrink the largest measured performance bottleneck, then re-profile. |
| `superpower-planning:tdd` | Test-driven development: write tests first, then make them pass. |
| `superpower-planning:debugging` | Systematic debugging: reproduce, isolate, fix, verify. |
| `superpower-planning:git-worktrees` | Use Claude Code native worktree isolation before implementation when needed. |
| `superpower-planning:archiving` | Archive completed plans, consolidate memory, and reset `.planning/` for the next task. |
| `superpower-planning:stashing` | Pause unfinished work, save it into `.planning/stash/`, and support later resume with stale-findings check. |
| `superpower-planning:requesting-review` | Prepare and submit code for review with context and rationale. |
| `superpower-planning:receiving-review` | Process review feedback systematically and address all comments. |
| `superpower-planning:releasing` | Bump versions, tag, and publish GitHub Releases with changelogs. |

## Review Routing

- For bounded code review tied to a plan, milestone, or merge readiness → use `requesting-review` / `receiving-review`.
- For large parallel review or adversarial cross-checking, prefer a Claude Code dynamic workflow rather than a plugin skill.

## Session Handoff

- For long-session independent audits, prefer a Claude Code dynamic workflow that dispatches multiple read-only agents and cross-checks their findings against source code.
- Keep `.planning/progress.md` and `.planning/findings.md` current so a fresh session or workflow has reliable file-based context.

## Stash / Resume Routing

- When the user says they want to pause current unfinished work, switch projects, or come back later: use `superpower-planning:stashing` or `/stash`
- When the user says they want to continue paused work, resume a previous project, or recover a stashed task: use `/resume-stash`
- Resume must include a stale-findings check before execution continues

## User Instructions

Instructions say WHAT, not HOW. "Add X" or "Fix Y" doesn't mean skip workflows.
