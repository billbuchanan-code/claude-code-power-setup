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

## Related Repositories

This setup references two companion projects:

| Repo             | Description                                                                                                                                                                                              | Link                                                      |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| **SpecFlow**     | Agentic workflow system powering the 12 `flow.*` skills and 10 SpecFlow agents. Handles spec-driven design, implementation, review, and merge workflows.                                                 | [wiseyoda/specflow](https://github.com/wiseyoda/specflow) |
| **AI Assistant** | Custom MCP server providing 100+ tools across email, calendar, contacts, drive, messaging, tasks, health, weather, and more. Powers the `ai-assistant` MCP integration referenced throughout this setup. | Private repo — contact for access                         |

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

## Repository Structure

```
claude-code-power-setup/
  README.md                    # This overview
  HOWTO.md                     # Step-by-step implementation guide
  IMPLEMENTATION-PROMPT.md     # Copy-paste prompt to build the setup
  config/
    CLAUDE.md                  # Global behavior instructions
    REFERENCE.md               # On-demand reference doc
    agents.md                  # Agent roster and routing rules
    settings.json              # Core settings (model, hooks, permissions)
    mcp.json                   # MCP server definitions
  agents/                      # 23 agent definition files
    agent-manager.md
    code-reviewer.md
    cost-cleric.md
    data-scientist.md
    database-reviewer.md
    debugger.md
    deploy-engineer.md
    documenter.md
    media-planner.md
    security-auditor.md
    specflow-*.md              # 10 SpecFlow workflow agents
    strategic-thinker.md
    test-builder.md
    ux-designer.md
  skills/                      # 27 skill definitions
    commit/SKILL.md
    start/skill.md
    handoff/SKILL.md
    compact/SKILL.md
    research/SKILL.md
    test-and-fix/SKILL.md
    multi-plan/SKILL.md
    visualize/SKILL.md
    exec-brief/SKILL.md
    pr-review/SKILL.md
    standup/SKILL.md
    evolve/SKILL.md
    bill-voice-skill/SKILL.md
    claude.sync.up/SKILL.md
    claude.sync.down/SKILL.md
    roadmap-review/SKILL.md
    flow.*/SKILL.md            # 12 SpecFlow workflow skills
  hooks/                       # 12 safety and automation scripts
    block-destructive.sh
    validate-readonly-query.sh
    guard-mcp-publish.sh
    guard-mcp-sql.sh
    auto-format.sh
    convert-before-read.sh
    notify-on-stop.sh
    audit-config-change.sh
    inject-security-context.sh
    log-subagent-start.sh
    verify-task-complete.sh
    mcp-publish-allowlist.conf
  scripts/
    claude-skills              # CLI tool to manage per-project skill selection
  rules/
    coding.md                  # Global coding conventions
```

## Skill Library System

Skills are organized into three tiers:

| Tier                                 | Skills                                                                                                                            | Behavior                          |
| ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------- | --------------------------------- |
| **Global** (always on)               | `commit`, `start`, `handoff`, `compact`, `evolve`                                                                                 | Available in every project        |
| **Bundles** (opt-in as a group)      | `specflow` (12 flow.\* skills), `sync` (sync.up + sync.down)                                                                      | Add to a project with one command |
| **Selectable** (opt-in individually) | `research`, `test-and-fix`, `multi-plan`, `visualize`, `exec-brief`, `pr-review`, `standup`, `roadmap-review`, `bill-voice-skill` | Pick per project                  |

All skills live in `~/.claude/skill-library/`. Projects opt in via symlinks using the `claude-skills` CLI:

```bash
claude-skills add specflow              # Enable all 12 flow.* skills
claude-skills add research pr-review    # Enable individual skills
claude-skills add sync                  # Enable dotfile sync
claude-skills remove sync              # Disable dotfile sync
claude-skills list                     # Show what's enabled
claude-skills available                # Show full library
```

## Getting Started

1. Read the **[HOWTO.md](HOWTO.md)** for a detailed walkthrough of every component
2. Browse the `agents/`, `skills/`, and `hooks/` directories to see real production files
3. Use **[IMPLEMENTATION-PROMPT.md](IMPLEMENTATION-PROMPT.md)** to have Claude Code build the setup for you

## Installation

To install everything at once, copy the files into your `~/.claude/` directory:

```bash
# Clone the repo
git clone https://github.com/billbuchanan-code/claude-code-power-setup.git
cd claude-code-power-setup

# Copy config files
cp config/CLAUDE.md ~/.claude/CLAUDE.md
cp config/REFERENCE.md ~/.claude/REFERENCE.md
cp config/agents.md ~/.claude/agents.md
cp config/settings.json ~/.claude/settings.json

# Copy agents, hooks, rules
cp -r agents/ ~/.claude/agents/
cp -r hooks/ ~/.claude/hooks/
cp -r rules/ ~/.claude/rules/

# Install skills into the skill library (not directly into skills/)
cp -r skills/ ~/.claude/skill-library/

# Symlink global skills (always available)
mkdir -p ~/.claude/skills
for skill in commit start handoff compact evolve; do
  ln -sf ~/.claude/skill-library/$skill ~/.claude/skills/$skill
done

# Install the skills manager CLI
mkdir -p ~/.claude/scripts
cp scripts/claude-skills ~/.claude/scripts/claude-skills
chmod +x ~/.claude/scripts/claude-skills
echo 'export PATH="$HOME/.claude/scripts:$PATH"' >> ~/.zshrc

# Make hooks executable
chmod +x ~/.claude/hooks/*.sh

# Create required directories
mkdir -p ~/.claude/{agent-memory,projects}
```

Then customize `~/.claude/CLAUDE.md` for your role and preferences.
