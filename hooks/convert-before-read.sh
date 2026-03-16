#!/bin/bash
# PreToolUse hook: Block Read on convertible file types
# Redirects to mcp__to-markdown__convert_file instead
# Exit 2 = block the tool call with error message

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Extract extension (lowercase)
EXT=$(echo "$FILE_PATH" | sed 's/.*\.//' | tr '[:upper:]' '[:lower:]')

# Convertible file types that to-markdown handles better than raw Read
case "$EXT" in
  pdf|docx|doc|xlsx|xls|pptx|ppt|rtf|odt|ods|odp|epub|mobi|html|htm|eml|msg|csv|tsv|bmp|tiff|tif|heic|heif|webp)
    echo "{\"error\": \"BLOCKED: Use mcp__to-markdown__convert_file instead of Read for .$EXT files. It produces clean, structured markdown that is far easier to work with. Pass summary: true if the user wants a summary.\"}" >&2
    exit 2
    ;;
esac

exit 0
