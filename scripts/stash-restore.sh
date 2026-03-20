#!/usr/bin/env bash
# Restore a stash entry back to active .planning/ state
#
# Usage: stash-restore.sh <stash-name-or-path> [project-root]
#
# Supports both:
#   - Directory-based stashes (new format): .planning/stash/<name>/
#   - Single-file stashes (legacy format): .planning/stash/<name>.md
#
# Copies files from the stash back to .planning/ root.
# Does NOT delete the stash entry or reset .planning/ — caller handles that.
#
# Exit 0 on success, 1 on error.

set -e

STASH_INPUT="${1:?Usage: stash-restore.sh <stash-name-or-path> [project-root]}"
PROJECT_ROOT="${2:-.}"
PLANNING_DIR="${PROJECT_ROOT}/.planning"
STASH_DIR="${PLANNING_DIR}/stash"

# Resolve stash path
if [ -d "$STASH_INPUT" ]; then
    # Full path provided and it's a directory
    STASH_PATH="$STASH_INPUT"
    FORMAT="directory"
elif [ -d "${STASH_DIR}/${STASH_INPUT}" ]; then
    # Name provided, directory exists
    STASH_PATH="${STASH_DIR}/${STASH_INPUT}"
    FORMAT="directory"
elif [ -f "$STASH_INPUT" ]; then
    # Full path provided and it's a file
    STASH_PATH="$STASH_INPUT"
    FORMAT="legacy"
elif [ -f "${STASH_DIR}/${STASH_INPUT}.md" ]; then
    # Name provided, legacy file exists
    STASH_PATH="${STASH_DIR}/${STASH_INPUT}.md"
    FORMAT="legacy"
else
    echo "[stash-restore] Error: stash not found: ${STASH_INPUT}" >&2
    exit 1
fi

if [ "$FORMAT" = "directory" ]; then
    restored=0
    for f in design.md plan.md findings.md progress.md; do
        if [ -f "${STASH_PATH}/$f" ]; then
            cp "${STASH_PATH}/$f" "${PLANNING_DIR}/"
            restored=$(( restored + 1 ))
        fi
    done

    if [ -d "${STASH_PATH}/agents" ]; then
        cp -r "${STASH_PATH}/agents" "${PLANNING_DIR}/"
        echo "[stash-restore] Restored agents/"
    fi

    echo "[stash-restore] Restored ${restored} files from ${STASH_PATH} (directory format)"

    # Output snapshot.md path if it exists (caller can read it for context)
    if [ -f "${STASH_PATH}/snapshot.md" ]; then
        echo "SNAPSHOT_FILE=${STASH_PATH}/snapshot.md"
    fi
else
    # Legacy format: single .md file — just report it for the LLM to process
    echo "[stash-restore] Legacy stash file: ${STASH_PATH}"
    echo "LEGACY_FILE=${STASH_PATH}"
    echo "[stash-restore] Caller should read this file and extract context into .planning/ files"
fi
