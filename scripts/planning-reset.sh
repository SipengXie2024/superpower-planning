#!/usr/bin/env bash
# Clear the stashed or archived work out of .planning/, keeping findings.md
#
# Usage: planning-reset.sh [project-root]
#
# Removes: agents/ and older-layout top-level files (progress.md, plan.md,
#          design.md and any other top-level .md except findings.md)
# Keeps:   findings.md (project knowledge outlives the task), archive/, stash/
# Run it only after snapshot-save.sh has copied those files somewhere.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT_ROOT="${1:-.}"
PLANNING_DIR="${PROJECT_ROOT}/.planning"

if [ ! -d "$PLANNING_DIR" ]; then
    echo "[planning-reset] No .planning/ directory found. Nothing to reset."
    exit 0
fi

for f in "${PLANNING_DIR}"/*.md; do
    [ -f "$f" ] || continue
    [ "$(basename "$f")" = "findings.md" ] && continue
    rm -f "$f"
    echo "[planning-reset] Removed $(basename "$f")"
done

if [ -d "${PLANNING_DIR}/agents" ]; then
    rm -rf "${PLANNING_DIR}/agents"
    echo "[planning-reset] Removed .planning/agents/"
fi

# Recreates findings.md from the template only if it is absent
"${SCRIPT_DIR}/init-planning-dir.sh" "$PROJECT_ROOT" >/dev/null

echo "[planning-reset] .planning/ cleared (findings.md, archive/ and stash/ kept)"
