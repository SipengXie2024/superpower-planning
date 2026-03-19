#!/usr/bin/env bash
# List available stash files with summary info
#
# Usage: stash-list.sh [project-root]
#
# Output: one line per stash file with date and name, or "none" if empty
# Exit 0 always

set -e

PROJECT_ROOT="${1:-.}"
STASH_DIR="${PROJECT_ROOT}/.planning/stash"

if [ ! -d "$STASH_DIR" ]; then
    echo "none"
    exit 0
fi

FILE_COUNT=$(find "$STASH_DIR" -maxdepth 1 -name '*.md' -type f 2>/dev/null | wc -l)

if [ "$FILE_COUNT" -eq 0 ]; then
    echo "none"
    exit 0
fi

echo "Available stashes:"
find "$STASH_DIR" -maxdepth 1 -name '*.md' -type f 2>/dev/null | sort | while IFS= read -r f; do
    fname=$(basename "$f" .md)
    # Extract status line from the stash file
    status=$(grep -m1 '^\*\*Status:\*\*' "$f" 2>/dev/null | sed 's/\*\*Status:\*\* //' || echo "unknown")
    # Extract current goal (first line of that section)
    goal=$(sed -n '/^## Current Goal/,/^##/{/^## Current Goal/d;/^##/d;/^$/d;/^<!--/d;p;}' "$f" 2>/dev/null | head -1 || echo "")
    if [ -n "$goal" ]; then
        echo "  - ${fname}  [${status}]  ${goal}"
    else
        echo "  - ${fname}  [${status}]"
    fi
done
