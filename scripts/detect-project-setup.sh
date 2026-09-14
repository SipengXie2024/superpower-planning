#!/usr/bin/env bash
# Detect and optionally run project setup command
#
# Usage: detect-project-setup.sh [--dry-run] [project-root]
#
# Detects package manager / build tool and returns (or runs) the setup command.
# --dry-run: only print the command, don't execute
# Output: setup command on stdout
# Exit 0 if detected/executed, 1 if unknown project type.

set -e

DRY_RUN=false
if [ "$1" = "--dry-run" ]; then
    DRY_RUN=true
    shift
fi

PROJECT_ROOT="${1:-.}"

run_or_print() {
    local cmd="$1"
    if [ "$DRY_RUN" = true ]; then
        echo "$cmd"
    else
        echo "[detect-project-setup] Running: $cmd"
        # shellcheck disable=SC2086
        cd "$PROJECT_ROOT" && $cmd
    fi
}

if [ -f "${PROJECT_ROOT}/package-lock.json" ]; then
    run_or_print "npm install"
    exit 0
fi

if [ -f "${PROJECT_ROOT}/yarn.lock" ]; then
    run_or_print "yarn install"
    exit 0
fi

if [ -f "${PROJECT_ROOT}/pnpm-lock.yaml" ]; then
    run_or_print "pnpm install"
    exit 0
fi

if [ -f "${PROJECT_ROOT}/package.json" ]; then
    run_or_print "npm install"
    exit 0
fi

if [ -f "${PROJECT_ROOT}/Cargo.toml" ]; then
    run_or_print "cargo build"
    exit 0
fi

if [ -f "${PROJECT_ROOT}/go.mod" ]; then
    run_or_print "go mod download"
    exit 0
fi

if [ -f "${PROJECT_ROOT}/poetry.lock" ]; then
    run_or_print "poetry install"
    exit 0
fi

if [ -f "${PROJECT_ROOT}/Pipfile.lock" ]; then
    run_or_print "pipenv install"
    exit 0
fi

if [ -f "${PROJECT_ROOT}/requirements.txt" ]; then
    run_or_print "pip install -r requirements.txt"
    exit 0
fi

if [ -f "${PROJECT_ROOT}/pyproject.toml" ]; then
    run_or_print "pip install -e ."
    exit 0
fi

echo "[detect-project-setup] No recognized project setup file found" >&2
exit 1
