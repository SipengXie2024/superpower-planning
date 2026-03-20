#!/usr/bin/env bash
# Reset .planning/ to clean state while preserving archive/ and stash/
#
# Usage: planning-reset.sh [project-root]
#
# Removes: progress.md, findings.md, agents/
# Preserves: archive/, stash/
# Then runs init-planning-dir.sh to recreate canonical files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT_ROOT="${1:-.}"
PLANNING_DIR="${PROJECT_ROOT}/.planning"

if [ ! -d "$PLANNING_DIR" ]; then
    echo "[planning-reset] No .planning/ directory found. Nothing to reset."
    exit 0
fi

# Remove active planning files
rm -f "${PLANNING_DIR}/progress.md"
rm -f "${PLANNING_DIR}/findings.md"
rm -f "${PLANNING_DIR}/design.md"
rm -f "${PLANNING_DIR}/plan.md"

# Remove agents directory
if [ -d "${PLANNING_DIR}/agents" ]; then
    rm -rf "${PLANNING_DIR}/agents"
    echo "[planning-reset] Removed .planning/agents/"
fi

# Recreate canonical files from templates
"${SCRIPT_DIR}/init-planning-dir.sh" "$PROJECT_ROOT"

echo "[planning-reset] .planning/ reset to clean state (archive/ and stash/ preserved)"
