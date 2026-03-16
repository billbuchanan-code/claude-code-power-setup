#!/bin/bash
# Stop hook: Send macOS notification when Claude finishes and needs input
# Runs async so it doesn't block the response

osascript -e 'display notification "Claude has finished and is waiting for input." with title "Claude Code" sound name "Glass"' 2>/dev/null

exit 0
