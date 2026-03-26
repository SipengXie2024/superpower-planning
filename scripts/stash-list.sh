#!/usr/bin/env bash
# List available stash entries with summary info
#
# Usage: stash-list.sh [project-root]
#
# Supports both directory-based stashes (new) and single-file stashes (legacy).
# Output: one line per stash entry with date and name, or "none" if empty
# Exit 0 always

set -e

PROJECT_ROOT="${1:-.}"
STASH_DIR="${PROJECT_ROOT}/.planning/stash"

if [ ! -d "$STASH_DIR" ]; then
    echo "none"
    exit 0
fi

# Collect entries into an array
entries=()

# Directory-based stashes (new format)
for d in "$STASH_DIR"/*/; do
    [ -d "$d" ] || continue
    dname=$(basename "$d")
    meta_file=""
    if [ -f "$d/snapshot.md" ]; then
        meta_file="$d/snapshot.md"
    elif [ -f "$d/progress.md" ]; then
        meta_file="$d/progress.md"
    fi
    status="paused"
    goal=""
    if [ -n "$meta_file" ]; then
        status=$(grep -m1 '^\*\*Status:\*\*' "$meta_file" 2>/dev/null | sed 's/\*\*Status:\*\* //' || echo "paused")
        goal=$(sed -n '/^## Current Goal/,/^##/{/^## Current Goal/d;/^##/d;/^$/d;/^<!--/d;p;}' "$meta_file" 2>/dev/null | head -1 || echo "")
    fi
    if [ -n "$goal" ]; then
        entries+=("  - ${dname}  [${status}]  ${goal}")
    else
        entries+=("  - ${dname}  [${status}]")
    fi
done

# Legacy single-file stashes
for f in "$STASH_DIR"/*.md; do
    [ -f "$f" ] || continue
    fname=$(basename "$f" .md)
    status=$(grep -m1 '^\*\*Status:\*\*' "$f" 2>/dev/null | sed 's/\*\*Status:\*\* //' || echo "unknown")
    goal=$(sed -n '/^## Current Goal/,/^##/{/^## Current Goal/d;/^##/d;/^$/d;/^<!--/d;p;}' "$f" 2>/dev/null | head -1 || echo "")
    if [ -n "$goal" ]; then
        entries+=("  - ${fname}  [${status}]  ${goal}  (legacy)")
    else
        entries+=("  - ${fname}  [${status}]  (legacy)")
    fi
done

if [ "${#entries[@]}" -eq 0 ]; then
    echo "none"
else
    echo "Available stashes:"
    for entry in "${entries[@]}"; do
        echo "$entry"
    done
fi
