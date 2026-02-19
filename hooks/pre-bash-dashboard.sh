#!/bin/bash
# Show planning dashboard before substantial Bash commands.
# Triggered by PreToolUse on Bash; reads command from stdin JSON.

PROGRESS_FILE=".planning/progress.md"
[ -f "$PROGRESS_FILE" ] || exit 0

COMMAND=$(jq -r '.tool_input.command // empty' 2>/dev/null)
[ -z "$COMMAND" ] && exit 0

# Only show dashboard for build/test/commit/release commands
if echo "$COMMAND" | grep -qE '(^|\s|&&|\|)(make|npm (run|test)|npx |yarn |pnpm |cargo (build|test|run)|pytest|python -m pytest|jest|vitest|go (build|test)|git (commit|push|tag|merge|rebase)|gh (pr|release))(\s|$|;)'; then
  head -15 "$PROGRESS_FILE"
fi
