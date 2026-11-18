#!/usr/bin/env bash
# Clear the stashed or archived work out of .planning/, keeping findings.md
#
# Usage: planning-reset.sh [project-root]
#
# Removes: agents/ and the files earlier versions of this plugin kept
#          (progress.md, plan.md, design.md)
# Keeps:   findings.md (project knowledge outlives the task), archive/, stash/,
#          and any other file the user keeps in .planning/
# Run it only after snapshot-save.sh has copied those files somewhere.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT_ROOT="${1:-.}"
PLANNING_DIR="${PROJECT_ROOT}/.planning"

if [ ! -d "$PLANNING_DIR" ]; then
    echo "[planning-reset] No .planning/ directory found. Nothing to reset."
    exit 0
fi

for f in progress.md plan.md design.md; do
    if [ -f "${PLANNING_DIR}/$f" ]; then
        rm -f "${PLANNING_DIR}/$f"
        echo "[planning-reset] Removed $f"
    fi
done

if [ -d "${PLANNING_DIR}/agents" ]; then
    rm -rf "${PLANNING_DIR}/agents"
    echo "[planning-reset] Removed .planning/agents/"
fi

# Recreates findings.md from the template only if it is absent
"${SCRIPT_DIR}/init-planning-dir.sh" "$PROJECT_ROOT" >/dev/null

echo "[planning-reset] .planning/ cleared (findings.md, archive/ and stash/ kept)"
