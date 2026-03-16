---
description: Generate a HANDOFF.md documenting session progress for seamless continuation in a new session
context: fork
allowed-tools: Read, Write, Grep, Glob, Bash
model: haiku
---

# Handoff Document Generator

Generate a comprehensive HANDOFF.md that captures the full session state so a new Claude Code session can pick up exactly where this one left off.

## Process

### Step 1: Gather Session State

Run the following in parallel to collect information:

1. **Recent git history**: Run `git log --oneline -20` and `git log --stat -5` to see what was committed recently.
2. **Uncommitted work**: Run `git status` and `git diff --stat` to find uncommitted changes. If there are staged changes, also run `git diff --cached --stat`.
3. **Branch info**: Run `git branch --show-current` and `git log --oneline origin/main..HEAD 2>/dev/null || git log --oneline main..HEAD 2>/dev/null` to understand branch state relative to main.
4. **TODOs in changed files**: For each file shown in `git diff --name-only` and `git diff --cached --name-only`, search for TODO, FIXME, HACK, and XXX comments using Grep.
5. **Recent file modifications**: Run `git diff --name-only HEAD~5..HEAD 2>/dev/null` to get files changed in recent commits.

### Step 2: Infer Session Context

From the gathered data, determine:

- **What the user was working on**: Infer the goal from commit messages, changed files, and branch name.
- **What was completed**: Identify finished work from commits and their messages.
- **What is in progress**: Identify from uncommitted changes and TODOs.
- **What patterns/decisions are visible**: Look at the nature of changes (new files vs edits, test files, config changes) to infer architectural decisions.

### Step 3: Write HANDOFF.md

Write a file called `HANDOFF.md` in the current working directory with this structure:

```markdown
# Session Handoff

_Generated: [current date/time]_
_Branch: [branch name]_
_Repository: [repo root directory name]_

## Goal

[One or two sentences describing what the user was trying to accomplish, inferred from commits, branch name, and changes.]

## Progress

[Bulleted list of what was completed, with file paths. Group by logical unit of work.]

- Completed [description] (`path/to/file`)
- Completed [description] (`path/to/file`)

## Current State

- **Branch**: `[branch]` ([N commits ahead of main / or state])
- **Uncommitted changes**: [Yes/No - if yes, list files]
- **Staged changes**: [Yes/No - if yes, list files]
- **Build/test status**: [If inferable from recent commits or files]

## Attempted Solutions

[If visible from git history - reverts, multiple commits touching the same file, or FIXME comments suggesting something was tried. If nothing is apparent, write "No failed attempts visible in git history."]

## Next Steps

[Inferred from TODOs, FIXMEs, uncommitted work, and incomplete patterns. Be specific.]

1. [Next step with file path if applicable]
2. [Next step]

## Key Decisions

[Architectural or design decisions visible from the changes - new dependencies added, patterns chosen, file structure decisions, etc. If not clearly visible, note "Review commits for context."]

## Files Changed

### Recent Commits

[List from git log --stat, grouped by commit]

### Uncommitted

[List from git status]

## Open Questions

[Any ambiguities: TODO comments without resolution, inconsistent patterns, half-finished migrations, etc. If none, write "None identified."]

---

_To continue this work, paste this file's contents at the start of a new Claude Code session._
```

### Important Rules

- Use ONLY information gathered from git and the filesystem. Do not fabricate details.
- All file paths must be relative to the repository root.
- If the repository has no git history (fresh repo or not a git repo), note this and focus on file structure and any TODO comments found via Glob and Grep.
- Keep the document concise but complete. Aim for something a developer can scan in 30 seconds to understand the state.
- If you cannot determine something with confidence, say so explicitly rather than guessing.
