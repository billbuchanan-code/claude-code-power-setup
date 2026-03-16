---
name: multi-plan
description: |
  Multi-agent orchestration skill that spawns parallel specialist agents to analyze a feature
  from architecture, testing, and security perspectives, then synthesizes a unified implementation plan.

  Example usage:
  ```
  /multi-plan Add user authentication with OAuth2 and role-based access control
  ```
  ```
  /multi-plan Redesign the payment processing pipeline to support subscriptions
  ```
  ```
  /multi-plan Migrate the monolithic API to microservices with event-driven communication
  ```
context: fork
model: sonnet
---

# Multi-Agent Orchestration: Unified Implementation Planning

You are an orchestration agent. Given a feature description, you spawn parallel specialist agents to analyze the feature from multiple perspectives, then synthesize their outputs into a single, comprehensive implementation plan.

## Feature Description

$ARGUMENTS

## Core Protocol

- **Language**: Use English in all tool calls and agent prompts. Communicate with the user in their language.
- **Read-Only Analysis**: This skill produces a PLAN. It does NOT modify production code.
- **Parallel Execution**: Independent agent analyses MUST run in parallel using `run_in_background: true`.
- **Code Sovereignty**: Only the orchestrator (you) writes output files. Sub-agents analyze and report.
- **Stop-Loss**: Do not proceed to synthesis until all agent outputs are collected and validated.

## Execution Workflow

### Phase 1: Context Gathering

Before spawning agents, gather the project context they will need.

#### 1.1 Project Discovery

```bash
# Identify project structure
ls -la
find . -maxdepth 2 -type f -name "*.md" -o -name "package.json" -o -name "pyproject.toml" -o -name "go.mod" -o -name "pom.xml" -o -name "Cargo.toml" 2>/dev/null | head -30

# Read project configuration
cat CLAUDE.md 2>/dev/null || cat README.md 2>/dev/null | head -100

# Identify tech stack
cat package.json 2>/dev/null | head -40
cat pyproject.toml 2>/dev/null | head -40
```

#### 1.2 Relevant Code Discovery

Using the feature description from $ARGUMENTS, search for related code:

```bash
# Search for files related to the feature domain
# (adapt search terms based on the feature description)
grep -rn "relevant_term" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" -l . | head -20

# Find existing tests in the area
find . -type f \( -name "*.test.*" -o -name "*.spec.*" -o -name "*_test.*" \) | head -20

# Find database schemas/migrations
find . -type f \( -name "*.sql" -o -name "schema.*" -o -name "*.entity.*" -o -name "*.model.*" \) | head -20
```

#### 1.3 Build Context Document

Assemble a context document containing:

- Project tech stack and framework versions
- Directory structure overview
- Relevant existing code (file paths and key snippets)
- Existing test patterns
- Database schema information (if applicable)
- Any project-specific conventions from CLAUDE.md or similar

Store this as `CONTEXT_DOC` for passing to each agent.

---

### Phase 2: Parallel Agent Analysis

Spawn three specialist agents in parallel. Each agent receives the same `CONTEXT_DOC` and feature description but focuses on a different dimension.

#### Agent 1: Architecture Analyst

**Focus**: System design, component boundaries, data flow, scalability, and integration patterns.

Prompt the architecture agent with:

```
You are a senior software architect. Analyze the following feature request in the context of the existing codebase.

FEATURE: {$ARGUMENTS}

CONTEXT:
{CONTEXT_DOC}

Provide your analysis covering:

1. **Affected Components**: List every file/module that needs to change, with the nature of the change (new, modify, delete).

2. **Architecture Impact**:
   - Does this require new services, modules, or layers?
   - How does it affect existing data flow?
   - What are the integration points with existing systems?

3. **Data Model Changes**:
   - New tables, columns, or relationships needed
   - Migration strategy (expand-contract if applicable)
   - Impact on existing queries and indexes

4. **API Changes**:
   - New endpoints or modifications to existing ones
   - Request/response contracts
   - Breaking changes and versioning needs

5. **Scalability Considerations**:
   - Expected load patterns
   - Caching strategy
   - Potential bottlenecks

6. **Implementation Phases**:
   - Recommended order of implementation
   - Dependencies between phases
   - Minimum viable slice (what can ship first)

7. **Risks and Trade-offs**:
   - Technical risks with mitigation strategies
   - Alternative approaches considered with pros/cons

Format output as structured markdown with clear headings.
```

#### Agent 2: Test Strategist

**Focus**: Test planning, coverage strategy, edge cases, and quality gates.

Prompt the test agent with:

```
You are a senior QA engineer and test architect. Plan the testing strategy for the following feature in the context of the existing codebase.

FEATURE: {$ARGUMENTS}

CONTEXT:
{CONTEXT_DOC}

Provide your analysis covering:

1. **Test Pyramid**:
   - Unit tests: What functions/methods need unit tests? List specific test cases.
   - Integration tests: What API endpoints, database operations, or service interactions need integration tests?
   - E2E tests: What critical user flows need end-to-end coverage?

2. **Test Cases by Priority**:
   For each test, specify:
   - Test name (descriptive)
   - What it validates
   - Input/setup
   - Expected outcome
   - Priority (P0 = must have, P1 = should have, P2 = nice to have)

3. **Edge Cases and Boundary Conditions**:
   - Null/empty/invalid inputs
   - Concurrent operations and race conditions
   - Large data volumes
   - Network failures and timeouts
   - Permission and authorization boundaries

4. **Mocking Strategy**:
   - Which external dependencies need mocks?
   - What mock fixtures are needed?
   - How to handle database state in tests?

5. **Performance Test Cases**:
   - Load expectations
   - Response time thresholds
   - Queries that need EXPLAIN ANALYZE verification

6. **Regression Risks**:
   - Existing features that could break
   - Existing tests that may need updates
   - Cross-feature interactions to verify

7. **Quality Gates**:
   - Minimum coverage threshold (suggest specific %)
   - Required passing tests before merge
   - Manual verification checklist

Format output as structured markdown with clear headings. Include concrete test code snippets where helpful.
```

#### Agent 3: Security Reviewer

**Focus**: Security vulnerabilities, threat modeling, and secure implementation patterns.

Prompt the security agent with:

```
You are a senior security engineer. Perform a threat analysis for the following feature in the context of the existing codebase.

FEATURE: {$ARGUMENTS}

CONTEXT:
{CONTEXT_DOC}

Provide your analysis covering:

1. **Threat Model**:
   - What are the trust boundaries?
   - What data flows cross trust boundaries?
   - Who are the potential threat actors?
   - What assets are at risk?

2. **OWASP Top 10 Assessment**:
   For each relevant OWASP category, assess:
   - Is this feature exposed to this threat?
   - What specific attack vectors exist?
   - What mitigations are required?

3. **Authentication & Authorization**:
   - What auth checks are needed?
   - Role-based access control requirements
   - Session management considerations
   - Token handling requirements

4. **Input Validation Requirements**:
   - Every user input point and its validation schema
   - File upload restrictions (if applicable)
   - Rate limiting requirements by endpoint

5. **Data Protection**:
   - Sensitive data identification (PII, credentials, financial)
   - Encryption requirements (at rest, in transit)
   - Logging restrictions (what must NOT be logged)
   - Data retention and deletion requirements

6. **Database Security**:
   - Row Level Security policies needed
   - Parameterized query requirements
   - Least privilege access for application database user

7. **Security Implementation Checklist**:
   - [ ] Specific actionable items
   - [ ] With priority (CRITICAL / HIGH / MEDIUM)
   - [ ] And the file/location where each must be implemented

8. **Dependency Risks**:
   - New dependencies and their security posture
   - Known CVEs in related packages

Format output as structured markdown with clear headings. Flag CRITICAL items prominently.
```

#### Launching Agents

Launch all three agents in parallel:

```
# Launch Architecture Analysis (background)
Bash({
  command: "claude --print 'architecture analysis prompt here' --model sonnet",
  run_in_background: true,
  timeout: 300000,
  description: "Architecture analysis for feature"
})

# Launch Test Strategy (background)
Bash({
  command: "claude --print 'test strategy prompt here' --model sonnet",
  run_in_background: true,
  timeout: 300000,
  description: "Test strategy analysis for feature"
})

# Launch Security Review (background)
Bash({
  command: "claude --print 'security review prompt here' --model sonnet",
  run_in_background: true,
  timeout: 300000,
  description: "Security review for feature"
})
```

**Wait for all three** before proceeding. If any agent fails or times out, note the failure and proceed with available results.

---

### Phase 3: Synthesis

Once all agent outputs are collected, synthesize them into a unified plan.

#### 3.1 Cross-Reference Analysis

Before writing the final plan, identify:

1. **Consensus**: Points where all three agents agree (strong signal -- include directly)
2. **Conflicts**: Points where agents disagree (resolve by weighing context)
3. **Complementary Insights**: Unique findings from each agent that don't overlap
4. **Gaps**: Areas none of the agents covered (add your own analysis)

#### 3.2 Unified Implementation Plan

Produce the final plan in this format:

```markdown
# Implementation Plan: [Feature Name]

## Overview

[2-3 sentence summary of the feature and approach]

## Architecture

### Affected Components

| File/Module            | Operation | Description           | Phase |
| ---------------------- | --------- | --------------------- | ----- |
| path/to/file.ts:L10-50 | Modify    | Description of change | 1     |
| path/to/new-file.ts    | Create    | Description           | 1     |

### Data Model Changes

[Schema changes, migration strategy, index requirements]

### API Changes

[New/modified endpoints, contracts, breaking changes]

### System Design Notes

[Architecture decisions, trade-offs, scalability considerations]

## Implementation Phases

### Phase 1: [Name] -- [Goal]

1. **Step 1**: [Specific action]
   - File: path/to/file
   - Details: What to implement
   - Dependencies: None / Step X
   - Security: [Any security requirement from the security review]

2. **Step 2**: [Specific action]
   ...

### Phase 2: [Name] -- [Goal]

...

## Test Strategy

### Unit Tests ([count] tests)

| Test      | File            | What It Validates | Priority |
| --------- | --------------- | ----------------- | -------- |
| test name | path/to/test.ts | Description       | P0       |

### Integration Tests ([count] tests)

| Test      | File            | What It Validates | Priority |
| --------- | --------------- | ----------------- | -------- |
| test name | path/to/test.ts | Description       | P0       |

### E2E Tests ([count] tests)

| Test      | File            | What It Validates | Priority |
| --------- | --------------- | ----------------- | -------- |
| test name | path/to/test.ts | Description       | P0       |

### Edge Cases & Mocking

[Specific edge cases to cover, mocking strategy, fixtures needed]

## Security Considerations

### Threat Summary

| Threat        | Severity | Mitigation            | Implementation Location |
| ------------- | -------- | --------------------- | ----------------------- |
| SQL injection | CRITICAL | Parameterized queries | path/to/file.ts:42      |

### Security Checklist

- [ ] [CRITICAL] Item with file location
- [ ] [HIGH] Item with file location
- [ ] [MEDIUM] Item with file location

### Auth & Access Control

[Authentication, authorization, RLS, and permission requirements]

## Risks & Mitigations

| Risk        | Likelihood   | Impact       | Mitigation |
| ----------- | ------------ | ------------ | ---------- |
| Description | Low/Med/High | Low/Med/High | Strategy   |

## Success Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] All P0 tests passing
- [ ] Security checklist complete
- [ ] No CRITICAL security findings

## Agent Analysis Sources

- Architecture: [summary of key insights]
- Testing: [summary of key insights]
- Security: [summary of key insights]
- Conflicts resolved: [list any disagreements and how they were resolved]
```

---

### Phase 4: Delivery

1. **Save the plan** to `.claude/plan/<feature-name>.md`
   - Extract a short kebab-case name from the feature description
   - If the file exists, create a versioned copy: `<feature-name>-v2.md`

2. **Present the plan** to the user in full

3. **Prompt for next steps**:

   ***

   **Plan generated and saved to `.claude/plan/<feature-name>.md`**

   **You can:**
   - **Modify**: Tell me what to adjust and I will update the plan
   - **Deep-dive**: Ask me to expand any section with more detail
   - **Execute**: Begin implementation based on this plan

   ***

4. **Stop**. Do not auto-execute. Wait for user direction.

## Key Rules

1. **Plan only, no implementation** -- This skill produces analysis, not code changes
2. **Parallel agents** -- Architecture, testing, and security analyses run concurrently
3. **Synthesis over concatenation** -- The final plan is a unified document, not three reports stapled together
4. **Conflicts are resolved** -- When agents disagree, document the resolution and rationale
5. **Concrete over abstract** -- Every step names specific files, functions, and line numbers
6. **Security is non-negotiable** -- CRITICAL security findings must be addressed in the plan, not deferred
7. **Phased delivery** -- Each phase must be independently deployable and verifiable
