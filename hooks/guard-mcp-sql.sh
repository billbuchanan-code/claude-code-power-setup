#!/bin/bash
# PreToolUse hook: Validate MCP database tool calls for SQL write operations
# Catches dangerous SQL sent through MCP database servers (BigQuery, Postgres, etc.)
# Exit 2 = block the tool call

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // empty')

# Only check database-related MCP tools
if ! echo "$TOOL_NAME" | grep -qiE 'mcp__.*(sql|query|database|postgres|bigquery|db|supabase|neon)'; then
  exit 0
fi

# Extract any SQL-like content from the tool input (check all string values)
SQL_CONTENT=$(echo "$TOOL_INPUT" | jq -r '.. | strings' 2>/dev/null)

# Block destructive SQL operations
if echo "$SQL_CONTENT" | grep -qiE '\b(INSERT\s+INTO|UPDATE\s+\w+\s+SET|DELETE\s+FROM|DROP\s+(TABLE|DATABASE|INDEX|SCHEMA|VIEW)|CREATE\s+(TABLE|DATABASE|INDEX|SCHEMA|VIEW)|ALTER\s+(TABLE|DATABASE)|TRUNCATE|GRANT|REVOKE)\b'; then
  echo '{"error": "BLOCKED: Destructive SQL detected in MCP database call ('"$TOOL_NAME"'). Only SELECT/EXPLAIN queries are allowed without explicit approval."}' >&2
  exit 2
fi

exit 0
