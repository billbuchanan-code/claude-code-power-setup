# Claude Code Configuration

Agent routing details in `~/.claude/agents.md` — consult when dispatching agents.
Full reference (skills, hooks, MCP) in `~/.claude/REFERENCE.md` — consult on demand.

---

## Communication Rules

### Audience

- The user is a [YOUR ROLE] — adapt language, jargon level, and detail accordingly
- Do the work, then state the result in one sentence — do not narrate your process
- Do not show intermediate steps, diffs, or technical output unless asked

### Verbosity

- Complete the task, then stop — no unsolicited next steps or alternatives
- Do not summarize what you just did after doing it
- Do not explain reasoning unless asked "why"
- One question at a time — never ask multiple questions in one message

### When Manual Action Is Required

When the user must do something themselves:

1. Say **"Action needed:"** on its own line
2. Give numbered steps with exact names (app, button, menu item) in quotes
3. Include what the user should see at each step to confirm it worked
4. End with "Let me know when done" or a specific yes/no question

- Never say "you might want to" — say "do this"
- If something is optional, say so explicitly

---

## File Reading

When a user provides a non-code file (PDF, DOCX, XLSX, PPTX, RTF, ODT, HTML, EPUB, CSV, images), always use `mcp__to-markdown__convert_file` instead of the Read tool. Use `summary: true` for summaries. Use `clean: true` (default) for artifact-free output.

---

## Rules

Global: **coding.md** — Conventions, function size, error handling, testing, secrets

Project-scoped:

- **marketing.md** — `~/your-project/.claude/rules/`
- **database.md** — `~/your-other-project/.claude/rules/`

---

## Behavioral Rules

### Two-Correction /clear Rule

If corrected twice on the same issue: acknowledge the pattern, ask user to restate, confirm understanding, suggest /clear if context drift is the cause.

### Commit Shorthand Recognition

When the user says "push it", "commit this", "commit and push", or "document, commit and push" — treat it as a `/commit` skill invocation. Do not re-derive the workflow from scratch each time.

### Session Naming Convention

Name sessions as `[project]-[date]-[2-word-topic]`. Use in HANDOFF.md filenames.

---

## Session Management

- `/start` at session start — verifies tools, MCP, keys, agents
- `/handoff` before switching sessions — generates HANDOFF.md
- `/compact` for tailored compaction instructions
- `/clear` proactively at 50-60% context — don't push to limit
- `/evolve` periodically to discover patterns worth automating
- Max 3-4 agents active simultaneously
- **Writer/Reviewer pattern**: For features >100 lines, use two sessions — Session A implements, Session B reviews with fresh context (no implementation bias)

---

## gstack

Use the `/browse` skill from gstack for all web browsing — never use `mcp__claude-in-chrome__*` tools directly.

Available skills: `/plan-ceo-review`, `/plan-eng-review`, `/plan-design-review`, `/design-consultation`, `/review`, `/ship`, `/browse`, `/qa`, `/qa-only`, `/qa-design-review`, `/setup-browser-cookies`, `/retro`, `/document-release`, `/debug`, `/office-hours`
