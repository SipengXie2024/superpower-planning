#!/usr/bin/env bash
# Restore a stash entry back to active .planning/ state
#
# Usage: stash-restore.sh <stash-name-or-path> [project-root]
#
# Supports both:
#   - Directory-based stashes (new format): .planning/stash/<name>/
#   - Single-file stashes (legacy format): .planning/stash/<name>.md
#
# Restores agents/ into .planning/ and prints the paths the caller reads:
#   SNAPSHOT_FILE=<path>   snapshot.md, whose Task Note section goes back into the task note
#   OLDER_FILE=<path>      a progress.md / plan.md / design.md / findings.md saved by an
#                          older version of this plugin: move live status into the task
#                          note and any findings not yet in .planning/findings.md into it
# Does NOT delete the stash entry or overwrite .planning/findings.md.
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
    if [ -d "${STASH_PATH}/agents" ]; then
        cp -r "${STASH_PATH}/agents" "${PLANNING_DIR}/"
        echo "[stash-restore] Restored agents/"
    fi

    for f in "${STASH_PATH}"/*.md; do
        [ -f "$f" ] || continue
        [ "$(basename "$f")" = "snapshot.md" ] && continue
        echo "OLDER_FILE=$f"
    done

    echo "[stash-restore] Read ${STASH_PATH} (directory format)"

    # Output snapshot.md path if it exists (caller can read it for context)
    if [ -f "${STASH_PATH}/snapshot.md" ]; then
        echo "SNAPSHOT_FILE=${STASH_PATH}/snapshot.md"
    fi
else
    # Legacy format: single .md file — just report it for the LLM to process
    echo "[stash-restore] Legacy stash file: ${STASH_PATH}"
    echo "LEGACY_FILE=${STASH_PATH}"
    echo "[stash-restore] Caller should read this file: live status goes into the task note, lasting facts into .planning/findings.md"
fi
