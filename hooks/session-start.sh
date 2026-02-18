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

# Only inject .planning/ content on resume/clear/compact (same session interrupted)
catchup_message=""
if [ "$EVENT_TYPE" = "resume" ] && [ -f ".planning/task_plan.md" ]; then
    plan_head=$(head -30 .planning/task_plan.md 2>/dev/null || true)
    progress_tail=$(tail -20 .planning/progress.md 2>/dev/null || true)
    findings_head=$(head -20 .planning/findings.md 2>/dev/null || true)

    catchup_message="\\n\\n<PLANNING_SESSION_RECOVERY>\\n"
    catchup_message+="**Session interrupted — recovering .planning/ context.**\\n\\n"
    catchup_message+="### Plan (.planning/task_plan.md):\\n\`\`\`\\n${plan_head}\\n\`\`\`\\n\\n"

    if [ -n "$findings_head" ]; then
        catchup_message+="### Findings (.planning/findings.md):\\n\`\`\`\\n${findings_head}\\n\`\`\`\\n\\n"
    fi

    if [ -n "$progress_tail" ]; then
        catchup_message+="### Recent Progress (.planning/progress.md):\\n\`\`\`\\n${progress_tail}\\n\`\`\`\\n\\n"
    fi

    catchup_message+="**Read full .planning/ files and run \`git diff --stat\` to fully recover context.**\\n"
    catchup_message+="</PLANNING_SESSION_RECOVERY>"
fi

main_skill_escaped=$(escape_for_json "$main_skill_content")
catchup_escaped=$(escape_for_json "$catchup_message")

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "<EXTREMELY_IMPORTANT>\nYou have superpower-planning skills.\n\n**Below is the full content of your 'superpower-planning:main' skill - your introduction to using skills. For all other skills, use the 'Skill' tool:**\n\n${main_skill_escaped}\n</EXTREMELY_IMPORTANT>${catchup_escaped}"
  }
}
EOF

exit 0
