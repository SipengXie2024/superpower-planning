#!/bin/bash
# Stop hook: Check if top-level findings.md is stale when agent stops
#
# Architecture: subagents write to their own .planning/agents/{role}/findings.md.
# The orchestrator/main agent aggregates into .planning/findings.md.
# This hook only checks the top-level file — it's a reminder for the main agent.
# Subagents are guided by agent-context.md rules (2-Action Rule) instead.

FINDINGS_FILE=".planning/findings.md"

# Only active during planning sessions
[ -f "$FINDINGS_FILE" ] || exit 0

# Skip if this looks like a subagent (has an agent planning dir env var)
[ -n "$AGENT_PLANNING_DIR" ] && exit 0

# Check mtime
MTIME=$(stat -c %Y "$FINDINGS_FILE" 2>/dev/null) || exit 0
NOW=$(date +%s)
AGE=$(( NOW - MTIME ))

if [ "$AGE" -ge 300 ]; then
    echo "[superpower-planning] findings.md hasn't been updated in $(( AGE / 60 ))m. Consider recording any new discoveries, decisions, or surprises before ending this session."
fi
