#!/bin/bash
# SubagentStart hook: Log subagent start events to audit log
# Async, non-blocking
INPUT=$(cat)
AGENT_NAME=$(echo "$INPUT" | jq -r '.agent_name // empty')
echo "Subagent started: $AGENT_NAME" >> ~/.claude/audit.log
exit 0
