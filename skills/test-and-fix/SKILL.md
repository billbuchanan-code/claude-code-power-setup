---
description: Run tests, analyze failures, fix issues, and re-run in a loop until all tests pass
context: fork
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
model: sonnet
---

# Test and Fix Skill

Run the test-fix-verify loop: execute tests, analyze failures, fix issues, and re-run until all tests pass.

## Process

1. **Discover the test command** by checking for:
   - `package.json` (look for `test`, `test:unit`, `test:integration` scripts)
   - `Makefile` (look for `test` target)
   - `pytest.ini`, `pyproject.toml`, `setup.cfg` (Python projects)
   - `Cargo.toml` (Rust projects — use `cargo test`)
   - `go.mod` (Go projects — use `go test ./...`)
   - Fall back to common conventions if none found

2. **Run tests** via Bash. If $ARGUMENTS specifies a test file or pattern, use that instead of the full suite.

3. **If tests pass**, report success and exit with a summary of what was run.

4. **If tests fail**, analyze the failure output:
   - Identify which tests failed and why
   - Extract error messages, stack traces, and assertion details
   - Determine the root cause (code bug vs. test bug vs. environment issue)

5. **Read the failing test** and the **code under test** to understand the expected behavior.

6. **Fix the issue**:
   - Prefer fixing the application code, not the test, unless the test itself is clearly wrong
   - Make minimal, targeted changes
   - Explain what was changed and why

7. **Re-run tests** to verify the fix.

8. **Repeat** steps 3-7 up to **5 iterations** maximum. If tests still fail after 5 attempts, stop and report the remaining issues.

9. **Report final results**:
   - Total iterations performed
   - Tests fixed vs. tests still failing
   - Summary of all changes made
   - Any remaining issues that need manual attention
