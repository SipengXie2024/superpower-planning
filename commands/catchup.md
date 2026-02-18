---
name: catchup
description: Recover context from previous session using .planning/ files
---

Invoke the `superpower-planning:planning-foundation` skill and follow its session recovery instructions:

1. Run the session catchup script
2. Read .planning/progress.md (Task Status Dashboard + session log), .planning/findings.md
3. Read .planning/task_plan.md if it exists (ad-hoc plans only)
4. Run `git diff --stat` to see what changed
5. Update planning files based on recovered context
6. Continue with the task
