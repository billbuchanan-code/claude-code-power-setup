# How to Build This Setup

This guide walks through every component of the configuration. Copy what you need, adapt to your workflow.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Directory Structure](#2-directory-structure)
3. [Settings Configuration](#3-settings-configuration)
4. [Global Instructions (CLAUDE.md)](#4-global-instructions-claudemd)
5. [Safety Hooks](#5-safety-hooks)
6. [Specialist Agents](#6-specialist-agents)
7. [Custom Skills](#7-custom-skills)
   - [7.5 gstack: Browser QA and Shipping Skills](#75-gstack-browser-qa-and-shipping-skills)
8. [MCP Server Integrations](#8-mcp-server-integrations)
9. [Behavioral Rules](#9-behavioral-rules)
10. [Memory System](#10-memory-system)
11. [Reference Documentation](#11-reference-documentation)
12. [Session Workflow](#12-session-workflow)

---

## 1. Prerequisites

- **Claude Code CLI** installed (`npm install -g @anthropic-ai/claude-code`)
- **Node.js** (v18+), **Python 3**, **Git**, **GitHub CLI** (`gh`)
- **jq** installed (`brew install jq` on macOS) — required by hook scripts
- A Claude API key or Claude Max subscription
- Optional: **Doppler** for secrets management, **Prettier/Black/gofmt** for auto-formatting
- Optional: **Bun v1.0+** (`curl -fsSL https://bun.sh/install | bash`) — required for gstack skills

---

## 2. Directory Structure

Create the full directory tree:

```bash
mkdir -p ~/.claude/{agents,skills,hooks,rules,agent-memory,projects,scripts}
```

The key files you'll create:

```
~/.claude/
  CLAUDE.md              # Your global behavior instructions
  REFERENCE.md           # On-demand reference doc (routing tables, etc.)
  agents.md              # Agent summary and routing rules
  settings.json          # Core configuration
  mcp.json               # MCP server connections
  rules/coding.md        # Global coding rules
  hooks/*.sh             # Safety and automation scripts
  agents/*.md            # Agent definitions
  skills/*/SKILL.md      # Skill definitions
```

---

## 3. Settings Configuration

Create `~/.claude/settings.json`:

```json
{
  "env": {
    "MCP_TIMEOUT": "5000",
    "MAX_MCP_OUTPUT_TOKENS": "15000",
    "ENABLE_TOOL_SEARCH": "auto:5",
    "CLAUDE_CODE_EFFORT_LEVEL": "low",
    "CLAUDE_CODE_SUBAGENT_MODEL": "sonnet"
  },
  "permissions": {
    "deny": [
      "Read(**/.env*)",
      "Read(**/*.key)",
      "Read(**/*.pem)",
      "Read(**/credentials*)",
      "Read(**/secrets/**)",
      "Read(**/node_modules/**)"
    ]
  },
  "model": "sonnet",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/convert-before-read.sh"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/block-destructive.sh"
          },
          {
            "type": "command",
            "command": "~/.claude/hooks/validate-readonly-query.sh"
          }
        ]
      },
      {
        "matcher": "mcp__.*",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/guard-mcp-publish.sh"
          },
          {
            "type": "command",
            "command": "~/.claude/hooks/guard-mcp-sql.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/auto-format.sh",
            "async": true
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'PRESERVE during compaction: all decisions and rationale, file paths modified, user constraints, working solutions, task list state, current project name and phase, active sprint goals, test commands.'"
          }
        ]
      }
    ],
    "ConfigChange": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/audit-config-change.sh",
            "async": true
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/notify-on-stop.sh",
            "async": true
          }
        ]
      }
    ]
  }
}
```

### What Each Setting Does

| Setting                      | Value         | Purpose                                                                       |
| ---------------------------- | ------------- | ----------------------------------------------------------------------------- |
| `ENABLE_TOOL_SEARCH`         | `auto:5`      | Defers MCP tools that would consume >5% of context — loads them on demand     |
| `CLAUDE_CODE_EFFORT_LEVEL`   | `low`         | Faster responses for routine tasks; toggle to `high` for complex architecture |
| `CLAUDE_CODE_SUBAGENT_MODEL` | `sonnet`      | All sub-agents use Sonnet by default (cost-effective)                         |
| `model`                      | `sonnet`      | Default model for the main session                                            |
| `permissions.deny`           | glob patterns | Prevents Claude from reading secrets, env files, keys, and node_modules       |

> **Warning — `skipDangerousModePermissionPrompt`**: The `config/settings.json` in this repo includes `"skipDangerousModePermissionPrompt": true`. This disables the permission prompt that Claude normally shows before taking potentially destructive actions. Only enable this if you have strong hook-based guardrails in place (e.g., `block-destructive.sh`, `guard-mcp-publish.sh`). If you are just getting started, omit this setting so Claude will always ask for confirmation.

---

## 4. Global Instructions (CLAUDE.md)

Create `~/.claude/CLAUDE.md` — this is loaded into every conversation:

```markdown
# Claude Code Configuration

Agent routing details in `~/.claude/agents.md` — consult when dispatching agents.
Full reference (skills, hooks, MCP) in `~/.claude/REFERENCE.md` — consult on demand.

---

## Communication Rules

### Audience

- The user is a [YOUR ROLE] — adapt language accordingly
- Do the work, then state the result in one sentence
- Do not show intermediate steps unless asked

### Verbosity

- Complete the task, then stop — no unsolicited next steps
- Do not summarize what you just did after doing it
- Do not explain reasoning unless asked "why"
- One question at a time

### When Manual Action Is Required

When the user must do something themselves:

1. Say **"Action needed:"** on its own line
2. Give numbered steps with exact names
3. Include what the user should see at each step
4. End with "Let me know when done"

---

## Rules

Global: **coding.md** — Conventions, function size, error handling, testing, secrets

## Behavioral Rules

### Two-Correction Rule

If corrected twice on the same issue: acknowledge the pattern, ask user to restate,
confirm understanding, suggest /clear if context drift is the cause.

### Commit Shorthand

When the user says "push it", "commit this", "commit and push" — treat it as
a `/commit` skill invocation.

### Session Naming

Name sessions as `[project]-[date]-[2-word-topic]`.

---

## Session Management

- `/start` at session start
- `/handoff` before switching sessions
- `/compact` for context management
- `/clear` proactively at 50-60% context
- Max 3-4 agents active simultaneously
```

**Customize the Audience section** — this is the single most impactful setting. It controls how Claude communicates with you. A business executive gets results-only output. A senior engineer gets technical detail. A student gets explanations.

---

## 5. Safety Hooks

These are the most important part of the setup. They prevent Claude from doing damage.

### 5a. Block Destructive Commands

Create `~/.claude/hooks/block-destructive.sh`:

```bash
#!/bin/bash
# PreToolUse hook: Block destructive bash commands
# Exit 2 = block the tool call with error message

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Block rm -rf
if echo "$COMMAND" | grep -qE '\brm\s+(-[a-zA-Z]*r[a-zA-Z]*f|--recursive\s+--force|-[a-zA-Z]*f[a-zA-Z]*r)\b'; then
  echo '{"error": "BLOCKED: rm -rf is not allowed. Remove specific files instead."}' >&2
  exit 2
fi

# Block git push --force
if echo "$COMMAND" | grep -qE '\bgit\s+push\s+.*(-f|--force|--force-with-lease)\b'; then
  echo '{"error": "BLOCKED: Force push is not allowed. Use regular git push."}' >&2
  exit 2
fi

# Block git reset --hard
if echo "$COMMAND" | grep -qE '\bgit\s+reset\s+--hard\b'; then
  echo '{"error": "BLOCKED: git reset --hard is not allowed. Use git stash or git reset --soft."}' >&2
  exit 2
fi

# Block git clean -f
if echo "$COMMAND" | grep -qE '\bgit\s+clean\s+.*-[a-zA-Z]*f'; then
  echo '{"error": "BLOCKED: git clean -f is not allowed. Review untracked files manually."}' >&2
  exit 2
fi

# Block DROP/TRUNCATE
if echo "$COMMAND" | grep -qiE '\b(DROP\s+(TABLE|DATABASE|SCHEMA)|TRUNCATE\s+TABLE)\b'; then
  echo '{"error": "BLOCKED: DROP/TRUNCATE operations are not allowed."}' >&2
  exit 2
fi

exit 0
```

### 5b. Validate Read-Only SQL

Create `~/.claude/hooks/validate-readonly-query.sh`:

```bash
#!/bin/bash
# PreToolUse hook: Validate SQL queries are read-only
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$COMMAND" | grep -qiE '\b(SELECT|INSERT|UPDATE|DELETE|CREATE|ALTER|DROP)\b'; then
  if echo "$COMMAND" | grep -qiE '\b(INSERT\s+INTO|UPDATE\s+\w+\s+SET|DELETE\s+FROM|DROP\s+(TABLE|DATABASE|INDEX|SCHEMA)|CREATE\s+(TABLE|DATABASE|INDEX|SCHEMA)|ALTER\s+(TABLE|DATABASE)|TRUNCATE)\b'; then
    echo '{"error": "BLOCKED: SQL write operations are not allowed. Use read-only queries."}' >&2
    exit 2
  fi
fi

exit 0
```

### 5c. Guard MCP Publish Operations

Create `~/.claude/hooks/guard-mcp-publish.sh`:

```bash
#!/bin/bash
# PreToolUse hook: Block autonomous MCP write/publish operations
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

if [[ "$TOOL_NAME" != mcp__* ]]; then
  exit 0
fi

# Load allowlist
ALLOWLIST_FILE="$(dirname "$0")/mcp-publish-allowlist.conf"
if [[ -f "$ALLOWLIST_FILE" ]]; then
  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// /}" ]] && continue
    if echo "$TOOL_NAME" | grep -qiE "$line"; then
      exit 0
    fi
  done < "$ALLOWLIST_FILE"
fi

# Block write operations
if echo "$TOOL_NAME" | grep -qiE '(write|publish|post|send|create|update|delete|push|upload|modify|remove|drop|insert)'; then
  # Allow read-like ops that match (e.g., "get_post")
  if echo "$TOOL_NAME" | grep -qiE '^mcp__.*__(get_|list_|read_|search_|describe_|fetch_|query_|find_|check_|resolve_|download_)'; then
    exit 0
  fi
  echo '{"error": "BLOCKED: MCP write/publish operation requires explicit user approval. Tool: '"$TOOL_NAME"'. Ask the user to confirm this action."}' >&2
  exit 2
fi

exit 0
```

Create the allowlist at `~/.claude/hooks/mcp-publish-allowlist.conf`:

```conf
# MCP Publish Allowlist
# One tool-name regex per line. Blank lines and # comments are ignored.
# These tools bypass the guard-mcp-publish hook.

# Chrome browser automation
^mcp__chrome-browser__
^mcp__claude-in-chrome__
```

### 5d. Guard MCP SQL

Create `~/.claude/hooks/guard-mcp-sql.sh`:

```bash
#!/bin/bash
# PreToolUse hook: Block destructive SQL in MCP database tools
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // empty')

if ! echo "$TOOL_NAME" | grep -qiE 'mcp__.*(sql|query|database|postgres|bigquery|db|supabase|neon)'; then
  exit 0
fi

SQL_CONTENT=$(echo "$TOOL_INPUT" | jq -r '.. | strings' 2>/dev/null)

if echo "$SQL_CONTENT" | grep -qiE '\b(INSERT\s+INTO|UPDATE\s+\w+\s+SET|DELETE\s+FROM|DROP\s+(TABLE|DATABASE|INDEX|SCHEMA|VIEW)|CREATE\s+(TABLE|DATABASE|INDEX|SCHEMA|VIEW)|ALTER\s+(TABLE|DATABASE)|TRUNCATE|GRANT|REVOKE)\b'; then
  echo '{"error": "BLOCKED: Destructive SQL detected in MCP database call ('"$TOOL_NAME"'). Only SELECT/EXPLAIN queries are allowed without explicit approval."}' >&2
  exit 2
fi

exit 0
```

### 5e. Auto-Format After Writes

Create `~/.claude/hooks/auto-format.sh`:

```bash
#!/bin/bash
# PostToolUse hook: Auto-format files after Write/Edit
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ "$TOOL" != "Write" && "$TOOL" != "Edit" ]]; then
  exit 0
fi

if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

EXT="${FILE_PATH##*.}"

# Prettier for web files
if command -v npx &>/dev/null; then
  case "$EXT" in
    js|jsx|ts|tsx|json|css|scss|less|html|md|yaml|yml|graphql)
      npx --yes prettier --write "$FILE_PATH" 2>/dev/null
      exit 0
      ;;
  esac
fi

# Python
if [[ "$EXT" == "py" ]]; then
  if command -v black &>/dev/null; then
    black --quiet "$FILE_PATH" 2>/dev/null
  elif command -v autopep8 &>/dev/null; then
    autopep8 --in-place "$FILE_PATH" 2>/dev/null
  fi
  exit 0
fi

# Go
if [[ "$EXT" == "go" ]] && command -v gofmt &>/dev/null; then
  gofmt -w "$FILE_PATH" 2>/dev/null
  exit 0
fi

# Rust
if [[ "$EXT" == "rs" ]] && command -v rustfmt &>/dev/null; then
  rustfmt "$FILE_PATH" 2>/dev/null
  exit 0
fi

exit 0
```

### 5f. File Conversion Hook

Create `~/.claude/hooks/convert-before-read.sh`:

```bash
#!/bin/bash
# PreToolUse hook: Block Read on convertible file types
# Redirects to mcp__to-markdown__convert_file instead
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
EXT=$(echo "$FILE_PATH" | sed 's/.*\.//' | tr '[:upper:]' '[:lower:]')

case "$EXT" in
  pdf|docx|doc|xlsx|xls|pptx|ppt|rtf|odt|ods|odp|epub|mobi|html|htm|eml|msg|csv|tsv|bmp|tiff|tif|heic|heif|webp)
    echo "{\"error\": \"BLOCKED: Use mcp__to-markdown__convert_file instead of Read for .$EXT files.\"}" >&2
    exit 2
    ;;
esac

exit 0
```

### 5g. Notification on Stop

Create `~/.claude/hooks/notify-on-stop.sh`:

```bash
#!/bin/bash
# Stop hook: macOS notification when Claude finishes
osascript -e 'display notification "Claude has finished and is waiting for input." with title "Claude Code" sound name "Glass"' 2>/dev/null
exit 0
```

### 5h. Audit Config Changes

Create `~/.claude/hooks/audit-config-change.sh`:

```bash
#!/bin/bash
# ConfigChange hook: Log all configuration changes
INPUT=$(cat)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SOURCE=$(echo "$INPUT" | jq -r '.source // "unknown"')
echo "[$TIMESTAMP] Config changed: source=$SOURCE" >> ~/.claude/audit.log
exit 0
```

### Make All Hooks Executable

```bash
chmod +x ~/.claude/hooks/*.sh
```

---

## 6. Specialist Agents

Agents are markdown files in `~/.claude/agents/`. Each defines a persona, tools, model, and output format.

### Agent Definition Format

```markdown
---
name: agent-name
description: |
  One-line description of what the agent does.
  <example>Example task 1</example>
  <example>Example task 2</example>
tools: Read, Grep, Glob, Bash
model: sonnet
color: red
---

You are a [role description]. You [key responsibilities].

## Core Responsibilities

1. **Area 1** — What it does
2. **Area 2** — What it does

## Process

1. **Step 1** — How to approach
2. **Step 2** — What to analyze
3. **Step 3** — How to report

## Output Format

[Structured template for the agent's deliverables]

## Quality Standards

- [Standard 1]
- [Standard 2]
```

### Recommended Starter Agents

Here are the 13 core agents that cover most workflows:

| Agent               | Model  | Tools                  | Purpose                                          |
| ------------------- | ------ | ---------------------- | ------------------------------------------------ |
| `agent-manager`     | haiku  | Read-only              | Triage ambiguous tasks to the right specialist   |
| `code-reviewer`     | sonnet | Read-only              | Correctness, maintainability, performance review |
| `security-auditor`  | sonnet | Read-only              | OWASP Top 10, secrets scanning, CVE checks       |
| `test-builder`      | sonnet | Read-write, worktree   | Write tests with full coverage                   |
| `debugger`          | sonnet | Read-only              | Systematic bug diagnosis and root cause analysis |
| `database-reviewer` | sonnet | Read-only              | Schema review, N+1 detection, migration safety   |
| `deploy-engineer`   | sonnet | Read-write, worktree   | CI/CD pipelines, Docker, infrastructure          |
| `documenter`        | haiku  | Read-write, background | READMEs, changelogs, ADRs                        |
| `ux-designer`       | sonnet | Read-only              | Visual design, accessibility, WCAG compliance    |
| `strategic-thinker` | sonnet | Web-enabled            | Marketing strategy, competitive analysis, GTM    |
| `media-planner`     | sonnet | Web-enabled            | Media plans, budget allocation, campaign design  |
| `data-scientist`    | sonnet | Web-enabled            | Statistical analysis, cohort analysis, funnels   |
| `cost-cleric`       | haiku  | Read-only, background  | AI model cost optimization                       |

### Model Selection Guide

- **Haiku** — Lightweight triage, documentation, cost analysis (cheapest)
- **Sonnet** — Most tasks: code review, security, testing, strategy (best value)
- **Opus** — Complex architecture planning, multi-system analysis (most capable, most expensive)

### Routing Rules

Create `~/.claude/agents.md` with a summary table and routing decision rules:

```markdown
## Routing Decision Rules

1. **Clear signal match** → Dispatch directly (no triage)
2. **Multiple signals, same domain** → Pick the most specific agent
3. **Signals from 2+ domains** → Run parallel combo if independent, otherwise agent-manager
4. **No signal match** → Handle directly in main session
5. **User names an agent explicitly** → Respect their choice
6. **Cost-sensitive batch ops** → Run cost-cleric in background alongside primary agent
```

### Parallel Agent Combos

These groups of agents can run simultaneously on independent concerns:

| Scenario           | Agents                                               |
| ------------------ | ---------------------------------------------------- |
| Feature review     | code-reviewer + security-auditor + test-builder      |
| PR with DB changes | code-reviewer + database-reviewer + security-auditor |
| Campaign planning  | strategic-thinker + media-planner + data-scientist   |
| Pre-deploy check   | code-reviewer + security-auditor + deploy-engineer   |

---

## 7. Custom Skills & Skill Library

Skills are slash commands defined as markdown files. This setup uses a **skill library** pattern where all skills live in a central directory (`~/.claude/skill-library/`) and are selectively enabled per project via symlinks.

### Architecture

```
~/.claude/
  skill-library/           # Central library — all skills live here
    commit/SKILL.md
    research/SKILL.md
    flow.init/SKILL.md
    ...
  skills/                  # Global skills — symlinks to library (always available)
    commit -> ../skill-library/commit
    start -> ../skill-library/start
    ...
  scripts/
    claude-skills          # CLI tool to manage per-project skill selection

~/my-project/.claude/
  skills/                  # Project skills — symlinks to library (project-specific)
    flow.init -> ~/.claude/skill-library/flow.init
    research -> ~/.claude/skill-library/research
    ...
```

### Skill Tiers

| Tier                                 | Skills                                                                                                                            | Behavior                                               |
| ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| **Global** (always on)               | `commit`, `start`, `handoff`, `compact`, `evolve`                                                                                 | Symlinked in `~/.claude/skills/`, available everywhere |
| **Bundles** (opt-in as group)        | `specflow` (12 flow.\* skills), `sync` (sync.up + sync.down)                                                                      | Add to a project with one command                      |
| **Selectable** (opt-in individually) | `research`, `test-and-fix`, `multi-plan`, `visualize`, `exec-brief`, `pr-review`, `standup`, `roadmap-review`, `bill-voice-skill` | Pick per project                                       |

### claude-skills CLI

Install the CLI tool from `scripts/claude-skills` in this repo:

```bash
cp scripts/claude-skills ~/.claude/scripts/claude-skills
chmod +x ~/.claude/scripts/claude-skills
echo 'export PATH="$HOME/.claude/scripts:$PATH"' >> ~/.zshrc
```

Usage:

```bash
claude-skills add specflow              # Enable all 12 flow.* skills in current project
claude-skills add research pr-review    # Enable individual skills
claude-skills add sync                  # Enable dotfile sync pair
claude-skills remove sync              # Disable dotfile sync
claude-skills list                     # Show enabled skills (global + project)
claude-skills available                # Show full library with status
claude-skills global-add standup       # Promote a skill to global
claude-skills global-remove standup    # Demote back to library-only
```

### Setting Up the Library

```bash
# 1. Create the library
mkdir -p ~/.claude/skill-library

# 2. Move all skills from ~/.claude/skills/ to the library
for dir in ~/.claude/skills/*/; do
  mv "$dir" ~/.claude/skill-library/
done

# 3. Symlink the global skills back
for skill in commit start handoff compact evolve; do
  ln -s ~/.claude/skill-library/$skill ~/.claude/skills/$skill
done

# 4. Enable skills per project
cd ~/my-project
mkdir -p .claude/skills
claude-skills add specflow research
```

### Skill Definition Format

Each skill lives in `~/.claude/skill-library/<name>/SKILL.md`:

```markdown
---
description: One-line description of what the skill does
context: fork
allowed-tools: Read, Bash, Grep, Glob
model: haiku
---

# Skill Name

## When to Activate

Trigger this skill when the user says: `/skill-name` or "natural language alias"

## Process

### Step 1: [Name]

[What to do]

### Step 2: [Name]

[What to do]

## Rules

- [Rule 1]
- [Rule 2]
```

### Key Settings

| Field           | Options                   | Purpose                                                 |
| --------------- | ------------------------- | ------------------------------------------------------- |
| `context`       | `fork` or `inherit`       | `fork` = isolated context (recommended for most skills) |
| `allowed-tools` | tool names                | Restricts which tools the skill can use                 |
| `model`         | `haiku`, `sonnet`, `opus` | Override the session's default model                    |

### Recommended Starter Skills

**Essential (start here):**

| Skill           | Model  | What It Does                                           |
| --------------- | ------ | ------------------------------------------------------ |
| `/commit`       | haiku  | Stage specific files, write conventional commits, push |
| `/start`        | haiku  | Session health check — verify tools, MCP, keys, agents |
| `/handoff`      | haiku  | Generate HANDOFF.md for session continuation           |
| `/compact`      | haiku  | Smart context compaction preserving key decisions      |
| `/test-and-fix` | sonnet | Run tests, analyze failures, fix, re-run loop          |

**Power user:**

| Skill         | Model  | What It Does                                          |
| ------------- | ------ | ----------------------------------------------------- |
| `/research`   | sonnet | Deep web + codebase research with synthesized report  |
| `/multi-plan` | sonnet | Parallel multi-agent feature planning                 |
| `/visualize`  | sonnet | Generate interactive HTML dashboards from data        |
| `/exec-brief` | sonnet | Transform analysis into a 1-page executive summary    |
| `/pr-review`  | sonnet | Structured PR review with actionable feedback         |
| `/standup`    | haiku  | Daily standup from git activity                       |
| `/evolve`     | haiku  | Analyze session patterns, recommend new skills/agents |

### Example: /commit Skill

```markdown
---
description: Stage, commit, and push changes following project conventions
context: fork
allowed-tools: Read, Bash, Grep, Glob
model: haiku
---

# Commit Skill

## Process

### Step 1: Gather State (parallel)

1. `git status`
2. `git diff --stat`
3. `git diff --cached --stat`
4. `git log --oneline -5`

### Step 2: Stage Files

- Stage modified and new files by specific name
- **Never use `git add .` or `git add -A`**
- Skip .env, credentials, secrets, large binaries

### Step 3: Write Commit Message

- Match the repo's commit style from git log
- Imperative mood, under 72 characters
- End with: `Co-Authored-By: Claude <noreply@anthropic.com>`

### Step 4: Commit and Push

1. `git add <specific files>`
2. `git commit` with HEREDOC message
3. `git push`
4. `git status` to verify

### Step 5: Report

- Files committed, message used, push status

## Rules

- Never amend unless explicitly asked
- Never use --no-verify
- Never force push unless explicitly asked
- If no changes, say so and stop
```

---

## 7.5 gstack: Browser QA and Shipping Skills

[gstack](https://github.com/garrytan/gstack) is an open-source skill library by Garry Tan (YC CEO) with 23.6k stars. It provides 15 slash-command skills that extend Claude Code with real browser QA testing, visual design audits, CEO/engineering plan reviews, shipping workflows, and retrospectives.

### What gstack Provides

- **Real browser QA** — `/qa` and `/qa-only` run actual browser tests against your running app
- **Design audits** — `/qa-design-review` combines functional QA with visual design feedback
- **Plan reviews** — `/plan-ceo-review`, `/plan-eng-review`, `/plan-design-review` give multi-lens feedback on proposals
- **Shipping** — `/ship` handles the end-to-end release workflow
- **Browsing** — `/browse` wraps chrome browser tools so you never call `mcp__claude-in-chrome__*` directly
- **Retrospectives** — `/retro` facilitates structured team retrospectives

### How gstack Complements Custom Skills

The custom skills and SpecFlow in this setup handle spec-driven development: planning, implementation, review, and merge. gstack handles the outer loop — QA, shipping, and stakeholder reviews — that happens before and after code lands.

| Phase         | Use This                     |
| ------------- | ---------------------------- |
| Design specs  | `/flow.design` (SpecFlow)    |
| Implement     | `/flow.implement` (SpecFlow) |
| Code review   | `/flow.review` (SpecFlow)    |
| QA testing    | `/qa` (gstack)               |
| Ship          | `/ship` (gstack)             |
| Retrospective | `/retro` (gstack)            |

### Installation

gstack requires Bun v1.0+:

```bash
# Install Bun if needed
curl -fsSL https://bun.sh/install | bash

# Install gstack
git clone https://github.com/garrytan/gstack.git ~/.claude/skills/gstack
cd ~/.claude/skills/gstack && ./setup
```

### Key Rule: Use `/browse` for All Web Browsing

Never call `mcp__claude-in-chrome__*` or `mcp__chrome-browser__*` tools directly. Always use `/browse` from gstack instead — it wraps the browser tools with proper error handling and session management.

For full documentation on all 15 skills, see the [gstack repo](https://github.com/garrytan/gstack).

---

## 8. MCP Server Integrations

MCP servers connect Claude to external services. Define them in `~/.claude/mcp.json`:

```json
{
  "mcpServers": {
    "to-markdown": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/to-markdown-mcp"]
    }
  }
}
```

### Adding Servers

You can also add via CLI:

```bash
# User-level (available in all projects)
claude mcp add to-markdown npx -y @anthropic-ai/to-markdown-mcp

# Project-level (available only in this project)
claude mcp add --scope project airtable npx -y @anthropic-ai/airtable-mcp
```

### Recommended MCP Servers

| Server                  | Install Command                                                                   | What It Does                              |
| ----------------------- | --------------------------------------------------------------------------------- | ----------------------------------------- |
| **to-markdown**         | `claude mcp add to-markdown npx -y @anthropic-ai/to-markdown-mcp`                 | Convert PDF/DOCX/XLSX to markdown         |
| **sequential-thinking** | `claude mcp add sequential-thinking npx -y @anthropic-ai/sequential-thinking-mcp` | Structured reasoning for complex problems |
| **memory**              | `claude mcp add memory npx -y @anthropic-ai/memory-mcp`                           | Knowledge graph for persistent facts      |
| **playwright**          | `claude mcp add playwright npx -y @anthropic-ai/playwright-mcp`                   | Headless browser automation               |
| **Context7**            | Available as Claude.ai connector                                                  | Live documentation lookup                 |

### Cloud Connectors (via Claude.ai)

These connect through your Claude.ai account settings:

- Google Workspace (Gmail, Drive, Docs, Sheets, Calendar)
- Slack
- Asana
- GitHub

---

## 9. Behavioral Rules

### Global Rules

Create `~/.claude/rules/coding.md`:

```markdown
# Coding Rules

## Before Modifying Code

- Always read existing code before making changes
- Follow existing naming conventions, patterns, and style
- Prefer editing existing files over creating new ones

## Code Quality

- Keep functions under 30 lines with low cyclomatic complexity
- Use early returns to reduce nesting
- Handle errors at system boundaries; trust internal code
- Write tests for all new functionality

## Security

- Use parameterized queries for all SQL
- Never commit .env files, credentials, secrets, or API keys
- Validate and sanitize all external inputs

## Commits

- Stage specific files — avoid `git add .` or `git add -A`
- Review diffs before committing
```

### Project-Scoped Rules

Place rules in a project's `.claude/rules/` directory. They only load when Claude is working in that project:

```bash
# Example: database rules for a specific project
mkdir -p ~/my-project/.claude/rules
cat > ~/my-project/.claude/rules/database.md << 'EOF'
# Database Rules
- All queries must use parameterized statements
- Migrations must be reversible
- Add indexes for any column used in WHERE or JOIN
EOF
```

---

## 10. Memory System

Claude Code has built-in persistent memory stored in `~/.claude/projects/<path>/memory/`.

### Memory Types

| Type        | Purpose                         | Example                                 |
| ----------- | ------------------------------- | --------------------------------------- |
| `user`      | Who you are, your preferences   | "Senior engineer, prefers terse output" |
| `feedback`  | Corrections you've given Claude | "Don't mock the database in tests"      |
| `project`   | Ongoing work context            | "Merge freeze starts March 5"           |
| `reference` | Where to find external info     | "Bugs tracked in Linear project INGEST" |

### Memory File Format

Each memory is a markdown file with frontmatter:

```markdown
---
name: user-role
description: User's role and communication preferences
type: user
---

Senior software engineer. Prefers concise, technical responses.
Deep expertise in Go and PostgreSQL, new to React.
```

### MEMORY.md Index

The index file at `memory/MEMORY.md` links to all memory files. Keep it under 200 lines — it's loaded into every conversation:

```markdown
# Project Memory

## User Identity

- [user_role.md](user_role.md) — Role and preferences

## Feedback

- [feedback_testing.md](feedback_testing.md) — Testing conventions

## Project Context

- [project_auth.md](project_auth.md) — Auth rewrite context
```

---

## 11. Reference Documentation

Create `~/.claude/REFERENCE.md` as an on-demand reference (not loaded per-turn):

```markdown
# Claude Code Reference

> Read-on-demand reference material. Consult when needed.

## Agent Routing Tables

### Fast-Path Routing (signal keywords -> agent)

| Signal Keywords          | Agent            | Notes         |
| ------------------------ | ---------------- | ------------- |
| CSS, accessibility, WCAG | ux-designer      | Frontend only |
| test, coverage, TDD      | test-builder     | Write-capable |
| security, OWASP, CVE     | security-auditor | Read-only     |
| bug, debug, error        | debugger         | Read-only     |

...

## Parallel Agent Combos

| Scenario       | Agents                                          |
| -------------- | ----------------------------------------------- |
| Feature review | code-reviewer + security-auditor + test-builder |

...

## Skills Registry

[List all skills with descriptions]

## Hooks Detail

[List all hooks with matchers and actions]
```

---

## 12. Session Workflow

### Starting a Session

```
/start
```

This runs the health check: verifies CLI, model, MCP servers, agents, hooks, rules, and memory.

### During a Session

- Use slash commands: `/commit`, `/research`, `/test-and-fix`
- Claude automatically routes to specialist agents based on your request
- At 50-60% context, run `/compact` or `/clear`

### Ending a Session

```
/handoff
```

Generates a HANDOFF.md documenting progress, decisions, and next steps for the next session.

### Session Naming

Name sessions as `[project]-[date]-[topic]`:

- `ai-assistant-2026-03-16-auth-fix`
- `product-dev-2026-03-16-campaign-plan`

---

## Tips and Best Practices

1. **Start with hooks** — The safety hooks are the highest-value component. They prevent costly mistakes.

2. **Add agents incrementally** — Start with code-reviewer, security-auditor, and test-builder. Add more as you find workflow gaps.

3. **Use Haiku for lightweight skills** — `/commit`, `/standup`, `/handoff` don't need Opus or Sonnet. Haiku is 10-20x cheaper.

4. **Project-scope your MCP servers** — Don't load Airtable into a pure coding project. Use `--scope project`.

5. **Keep MEMORY.md under 200 lines** — It's loaded every turn. Link to detailed memory files instead.

6. **Use the PreCompact hook** — Without it, context compaction can lose critical decisions and file paths.

7. **Set up .claudeignore** — In every project, exclude `node_modules`, `dist`, `.next`, and other build artifacts:

```
node_modules/
dist/
.next/
*.min.js
*.map
```

8. **Writer/Reviewer pattern** — For features over 100 lines, use two sessions. Session A implements, Session B reviews with fresh context (no implementation bias).
