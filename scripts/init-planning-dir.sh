#!/usr/bin/env bash
# Initialize .planning/ for a project
# Usage: ./init-planning-dir.sh [project-root]
#
# Creates .planning/findings.md from the template and adds .planning/ to
# .gitignore. Task progress lives in the session's task note, not on disk.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT_ROOT="${1:-.}"
PLANNING_DIR="${PROJECT_ROOT}/.planning"

# agents/ subdirs are created by delegated roles on demand
mkdir -p "${PLANNING_DIR}"

echo "Initializing .planning/ directory at: ${PLANNING_DIR}"

GITIGNORE="${PROJECT_ROOT}/.gitignore"
if [ -f "$GITIGNORE" ]; then
    if ! grep -qF '.planning/' "$GITIGNORE" 2>/dev/null; then
        echo '.planning/' >> "$GITIGNORE"
        echo "Added .planning/ to .gitignore"
    fi
elif [ -d "${PROJECT_ROOT}/.git" ]; then
    echo '.planning/' > "$GITIGNORE"
    echo "Created .gitignore with .planning/"
fi

if [ ! -f "${PLANNING_DIR}/findings.md" ]; then
    TEMPLATE_DIR="${SCRIPT_DIR}/../skills/planning-foundation/templates"
    # No inline fallback. The template ships in this repo, so a missing one is a
    # packaging bug, and a hand-rolled substitute drifts from the real template
    # without anyone noticing.
    if [ ! -f "${TEMPLATE_DIR}/findings.md" ]; then
        echo "error: template not found at ${TEMPLATE_DIR}/findings.md" >&2
        exit 1
    fi
    cp "${TEMPLATE_DIR}/findings.md" "${PLANNING_DIR}/findings.md"
    echo "Created findings.md"
else
    echo "findings.md already exists, skipping"
fi

echo ""
echo "Planning directory initialized: .planning/findings.md"
