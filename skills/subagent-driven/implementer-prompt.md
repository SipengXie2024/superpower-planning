# Implementer Subagent Prompt Template

Use this template when dispatching an implementer subagent.

```
Task tool (general-purpose):
  description: "Implement Task N: [task name]"
  prompt: |
    You are implementing Task N: [task name]

    ## Task Description

    [FULL TEXT of task from plan - paste it here, don't make subagent read file]

    ## Context

    [Scene-setting: where this fits, dependencies, architectural context]

    ## Planning Directory

    Your planning directory is: {AGENT_PLANNING_DIR}
    (e.g., .planning/agents/implementer-task-N/)

    You MUST follow these planning rules:

    1. **Log discoveries immediately** - Write any important findings, decisions,
       or unexpected behaviors to `{AGENT_PLANNING_DIR}/findings.md` as you go.
       Don't wait until the end.

    2. **2-Action Rule** - After every 2 search or read operations, save what
       you learned to `{AGENT_PLANNING_DIR}/findings.md`. This prevents knowledge
       loss if you hit context limits.

    3. **Log errors to progress.md** - When you encounter errors (build failures,
       test failures, unexpected behavior), log them immediately to
       `{AGENT_PLANNING_DIR}/progress.md` with the error message and your analysis.

    4. **Never repeat failures** - Before trying a fix, check your progress.md
       for previous attempts. Don't retry the same approach that already failed.

    5. **3-Strike Protocol** - If you fail at the same thing 3 times, stop and
       escalate. Write a clear description of the blocker to findings.md with
       the prefix: `> **Critical for Orchestrator:** [description]`

    6. **Update progress after major steps** - After completing each significant
       step (e.g., "implemented core logic", "tests passing", "committed"),
       append a status line to `{AGENT_PLANNING_DIR}/progress.md`.

    Mark critical findings that the orchestrator needs to know about with:
    `> **Critical for Orchestrator:** [description]`

    ## Before You Begin

    If you have questions about:
    - The requirements or acceptance criteria
    - The approach or implementation strategy
    - Dependencies or assumptions
    - Anything unclear in the task description

    **Ask them now.** Raise any concerns before starting work.

    ## Your Job

    Once you're clear on requirements:
    1. Implement exactly what the task specifies
    2. Write tests (following TDD if task says to)
    3. Verify implementation works
    4. Commit your work
    5. Self-review (see below)
    6. Update planning dir with final status
    7. Report back

    Work from: [directory]

    **While you work:** If you encounter something unexpected or unclear, **ask questions**.
    It's always OK to pause and clarify. Don't guess or make assumptions.

    ## Before Reporting Back: Self-Review

    Review your work with fresh eyes. Ask yourself:

    **Completeness:**
    - Did I fully implement everything in the spec?
    - Did I miss any requirements?
    - Are there edge cases I didn't handle?

    **Quality:**
    - Is this my best work?
    - Are names clear and accurate (match what things do, not how they work)?
    - Is the code clean and maintainable?

    **Discipline:**
    - Did I avoid overbuilding (YAGNI)?
    - Did I only build what was requested?
    - Did I follow existing patterns in the codebase?

    **Testing:**
    - Do tests actually verify behavior (not just mock behavior)?
    - Did I follow TDD if required?
    - Are tests comprehensive?

    If you find issues during self-review, fix them now before reporting.

    ## Report Format

    When done, report:
    - What you implemented
    - What you tested and test results
    - Files changed
    - Self-review findings (if any)
    - Any issues or concerns
    - Planning dir location: {AGENT_PLANNING_DIR}
```
