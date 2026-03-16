## Agents (13)

| Agent                 | Model  | Color   | Capability                       | Purpose                                             |
| --------------------- | ------ | ------- | -------------------------------- | --------------------------------------------------- |
| **agent-manager**     | haiku  | white   | Read-only                        | Triage ambiguous/multi-domain tasks to specialists  |
| **ux-designer**       | sonnet | pink    | Read-only                        | Visual design review, accessibility auditing        |
| **cost-cleric**       | haiku  | yellow  | Read-only, background            | Model cost optimization                             |
| **documenter**        | haiku  | cyan    | Read-write, background, worktree | READMEs, changelogs, ADRs                           |
| **test-builder**      | sonnet | green   | Read-write, worktree             | Test plans, test writing, coverage                  |
| **strategic-thinker** | sonnet | magenta | Web-enabled                      | Marketing strategy, competitive analysis, GTM       |
| **media-planner**     | sonnet | blue    | Web-enabled                      | Media plans, budget allocation, flighting           |
| **data-scientist**    | sonnet | blue    | Web-enabled                      | Statistical analysis, marketing analytics           |
| **security-auditor**  | sonnet | red     | Read-only                        | OWASP Top 10, secrets, CVEs, auth review            |
| **code-reviewer**     | sonnet | white   | Read-only                        | Correctness, maintainability, performance           |
| **debugger**          | sonnet | yellow  | Read-only                        | Systematic bug diagnosis, root cause analysis       |
| **deploy-engineer**   | sonnet | orange  | Read-write, worktree             | CI/CD pipelines, Dockerfiles, IaC                   |
| **database-reviewer** | sonnet | cyan    | Read-only                        | Schema review, query optimization, migration safety |

### Capability Legend

- **Read-only**: Read, Grep, Glob, Bash — analyze and report only
- **Read-write**: Above + Write, Edit — can create/edit files
- **Web-enabled**: Above + WebSearch, WebFetch — real-time research
- **background**: Runs without blocking main conversation
- **worktree**: Runs in isolated git worktree for safe parallel execution

### Agent Memory

Stored in `~/.claude/agent-memory/<name>/MEMORY.md`. First 200 lines auto-injected into agent system prompt.

### Routing Decision Rules

1. **Clear signal match** → Dispatch directly (fast path, no triage)
2. **Multiple signals from same domain** → Pick the most specific agent
3. **Signals from 2+ domains** → Use parallel combo if independent, otherwise run agent-manager for triage
4. **No signal match** → Handle directly in main (Opus) or ask user to clarify
5. **User names an agent explicitly** → Respect their choice, skip routing
6. **Cost-sensitive batch ops** → Run cost-cleric in background alongside the primary agent

Full routing tables, skill registry, hooks detail, and MCP inventory in `~/.claude/REFERENCE.md`.
