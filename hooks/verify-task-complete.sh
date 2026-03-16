#!/bin/bash
# TaskCompleted hook: Verify quality before marking tasks complete
# Non-blocking — logs a warning if tests might be needed but doesn't block
INPUT=$(cat)
TASK_SUBJECT=$(echo "$INPUT" | jq -r '.task.subject // empty')

# Check if this looks like a coding task that should have tests
if echo "$TASK_SUBJECT" | grep -qiE '(implement|create|add|fix|refactor|write|build)'; then
  # Check if tests exist and were recently run
  if [ -f "package.json" ] || [ -f "pytest.ini" ] || [ -f "Cargo.toml" ]; then
    echo "Note: This looks like a code task. Verify tests pass before considering complete." >&2
  fi
fi
exit 0
