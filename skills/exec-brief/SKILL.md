---
description: Produce a 1-page executive summary from raw data or analysis
context: fork
allowed-tools: Read, Glob, Grep
model: sonnet
---

# Executive Brief

Transform raw data, analysis, or research output into a concise 1-page executive summary suitable for C-suite review.

## Process

1. **Parse the input** from $ARGUMENTS. Accept:
   - A file path to raw data or analysis
   - Inline text pasted by the user
   - A reference to output from a previous agent or skill

2. **If the input is a file path**, read it. If multiple files are referenced, read all of them.

3. **Extract key findings** by identifying:
   - The core question or problem being addressed
   - The 3 most significant data points or conclusions
   - Any metrics, dollar amounts, or percentages that support findings
   - Risks or caveats that decision-makers must know

4. **Structure the brief** using this exact format:

### Situation

2-3 sentences. What prompted this analysis and what was examined.

### Key Findings

Exactly 3 findings, each as a bolded heading with 1-2 supporting sentences. Every finding must include at least one metric or specific data point sourced from the input.

### Recommendation

1-2 sentences. The single clearest action to take, with expected outcome.

### Risk

1-2 sentences. The primary risk of acting (or not acting), with likelihood/impact if available.

### Supporting Detail

3-5 bullet points of secondary findings or context for those who want to dig deeper.

## Quality Rules

- No paragraph longer than 3 sentences
- Every claim must be traceable to the input data — no fabrication
- Target length: 300-400 words
- Use specific numbers, not vague qualifiers ("revenue increased 23%" not "revenue increased significantly")
- Use ISO 8601 dates where dates appear
- Label any inference or assumption explicitly

## Output Format

Present the brief in clean markdown, ready to share. Follow the brief with a single metadata line:

**Source:** [input file name or "inline data"] | **Word count:** [N] | **Date:** [YYYY-MM-DD]
