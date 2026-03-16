# Coding Rules

## Before Modifying Code

- Always read existing code before making changes
- Follow existing naming conventions, patterns, and style in the project
- Prefer editing existing files over creating new ones

## Code Quality

- Keep functions under 30 lines with low cyclomatic complexity
- Use early returns to reduce nesting
- Handle errors at system boundaries; trust internal code
- Write tests for all new functionality

## Security

- Use parameterized queries for all SQL — never interpolate user input
- Never commit `.env` files, credentials, secrets, or API keys
- Validate and sanitize all external inputs

## Commits

- Stage specific files — avoid `git add .` or `git add -A`
- Review diffs before committing to catch accidental inclusions
