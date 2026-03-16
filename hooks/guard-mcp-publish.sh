#!/bin/bash
# PreToolUse hook: Block autonomous MCP write/publish/post operations
# Prevents the fabricated-publishing risk (GitHub Issue #27430)
# Exit 2 = block the tool call with error message
# Allowlist loaded from mcp-publish-allowlist.conf (one regex per line)

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Only check MCP tool calls (they start with mcp__)
if [[ "$TOOL_NAME" != mcp__* ]]; then
  exit 0
fi

# Load allowlist from config file
ALLOWLIST_FILE="$(dirname "$0")/mcp-publish-allowlist.conf"
if [[ -f "$ALLOWLIST_FILE" ]]; then
  while IFS= read -r line; do
    # Skip comments and blank lines
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// /}" ]] && continue
    if echo "$TOOL_NAME" | grep -qiE "$line"; then
      exit 0
    fi
  done < "$ALLOWLIST_FILE"
fi

# Block MCP tools that write, publish, post, send, create, update, or delete
# These patterns cover destructive/publishing operations across common MCP servers
if echo "$TOOL_NAME" | grep -qiE '(write|publish|post|send|create|update|delete|push|upload|modify|remove|drop|insert)'; then
  # Allow read-like operations that happen to match (e.g., "get_post" contains "post")
  if echo "$TOOL_NAME" | grep -qiE '^mcp__.*__(get_|list_|read_|search_|describe_|fetch_|query_|find_|check_|resolve_|download_)'; then
    exit 0
  fi
  echo '{"error": "BLOCKED: MCP write/publish operation requires explicit user approval. Tool: '"$TOOL_NAME"'. Ask the user to confirm this action."}' >&2
  exit 2
fi

exit 0
