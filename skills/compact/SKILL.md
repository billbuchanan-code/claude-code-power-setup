---
description: Smart context compaction that preserves agent decisions and discards debugging noise
context: fork
allowed-tools: Read, Grep, Glob
model: haiku
---

# Smart Compact Instruction Generator

Analyze the current session to generate a tailored `/compact` instruction that preserves important context and discards noise.

## Process

### Step 1: Infer Session Contents

You do not have direct access to the conversation history. Instead, infer what happened in the session from available signals:

1. **Check git state**: Use Glob and Grep to look at:
   - Files recently modified (check modification times via `ls -lt` patterns or git status)
   - Any HANDOFF.md or TODO files that describe session work
   - `.claude/` directory for any session artifacts

2. **Detect agent delegation patterns**: Look for signs that sub-agents were used:
   - Multiple files explored in a short time (breadth-first patterns)
   - Search result files or temporary analysis files
   - Changes across many unrelated directories (suggests parallel agent work)

3. **Detect MCP server usage**: Check for:
   - `.mcp.json` or `mcp_config.json` files in the project
   - References to external services in recently changed files
   - Configuration files for Slack, GitHub, databases, etc.

4. **Identify key decisions**: Look for:
   - New dependencies added (package.json, Cargo.toml, requirements.txt, go.mod changes)
   - New files created (architectural decisions about structure)
   - Configuration file changes (tooling/infrastructure decisions)
   - Pattern choices visible in code (e.g., choosing a specific design pattern)

5. **Identify debugging noise**: Look for signs of troubleshooting:
   - Files with many recent modifications (iterative debugging)
   - Test files that were changed multiple times
   - Log or output files
   - Temporary files or scratch work

### Step 2: Categorize Context

Sort everything into two categories:

**Preserve** (high-value context that is expensive to reconstruct):

- Architecture and design decisions made
- File paths that were created or significantly modified
- Agent delegation results (what was found, what was decided)
- MCP connection states and which servers are active
- User preferences or constraints stated during the session
- Working solutions that were arrived at
- Branch name and what it represents
- Key relationships between files discovered during exploration

**Discard** (low-value context that inflates the conversation):

- Failed search attempts and dead-end explorations
- Verbose tool outputs (full file contents that were just scanned)
- Debugging iterations that led nowhere
- Repeated reads of the same file
- Error messages from failed commands that were subsequently fixed
- Exploratory reads of files that turned out to be irrelevant
- Long git diffs or log outputs
- Build/test output noise

### Step 3: Generate the Compact Instruction

Output the following to the user:

---

**Suggested `/compact` command:**

```
/compact Preserve: [specific list based on analysis]. Discard: [specific list based on analysis].
```

Then provide a brief explanation:

**What this keeps:**

- [Bullet list of what will be preserved and why]

**What this drops:**

- [Bullet list of what will be discarded and why]

**Estimated context reduction:** [Rough estimate: light/moderate/heavy based on how much noise was detected]

---

### Important Rules

- Be specific in the preserve/discard lists. Use actual file names, tool names, and decision descriptions rather than generic categories.
- The generated `/compact` instruction should be a single line the user can copy-paste directly.
- If the session appears to be early (few files changed, little history), suggest a lighter compaction and note that aggressive compaction may not be needed yet.
- If you cannot determine what happened in the session with any confidence, say so and provide a generic but safe compact instruction that preserves decisions and discards verbose outputs.
- Never include the backtick fence markers inside the actual compact instruction text - keep it as plain copyable text.
