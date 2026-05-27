---
description: Enforce fresh verification evidence before any completion claim, commit, or PR creation. Runs the project's full verification pipeline and produces a structured report.
---

# Final Verify

## How to invoke

Start this agent after completing implementation work. It will identify the project's verification commands, run them, and produce a structured report with evidence.

---

## Step 0: Identify Verification Commands

Inspect the repository to discover the verification pipeline:

1. Check for project-level verification scripts:
   - `Makefile` → look for `verify`, `check`, `ci`, or `all` targets
   - `package.json` → look for `test`, `lint`, `check`, `verify`, `ci` scripts
   - `*.csproj` / `Directory.Build.props` → `dotnet build` + `dotnet test`
   - `go.mod` → `go build ./...` + `go test ./...` + `golangci-lint run`
   - `pyproject.toml` → `pytest` + `ruff check` / `mypy`
   - `Cargo.toml` → `cargo build` + `cargo test` + `cargo clippy`

2. Detect linting and formatting:
   - ESLint, Prettier, Biome, dprint
   - golangci-lint, gofmt
   - ruff, black, isort
   - dotnet format
   - rustfmt, clippy

3. Detect test runner:
   - Jest, Vitest, Mocha
   - xUnit, NUnit, MSTest
   - pytest, unittest
   - Go testing
   - Cargo test

4. Check for a single gate command (preferred):
   - `make verify`, `make ci`, `npm run ci`, `npm run check`
   - CI workflow file (`.github/workflows/`) → extract the commands CI runs

Produce:
```
VERIFICATION PIPELINE
- Gate command (if exists): ...
- Build: ...
- Lint: ...
- Format check: ...
- Tests: ...
- Type check (if applicable): ...
```

If no clear verification commands can be determined, ask the developer before proceeding.

---

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If the verification command has not been run **in the current session** after the **last code change**, the result cannot be claimed.

---

## Your Objective

Run the full verification pipeline and produce a Verification Report with honest evidence. If anything fails, diagnose and report — do not hide failures or claim partial success.

---

## Hard Constraints

1. DO NOT claim success without showing actual command output
2. DO NOT skip any part of the verification pipeline
3. DO NOT suppress warnings or errors to make the report look clean
4. DO NOT use previous run results — every verification must be fresh
5. DO NOT commit or suggest committing if verification fails

---

## Verification Process

### 1. Scope Assessment

Determine the verification scope based on what's being claimed:

| Claim | Required Scope |
|---|---|
| "This test passes" | Run the specific test |
| "This file is correct" | Build + lint + tests touching that file |
| "Task complete" | Full pipeline: build + lint + format + all tests |
| "Ready to commit" | Full pipeline + diff review |
| "Ready for PR" | Full pipeline + diff review + no unrelated changes |

**A narrow verification does not support a broad claim.**

---

### 2. Execute Verification

Run commands in this order (skip what doesn't apply to the stack):

1. **Build** — Does the code compile?
2. **Format check** — Is the code formatted correctly?
3. **Lint** — Are there lint errors or warnings?
4. **Type check** — Does static analysis pass? (TypeScript, mypy, etc.)
5. **Tests** — Do all tests pass?

If a single gate command exists (e.g., `make verify`), prefer that over running individual commands.

---

### 3. Read Output Carefully

For each command:
- Check the exit code (0 = success, non-zero = failure)
- Count errors and warnings
- Note any test failures with names
- Note any lint violations with file paths

---

### 4. Produce Verification Report

```
VERIFICATION REPORT
───────────────────
Claim: [What is being claimed]
Scope: [Narrow / Full pipeline]

Command: [Exact command run]
Exit code: [0 or non-zero]
Output summary:
  - Build: [result]
  - Lint: [N errors, N warnings / clean]
  - Format: [clean / N files need formatting]
  - Tests: [N passed, N failed, N skipped]
Warnings: [List any, or "none"]
Errors: [List any, or "none"]

Verdict: PASS ✅ or FAIL ❌
```

---

## When Verification Fails

Failure is information, not a dead end. Follow this protocol:

1. **Read the failure** — Identify the exact error. Quote relevant output.
2. **Diagnose** — Trace to the root cause. If multiple failures, address them in order (first failure first).
3. **Fix** — Apply the minimal change that addresses the actual error.
4. **Re-verify from scratch** — Run the full command again. Do not assume the fix worked.
5. **Report again** — Produce a new Verification Report.

**Never:**
- Claim partial success ("3 of 4 checks pass")
- Skip re-verification after a fix
- Blame tooling without evidence of a false positive
- Move to the next task while verification is failing

---

## Red Flags

- Using words like "should work", "probably passes", "seems correct"
- Expressing satisfaction before running verification
- About to commit without showing verification output
- Trusting another agent's success report without independent verification
- Relying on a partial check to support a broad claim
- Running only tests without build + lint

---

## Pre-Commit Gate

Before any `git commit`:

1. Run the full verification pipeline. Not a subset.
2. Confirm zero errors, zero test failures in the output.
3. Produce a Verification Report with verdict **PASS**.
4. Review the staged diff: `git diff --cached --stat` — confirm no unrelated files.
5. Only then proceed with the commit.

If the pipeline has not passed **after the last code change**, the commit must not proceed.

---

## Pre-PR Gate

Before creating a PR (all of the above, plus):

1. Verify the diff matches the intended changes.
2. Confirm no debug code, console.logs, TODO comments, or temporary workarounds.
3. Confirm no unrelated files are staged.
4. Confirm the branch is up to date with the target branch (no merge conflicts).

---

## Rationalization Prevention

| Rationalization | Response |
|---|---|
| "Should work now" | Run the verification |
| "I'm confident" | Confidence ≠ evidence |
| "Just this once" | No exceptions |
| "Linter passed so it's fine" | Linter ≠ tests ≠ build |
| "Agent said success" | Verify independently |
| "Partial check is enough" | Partial proves nothing broad |
| "The test is flaky" | Prove it with multiple runs |
