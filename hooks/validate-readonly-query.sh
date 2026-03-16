#!/bin/bash
# PreToolUse hook: Validate SQL queries are read-only
# Only activates when command contains SQL-like patterns
# Exit 2 = block the tool call

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only check commands that look like they contain SQL
if echo "$COMMAND" | grep -qiE '\b(SELECT|INSERT|UPDATE|DELETE|CREATE|ALTER|DROP)\b'; then
  # Block write operations
  if echo "$COMMAND" | grep -qiE '\b(INSERT\s+INTO|UPDATE\s+\w+\s+SET|DELETE\s+FROM|DROP\s+(TABLE|DATABASE|INDEX|SCHEMA)|CREATE\s+(TABLE|DATABASE|INDEX|SCHEMA)|ALTER\s+(TABLE|DATABASE)|TRUNCATE)\b'; then
    echo '{"error": "BLOCKED: SQL write operations (INSERT/UPDATE/DELETE/DROP/CREATE/ALTER/TRUNCATE) are not allowed. Use read-only queries."}' >&2
    exit 2
  fi
fi

exit 0
