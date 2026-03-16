#!/bin/bash
# ConfigChange hook: Log all configuration changes for auditing
INPUT=$(cat)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SOURCE=$(echo "$INPUT" | jq -r '.source // "unknown"')
echo "[$TIMESTAMP] Config changed: source=$SOURCE" >> ~/.claude/audit.log
exit 0
