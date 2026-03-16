#!/usr/bin/env bash
# inject-security-context.sh — Injects security context into tool calls
# Reads tool input from stdin, validates no secrets/credentials are exposed

set -euo pipefail

INPUT=$(cat)
TOOL_NAME="${TOOL_USE_NAME:-unknown}"

# Check for common secret patterns in tool input
if echo "$INPUT" | grep -qiE '(api[_-]?key|secret[_-]?key|password|token|credential|private[_-]?key)\s*[:=]\s*["\x27]?[A-Za-z0-9+/=_-]{8,}'; then
  echo "BLOCK: Potential secret detected in $TOOL_NAME tool input. Review before proceeding." >&2
  exit 2
fi

exit 0
