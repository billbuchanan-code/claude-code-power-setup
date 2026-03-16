# Implementation Prompt

Copy and paste this entire prompt into a fresh Claude Code session to build the setup from scratch. Edit the `[CUSTOMIZE]` sections before running.

---

## The Prompt

```
I want you to set up a production-grade Claude Code configuration. Here's exactly what I need:

## My Profile
- Role: [CUSTOMIZE: e.g., "business executive", "senior engineer", "marketing director"]
- Communication style: [CUSTOMIZE: e.g., "results-only, no jargon", "technical and detailed", "explain like I'm learning"]
- Primary work: [CUSTOMIZE: e.g., "code reviews and deployments", "marketing strategy and data analysis", "full-stack development"]

## Step 1: Create Directory Structure

Create these directories:
~/.claude/agents/
~/.claude/skills/
~/.claude/hooks/
~/.claude/rules/
~/.claude/agent-memory/
~/.claude/scripts/

## Step 2: Settings Configuration

Create ~/.claude/settings.json with:
- Model: sonnet (default)
- Subagent model: sonnet
- Effort level: low
- Tool search: auto:5 (defer unused MCP tools)
- Permission denies for: .env*, *.key, *.pem, credentials*, secrets/*, node_modules/**
- PreToolUse hooks on Bash (block-destructive.sh, validate-readonly-query.sh)
- PreToolUse hooks on Read (convert-before-read.sh)
- PreToolUse hooks on mcp__* (guard-mcp-publish.sh, guard-mcp-sql.sh)
- PostToolUse hook on Write|Edit (auto-format.sh, async)
- PreCompact hook that echoes preservation instructions for: decisions, file paths, constraints, task state
- ConfigChange hook (audit-config-change.sh, async)
- Stop hook (notify-on-stop.sh, async)

## Step 3: Safety Hooks

Create these executable shell scripts in ~/.claude/hooks/:

1. block-destructive.sh — Block rm -rf, git push --force, git reset --hard, git clean -f, DROP TABLE/TRUNCATE
2. validate-readonly-query.sh — Block INSERT/UPDATE/DELETE/DROP/CREATE/ALTER/TRUNCATE in bash SQL
3. guard-mcp-publish.sh — Block MCP write/publish/send/create/update/delete ops unless allowlisted
4. guard-mcp-sql.sh — Block destructive SQL in MCP database tool calls
5. auto-format.sh — Auto-format after Write/Edit using Prettier (JS/TS/CSS/HTML/JSON/YAML), Black (Python), gofmt (Go), rustfmt (Rust)
6. convert-before-read.sh — Block Read on PDF/DOCX/XLSX/PPTX/etc, redirect to to-markdown MCP
7. notify-on-stop.sh — macOS notification when Claude finishes
8. audit-config-change.sh — Log config changes to ~/.claude/audit.log

Also create ~/.claude/hooks/mcp-publish-allowlist.conf with one regex per line for allowed MCP write tools (start with Chrome browser automation).

All hooks receive JSON on stdin with tool_name and tool_input. Exit 0 = allow, Exit 2 = block (with JSON error on stderr).

Make all hooks executable with chmod +x.

## Step 4: Global Instructions

Create ~/.claude/CLAUDE.md with:
- Communication rules tailored to my role (see profile above)
- Verbosity rules: do the work then state result in one sentence, no summaries, no unsolicited next steps
- Manual action format: "Action needed:" + numbered steps + confirmation
- Two-correction rule: if corrected twice, acknowledge pattern and suggest /clear
- Commit shorthand: "push it" / "commit this" triggers /commit skill
- Session naming: [project]-[date]-[2-word-topic]
- Session management: /start at begin, /handoff before switching, /clear at 50-60% context
- Pointer to agents.md for routing and REFERENCE.md for full reference

## Step 5: Coding Rules

Create ~/.claude/rules/coding.md with:
- Read existing code before changes
- Follow existing naming conventions
- Functions under 30 lines
- Early returns to reduce nesting
- Error handling at system boundaries only
- Parameterized SQL always
- Never commit secrets
- Stage specific files (never git add . or -A)

## Step 6: Core Agents

Create these agent definition files in ~/.claude/agents/:

[CUSTOMIZE: Pick the ones relevant to your work from this list]

### For Everyone:
- code-reviewer.md (sonnet, read-only) — Correctness, maintainability, performance
- security-auditor.md (sonnet, read-only) — OWASP Top 10, secrets, CVEs
- debugger.md (sonnet, read-only) — Systematic bug diagnosis
- test-builder.md (sonnet, read-write + worktree) — Test plans and test writing
- agent-manager.md (haiku, read-only) — Triage ambiguous tasks

### For DevOps:
- deploy-engineer.md (sonnet, read-write + worktree) — CI/CD, Docker, IaC
- database-reviewer.md (sonnet, read-only) — Schema, queries, migrations

### For Frontend:
- ux-designer.md (sonnet, read-only) — Visual design, accessibility, WCAG

### For Marketing/Business:
- strategic-thinker.md (sonnet, web-enabled) — Strategy, competitive analysis, GTM
- media-planner.md (sonnet, web-enabled) — Media plans, budget allocation
- data-scientist.md (sonnet, web-enabled) — Statistics, cohort analysis, funnels

### For Documentation:
- documenter.md (haiku, read-write + background) — READMEs, changelogs, ADRs

### For Cost Control:
- cost-cleric.md (haiku, read-only + background) — Model cost optimization

Each agent needs: name, description with examples, tools list, model, color, system prompt with role, responsibilities, process, output format, and quality standards.

## Step 7: Agent Routing

Create ~/.claude/agents.md with:
- Table of all agents (name, model, color, capability, purpose)
- Fast-path routing table (signal keywords → agent)
- Parallel agent combos (e.g., feature review = code-reviewer + security-auditor + test-builder)
- Sequential chains (e.g., debug → fix → test)
- Routing decision rules (clear match → direct, multi-domain → agent-manager, etc.)

## Step 8: Core Skills

Create these skills in ~/.claude/skills/<name>/SKILL.md:

### Essential:
- commit — Stage specific files, conventional commits, push (haiku)
- start — Session health check: tools, MCP, keys, agents, hooks (haiku)
- handoff — Generate HANDOFF.md for session continuation (haiku)
- compact — Smart context compaction preserving decisions (haiku)

### Recommended:
- test-and-fix — Run tests, analyze, fix, re-run loop (sonnet)
- research — Deep web + codebase research with report (sonnet)
- standup — Daily standup from git activity (haiku)
- evolve — Analyze session patterns, recommend automations (haiku)

[CUSTOMIZE: Add any domain-specific skills you need]

## Step 9: Reference Doc

Create ~/.claude/REFERENCE.md with:
- Agent routing tables (signal keywords → agent, parallel combos, sequential chains)
- Skills registry (all skills with model and purpose)
- Hooks detail (all hooks with matchers and actions)
- Environment variables reference
- MCP server inventory

## Step 10: Memory Index

Create ~/.claude/projects/-Users-[YOUR_USERNAME]-[YOUR_PROJECT]/memory/MEMORY.md with:
- Your name and role
- Active projects table
- Key preferences
- Session conventions

## Final Verification

After creating everything:
1. Run `ls -la ~/.claude/hooks/*.sh` — confirm all hooks are executable
2. Run `cat ~/.claude/settings.json | python3 -m json.tool` — confirm valid JSON
3. Run `ls ~/.claude/agents/` — confirm all agent files exist
4. Run `ls ~/.claude/skills/` — confirm all skill directories exist
5. Run `cat ~/.claude/CLAUDE.md | head -5` — confirm CLAUDE.md exists
6. Run `cat ~/.claude/rules/coding.md | head -5` — confirm rules exist

Report what was created and any issues found.
```
