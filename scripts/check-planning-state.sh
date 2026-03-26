#!/usr/bin/env bash
# Check if .planning/ has meaningful content beyond empty templates
#
# Usage: check-planning-state.sh [project-root]
#
# Output (one of):
#   missing    — no .planning/ directory
#   empty      — files exist but are template-only (no real content)
#   complete   — all tasks marked complete or ARCHIVE REMINDER present
#   active     — work in progress with real content
#
# Exit code is always 0; state is communicated via stdout.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT_ROOT="${1:-.}"
PLANNING_DIR="${PROJECT_ROOT}/.planning"
PROGRESS="${PLANNING_DIR}/progress.md"
FINDINGS="${PLANNING_DIR}/findings.md"
TEMPLATE_DIR="${SCRIPT_DIR}/../skills/planning-foundation/templates"

if [ ! -d "$PLANNING_DIR" ]; then
    echo "missing"
    exit 0
fi

if [ ! -f "$PROGRESS" ] && [ ! -f "$FINDINGS" ]; then
    echo "empty"
    exit 0
fi

# Check for ARCHIVE REMINDER
if [ -f "$PROGRESS" ] && grep -q 'ARCHIVE REMINDER' "$PROGRESS" 2>/dev/null; then
    echo "complete"
    exit 0
fi

# Check if all tasks are complete (reuse check-complete logic)
if [ -f "$PROGRESS" ]; then
    TOTAL=$(grep -cE '\| (✅ )?(complete|in_progress|pending|blocked|skipped) \|' "$PROGRESS" 2>/dev/null || true)
    COMPLETE=$(grep -cE '\| (✅ )?complete \|' "$PROGRESS" 2>/dev/null || true)

    if [ "${TOTAL:-0}" -gt 0 ] && [ "$COMPLETE" -eq "$TOTAL" ]; then
        echo "complete"
        exit 0
    fi
fi

# Compare against templates to detect unmodified files
has_content=false

if [ -f "$PROGRESS" ]; then
    if [ -f "${TEMPLATE_DIR}/progress.md" ]; then
        # Quick size check: if progress is significantly larger than template, it has content
        template_lines=$(wc -l < "${TEMPLATE_DIR}/progress.md")
        progress_lines=$(wc -l < "$PROGRESS")
        if [ "$progress_lines" -gt $(( template_lines + 3 )) ]; then
            has_content=true
        else
            # Check for actual task rows in dashboard (not empty table)
            task_rows=$(grep -cE '\| (✅ )?(complete|in_progress|pending|blocked|skipped) \|' "$PROGRESS" 2>/dev/null || true)
            if [ "${task_rows:-0}" -gt 0 ]; then
                has_content=true
            fi
        fi
    else
        # No template to compare against — check for task rows
        task_rows=$(grep -cE '\| (✅ )?(complete|in_progress|pending|blocked|skipped) \|' "$PROGRESS" 2>/dev/null || true)
        if [ "${task_rows:-0}" -gt 0 ]; then
            has_content=true
        fi
    fi
fi

if [ "$has_content" = false ] && [ -f "$FINDINGS" ]; then
    if [ -f "${TEMPLATE_DIR}/findings.md" ]; then
        # Compare findings against template (byte-level)
        if ! diff -q "$FINDINGS" "${TEMPLATE_DIR}/findings.md" >/dev/null 2>&1; then
            # Files differ — check if the difference is meaningful
            # (not just trailing whitespace)
            diff_lines=$(diff "${TEMPLATE_DIR}/findings.md" "$FINDINGS" 2>/dev/null | grep -cE '^[<>]' || true)
            if [ "${diff_lines:-0}" -gt 0 ]; then
                has_content=true
            fi
        fi
    else
        # No template — check for non-empty bullets or table data
        real_bullets=$(grep -cE '^\- .+' "$FINDINGS" 2>/dev/null || true)
        if [ "${real_bullets:-0}" -gt 0 ]; then
            has_content=true
        fi
    fi
fi

# Check agent files
if [ "$has_content" = false ] && [ -d "${PLANNING_DIR}/agents" ]; then
    agent_files=$(find "${PLANNING_DIR}/agents" -name '*.md' -size +100c 2>/dev/null | head -1)
    if [ -n "$agent_files" ]; then
        has_content=true
    fi
fi

# Check design.md and plan.md
if [ "$has_content" = false ]; then
    if [ -f "${PLANNING_DIR}/design.md" ] || [ -f "${PLANNING_DIR}/plan.md" ]; then
        has_content=true
    fi
fi

if [ "$has_content" = true ]; then
    echo "active"
else
    echo "empty"
fi
