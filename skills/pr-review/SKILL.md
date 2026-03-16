---
description: Review a pull request by analyzing the diff, checking for issues, and providing structured feedback
context: fork
allowed-tools: Read, Grep, Glob, Bash, WebSearch
model: sonnet
---

# PR Review Skill

Review a pull request by analyzing the diff, checking for issues, and providing structured feedback.

## Process

1. **Get the PR number** from $ARGUMENTS. If no PR number is provided, detect the current branch's PR using `gh pr view --json number`.

2. **Fetch PR details** by running:
   - `gh pr view <number>` for the PR description, title, and metadata
   - `gh pr diff <number>` for the full diff
   - `gh pr view <number> --json files` to get the list of changed files

3. **For each changed file**, read the full file using Read to understand the broader context around the changes. Do not review the diff in isolation.

4. **Analyze changes** across these dimensions:
   - **Correctness**: Does the code do what it claims? Are there logic errors, off-by-one errors, or missing edge cases?
   - **Security**: Are there injection risks, exposed secrets, missing auth checks, or unsafe operations?
   - **Performance**: Are there N+1 queries, unnecessary allocations, missing indexes, or algorithmic concerns?
   - **Maintainability**: Is the code readable? Are names clear? Is there unnecessary complexity or duplication?
   - **Test coverage**: Were tests added or updated for new behavior? Are edge cases covered?

5. **Check for missing tests**: If new functionality was added without corresponding tests, flag it.

6. **Generate a structured review** using the output format below.

## Output Format

Structure the output as a **PR Review** with the following sections:

### Summary

One paragraph describing what this PR does and its overall quality.

### Must Fix

Critical issues that should be resolved before merging. These are bugs, security issues, or correctness problems. List file path and line number for each.

### Should Fix

Non-critical issues that would improve the code. These are performance concerns, maintainability improvements, or minor bugs. List file path and line number for each.

### Suggestions

Optional improvements — style, naming, alternative approaches. These are nice-to-haves.

### Assessment

One of:

- **Approve**: No must-fix items, code is ready to merge
- **Request Changes**: Has must-fix items that need to be addressed
- **Comment**: No must-fix items but has enough should-fix items to warrant another look
