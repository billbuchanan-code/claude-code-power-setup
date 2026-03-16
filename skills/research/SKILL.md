---
description: Deep research combining web search, codebase exploration, and synthesis into a comprehensive report
context: fork
allowed-tools: Read, Grep, Glob, Bash, WebSearch, WebFetch, Task
model: sonnet
---

# Deep Research Skill

Perform deep research on a given topic by combining web search, codebase exploration, and synthesis into a comprehensive report.

## Process

1. **Parse the research question** from $ARGUMENTS
2. **Search the web** for current information using WebSearch. Run multiple queries with different phrasings to get broad coverage. Use WebFetch to read the most relevant results in detail.
3. **Explore the local codebase** for relevant context using Grep, Glob, and Read. Look for related code, configuration, documentation, and dependencies.
4. **Synthesize findings** into a structured research report that connects web findings with codebase context.
5. **Include sources, confidence levels, and actionable recommendations** for each finding.

## Output Format

Structure the output as a **Research Report** with the following sections:

### Executive Summary

A 2-3 sentence overview of the key findings.

### Web Findings

Bullet points of what was discovered from web searches, with source URLs.

### Codebase Findings

Relevant code, configuration, or documentation found in the local project, with file paths.

### Synthesis

How the web findings and codebase findings connect. Identify gaps, risks, or opportunities.

### Sources

A numbered list of all sources consulted (URLs, file paths).

### Recommended Next Steps

Actionable items ranked by priority, with confidence level (High / Medium / Low) for each recommendation.
