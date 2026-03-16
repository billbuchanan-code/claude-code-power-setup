---
description: Sync dotfiles DOWN — pull latest changes from GitHub and merge into local.
context: fork
allowed-tools: Bash, Glob, Read
model: haiku
---

# Claude Sync Down

Pull the latest changes from the private GitHub repo into the claude-dotfiles repo and sync them to `~/.claude/`.

## When to Activate

Trigger this skill when the user says:

- `/claude.sync.down`
- "pull dotfiles"
- "update dotfiles from github"

## Process

### Step 0: Detect Dotfiles Path

```bash
if [ -d ~/claude-dotfiles/.git ]; then echo ~/claude-dotfiles; elif [ -d ~/claude/claude-dotfiles/.git ]; then echo ~/claude/claude-dotfiles; else echo "NOT_FOUND"; fi
```

Store the result as `DOTFILES_DIR`. If `NOT_FOUND`, report the error and stop.

### Step 1: Stash Local Changes

```bash
cd $DOTFILES_DIR && git status --short
```

If there are uncommitted local changes, stash them first:

```bash
cd $DOTFILES_DIR && git stash
```

Note whether a stash was created.

### Step 2: Pull from Remote

```bash
cd $DOTFILES_DIR && git pull --rebase origin main
```

If pull shows "Already up to date." and no stash was created, report "Dotfiles already up to date." and stop.

### Step 3: Pop Stash (if applicable)

If changes were stashed in Step 1:

```bash
cd $DOTFILES_DIR && git stash pop
```

If there are merge conflicts, report them to the user and stop — do not auto-resolve.

### Step 4: Run Install Script

Re-run the install script to ensure symlinks and generated files are up to date:

```bash
cd $DOTFILES_DIR && bash install.sh
```

### Step 5: Report

Output:

- Commits pulled (or "already up to date")
- Whether a stash was applied
- Any conflicts encountered
- Files synced to `~/.claude/`

## Rules

- Always `cd $DOTFILES_DIR` before any git command
- Never force-pull or reset — always rebase
- Never auto-resolve merge conflicts — report and stop
- Always sync to `~/.claude/` after pulling
