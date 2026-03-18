---
description: Resume paused work from .planning/stash/, restore active planning state, and check whether saved findings are stale.
disable-model-invocation: true
---

Invoke the `superpower-planning:stashing` skill and follow its resume protocol exactly:
1. Check if active `.planning/` has any meaningful content (unfinished, completed, or agent state) — offer stash/archive/overwrite options if conflict exists
2. List available stash files in `.planning/stash/`
3. Ask the user which stash to resume if multiple exist
4. Restore the selected stash into active `.planning/`
5. Run the stale-findings check before continuing
