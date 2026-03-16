---
description: Stage, commit, and push changes following project conventions. Stages specific files (never git add . or -A), writes conventional commit messages, and pushes to remote.
context: fork
allowed-tools: Read, Bash, Grep, Glob
model: haiku
---

# Commit Skill

Stage, commit, and push the current changes following the user's established conventions.

## When to Activate

Trigger this skill when the user says any of:

- `/commit`
- "push it"
- "commit this"
- "commit and push"
- "document, commit and push"
- "document commit and push"

## Process

### Step 1: Gather State (parallel)

Run these commands in parallel:

1. `git status` — see all modified, staged, and untracked files
2. `git diff --stat` — summary of unstaged changes
3. `git diff --cached --stat` — summary of already-staged changes
4. `git log --oneline -5` — recent commit messages for style reference

### Step 2: Determine What to Stage

- Stage all modified and new files that are part of the current work
- **Never use `git add .` or `git add -A`** — always stage specific files by name
- Skip `.env` files, credentials, secrets, and large binaries
- If the user said "document" (e.g., "document, commit and push"), update relevant documentation before staging

### Step 3: Write the Commit Message

- Read the recent git log output from Step 1 to match the repository's commit style
- Summarize the nature of changes: new feature, enhancement, bug fix, refactor, docs, etc.
- Use imperative mood ("Add feature" not "Added feature")
- Keep the first line under 72 characters
- Add a blank line and body if the changes warrant explanation
- End with: `Co-Authored-By: Claude <noreply@anthropic.com>`
- Use a HEREDOC to pass the message to `git commit -m`

### Step 4: Commit and Push

Run sequentially:

1. `git add <specific files>`
2. `git commit` with the HEREDOC message
3. `git push`
4. `git status` — verify clean working tree

If the commit fails due to a pre-commit hook, fix the issue and create a **new** commit (never amend).

### Step 5: Report

Output a brief summary:

- Files committed
- Commit message used
- Push status (success or any errors)

## Rules

- Never amend a previous commit unless the user explicitly asks
- Never use `--no-verify` or skip hooks
- Never force push unless explicitly asked (and warn if targeting main/master)
- If there are no changes to commit, say so and stop
- If pushing fails (e.g., no upstream), set upstream with `git push -u origin <branch>`
