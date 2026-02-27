---
description: Execute an implementation plan using the best execution strategy
disable-model-invocation: true
---

Before invoking any execution skill, you MUST:

1. **Locate the plan** — Check `docs/plans/` for the most recent `*-implementation.md` file. If multiple exist, ask the user which plan to execute via `AskUserQuestion`.

2. **Read the plan** — Skim the plan to understand its parallelism groups and task complexity.

3. **Present the execution strategy** — Use `AskUserQuestion` with exactly these three options:

   **1. Subagent-Driven (this session, sequential)** — Fresh subagent per task, two-stage review, serial execution. Best for light tasks with serial dependencies.

   **2. Team-Driven (this session, parallel)** — Agent Team with parallel implementers + dedicated reviewer. Best when tasks are heavy or parallelizable.

   **3. Parallel Session (separate session)** — Open new session with executing-plans, batch execution with human checkpoints.

   Include your recommendation based on the plan's parallelism score and task weight.

4. **Invoke the chosen skill:**
   - Subagent-Driven → `superpower-planning:subagent-driven`
   - Team-Driven → `superpower-planning:team-driven`
   - Parallel Session → `superpower-planning:executing-plans`
