#!/usr/bin/env bash
# Copy the files of the work being stashed or archived into a target directory
#
# Usage: snapshot-save.sh <target-dir> [project-root]
#
# Copies agents/ and any older-layout files (progress.md, plan.md, design.md and
# other top-level .md files an earlier version of this plugin wrote) from
# .planning/ into <target-dir>. findings.md is not copied: it stays live in
# .planning/ as project knowledge. The caller writes snapshot.md or summary.md,
# which carries the task note. The target directory must already exist.
#
# Shared by both stashing and archiving workflows.
# Exit 0 on success, 1 on error.

set -e

TARGET_DIR="${1:?Usage: snapshot-save.sh <target-dir> [project-root]}"
PROJECT_ROOT="${2:-.}"
PLANNING_DIR="${PROJECT_ROOT}/.planning"

if [ ! -d "$PLANNING_DIR" ]; then
    echo "[snapshot-save] Error: no .planning/ directory at ${PLANNING_DIR}" >&2
    exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo "[snapshot-save] Error: target directory does not exist: ${TARGET_DIR}" >&2
    exit 1
fi

copied=0
for f in "${PLANNING_DIR}"/*.md; do
    [ -f "$f" ] || continue
    [ "$(basename "$f")" = "findings.md" ] && continue
    cp "$f" "${TARGET_DIR}/"
    copied=$(( copied + 1 ))
done

if [ -d "${PLANNING_DIR}/agents" ]; then
    cp -r "${PLANNING_DIR}/agents" "${TARGET_DIR}/"
    echo "[snapshot-save] Copied agents/"
fi

echo "[snapshot-save] Saved ${copied} files to ${TARGET_DIR}"
