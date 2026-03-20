#!/usr/bin/env bash
# Generate a unique filename with date prefix and optional numeric suffix
#
# Usage: unique-filename.sh <directory> <name> [extension]
#
# Output: full path to a unique file (does not create it)
#
# Examples:
#   unique-filename.sh .planning/stash my-feature
#   → .planning/stash/2026-03-19-my-feature.md
#
#   unique-filename.sh .planning/archive my-feature
#   → .planning/archive/2026-03-19-my-feature.md  (or -2, -3 if exists)

set -e

DIR="${1:?Usage: unique-filename.sh <directory> <name> [extension]}"
NAME="${2:?Usage: unique-filename.sh <directory> <name> [extension]}"
EXT="${3:-.md}"

DATE=$(date +%Y-%m-%d)
BASE="${DIR}/${DATE}-${NAME}"

# Try without suffix first
CANDIDATE="${BASE}${EXT}"
if [ ! -e "$CANDIDATE" ]; then
    echo "$CANDIDATE"
    exit 0
fi

# Add numeric suffix
SUFFIX=2
while [ -e "${BASE}-${SUFFIX}${EXT}" ]; do
    SUFFIX=$(( SUFFIX + 1 ))
done

echo "${BASE}-${SUFFIX}${EXT}"
