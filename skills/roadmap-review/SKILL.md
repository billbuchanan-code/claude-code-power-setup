---
name: roadmap-review
description: |
  Trigger the 9-person Executive Reviewer Panel to evaluate the product roadmap.
  Runs all reviewers in parallel, synthesizes a scored dashboard, and presents
  recommendations for you to accept, reject, or defer.

  Example usage:
  ```
  /roadmap-review
  ```
  ```
  /roadmap-review ceo coo cfo
  ```
  ```
  /roadmap-review --product media
  ```
  ```
  /roadmap-review --round 2
  ```
context: fork
model: sonnet
---

# Executive Reviewer Panel — Orchestration Skill

You are the orchestrator for the 9-person Executive Reviewer Panel. Your job is to spawn reviewer agents in parallel, collect their scored assessments, synthesize a dashboard, and present an actionable recommendation triage for the user.

## Arguments

$ARGUMENTS

Parse arguments for:
- **Reviewer filter**: If specific reviewer names are listed (e.g., `ceo coo cfo`), run only those reviewers. If no names given, run ALL 9.
- **Product filter**: If `--product <name>` is specified, focus reviews on that single product. Otherwise review all 7.
- **Round number**: If `--round <N>` is specified, label this as Review Round N. Otherwise detect from existing files in `docs/reviews/`.

### Valid Reviewer Names
`ceo`, `coo`, `cmo`, `cco`, `cfo`, `cto`, `talent`, `analyst`, `client`

---

## Phase 1: Gather the Roadmap Package

Before spawning reviewers, assemble the full context they need. Read these files and build a `ROADMAP_PACKAGE` variable:

### Required Files (read all in parallel)

```
docs/roadmap/master-roadmap.md
docs/roadmap/year-1-priorities.md
docs/synthesis/cross-cutting-themes.md
docs/roadmap-docs/00-tracker.md
decisions/decision-log.md
evidence/evidence-center.md
docs/capacity/owner-load.md
```

### Product Roadmap Files (read all 7)

```
docs/roadmap-docs/01-media.md
docs/roadmap-docs/02-search.md
docs/roadmap-docs/03-creative-and-brand.md
docs/roadmap-docs/04-web-development.md
docs/roadmap-docs/05-data-and-decision-sciences.md
docs/roadmap-docs/06-crm-and-lifecycle.md
docs/roadmap-docs/07-strategy-and-consulting.md
```

### Supporting Files (read in parallel)

```
docs/internal-briefs/01-media.md (through 07)
docs/market-briefs/01-media.md (through 07)
docs/framework-review/08-talent-model.md
docs/framework-review/09-tooling-and-data.md
docs/framework-review/year-3-end-states.md
docs/framework-review/reviewer-panel.md
```

If `--product <name>` was specified, only read the relevant product's roadmap, internal brief, and market brief.

### Previous Review Round (if exists)

Check for previous review files in `docs/reviews/`. If found, include the most recent synthesis as context so reviewers can assess improvement.

---

## Phase 2: Spawn Reviewer Agents

Launch each selected reviewer as a parallel Task agent. Each reviewer receives the ROADMAP_PACKAGE and their specific persona instructions.

### Reviewer Agent Prompt Template

For each reviewer, use the Task tool with `subagent_type: "general-purpose"` and provide this prompt structure:

```
You are the [REVIEWER_TITLE] reviewer for Level Agency's product roadmap.

## Your Persona

[PERSONA DESCRIPTION — copy from reviewer-panel.md Section for this reviewer]

## Your Scoring Dimensions (rate each 1-5)

[DIMENSIONS TABLE — copy from reviewer-panel.md]

## Scoring Scale

| Score | Label      | Meaning                                                        |
| ----- | ---------- | -------------------------------------------------------------- |
| 5     | Exemplary  | Best-in-class; would hold up against any top agency's roadmap  |
| 4     | Strong     | Solid with minor gaps; ready for executive presentation        |
| 3     | Adequate   | Meets baseline expectations but lacks differentiation or depth |
| 2     | Gaps       | Missing important elements; needs work before ALT presentation |
| 1     | Critical   | Fundamental problems; would undermine credibility if presented |

## Your Review Prompt

[REVIEW PROMPT — copy from reviewer-panel.md]

## The Roadmap Package

[FULL ROADMAP_PACKAGE CONTENT]

## Output Format — FOLLOW EXACTLY

Your output MUST follow this exact structure. Do not deviate.

### [REVIEWER_TITLE] Review — [TODAY'S DATE]

#### Overall Score: [Average of 5 dimensions, one decimal] / 5.0

#### Dimension Scores

| Dimension | Score | Key Finding |
| --------- | ----- | ----------- |
| [dim1]    | [1-5] | [1-2 sentence finding] |
| [dim2]    | [1-5] | [1-2 sentence finding] |
| [dim3]    | [1-5] | [1-2 sentence finding] |
| [dim4]    | [1-5] | [1-2 sentence finding] |
| [dim5]    | [1-5] | [1-2 sentence finding] |

#### Product-Level Assessment

| Product                  | Score | Strongest Element | Biggest Gap | Priority Fix |
| ------------------------ | ----- | ----------------- | ----------- | ------------ |
| Media                    | [1-5] | ...               | ...         | ...          |
| Search                   | [1-5] | ...               | ...         | ...          |
| Creative & Brand         | [1-5] | ...               | ...         | ...          |
| Web Development          | [1-5] | ...               | ...         | ...          |
| Data & Decision Sciences | [1-5] | ...               | ...         | ...          |
| CRM & Lifecycle          | [1-5] | ...               | ...         | ...          |
| Strategy & Consulting    | [1-5] | ...               | ...         | ...          |

#### Top Recommendations (3-5, prioritized)

**REC-[ABBREV]-01:** [One-line recommendation]
- Impact: HIGH / MEDIUM / LOW
- Effort: HIGH / MEDIUM / LOW
- Products affected: [list]
- Unblocks: [What this enables]
- Evidence: [What's missing or wrong today — cite specific sections]

**REC-[ABBREV]-02:** ...
(continue for 3-5 recommendations)

#### Key Quotes

Pull 2-3 specific quotes or data points from the roadmap package that support your most important findings. Reference them by document and section.
```

### Reviewer Abbreviations

Use these abbreviations in REC IDs:
- CEO → `CEO`
- COO → `COO`
- CMO → `CMO`
- Chief Client Officer → `CCO`
- CFO → `CFO`
- CTO → `CTO`
- VP of Talent → `TAL`
- Industry Analyst → `ANA`
- Sophisticated Client → `CLI`

### Launch Pattern

Launch ALL selected reviewers in parallel using `run_in_background: true`:

```
Task(subagent_type="general-purpose", description="CEO roadmap review", prompt="...", run_in_background=true)
Task(subagent_type="general-purpose", description="COO roadmap review", prompt="...", run_in_background=true)
... (one per reviewer)
```

Wait for all to complete before proceeding.

---

## Phase 3: Collect and Save Individual Reviews

As each reviewer completes:

1. Save their output to `docs/reviews/round-[N]-[reviewer].md` with frontmatter:

```yaml
---
title: "[Reviewer Title] Review — Round [N]"
description: "Executive reviewer assessment of product roadmap"
reviewer: "[reviewer_name]"
round: [N]
date: "[YYYY-MM-DD]"
overall_score: [X.X]
---
```

2. Extract their scores into a data structure for synthesis.

---

## Phase 4: Synthesize Dashboard

After ALL reviewer outputs are collected, create `docs/reviews/round-[N]-synthesis.md`:

### 4.1 Heat Map

Build a scored heat map table:

```markdown
## Scores by Product × Reviewer

|                          | CEO | COO | CMO | CCO | CFO | CTO | TAL | ANA | CLI | AVG |
| ------------------------ | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Media                    | X.X | ... | ... | ... | ... | ... | ... | ... | ... | X.X |
| Search                   | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |
| Creative & Brand         | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |
| Web Development          | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |
| Data & Decision Sciences | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |
| CRM & Lifecycle          | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |
| Strategy & Consulting    | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |
| **OVERALL**              | X.X | X.X | X.X | X.X | X.X | X.X | X.X | X.X | X.X | **X.X** |
```

Add color indicators: scores in the table with emoji markers
- 4.0+ → (green)
- 3.0-3.9 → (yellow)
- <3.0 → (red)

### 4.2 Dimension Scores by Reviewer

Show each reviewer's 5 dimension scores in a summary table.

### 4.3 Convergence Analysis

Analyze all recommendations across reviewers:

**Convergence Flags** (same issue raised by 3+ reviewers):
- List each convergent issue with which reviewers flagged it

**Tension Pairs** (reviewers in direct conflict):
- List each tension with the two opposing positions

**Blind Spots** (raised by only 1 reviewer):
- List with the reviewer who raised it

**Quick Wins** (HIGH impact + LOW effort from any reviewer):
- List with reviewer and recommendation ID

### 4.4 Unified Recommendation Backlog

Merge ALL recommendations from all reviewers into a single, prioritized table:

```markdown
## Recommendation Backlog

| #  | Rec ID      | Recommendation                          | Impact | Effort | Raised By           | Convergence | Status   |
| -- | ----------- | --------------------------------------- | ------ | ------ | ------------------- | ----------- | -------- |
| 1  | REC-CEO-01  | [recommendation text]                   | HIGH   | LOW    | CEO, CMO, ANA       | 3 reviewers | PENDING  |
| 2  | REC-CCO-02  | [recommendation text]                   | HIGH   | MEDIUM | CCO, CLI, CFO       | 3 reviewers | PENDING  |
| .. | ...         | ...                                     | ...    | ...    | ...                 | ...         | PENDING  |
```

Sort by: Convergence (desc) → Impact (HIGH first) → Effort (LOW first)

Every recommendation starts with `Status: PENDING`.

---

## Phase 5: Present Triage Interface

After saving the synthesis, present the results to the user in this format:

```
## Review Round [N] Complete — [DATE]

**Overall Score: X.X / 5.0** ([comparison to previous round if applicable])

### Score Summary
[The heat map table]

### Top 10 Recommendations (sorted by convergence + impact)

For each of the top 10, display:

**[#] REC-[XX]-[##]: [One-line recommendation]**
Impact: [H/M/L] | Effort: [H/M/L] | Convergence: [N] reviewers
Raised by: [list]
> [Brief evidence/rationale]

---

### What would you like to do?

1. **Accept recommendations** — Tell me which numbers to accept (e.g., "accept 1, 3, 5, 7")
2. **Reject recommendations** — Tell me which to reject with reason (e.g., "reject 2 — not feasible in Q2")
3. **Defer recommendations** — Push to next review round (e.g., "defer 4, 6")
4. **Deep dive** — Ask me to expand on any reviewer's full assessment
5. **Implement** — Pick accepted recommendations and I'll create implementation tasks
6. **Re-run** — Re-run specific reviewers with updated content

After you choose, I will update the status column in the recommendation backlog and save the updated synthesis.
```

---

## Phase 6: Process Triage Decisions

When the user responds with accept/reject/defer decisions:

1. Update `docs/reviews/round-[N]-synthesis.md` — change Status column:
   - Accepted → `ACCEPTED`
   - Rejected → `REJECTED — [reason]`
   - Deferred → `DEFERRED → Round [N+1]`

2. For ACCEPTED recommendations, create a summary section at the bottom of the synthesis:

```markdown
## Accepted Improvements

| #  | Rec ID     | Recommendation | Owner | Target Date | Implementation Notes |
| -- | ---------- | -------------- | ----- | ----------- | ------------------- |
| 1  | REC-CEO-01 | ...            | TBD   | TBD         | [brief notes]       |
```

3. Ask: "Would you like me to implement any of these accepted recommendations now, or save them for the next work session?"

---

## Key Rules

1. **Parallel execution** — All reviewers run simultaneously. Never run them sequentially.
2. **No score inflation** — Reviewers should be calibrated to be critical. A 3.0 average on v1.0 is expected and healthy.
3. **Evidence required** — Every score and recommendation MUST cite specific content from the roadmap package. No vague assertions.
4. **Honest assessment** — Reviewers should surface real weaknesses, not just validate. The point is stress-testing.
5. **Actionable output** — Every recommendation must be specific enough that someone could act on it without asking follow-up questions.
6. **Status tracking** — The recommendation backlog is the persistent artifact. It carries forward across rounds.
7. **Comparison across rounds** — When Round N > 1, the synthesis must compare scores to the previous round and call out improvements and regressions.
8. **User controls implementation** — Never auto-implement recommendations. The user decides what to accept.
9. **Save everything** — Every reviewer output and synthesis is saved to `docs/reviews/` for the permanent record.
10. **Context window management** — If the roadmap package is too large for a single agent, prioritize: master roadmap → cross-cutting themes → product roadmaps → supporting docs. Always include the decision log and capacity model.
