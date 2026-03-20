#!/usr/bin/env bash
# Aggregate agent findings into top-level .planning/ files
#
# Usage: aggregate-agent-findings.sh <agent-role> [task-heading] [project-root]
#
# Reads .planning/agents/<role>/findings.md and extracts lines marked with
# "Critical for Orchestrator". Appends them to .planning/findings.md under
# the given task heading.
#
# Also appends a status summary from the agent's progress.md to .planning/progress.md.
#
# Exit 0 on success, 1 if agent dir not found.

set -e

ROLE="${1:?Usage: aggregate-agent-findings.sh <agent-role> [task-heading] [project-root]}"
TASK_HEADING="${2:-Agent: ${ROLE}}"
PROJECT_ROOT="${3:-.}"
PLANNING_DIR="${PROJECT_ROOT}/.planning"
AGENT_DIR="${PLANNING_DIR}/agents/${ROLE}"

if [ ! -d "$AGENT_DIR" ]; then
    echo "[aggregate] Agent dir not found: ${AGENT_DIR}" >&2
    exit 1
fi

# Extract critical findings
AGENT_FINDINGS="${AGENT_DIR}/findings.md"
TOP_FINDINGS="${PLANNING_DIR}/findings.md"

if [ -f "$AGENT_FINDINGS" ] && [ -f "$TOP_FINDINGS" ]; then
    critical_items=$(grep -i 'Critical for Orchestrator' "$AGENT_FINDINGS" 2>/dev/null || true)
    if [ -n "$critical_items" ]; then
        {
            echo ""
            echo "### ${TASK_HEADING}"
            echo "$critical_items"
        } >> "$TOP_FINDINGS"
        count=$(echo "$critical_items" | wc -l)
        echo "[aggregate] Appended ${count} critical items from ${ROLE} to findings.md"
    else
        echo "[aggregate] No critical items found in ${ROLE}/findings.md"
    fi
fi

# Append agent progress summary
AGENT_PROGRESS="${AGENT_DIR}/progress.md"
TOP_PROGRESS="${PLANNING_DIR}/progress.md"

if [ -f "$AGENT_PROGRESS" ] && [ -f "$TOP_PROGRESS" ]; then
    # Extract the last session section (most recent work)
    last_section=$(tail -20 "$AGENT_PROGRESS" 2>/dev/null || true)
    if [ -n "$last_section" ]; then
        {
            echo ""
            echo "### ${TASK_HEADING} (from ${ROLE})"
            echo "$last_section"
        } >> "$TOP_PROGRESS"
        echo "[aggregate] Appended progress summary from ${ROLE} to progress.md"
    fi
fi
