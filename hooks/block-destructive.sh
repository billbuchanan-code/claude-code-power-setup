#!/bin/bash
# PreToolUse hook: Block destructive bash commands
# Exit 2 = block the tool call with error message

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Block rm -rf (but allow rm of specific files)
if echo "$COMMAND" | grep -qE '\brm\s+(-[a-zA-Z]*r[a-zA-Z]*f|--recursive\s+--force|-[a-zA-Z]*f[a-zA-Z]*r)\b'; then
  echo '{"error": "BLOCKED: rm -rf is not allowed. Remove specific files instead."}' >&2
  exit 2
fi

# Block git push --force (and -f shorthand)
if echo "$COMMAND" | grep -qE '\bgit\s+push\s+.*(-f|--force|--force-with-lease)\b'; then
  echo '{"error": "BLOCKED: Force push is not allowed. Use regular git push."}' >&2
  exit 2
fi

# Block git reset --hard
if echo "$COMMAND" | grep -qE '\bgit\s+reset\s+--hard\b'; then
  echo '{"error": "BLOCKED: git reset --hard is not allowed. Use git stash or git reset --soft."}' >&2
  exit 2
fi

# Block git clean -f
if echo "$COMMAND" | grep -qE '\bgit\s+clean\s+.*-[a-zA-Z]*f'; then
  echo '{"error": "BLOCKED: git clean -f is not allowed. Review untracked files manually."}' >&2
  exit 2
fi

# Block dropping database tables
if echo "$COMMAND" | grep -qiE '\b(DROP\s+(TABLE|DATABASE|SCHEMA)|TRUNCATE\s+TABLE)\b'; then
  echo '{"error": "BLOCKED: DROP/TRUNCATE operations are not allowed."}' >&2
  exit 2
fi

exit 0
