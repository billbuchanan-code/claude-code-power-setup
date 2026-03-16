#!/bin/bash
# PostToolUse hook: Auto-format files after Write/Edit
# Runs the appropriate formatter based on file extension

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only run on Write or Edit tools
if [[ "$TOOL" != "Write" && "$TOOL" != "Edit" ]]; then
  exit 0
fi

# Skip if no file path
if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Get file extension
EXT="${FILE_PATH##*.}"

# Try Prettier first (most common)
if command -v npx &>/dev/null; then
  case "$EXT" in
    js|jsx|ts|tsx|json|css|scss|less|html|md|yaml|yml|graphql)
      npx --yes prettier --write "$FILE_PATH" 2>/dev/null
      exit 0
      ;;
  esac
fi

# Python: try black, then autopep8
if [[ "$EXT" == "py" ]]; then
  if command -v black &>/dev/null; then
    black --quiet "$FILE_PATH" 2>/dev/null
  elif command -v autopep8 &>/dev/null; then
    autopep8 --in-place "$FILE_PATH" 2>/dev/null
  fi
  exit 0
fi

# Go: gofmt
if [[ "$EXT" == "go" ]]; then
  if command -v gofmt &>/dev/null; then
    gofmt -w "$FILE_PATH" 2>/dev/null
  fi
  exit 0
fi

# Rust: rustfmt
if [[ "$EXT" == "rs" ]]; then
  if command -v rustfmt &>/dev/null; then
    rustfmt "$FILE_PATH" 2>/dev/null
  fi
  exit 0
fi

exit 0
