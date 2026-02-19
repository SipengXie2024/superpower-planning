#!/bin/bash
# Check if all planning tasks are complete when Claude stops
# Called by Stop hook - only runs if .planning/progress.md exists

if [ ! -f .planning/progress.md ]; then
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
exec sh "$SCRIPT_DIR/check-complete.sh"
