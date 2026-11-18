# Planning Rules for Delegated Roles

Your planning directory is `{AGENT_PLANNING_DIR}`.

1. **Write discoveries as you make them** — anything unexpected or important goes into `{AGENT_PLANNING_DIR}/findings.md` as a dated entry: what you found and the evidence.
2. **Record dead ends** — an approach that failed gets an entry with the reason it failed, so nobody retries it.
3. **Work through ordinary errors** — diagnose, then retry or fix. When the same check still fails after three rounds of fixes, stop and report to the orchestrator what each round tried and what it showed.
4. **Report status in your final message** — what was done, what was verified and how, what is left. There is no progress file.

## Critical for Orchestrator

Mark any finding that the orchestrator needs to know about with:
```
> **Critical for Orchestrator:** [description]
```

This helps the orchestrator aggregate important discoveries into the top-level .planning/findings.md.
