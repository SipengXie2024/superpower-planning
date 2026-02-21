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
    (e.g., .planning/agents/implementer/)

    **Do NOT create per-task directories** like `implementer-task-1/`. Use ONE directory per role.

    **MANDATORY — Planning Rules (do this BEFORE any implementation work):**

    1. Use the Read tool to read this file:
       `{CLAUDE_PLUGIN_ROOT}/skills/planning-foundation/templates/agent-context.md`
       This contains the 6 planning rules you MUST follow. Replace `{AGENT_PLANNING_DIR}` with your planning dir path.

    2. Check if `{AGENT_PLANNING_DIR}/findings.md` and `progress.md` already exist:
       - **If they exist:** Read them first to understand context from previous tasks, then APPEND to them.
       - **If they don't exist:** Initialize by copying the templates:
         - Read `{CLAUDE_PLUGIN_ROOT}/skills/planning-foundation/templates/findings.md` → write to `{AGENT_PLANNING_DIR}/findings.md`
         - Read `{CLAUDE_PLUGIN_ROOT}/skills/planning-foundation/templates/progress.md` → write to `{AGENT_PLANNING_DIR}/progress.md`

    **You MUST have `findings.md` and `progress.md` in your planning dir before writing any code. Do NOT create other files like `notes.md` — only use `findings.md` and `progress.md`.**

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

    **2-Action Rule:** After every 2 read/search/explore operations, save key findings to `{AGENT_PLANNING_DIR}/findings.md`. Don't wait until the end — record discoveries, decisions, and surprises as you go.

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
