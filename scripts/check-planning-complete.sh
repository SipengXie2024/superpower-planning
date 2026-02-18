#!/bin/bash
# Check if all planning phases are complete when Claude stops
# Called by Stop hook - only runs if .planning/task_plan.md exists

if [ ! -f .planning/task_plan.md ]; then
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
exec sh "$SCRIPT_DIR/check-complete.sh"
