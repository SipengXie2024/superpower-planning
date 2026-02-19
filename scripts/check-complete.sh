#!/bin/bash
# Check if all tasks in .planning/progress.md Dashboard are complete
# Always exits 0 -- uses stdout for status reporting
# Used by Stop hook to report task completion status

PROGRESS_FILE="${1:-.planning/progress.md}"

if [ ! -f "$PROGRESS_FILE" ]; then
    echo "[superpower-planning] No .planning/progress.md found -- no active planning session."
    exit 0
fi

# Count total tasks: lines matching "| Task " pattern but excluding the header row
TOTAL=$(grep -c '^| Task [^|]' "$PROGRESS_FILE" || true)

# Count complete tasks (match with or without emoji prefix)
COMPLETE=$(grep -cE '\| (✅ )?complete \|' "$PROGRESS_FILE" || true)

# Count in_progress tasks (match with or without emoji prefix)
IN_PROGRESS=$(grep -cE '\| (⏳ )?in_progress \|' "$PROGRESS_FILE" || true)

# Count pending tasks (match with or without emoji prefix)
PENDING=$(grep -cE '\| (⏳ )?pending \|' "$PROGRESS_FILE" || true)

# Default to 0 if empty
: "${TOTAL:=0}"
: "${COMPLETE:=0}"
: "${IN_PROGRESS:=0}"
: "${PENDING:=0}"

# Report status (always exit 0 -- incomplete task is a normal state)
if [ "$COMPLETE" -eq "$TOTAL" ] && [ "$TOTAL" -gt 0 ]; then
    echo "[superpower-planning] ALL TASKS COMPLETE ($COMPLETE/$TOTAL)"
else
    echo "[superpower-planning] Task in progress ($COMPLETE/$TOTAL tasks complete)"
    if [ "$IN_PROGRESS" -gt 0 ]; then
        echo "[superpower-planning] $IN_PROGRESS task(s) still in progress."
    fi
    if [ "$PENDING" -gt 0 ]; then
        echo "[superpower-planning] $PENDING task(s) pending."
    fi
fi
exit 0
