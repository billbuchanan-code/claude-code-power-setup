---
description: Generate a daily standup summary from recent git activity, task status, and project state
context: fork
allowed-tools: Read, Grep, Glob, Bash
model: haiku
---

# Standup Skill

Generate a daily standup summary from recent git activity, task status, and project state.

## Process

1. **Get recent git commits** from the last 24 hours:

   ```
   git log --since="24 hours ago" --oneline --all
   ```

2. **Get current branch and uncommitted changes**:

   ```
   git status
   git diff --stat
   ```

3. **Look for TODO/FIXME comments** in recently changed files:
   - Identify files changed in the last 24 hours with `git diff --name-only HEAD~5` (or similar)
   - Search those files for TODO, FIXME, HACK, or XXX comments using Grep

4. **Check for open PRs**:

   ```
   gh pr list --author @me
   ```

5. **Summarize** everything into the standup format below.

## Output Format

**Yesterday**: [What was completed based on commits — summarize the work, not individual commit messages]

**Today**: [What's in progress based on current branch, uncommitted changes, and open PRs]

**Blockers**: [Any issues detected — failing tests, merge conflicts, stale PRs, unresolved TODOs]

Keep each section to 1-3 bullet points. Be concise but specific. If there is no activity for a section, say "None" rather than making something up.
