#!/usr/bin/env bash
# Copy the files of the work being stashed or archived into a target directory
#
# Usage: snapshot-save.sh <target-dir> [project-root]
#
# Copies agents/ and the files earlier versions of this plugin kept
# (progress.md, plan.md, design.md) from .planning/ into <target-dir>. Nothing
# else is touched: findings.md stays live as project knowledge, and other files
# the user keeps in .planning/ are not this plugin's to move. The caller writes snapshot.md or summary.md,
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
for f in progress.md plan.md design.md; do
    if [ -f "${PLANNING_DIR}/$f" ]; then
        cp "${PLANNING_DIR}/$f" "${TARGET_DIR}/"
        copied=$(( copied + 1 ))
    fi
done

if [ -d "${PLANNING_DIR}/agents" ]; then
    cp -r "${PLANNING_DIR}/agents" "${TARGET_DIR}/"
    echo "[snapshot-save] Copied agents/"
fi

echo "[snapshot-save] Saved ${copied} files to ${TARGET_DIR}"
