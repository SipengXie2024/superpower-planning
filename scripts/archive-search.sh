#!/usr/bin/env bash
# Search archive entries for relevant historical context
#
# Usage: archive-search.sh [keyword] [project-root]
#
# Lists archive entries. If keyword is provided, filters to entries whose
# summary.md (or the archive .md file for legacy format) contains the keyword.
#
# Output: one line per matching archive with path and summary excerpt.
# Exit 0 always.

set -e

KEYWORD="${1:-}"
PROJECT_ROOT="${2:-.}"
ARCHIVE_DIR="${PROJECT_ROOT}/.planning/archive"

if [ ! -d "$ARCHIVE_DIR" ]; then
    echo "none"
    exit 0
fi

found=false

# Directory-based archives (new format)
for d in "$ARCHIVE_DIR"/*/; do
    [ -d "$d" ] || continue
    dname=$(basename "$d")

    # Try summary.md first, fall back to any .md file
    summary_file=""
    if [ -f "$d/summary.md" ]; then
        summary_file="$d/summary.md"
    fi

    if [ -n "$KEYWORD" ] && [ -n "$summary_file" ]; then
        if ! grep -qi "$KEYWORD" "$summary_file" 2>/dev/null; then
            # Also check design.md and plan.md
            match=false
            for f in "$d/design.md" "$d/plan.md" "$d/findings.md"; do
                if [ -f "$f" ] && grep -qi "$KEYWORD" "$f" 2>/dev/null; then
                    match=true
                    break
                fi
            done
            [ "$match" = false ] && continue
        fi
    fi

    found=true
    # Extract first meaningful line from summary
    excerpt=""
    if [ -n "$summary_file" ]; then
        excerpt=$(sed -n '/^## Summary/,/^##/{/^## Summary/d;/^##/d;/^$/d;/^<!--/d;p;}' "$summary_file" 2>/dev/null | head -1 || echo "")
    fi
    echo "  ${dname}/  ${excerpt}"
done

# Legacy single-file archives
for f in "$ARCHIVE_DIR"/*.md; do
    [ -f "$f" ] || continue
    fname=$(basename "$f" .md)

    if [ -n "$KEYWORD" ]; then
        if ! grep -qi "$KEYWORD" "$f" 2>/dev/null; then
            continue
        fi
    fi

    found=true
    excerpt=$(sed -n '/^## Summary/,/^##/{/^## Summary/d;/^##/d;/^$/d;/^<!--/d;p;}' "$f" 2>/dev/null | head -1 || echo "")
    echo "  ${fname}  ${excerpt}  (legacy)"
done

if [ "$found" = false ]; then
    echo "none"
fi
