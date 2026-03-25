#!/usr/bin/env bash
# Attention refocus: re-inject plan goal before state-modifying tools.
# Fights "lost in the middle" by pushing objectives to attention window tail.
#
# Triggered by PreToolUse on Bash, Write, Edit.
# Inspired by Manus AI's attention manipulation technique.
set -e

PLAN_FILE=".planning/plan.md"
[ -f "$PLAN_FILE" ] || exit 0

# Extract goal from plan header
GOAL=$(grep -m1 -F '**Goal:**' "$PLAN_FILE" 2>/dev/null || true)
[ -z "$GOAL" ] && exit 0

echo "[PLAN REFOCUS] $GOAL"

# Show active (non-complete) tasks from progress dashboard
if [ -f ".planning/progress.md" ]; then
  awk '/^\| *Task /{found=1;next} found && /^\|[-| ]+$/{next} found && /^\|/ && !/✅/{print; if(++c>=3)exit} found && !/^\|/{exit}' ".planning/progress.md" 2>/dev/null || true
fi
