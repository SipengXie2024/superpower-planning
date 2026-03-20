#!/usr/bin/env bash
# Detect the appropriate test command for the current project
#
# Usage: detect-test-command.sh [project-root]
#
# Checks for common project files and returns the matching test command.
# Output: test command on stdout
# Exit 0 if detected, 1 if unknown project type.

set -e

PROJECT_ROOT="${1:-.}"

if [ -f "${PROJECT_ROOT}/package.json" ]; then
    # Check for common test scripts
    if command -v jq >/dev/null 2>&1 && [ -f "${PROJECT_ROOT}/package.json" ]; then
        test_script=$(jq -r '.scripts.test // empty' "${PROJECT_ROOT}/package.json" 2>/dev/null)
        if [ -n "$test_script" ] && [ "$test_script" != "null" ]; then
            echo "npm test"
            exit 0
        fi
    fi
    # Fallback: check for common test runners
    if [ -f "${PROJECT_ROOT}/vitest.config.ts" ] || [ -f "${PROJECT_ROOT}/vitest.config.js" ]; then
        echo "npx vitest run"
    elif [ -f "${PROJECT_ROOT}/jest.config.ts" ] || [ -f "${PROJECT_ROOT}/jest.config.js" ]; then
        echo "npx jest"
    else
        echo "npm test"
    fi
    exit 0
fi

if [ -f "${PROJECT_ROOT}/Cargo.toml" ]; then
    echo "cargo test"
    exit 0
fi

if [ -f "${PROJECT_ROOT}/go.mod" ]; then
    echo "go test ./..."
    exit 0
fi

if [ -f "${PROJECT_ROOT}/pyproject.toml" ] || [ -f "${PROJECT_ROOT}/setup.py" ] || [ -f "${PROJECT_ROOT}/setup.cfg" ]; then
    if [ -f "${PROJECT_ROOT}/pyproject.toml" ] && grep -q 'pytest' "${PROJECT_ROOT}/pyproject.toml" 2>/dev/null; then
        echo "pytest"
    elif [ -d "${PROJECT_ROOT}/tests" ] || [ -d "${PROJECT_ROOT}/test" ]; then
        echo "pytest"
    else
        echo "python -m pytest"
    fi
    exit 0
fi

if [ -f "${PROJECT_ROOT}/requirements.txt" ]; then
    echo "pytest"
    exit 0
fi

if [ -f "${PROJECT_ROOT}/Makefile" ]; then
    if grep -q '^test:' "${PROJECT_ROOT}/Makefile" 2>/dev/null; then
        echo "make test"
        exit 0
    fi
fi

echo "[detect-test-command] Error: could not detect test command" >&2
exit 1
