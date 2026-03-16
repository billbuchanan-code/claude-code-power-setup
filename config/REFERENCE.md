# Claude Code Reference

> Read-on-demand reference material. Not loaded per-turn — consult when needed.

## Agent Routing Tables

### Fast-Path Routing (signal keywords → agent)

| Signal Keywords                                                                              | Agent                 | Notes                        |
| -------------------------------------------------------------------------------------------- | --------------------- | ---------------------------- |
| CSS, accessibility, WCAG, contrast, responsive, UI review, color, spacing, ARIA              | **ux-designer**       | Frontend visual + a11y only  |
| cost, model selection, token, pricing (AI), haiku vs sonnet, budget (AI ops)                 | **cost-cleric**       | Runs in background           |
| README, changelog, ADR, documentation, docs, JSDoc, API docs                                 | **documenter**        | Runs in background, worktree |
| test, spec, coverage, TDD, unit test, edge cases, test plan                                  | **test-builder**      | Write-capable, worktree      |
| strategy, competitive, SWOT, positioning, GTM, go-to-market, brand, market                   | **strategic-thinker** | Web-enabled                  |
| media plan, budget allocation, channel mix, flighting, CPM, CPC, advertising, campaign spend | **media-planner**     | Web-enabled                  |
| statistics, cohort, funnel, A/B test, regression, analytics, LTV, churn, segmentation        | **data-scientist**    | Web-enabled                  |
| security, vulnerability, OWASP, audit, secrets, injection, CVE, auth review, hardcoded       | **security-auditor**  | Read-only                    |
| code review, review PR, review changes, maintainability, refactor review                     | **code-reviewer**     | Read-only                    |
| bug, debug, why is, broken, error, crash, failing, 500, 403, root cause                      | **debugger**          | Read-only                    |
| deploy, CI/CD, Docker, pipeline, GitHub Actions, infrastructure, Terraform, release          | **deploy-engineer**   | Write-capable, worktree      |
| schema, migration, query, N+1, index, SQL performance, database, ORM                         | **database-reviewer** | Read-only                    |
| ambiguous, multi-domain, "not sure which", end-to-end review, full audit                     | **agent-manager**     | Triage on haiku              |

### Parallel Agent Combos (independent concerns)

| Scenario                   | Agents (parallel)                                                  |
| -------------------------- | ------------------------------------------------------------------ |
| **Feature review**         | code-reviewer + security-auditor + test-builder                    |
| **PR with DB changes**     | code-reviewer + database-reviewer + security-auditor               |
| **Full code audit**        | security-auditor + code-reviewer + database-reviewer + ux-designer |
| **Campaign planning**      | strategic-thinker + media-planner + data-scientist                 |
| **Pre-deploy check**       | code-reviewer + security-auditor + deploy-engineer                 |
| **New feature (complete)** | test-builder + security-auditor + documenter                       |

### Sequential Agent Chains (output feeds next)

| Scenario                    | Chain                                              |
| --------------------------- | -------------------------------------------------- |
| **Debug → Fix → Test**      | debugger → _(main implements fix)_ → test-builder  |
| **Review → Document**       | code-reviewer → documenter                         |
| **Strategy → Media → Data** | strategic-thinker → media-planner → data-scientist |

---

## Skills (24)

### SpecFlow Workflow (12)

`/flow.init` `/flow.design` `/flow.analyze` `/flow.implement` `/flow.verify` `/flow.orchestrate` `/flow.memory` `/flow.merge` `/flow.review` `/flow.doctor` `/flow.roadmap` `/flow.taskstoissues`

### Custom Skills (12)

| Skill           | Model  | Purpose                                                                 |
| --------------- | ------ | ----------------------------------------------------------------------- |
| `/research`     | sonnet | Deep web + codebase research with synthesized report                    |
| `/test-and-fix` | sonnet | Run tests, analyze failures, fix, re-run loop (5 iterations)            |
| `/pr-review`    | sonnet | PR diff analysis with structured review feedback                        |
| `/pdf-to-md`    | sonnet | Convert PDF to clean, AI-ready Markdown preserving filename             |
| `/standup`      | haiku  | Daily standup from git activity and open PRs                            |
| `/visualize`    | sonnet | Generate interactive HTML dashboards                                    |
| `/multi-plan`   | sonnet | Parallel multi-agent feature planning (architecture + tests + security) |
| `/evolve`       | haiku  | Analyze session patterns, recommend new skills/agents                   |
| `/handoff`      | haiku  | Generate HANDOFF.md for session continuation                            |
| `/compact`      | haiku  | Generate tailored /compact instructions preserving key context          |
| `/exec-brief`   | sonnet | Transform raw data/analysis into 1-page C-suite executive summary       |
| `/start`        | haiku  | Session startup health check — tools, MCP, keys, agents, checklist      |

---

## Hooks (11 scripts, 7 events)

### PreToolUse

| Script                       | Matcher   | Action                                                                          |
| ---------------------------- | --------- | ------------------------------------------------------------------------------- |
| `convert-before-read.sh`     | Read      | Blocks Read on convertible files (PDF, DOCX, etc.); use to-markdown MCP instead |
| `block-destructive.sh`       | Bash      | Blocks rm -rf, force push, hard reset, git clean, DROP/TRUNCATE                 |
| `validate-readonly-query.sh` | Bash      | Blocks SQL write operations in shell commands                                   |
| `guard-mcp-publish.sh`       | mcp\_\_\* | Blocks MCP write/publish/post/send/create/update/delete                         |
| `guard-mcp-sql.sh`           | mcp\_\_\* | Blocks destructive SQL in MCP database tool calls                               |

### PostToolUse

| Script           | Matcher     | Action                                              |
| ---------------- | ----------- | --------------------------------------------------- |
| `auto-format.sh` | Write\|Edit | Async auto-format (Prettier, Black, gofmt, rustfmt) |

### PreCompact

| Script | Matcher | Action                                                     |
| ------ | ------- | ---------------------------------------------------------- |
| inline | .\*     | Echo preservation reminder (decisions, files, constraints) |

### ConfigChange

| Script                   | Matcher | Action                                 |
| ------------------------ | ------- | -------------------------------------- |
| `audit-config-change.sh` | .\*     | Async logging to `~/.claude/audit.log` |

### TaskCompleted

| Script                    | Matcher | Action                                 |
| ------------------------- | ------- | -------------------------------------- |
| `verify-task-complete.sh` | .\*     | Reminds to verify tests for code tasks |

### SubagentStart

| Script                  | Matcher | Action                       |
| ----------------------- | ------- | ---------------------------- |
| `log-subagent-start.sh` | .\*     | Async subagent start logging |

### Stop

| Script              | Matcher | Action                                           |
| ------------------- | ------- | ------------------------------------------------ |
| `notify-on-stop.sh` | .\*     | Async macOS notification when Claude needs input |
| prompt (inline)     | .\*     | Verify files saved, no syntax errors, tests pass |

---

## MCP Servers

### User-Level (load everywhere)

| Server               | Purpose                                              |
| -------------------- | ---------------------------------------------------- |
| **Google Workspace** | Gmail, Drive, Docs, Sheets, Calendar                 |
| **Gemini Imagen**    | Image generation                                     |
| **to-markdown**      | File-to-Markdown converter (PDF, DOCX, XLSX, images) |

### Project-Level (add per-project with `claude mcp add --scope project`)

| Server          | Scope          | Add Command                                      |
| --------------- | -------------- | ------------------------------------------------ |
| **Airtable**    | Marketing      | `claude mcp add --scope project airtable ...`    |
| **Asana**       | Marketing      | `claude mcp add --scope project asana ...`       |
| **Slack**       | Marketing      | `claude mcp add --scope project slack ...`       |
| **BigQuery**    | Marketing/Data | `claude mcp add --scope project bigquery ...`    |
| **Vercel**      | Dev            | `claude mcp add --scope project vercel ...`      |
| **Warp Runner** | Dev            | `claude mcp add --scope project warp-runner ...` |

Full add commands with credentials: see `~/.claude.json.backup-20260221-182630`

### Project: /Users/billbuchanan/claude

Sequential Thinking, Memory (knowledge graph), Playwright, Sentry

### Cloud-Synced (need auth)

Figma, HubSpot, Cloudflare, Fireflies

### Plugin Marketplace (not yet installed)

Firebase, GitLab, Greptile, Laravel Boost, Linear, Serena, Stripe, Supabase

---

## Environment Variables

| Variable                               | Value    | Purpose                         |
| -------------------------------------- | -------- | ------------------------------- |
| `MCP_TIMEOUT`                          | `20000`  | MCP server startup timeout (ms) |
| `MAX_MCP_OUTPUT_TOKENS`                | `50000`  | Max output per MCP call         |
| `ENABLE_TOOL_SEARCH`                   | `auto:5` | Defer MCP tools >5% of context  |
| `CLAUDE_CODE_EFFORT_LEVEL`             | `medium` | Default reasoning effort        |
| `CLAUDE_CODE_SUBAGENT_MODEL`           | `sonnet` | Default model for subagents     |
| `DISABLE_NON_ESSENTIAL_MODEL_CALLS`    | `1`      | Skip non-essential model calls  |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | unset    | Enable Agent Teams              |
| `CLAUDE_CODE_DISABLE_1M_CONTEXT`       | unset    | Disable 1M context for Opus 4.6 |

## CLI Tools

| Tool      | Version | Purpose                                   |
| --------- | ------- | ----------------------------------------- |
| `ccusage` | 18.0.8  | Claude Code usage analytics and reporting |
