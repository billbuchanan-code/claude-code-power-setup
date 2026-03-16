---
description: Sync dotfiles UP — commit local changes and push to GitHub.
context: fork
allowed-tools: Bash, Glob, Read
model: haiku
---

# Claude Sync Up

Commit any local changes in the claude-dotfiles repo and push them to the private GitHub repo.

## When to Activate

Trigger this skill when the user says:

- `/claude.sync.up`
- "push dotfiles"
- "save dotfiles to github"

## Process

### Step 0: Detect Dotfiles Path

```bash
if [ -d ~/claude-dotfiles/.git ]; then echo ~/claude-dotfiles; elif [ -d ~/claude/claude-dotfiles/.git ]; then echo ~/claude/claude-dotfiles; else echo "NOT_FOUND"; fi
```

Store the result as `DOTFILES_DIR`. If `NOT_FOUND`, report the error and stop.

### Step 1: Check for Changes

```bash
cd $DOTFILES_DIR && git status --short
```

If there are no changes, report "Dotfiles already in sync — nothing to push." and stop.

### Step 2: Gather Context (parallel)

1. `cd $DOTFILES_DIR && git diff --stat` — what changed
2. `cd $DOTFILES_DIR && git log --oneline -3` — recent commit style

### Step 3: Stage and Commit

- Stage specific changed files by name — **never** `git add .` or `git add -A`
- Skip any files that look like secrets or credentials
- Write a conventional commit message summarizing the changes
- Use imperative mood, keep first line under 72 characters
- End with: `Co-Authored-By: Claude <noreply@anthropic.com>`
- Use a HEREDOC for the message

### Step 4: Push

```bash
cd $DOTFILES_DIR && git push
```

If push fails with no upstream, use `git push -u origin main`.

### Step 5: Report

Output:

- Files committed
- Commit message
- Push status

## Rules

- Always `cd $DOTFILES_DIR` before any git command
- Never amend previous commits
- Never use `--no-verify` or force push
- Never commit secrets or `.env` files
