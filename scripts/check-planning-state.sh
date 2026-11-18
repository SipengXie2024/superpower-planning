#!/usr/bin/env bash
# Report what .planning/ holds on disk
#
# Usage: check-planning-state.sh [project-root]
#
# Output (one of):
#   missing   — no .planning/ directory
#   empty     — only findings.md (with or without entries); nothing in flight on disk
#   active    — agents/ files, or older-layout files (plan.md, design.md, a
#               progress.md with open tasks) from an earlier version of this plugin
#   complete  — an older-layout progress.md whose task rows are all complete
#
# The task in flight lives in the session's task note, which this script cannot
# see; callers judge that part themselves.
# Exit code is always 0; state is communicated via stdout.

set -e

PROJECT_ROOT="${1:-.}"
PLANNING_DIR="${PROJECT_ROOT}/.planning"
OLD_PROGRESS="${PLANNING_DIR}/progress.md"

if [ ! -d "$PLANNING_DIR" ]; then
    echo "missing"
    exit 0
fi

if [ -f "$OLD_PROGRESS" ]; then
    if grep -q 'ARCHIVE REMINDER' "$OLD_PROGRESS" 2>/dev/null; then
        echo "complete"
        exit 0
    fi
    total=$(grep -cE '\| (✅ )?(complete|in_progress|pending|blocked|skipped) \|' "$OLD_PROGRESS" 2>/dev/null || true)
    done_rows=$(grep -cE '\| (✅ )?complete \|' "$OLD_PROGRESS" 2>/dev/null || true)
    if [ "${total:-0}" -gt 0 ] && [ "${done_rows:-0}" -eq "$total" ]; then
        echo "complete"
        exit 0
    fi
    if [ "${total:-0}" -gt 0 ]; then
        echo "active"
        exit 0
    fi
fi

if [ -f "${PLANNING_DIR}/plan.md" ] || [ -f "${PLANNING_DIR}/design.md" ]; then
    echo "active"
    exit 0
fi

if [ -d "${PLANNING_DIR}/agents" ] && [ -n "$(find "${PLANNING_DIR}/agents" -name '*.md' -size +100c 2>/dev/null | head -1)" ]; then
    echo "active"
    exit 0
fi

echo "empty"
