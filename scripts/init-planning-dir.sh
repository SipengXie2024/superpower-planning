#!/bin/bash
# Initialize .planning/ directory for a new work session
# Usage: ./init-planning-dir.sh [project-root]
#
# Creates:
#   .planning/progress.md    (Task Status Dashboard + session log)
#   .planning/findings.md
#   .planning/agents/        (empty dir for subagent working dirs)

set -e

PROJECT_ROOT="${1:-.}"
PLANNING_DIR="${PROJECT_ROOT}/.planning"
DATE=$(date +%Y-%m-%d)

# Create .planning directory
mkdir -p "${PLANNING_DIR}/agents"

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
    cat > "${PLANNING_DIR}/findings.md" << 'EOF'
# Findings & Decisions

## Requirements
-

## Research Findings
-

## Technical Decisions
| Decision | Rationale |
|----------|-----------|

## Issues Encountered
| Issue | Resolution |
|-------|------------|

## Resources
-
EOF
    echo "Created findings.md"
else
    echo "findings.md already exists, skipping"
fi

# Create progress.md if it doesn't exist
if [ ! -f "${PLANNING_DIR}/progress.md" ]; then
    cat > "${PLANNING_DIR}/progress.md" << EOF
# Progress Log

## Task Status Dashboard
<!-- Quick-scan execution status. Update after each task/phase completes. -->
| Task | Status | Agent/Batch | Key Outcome |
|------|--------|-------------|-------------|

## Session: $DATE

### Current Status
- **Started:** $DATE

### Actions Taken
-

### Test Results
| Test | Expected | Actual | Status |
|------|----------|--------|--------|

### Errors
| Error | Attempt | Resolution |
|-------|---------|------------|
EOF
    echo "Created progress.md"
else
    echo "progress.md already exists, skipping"
fi

echo ""
echo "Planning directory initialized!"
echo "Files: .planning/progress.md, .planning/findings.md"
echo "Agent dirs: .planning/agents/"
