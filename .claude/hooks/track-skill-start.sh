#!/usr/bin/env bash
# Track skill activations via SKILL.md reads
echo '{"async":true,"asyncTimeout":15000}'

# Read JSON input from stdin
INPUT=$(cat)

# Extract tool and file path
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.command // empty')

# Only process Read tool or cat commands
case "$TOOL" in
    Read|Bash) ;;
    *) exit 0 ;;
esac

# Check if path matches any file in a skill directory
# Matches: .claude/skills/[name]/* or /skills/[name]/*
if [[ "$FILE_PATH" =~ \.claude/skills/([^/]+)/ ]] || [[ "$FILE_PATH" =~ /skills/([^/]+)/ ]]; then
    SKILL_NAME="${BASH_REMATCH[1]}"
elif [[ "$FILE_PATH" =~ cat.*skills/([^/]+)/ ]]; then
    SKILL_NAME="${BASH_REMATCH[1]}"
else
    exit 0
fi

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Ensure log directory exists
mkdir -p .claude/activity-logs

# Write start event using jq for proper JSON (compact for JSONL)
jq -nc --arg ts "$TIMESTAMP" --arg sid "$SESSION_ID" --arg skill "$SKILL_NAME" \
  '{timestamp: $ts, session_id: $sid, skill: $skill, event: "start"}' >> .claude/activity-logs/skill-usage.jsonl

exit 0
