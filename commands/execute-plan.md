---
description: Execute a reviewed implementation plan using the best execution strategy
disable-model-invocation: true
---

Before invoking any execution skill, you MUST:

1. **Locate the plan** — Check `.planning/plan.md`. If it does not exist, check `.planning/` state and suggest writing a plan first.

2. **Confirm the plan is ready for execution** — The plan should already have gone through `writing-plans`, including its plan review loop. If you discover the plan is incomplete, ambiguous, or clearly not review-ready, send it back through `superpower-planning:writing-plans` before execution.

3. **Read the plan** — Skim the plan to understand its file decomposition, parallelism groups, task complexity, and verification steps.

4. **Present the execution strategy** — Use `AskUserQuestion` with exactly these three options:

   **1. Subagent-Driven (this session, sequential)** — Fresh subagent per task, two-stage review, serial execution. Best for light tasks with serial dependencies.

   **2. Team-Driven (this session, parallel)** — Agent Team with parallel implementers + dedicated reviewer. Best when tasks are heavy or parallelizable.

   **3. Parallel Session (separate session)** — Open new session with executing-plans, batch execution with human checkpoints.

   Include your recommendation based on the plan's parallelism score and task weight.

5. **Invoke the chosen skill:**
   - Subagent-Driven → `superpower-planning:subagent-driven`
   - Team-Driven → `superpower-planning:team-driven`
   - Parallel Session → `superpower-planning:executing-plans`

## Notes

- Do not skip straight from a rough plan to execution.
- Execution routing exists because different plans need different orchestration styles.
- If the plan reveals tightly coupled work with weak decomposition, it may need to be revised before execution instead of forcing a bad execution strategy.
