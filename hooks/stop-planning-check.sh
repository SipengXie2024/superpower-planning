#!/bin/bash
# Stop hook: Check if top-level findings.md and progress.md are stale when agent stops
#
# Architecture: subagents write to their own .planning/agents/{role}/ files.
# The orchestrator/main agent aggregates into .planning/findings.md and .planning/progress.md.
# This hook only checks the top-level files — it's a reminder for the main agent.
# Subagents are guided by agent-context.md rules (2-Action Dispatch Rule) instead.

FINDINGS_FILE=".planning/findings.md"
PROGRESS_FILE=".planning/progress.md"

# Only active during planning sessions
[ -f "$FINDINGS_FILE" ] || exit 0

# Skip if this looks like a subagent (has an agent planning dir env var)
[ -n "$AGENT_PLANNING_DIR" ] && exit 0

NOW=$(date +%s)
STALE_THRESHOLD=300  # 5 minutes
WARNINGS=""

# Check findings.md freshness
if [ -f "$FINDINGS_FILE" ]; then
    MTIME=$(stat -c %Y "$FINDINGS_FILE" 2>/dev/null) || true
    if [ -n "$MTIME" ]; then
        AGE=$(( NOW - MTIME ))
        if [ "$AGE" -ge "$STALE_THRESHOLD" ]; then
            WARNINGS="${WARNINGS}[superpower-planning] findings.md hasn't been updated in $(( AGE / 60 ))m. Record any new discoveries, decisions, or surprises before ending.\n"
        fi
    fi
fi

# Check progress.md freshness
if [ -f "$PROGRESS_FILE" ]; then
    MTIME=$(stat -c %Y "$PROGRESS_FILE" 2>/dev/null) || true
    if [ -n "$MTIME" ]; then
        AGE=$(( NOW - MTIME ))
        if [ "$AGE" -ge "$STALE_THRESHOLD" ]; then
            WARNINGS="${WARNINGS}[superpower-planning] progress.md hasn't been updated in $(( AGE / 60 ))m. Update Task Status Dashboard and log recent actions before ending.\n"
        fi
    fi
fi

if [ -n "$WARNINGS" ]; then
    printf "%b" "$WARNINGS"
fi
