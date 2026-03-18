---
description: Session startup health check — verifies tools, MCP servers, keys, agents, and provides a session startup checklist
context: fork
allowed-tools: Read, Grep, Glob, Bash, ListMcpResourcesTool, ToolSearch, AskUserQuestion, mcp__ai-assistant__*, mcp__claude_ai_Asana__asana_list_workspaces
model: haiku
---

# Session Startup Health Check

Run a comprehensive environment and configuration health check, then provide a session startup checklist.

## Process

### Step 1: Core Environment

Run these bash commands to gather environment info:

```bash
# Claude Code version
claude --version 2>/dev/null || echo "claude CLI: not found"

# Runtime versions
node --version 2>/dev/null || echo "node: not found"
python3 --version 2>/dev/null || echo "python3: not found"
git --version 2>/dev/null || echo "git: not found"
gh --version 2>/dev/null | head -1 || echo "gh: not found"
```

### Step 2: GitHub Authentication

```bash
gh auth status 2>&1 | head -5
```

### Step 3: MCP Servers

Check which MCP servers are configured. The primary config is `~/.claude/mcp.json`:

```bash
cat ~/.claude/mcp.json 2>/dev/null | python3 -c "
import sys, json
d = json.load(sys.stdin)
servers = d.get('mcpServers', {})
for name, cfg in servers.items():
    stype = cfg.get('type', 'stdio')
    cmd = cfg.get('command', cfg.get('url', 'N/A'))
    print(f'  {name}: {stype} ({cmd})')
" 2>/dev/null || echo "Could not parse ~/.claude/mcp.json"
```

**Verify each MCP server is live** by calling a lightweight tool on each one. Run these checks in parallel:

| Server         | Health check tool                                                          | Call           |
| -------------- | -------------------------------------------------------------------------- | -------------- |
| `ai-assistant` | `mcp__ai-assistant__time_now`                                              | No args needed |
| `asana`        | `mcp__claude_ai_Asana__asana_list_workspaces`                              | No args needed |
| `vercel`       | Use `ToolSearch` with `+vercel` to discover a read-only tool, then call it |

For any **claude.ai** connectors (e.g., `claude.ai Slack`), use `ListMcpResourcesTool` with `server` set to the connector name. If resources are returned, mark it as live.

For each server, report:

- **Live** — tool returned a valid response
- **Down** — tool errored or timed out
- **Auth expired** — tool returned an auth/unauthorized error

If a server is Down or Auth expired, flag it as a **HIGH** issue in the Issues Found section.

Also check for project-level MCP config:

```bash
cat .claude/mcp.json 2>/dev/null || cat .mcp.json 2>/dev/null || echo "No project-level MCP config"
```

---

## Optional: AI Assistant Infrastructure

> Steps 3b and 3c are specific to a custom AI Assistant MCP server that uses Doppler for secrets management. If you are not using this infrastructure, skip to Step 4.

---

### Step 3b: AI Assistant Secrets Check

Verify Doppler is available and check which secrets are configured:

```bash
cd ~/claude/ai-assistant && doppler run -- ai-assistant secrets list 2>&1
```

Report each secret's status (present/missing). Flag missing secrets as MEDIUM issues — they mean that provider won't work at runtime.

**Excluded providers** — these are intentionally not connected and their missing secrets should NOT be flagged as issues:

- Todoist (TODOIST_API_TOKEN)
- Zoom (ZOOM_CLIENT_ID, ZOOM_CLIENT_SECRET, ZOOM_ACCOUNT_ID)
- Bear Notes (BEAR_API_TOKEN)

If a missing secret belongs to an excluded provider, silently skip it.

### Step 3c: AI Assistant Provider Liveness (live calls via Doppler)

This is the **primary** health check — it makes real API calls to verify each provider actually works, not just that secrets exist. Run each check via Doppler from the ai-assistant project directory. Run all checks **in parallel**.

```bash
cd ~/claude/ai-assistant && doppler run -- ai-assistant secrets check email/gmail 2>&1
```

| Category    | Provider        | Check command                                                        |
| ----------- | --------------- | -------------------------------------------------------------------- |
| Email       | gmail           | `doppler run -- ai-assistant secrets check email/gmail`              |
| Calendar    | google-calendar | `doppler run -- ai-assistant secrets check calendar/google-calendar` |
| Drive       | google-drive    | `doppler run -- ai-assistant secrets check drive/google-drive`       |
| Messaging   | imessage        | `doppler run -- ai-assistant secrets check messaging/imessage`       |
| Messaging   | slack           | `doppler run -- ai-assistant secrets check messaging/slack`          |
| Notes       | apple-notes     | `doppler run -- ai-assistant secrets check notes/apple-notes`        |
| Tasks       | apple-reminders | `doppler run -- ai-assistant secrets check tasks/apple-reminders`    |
| Tasks       | asana           | `doppler run -- ai-assistant secrets check tasks/asana`              |
| Contacts    | apple-contacts  | `doppler run -- ai-assistant secrets check contacts/apple-contacts`  |
| Contacts    | google-contacts | `doppler run -- ai-assistant secrets check contacts/google-contacts` |
| VCS         | github          | `doppler run -- ai-assistant secrets check vcs/github`               |
| Weather     | open-meteo      | `doppler run -- ai-assistant secrets check weather/open-meteo`       |
| Transcripts | fireflies       | `doppler run -- ai-assistant secrets check transcripts/fireflies`    |
| Transcripts | granola         | `doppler run -- ai-assistant secrets check transcripts/granola`      |

After the secrets checks, make **real API calls** via MCP tools to verify auth actually works — `_capabilities` is NOT sufficient as it doesn't test auth tokens. Use `ToolSearch` to load tools first. Run all in **parallel**:

| Category    | Provider        | Tool                                          | Args                                                                                  | Why this call                    |
| ----------- | --------------- | --------------------------------------------- | ------------------------------------------------------------------------------------- | -------------------------------- |
| Email       | gmail           | `mcp__ai-assistant__email_search`             | `{ query: "test", limit: 1, provider: "gmail" }`                                      | Forces OAuth token refresh       |
| Calendar    | google-calendar | `mcp__ai-assistant__calendar_list_events`     | `{ startDate: "{today}", endDate: "{today}", limit: 1, provider: "google-calendar" }` | Forces OAuth token refresh       |
| Drive       | google-drive    | `mcp__ai-assistant__drive_search`             | `{ query: "test", limit: 1, provider: "google-drive" }`                               | Forces OAuth token refresh       |
| Contacts    | google-contacts | `mcp__ai-assistant__contacts_list`            | `{ limit: 1, provider: "google-contacts" }`                                           | Forces OAuth token refresh       |
| Messaging   | imessage        | `mcp__ai-assistant__messaging_capabilities`   | `{ provider: "imessage" }`                                                            | Local — no auth to test          |
| Messaging   | slack           | `mcp__ai-assistant__messaging_capabilities`   | `{ provider: "slack" }`                                                               | Token-based, capabilities enough |
| Notes       | apple-notes     | `mcp__ai-assistant__notes_capabilities`       | `{ provider: "apple-notes" }`                                                         | Local — no auth to test          |
| Tasks       | apple-reminders | `mcp__ai-assistant__tasks_capabilities`       | `{ provider: "apple-reminders" }`                                                     | Local — no auth to test          |
| Tasks       | asana           | `mcp__ai-assistant__tasks_capabilities`       | `{ provider: "asana" }`                                                               | Token-based, capabilities enough |
| Contacts    | apple-contacts  | `mcp__ai-assistant__contacts_capabilities`    | `{ provider: "apple-contacts" }`                                                      | Local — no auth to test          |
| VCS         | github          | `mcp__ai-assistant__vcs_repos_list`           | `{ limit: 1, provider: "github" }`                                                    | Forces token validation          |
| Weather     | open-meteo      | `mcp__ai-assistant__weather_current`          | `{ location: "New York" }`                                                            | Public API — verifies reachable  |
| Transcripts | fireflies       | `mcp__ai-assistant__transcripts_capabilities` | `{ provider: "fireflies" }`                                                           | Token-based, capabilities enough |
| Transcripts | granola         | `mcp__ai-assistant__transcripts_capabilities` | `{ provider: "granola" }`                                                             | Local — no auth to test          |

Use `{today}` = the current date in `YYYY-MM-DD` format.

For each provider, combine the secrets check and live call results to report:

- **Live** — secrets present AND live call returned data successfully
- **Auth expired** — live call returned `unauthorized`, `unauthorized_client`, or `Failed to refresh token`
- **Down** — tool errored or timed out for a non-auth reason
- **Secrets missing** — secrets check failed (provider can't work at all)

**Excluded providers** — skip these entirely, do not call or report:

- Zoom (`meetings` category — not connected)
- Todoist (`tasks` category — not connected)
- Bear (`notes` category — not connected)
- WhatsApp (`messaging` category — not yet stable)
- Obsidian (`notes` category — not yet connected)
- Apple Photos (`photos` category — not yet connected)
- Hardcover (`reading` category — not yet connected)
- Drafts (`notes` category — not yet connected)
- Readwise (`reading` category — not set up)
- Apple Health (`health` category — not set up)
- Apple Mail (`email` category — not used, use Gmail)
- Apple Calendar (`calendar` category — not used, use Google Calendar)

If any non-excluded provider is Auth expired, flag as **HIGH** and recommend the fix:

- Google providers (gmail, google-calendar, google-drive, google-contacts): `cd ~/claude/ai-assistant && doppler run -- ai-assistant auth google`
- GitHub: `cd ~/claude/ai-assistant && doppler run -- ai-assistant auth github`
- Slack: check `SLACK_TOKEN` in Doppler — `doppler secrets set SLACK_TOKEN`
- Fireflies: check `FIREFLIES_API_KEY` in Doppler — `doppler secrets set FIREFLIES_API_KEY`
- Asana: check `ASANA_ACCESS_TOKEN` in Doppler — `doppler secrets set ASANA_ACCESS_TOKEN`

If Down (non-auth error), flag as **HIGH** and recommend checking logs or restarting the MCP server.

### Step 4: API Keys

Check which API keys are available in the shell environment (names only, never values):

```bash
env | grep -iE "^(ANTHROPIC_|GEMINI_|GOOGLE_|GITHUB_|OPENAI_)" 2>/dev/null | sed 's/=.*$/=<set>/'
```

Note: Keys managed by `mcp-launch.sh` or Doppler won't appear here — that's expected and secure. Call this out explicitly.

### Step 5: Skills Inventory

```bash
ls ~/.claude/skills/ 2>/dev/null
ls .claude/skills/ 2>/dev/null 2>&1 || true
```

Count total skills (global + project-level).

### Step 6: Agents Inventory

```bash
ls ~/.claude/agent-memory/ 2>/dev/null
```

Confirm all 12 specialist agents have memory directories.

### Step 7: Hooks

List hook scripts and count how many are executable:

```bash
ls -la ~/.claude/hooks/*.sh 2>/dev/null
```

```bash
find ~/.claude/hooks/ -name "*.sh" -type f -perm +111 2>/dev/null | wc -l
```

The expected hook scripts are: `audit-config-change.sh`, `auto-format.sh`, `block-destructive.sh`, `convert-before-read.sh`, `guard-mcp-publish.sh`, `guard-mcp-sql.sh`, `inject-security-context.sh`, `validate-readonly-query.sh`, `verify-task-complete.sh`. Additional hooks (like `log-subagent-start.sh`) are normal and should not be flagged. Count the **minimum** as 9, but more is fine.

### Step 8: Rules

There are two types of rule files:

**Global rules** (in `~/.claude/rules/`):

```bash
ls ~/.claude/rules/ 2>/dev/null
```

Only `coding.md` is expected here. Confirm it is present.

**Project-scoped rules** (in each project's `.claude/rules/` directory):

- Any project-scoped rule files (e.g., `marketing.md`, `database.md`) — expected in each project's `.claude/rules/` directory

```bash
# Check for your own project-scoped rule files here. Example:
# ls ~/your-project/.claude/rules/marketing.md 2>/dev/null && echo "present" || echo "MISSING"
```

Do NOT flag project-scoped rules as missing from the global rules directory — they belong in their projects.

### Step 9: Settings and Model Detection

Read `settings.json` for env vars, hooks, **and the configured model**:

```bash
cat ~/.claude/settings.json 2>/dev/null | python3 -c "
import sys, json
d = json.load(sys.stdin)
env = d.get('env', {})
hooks = d.get('hooks', {})
model = d.get('model', 'NOT SET')
hook_count = sum(len(v) for v in hooks.values())
print(f'  model: {model}')
print(f'  Env vars: {len(env)} configured')
print(f'  Hook events: {len(hooks)} ({hook_count} total hook entries)')
for k, v in env.items():
    print(f'    {k}={v}')
" 2>/dev/null
```

Also check the environment variable fallback:

```bash
echo "ANTHROPIC_MODEL=${ANTHROPIC_MODEL:-NOT SET}"
```

**Model resolution logic** (apply in this order):

1. The `model` field in `~/.claude/settings.json` takes priority
2. If not set, fall back to the `ANTHROPIC_MODEL` environment variable
3. If neither is set, the default is `opus` (200K context)

**Context window detection:**

- If the resolved model string contains `[1m]` (e.g. `opus[1m]`, `sonnet[1m]`), the context window is **1M tokens**
- Otherwise, the context window is **200K tokens**

**Base model mapping:**

- `opus` or `opus[1m]` → Claude Opus 4.6
- `sonnet` or `sonnet[1m]` → Claude Sonnet 4.6
- `haiku` or `haiku[1m]` → Claude Haiku 4.5
- Any other value → report it verbatim and flag as INFO

Store the detected model name and context window — use these values in all output. Do NOT hardcode model or context values anywhere in the output.

### Step 10: Project Context

Check if we're in a git repo and if there's a project-level CLAUDE.md:

```bash
git rev-parse --is-inside-work-tree 2>/dev/null && echo "Git repo: yes ($(git remote get-url origin 2>/dev/null || echo 'no remote'))" || echo "Git repo: no"
cat CLAUDE.md 2>/dev/null | head -5 || echo "No project CLAUDE.md"
cat .claude/CLAUDE.md 2>/dev/null | head -5 || echo "No .claude/CLAUDE.md"
```

Check for HANDOFF.md or ROADMAP.md:

```bash
ls HANDOFF.md ROADMAP.md 2>/dev/null || echo "No HANDOFF.md or ROADMAP.md found"
```

### Step 11: Memory Check

```bash
cat ~/.claude/projects/$(pwd | sed 's|/|-|g' | sed 's|^-||')/memory/MEMORY.md 2>/dev/null | head -10 || echo "No session memory for this project directory"
```

## Output Format

**IMPORTANT — Model Reporting**: You (Haiku) are running this skill for cost efficiency. The USER's session model is determined by what you detected in Step 9. Use the **detected** model name and context window in all output — never hardcode these values and never report your own model identity (Haiku).

### When issues are found (MEDIUM or above)

Use the full detailed format with tables:

```
## Session Health Check — {date}

### Core Environment
| Item | Status |
|------|--------|
| Claude Code | v{version} |
| Model | {detected model name} |
| Context Window | {detected context window} |
| Node.js | v{version} |
| Python | {version} |
| Git | {version} |
| GitHub CLI | v{version}, {auth status} |

### MCP Servers ({count} active)
| Server | Status |
|--------|--------|
| {name} | {status} |
...

### Configuration
| Component | Count | Status |
|-----------|-------|--------|
| Skills | {n} global, {m} project | All loaded |
| Agents | {n} with memory | All present |
| Hooks | {n} scripts, {m} events | All executable |
| Rules | {n} global, {m} project-scoped | {status} |

### Issues Found
{severity badge} **{title}**
- {description}
- Fix: `{command}`
```

Then use `AskUserQuestion` to ask: **"Found {N} issue(s). Want me to fix them?"** with options:

- "Yes, fix all" — fix all issues automatically
- "Show me first" — list the fix commands and let the user decide
- "Skip" — continue without fixing

### When no issues are found (all clean or INFO-only)

Use a compact single-table format — no separate sections:

```
## Session Health Check — {date}

| | Status |
|---|---|
| Claude Code | v{version} · {detected model name} · {detected context window} context |
| Environment | Node {v} · Python {v} · Git {v} · gh {v} ({auth}) |
| MCP Servers | {live count}/{total count} live: {name}=Live, {name}=Down, ... |
| AI Assistant | {n}/{total} secrets · {live providers}/{checked providers} providers live (excluded: {list}) |
| Configuration | {n} skills · {n} agents · {n} hooks · {n} rules |
| Project | {pwd} · Git: {yes/no} · CLAUDE.md: {yes/no} |

{If INFO items exist, list as single-line notices}

**All systems operational.**
```

Then use `AskUserQuestion` to ask: **"Ready to work. Clear context and start fresh?"** with options:

- "Yes, /clear" — user wants to clear context before starting
- "No, continue" — keep current context and proceed

## Diagnostic Rules

Every issue found MUST be reported in the "Issues Found" section with three parts:

1. **What's wrong** — clear description of the problem
2. **Why it matters** — impact if left unfixed
3. **How to fix** — exact command(s) or steps to resolve it

### Issue Catalog

| Condition                                                       | Severity | Fix                                                                                                                                                                                                                                                                                                                                 |
| --------------------------------------------------------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MCP server not responding (specific server down)                | HIGH     | Name the server that failed. Check `~/.claude/mcp.json` config for that server. For stdio servers, verify the command exists and runs. For SSE servers, verify the URL is reachable. Restart Claude Code if needed.                                                                                                                 |
| MCP server auth expired                                         | HIGH     | Name the server. For OAuth-based servers (Asana, Slack), re-authenticate via `claude mcp login <server>`. For token-based servers, refresh the token in Doppler or `~/.claude/secrets/`.                                                                                                                                            |
| Missing core hook scripts (fewer than 9 .sh)                    | MEDIUM   | Identify which script is missing by comparing against: `audit-config-change.sh`, `auto-format.sh`, `block-destructive.sh`, `convert-before-read.sh`, `guard-mcp-publish.sh`, `guard-mcp-sql.sh`, `inject-security-context.sh`, `validate-readonly-query.sh`, `verify-task-complete.sh`. Additional hooks beyond these 9 are normal. |
| Hook script not executable                                      | MEDIUM   | Run `chmod +x ~/.claude/hooks/<script-name>` for each non-executable script.                                                                                                                                                                                                                                                        |
| Missing agent memory directories (expected 12)                  | LOW      | Run `mkdir -p ~/.claude/agent-memory/<agent-name>` for each missing agent. Expected: code-reviewer, cost-cleric, data-scientist, database-reviewer, debugger, deploy-engineer, documenter, media-planner, security-auditor, strategic-thinker, test-builder, ux-designer.                                                           |
| Missing global rule (coding.md)                                 | MEDIUM   | Check `~/.claude/rules/` for coding.md. Restore from backup or re-create.                                                                                                                                                                                                                                                           |
| Missing project-scoped rule file                                | LOW      | Check the project's `.claude/rules/` directory. Restore the missing rule file from your own backup or recreate it.                                                                                                                                                                                                                  |
| GitHub CLI not authenticated                                    | HIGH     | Run `gh auth login` and follow the prompts. Choose SSH protocol.                                                                                                                                                                                                                                                                    |
| GitHub CLI not installed                                        | HIGH     | Run `brew install gh` (macOS) or see https://cli.github.com/                                                                                                                                                                                                                                                                        |
| Node.js not found                                               | HIGH     | Install via `nvm install --lts` or `brew install node`                                                                                                                                                                                                                                                                              |
| Python not found                                                | MEDIUM   | Install via `brew install python3`                                                                                                                                                                                                                                                                                                  |
| Git not found                                                   | HIGH     | Install via `brew install git` or Xcode Command Line Tools                                                                                                                                                                                                                                                                          |
| No project CLAUDE.md (inside a git repo)                        | LOW      | Consider creating a project-level `CLAUDE.md` with repo-specific conventions. Run `touch CLAUDE.md` to start.                                                                                                                                                                                                                       |
| HANDOFF.md exists                                               | INFO     | A previous session left a handoff. Read it with `cat HANDOFF.md` to resume context.                                                                                                                                                                                                                                                 |
| ROADMAP.md exists                                               | INFO     | A project roadmap exists. Review it for phase orientation before starting work.                                                                                                                                                                                                                                                     |
| No session memory for this project                              | INFO     | No cross-session memory saved yet. Memories will accumulate as you work. No action needed.                                                                                                                                                                                                                                          |
| `~/.claude/mcp.json` cannot be parsed                           | HIGH     | Config file is corrupted. Check syntax with `python3 -m json.tool ~/.claude/mcp.json`.                                                                                                                                                                                                                                              |
| ai-assistant provider missing secrets                           | MEDIUM   | Run `doppler run -- ai-assistant secrets list` to see which secrets are missing. Set them via `doppler secrets set <KEY>`. Common: `SLACK_TOKEN`, `ZOOM_CLIENT_ID`, `ZOOM_CLIENT_SECRET`, `ZOOM_ACCOUNT_ID`.                                                                                                                        |
| ai-assistant status unhealthy                                   | HIGH     | Run `doppler run -- ai-assistant status` to diagnose. Check Doppler connection with `doppler run -- printenv`. Verify the server builds with `cd ~/claude/ai-assistant && pnpm build`.                                                                                                                                              |
| Doppler CLI not available or not authenticated                  | HIGH     | Install via `brew install dopplerhq/cli/doppler` then `doppler login`. Verify with `doppler run -- printenv`.                                                                                                                                                                                                                       |
| Claude Code CLI not found                                       | CRITICAL | Install or update: `npm install -g @anthropic-ai/claude-code`                                                                                                                                                                                                                                                                       |
| Claude Code CLI outdated (major version behind)                 | MEDIUM   | Update: `npm update -g @anthropic-ai/claude-code` or `claude update`                                                                                                                                                                                                                                                                |
| No model configured (neither settings.json nor ANTHROPIC_MODEL) | INFO     | Using default model. Set `"model": "opus[1m]"` in `~/.claude/settings.json` to make it explicit.                                                                                                                                                                                                                                    |
| settings.json model and ANTHROPIC_MODEL env var disagree        | LOW      | Both are set but differ. `settings.json` takes priority. Remove the env var or align them: `export ANTHROPIC_MODEL="<same value as settings.json>"`.                                                                                                                                                                                |
| Unrecognized model string in settings.json                      | INFO     | The `model` value doesn't match known models (opus, sonnet, haiku). Report it verbatim so the user can verify.                                                                                                                                                                                                                      |

### Output Rules

- If zero issues are found: use the **compact format**, end with **All systems operational.**, then ask "Ready to work. Clear context and start fresh?" via `AskUserQuestion`.
- If only INFO-level items are found: use the **compact format**, append INFO items as single-line notices, end with **All systems operational.**, then ask "Ready to work. Clear context and start fresh?" via `AskUserQuestion`.
- If MEDIUM or HIGH issues are found: use the **detailed format**, list each issue with severity badge, description, and fix command, then ask "Found {N} issue(s). Want me to fix them?" via `AskUserQuestion`.
- If any CRITICAL issue is found: use the **detailed format**, end with **CRITICAL: {description}. Resolve before proceeding.**, then ask to fix via `AskUserQuestion`.
- Always show the fix as a copyable command or concrete step — never just say "fix it" or "check the docs".
- **Never report your own model (Haiku) — always report the model and context window detected in Step 9.**
