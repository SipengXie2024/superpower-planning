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

# Count complete tasks
COMPLETE=$(grep -c '| complete |' "$PROGRESS_FILE" || true)
COMPLETE_EMOJI=$(grep -c '| ✅ complete |' "$PROGRESS_FILE" || true)
COMPLETE=$((COMPLETE + COMPLETE_EMOJI))

# Count in_progress tasks
IN_PROGRESS=$(grep -c '| in_progress |' "$PROGRESS_FILE" || true)
IN_PROGRESS_EMOJI=$(grep -c '| ⏳ in_progress |' "$PROGRESS_FILE" || true)
IN_PROGRESS=$((IN_PROGRESS + IN_PROGRESS_EMOJI))

# Count pending tasks
PENDING=$(grep -c '| pending |' "$PROGRESS_FILE" || true)
PENDING_EMOJI=$(grep -c '| ⏳ pending |' "$PROGRESS_FILE" || true)
PENDING=$((PENDING + PENDING_EMOJI))

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
