#!/usr/bin/env bash
# Initialize .planning/ directory for a new work session
# Usage: ./init-planning-dir.sh [project-root]
#
# Creates:
#   .planning/progress.md    (Task Status Dashboard + session log)
#   .planning/findings.md

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT_ROOT="${1:-.}"
PLANNING_DIR="${PROJECT_ROOT}/.planning"
DATE=$(date +%Y-%m-%d)

# Create .planning directory (agents/ subdirs are created by delegated roles on demand)
mkdir -p "${PLANNING_DIR}"

echo "Initializing .planning/ directory at: ${PLANNING_DIR}"

# Add .planning to .gitignore if not already there
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

# Create findings.md if it doesn't exist
if [ ! -f "${PLANNING_DIR}/findings.md" ]; then
    TEMPLATE_DIR="${SCRIPT_DIR}/../skills/planning-foundation/templates"
    # No inline fallback. The templates ship in this repo, so a missing one is a
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

# Create progress.md if it doesn't exist
if [ ! -f "${PLANNING_DIR}/progress.md" ]; then
    TEMPLATE_DIR="${SCRIPT_DIR}/../skills/planning-foundation/templates"
    # Same reasoning as findings.md above: the inline fallback that used to live
    # here had already drifted, emitting a four-column dashboard against a
    # seven-column template.
    if [ ! -f "${TEMPLATE_DIR}/progress.md" ]; then
        echo "error: template not found at ${TEMPLATE_DIR}/progress.md" >&2
        exit 1
    fi
    sed "s|\[DATE\]|$DATE|g" "${TEMPLATE_DIR}/progress.md" > "${PLANNING_DIR}/progress.md"
    echo "Created progress.md"
else
    echo "progress.md already exists, skipping"
fi

echo ""
echo "Planning directory initialized!"
echo "Files: .planning/progress.md, .planning/findings.md"
