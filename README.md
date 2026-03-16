# The Ultimate Claude Code Power Setup

A production-grade Claude Code configuration with 23 specialist agents, 27 custom skills, 12 safety hooks, and deep integrations across Google Workspace, Slack, Asana, browser automation, and more.

This guide documents a real-world setup built for a business executive who uses Claude Code as a daily operating system — not just a coding tool. It handles everything from strategic planning and marketing analytics to code reviews, security audits, and automated deployments.

---

## What's Inside

| Component             | Count      | Purpose                                                                                        |
| --------------------- | ---------- | ---------------------------------------------------------------------------------------------- |
| **Specialist Agents** | 23         | Autonomous sub-agents for code review, security, strategy, data science, and more              |
| **Custom Skills**     | 27         | Slash commands for workflows like `/commit`, `/research`, `/flow.design`                       |
| **Safety Hooks**      | 12         | Pre/post tool hooks that block destructive commands, enforce read-only SQL, auto-format code   |
| **MCP Servers**       | 14+        | External integrations: Google Workspace, Slack, Airtable, browser automation, image generation |
| **Behavioral Rules**  | 3 files    | Global coding standards, project-scoped rules for marketing and database work                  |
| **Memory System**     | Persistent | Cross-session memory with structured types (user, feedback, project, reference)                |

---

## Architecture Overview

```
~/.claude/
  CLAUDE.md              # Global behavior instructions (audience, verbosity, rules)
  REFERENCE.md           # On-demand reference: routing tables, skill registry, hook inventory
  agents.md              # Agent roster with routing decision rules
  settings.json          # Model config, env vars, hooks, permissions
  mcp.json               # MCP server definitions
  rules/
    coding.md            # Global coding conventions
  agents/                # 23 agent definition files (.md)
  skills/                # 27 skill directories (each with SKILL.md)
  hooks/                 # 12 shell scripts for safety and automation
  agent-memory/          # Per-agent persistent memory
  projects/              # Per-project session memory (auto-managed)
```

---

## Key Design Principles

1. **Safety First** — Hooks block `rm -rf`, force push, `DROP TABLE`, and unauthorized MCP writes before they execute
2. **Right-Sized Models** — Opus for planning, Sonnet for execution, Haiku for lightweight skills (cost optimization)
3. **Executive-Friendly** — Configured for results-only communication, no jargon, no code dumps
4. **Context-Aware** — Tool search defers unused tools, PreCompact hooks preserve critical decisions, project-scoped rules load only when relevant
5. **Autonomous but Safe** — MCP publish allowlist controls which integrations can write; everything else requires explicit approval

---

## Quick Stats

- **Default model**: Sonnet (fast, cost-effective for most tasks)
- **Planning model**: Opus (complex architecture and strategy)
- **Subagent model**: Sonnet (explicit, not inherited from parent)
- **Effort level**: Low default, toggled higher for complex work
- **Context management**: Auto-deferred tools at 5% of context, PreCompact preservation hooks, `/clear` at 50-60% usage

---

## Files in This Guide

| File                       | Description                                                              |
| -------------------------- | ------------------------------------------------------------------------ |
| `README.md`                | This overview                                                            |
| `HOWTO.md`                 | Step-by-step implementation guide with all configuration files           |
| `IMPLEMENTATION-PROMPT.md` | A single prompt you can paste into Claude Code to build the entire setup |
