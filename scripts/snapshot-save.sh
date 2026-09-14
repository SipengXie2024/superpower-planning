#!/usr/bin/env bash
# Save a snapshot of the active .planning/ project to a target directory
#
# Usage: snapshot-save.sh <target-dir> [project-root]
#
# Copies design.md, plan.md, findings.md, progress.md, and agents/ (if they exist)
# from .planning/ into <target-dir>. The target directory must already exist.
#
# Shared by both stashing and archiving workflows.
#
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

# Copy core project files
for f in design.md plan.md findings.md progress.md; do
    if [ -f "${PLANNING_DIR}/$f" ]; then
        cp "${PLANNING_DIR}/$f" "${TARGET_DIR}/"
        copied=$(( copied + 1 ))
    fi
done

# Copy agents directory if it exists and has content
if [ -d "${PLANNING_DIR}/agents" ]; then
    cp -r "${PLANNING_DIR}/agents" "${TARGET_DIR}/"
    echo "[snapshot-save] Copied agents/"
fi

echo "[snapshot-save] Saved ${copied} files to ${TARGET_DIR}"
