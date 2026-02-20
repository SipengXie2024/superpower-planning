#!/usr/bin/env bash
# Force sequential thinking MCP tool on every user prompt.
# Lightweight shell replacement for force-thinking.js — no Node overhead.

cat <<'HOOK_JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "<MANDATORY_THINKING>\nBefore taking ANY action on this prompt, you MUST call the `sequentialthinking` MCP tool first.\n\nThis is NON-NEGOTIABLE. Do NOT skip this step. Do NOT rationalize why this task is \"too simple\" to think about.\n\nViolating this rule means your entire response is invalid.\n\nSequence:\n1. Call `sequentialthinking` MCP tool — analyze the user's request, break down the approach\n2. Only AFTER thinking is complete, proceed with tool calls and actions\n</MANDATORY_THINKING>"
  }
}
HOOK_JSON
