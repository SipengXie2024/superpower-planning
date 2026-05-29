---
description: Execute a reviewed implementation plan using the remaining execution paths.
disable-model-invocation: true
---

Before invoking any execution skill, you MUST:

1. **Locate the plan** — Check `.planning/plan.md`. If it does not exist, check `.planning/` state and suggest writing a plan first.

2. **Confirm the plan is ready for execution** — If the plan is incomplete, ambiguous, or clearly not review-ready, send it back through `superpower-planning:writing-plans` before execution.

3. **Read the plan** — Skim file decomposition, parallelism groups, task complexity, and verification steps.

4. **Present the execution strategy** — Use `AskUserQuestion` with exactly these three options:

   **1. Claude Code Dynamic Workflow** — Native workflow execution for large, parallel, or cross-checked work. Best for high parallelism, codebase-wide audits, migrations, or plan stress tests.

   **2. Codex-Driven (this session, sequential)** — Use `superpower-planning:subagent-driven-codex` to route implementer and reviewer roles through Codex CLI.

   **3. Manual Batch Session** — Use `superpower-planning:executing-plans` for batch execution with explicit checkpoints.

   Include your recommendation based on the plan's parallelism score, task weight, and whether workflow support is available.

5. **Execute the chosen path:**
   - Claude Code Dynamic Workflow → ask Claude to run a workflow that executes `.planning/plan.md` (include the word "workflow" in the request so Claude writes one), or use `/effort ultracode` if the user wants automatic workflow orchestration.
   - Codex-Driven → invoke `superpower-planning:subagent-driven-codex`
   - Manual Batch Session → invoke `superpower-planning:executing-plans`

## Notes

- Do not route to removed manual orchestration skills.
- If the plan reveals tightly coupled work with weak decomposition, revise the plan before execution instead of forcing a bad execution strategy.
- Dynamic workflows should still read and update `.planning/` files so durable project context survives the workflow run.
