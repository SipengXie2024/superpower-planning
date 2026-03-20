#!/usr/bin/env bash
# Detect the default base branch (main or master)
#
# Usage: detect-base-branch.sh [project-root]
#
# Tries: main, master, develop (in order).
# Output: branch name on stdout
# Exit 0 if found, 1 if none detected.

set -e

PROJECT_ROOT="${1:-.}"
cd "$PROJECT_ROOT"

for branch in main master develop; do
    if git rev-parse --verify "$branch" >/dev/null 2>&1; then
        echo "$branch"
        exit 0
    fi
    # Also check remote-only branches
    if git rev-parse --verify "origin/$branch" >/dev/null 2>&1; then
        echo "$branch"
        exit 0
    fi
done

echo "[detect-base-branch] Error: could not detect base branch (tried main, master, develop)" >&2
exit 1
