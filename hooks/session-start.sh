#!/usr/bin/env bash
# SessionStart hook for superpower-planning plugin
#
# Usage: session-start.sh <startup|resume>
#   startup — new session: inject main skill only
#   resume  — same session interrupted (resume/clear/compact): inject main skill + .planning/ content

set -euo pipefail

EVENT_TYPE="${1:-startup}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Read main skill content
main_skill_content=$(cat "${PLUGIN_ROOT}/skills/main/SKILL.md" 2>&1 || echo "Error reading main skill")

# Escape string for JSON embedding
escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

# Build conditional context based on .planning/ state
planning_message=""
if [ -d ".planning" ]; then
    # .planning/ exists — inject recovery content
    if [ "$EVENT_TYPE" = "resume" ]; then
        dashboard_head=$(head -30 .planning/progress.md 2>/dev/null || true)
        findings_head=$(head -20 .planning/findings.md 2>/dev/null || true)

        planning_message="\\n\\n<PLANNING_SESSION_RECOVERY>\\n"
        planning_message+="**Session interrupted — recovering .planning/ context.**\\n\\n"
        planning_message+="### Dashboard (.planning/progress.md):\\n\`\`\`\\n${dashboard_head}\\n\`\`\`\\n\\n"

        if [ -n "$findings_head" ]; then
            planning_message+="### Findings (.planning/findings.md):\\n\`\`\`\\n${findings_head}\\n\`\`\`\\n\\n"
        fi

        planning_message+="**Read full .planning/ files and run \`git diff --stat\` to fully recover context.**\\n"
        planning_message+="</PLANNING_SESSION_RECOVERY>"
    fi
else
    # .planning/ does NOT exist — inject strong initialization reminder
    planning_message="\\n\\n<PLANNING_INIT_REQUIRED>\\n"
    planning_message+="**No .planning/ directory detected in this project.**\\n\\n"
    planning_message+="Before starting ANY task that involves multiple steps, research, or more than 5 tool calls, you MUST first initialize the planning directory:\\n\\n"
    planning_message+="\`\`\`bash\\n\${CLAUDE_PLUGIN_ROOT}/scripts/init-planning-dir.sh\\n\`\`\`\\n\\n"
    planning_message+="This is NOT optional for complex tasks. The .planning/ directory is your persistent working memory.\\n"
    planning_message+="- Simple questions or single-file edits: skip planning\\n"
    planning_message+="- Everything else: initialize .planning/ FIRST, then proceed\\n"
    planning_message+="</PLANNING_INIT_REQUIRED>"
fi

main_skill_escaped=$(escape_for_json "$main_skill_content")
planning_escaped=$(escape_for_json "$planning_message")

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "<EXTREMELY_IMPORTANT>\nYou have superpower-planning skills.\n\n**Below is the full content of your 'superpower-planning:main' skill - your introduction to using skills. For all other skills, use the 'Skill' tool:**\n\n${main_skill_escaped}\n</EXTREMELY_IMPORTANT>${planning_escaped}"
  }
}
EOF

exit 0
