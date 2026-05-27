---
description: Launch and drive this project's app to see a change working. Use when asked to run, start, or screenshot the app, or to confirm a change works in the real app (not just tests). Detects the project type, starts the dev server, and walks through the implemented feature to verify it works end-to-end.
---

# Run

## How to invoke

Start this agent after completing an implementation. Optionally describe the feature or flow to test. The agent will detect how to start the project, launch it, and verify the golden path works as expected.

---

## Step 0: Detect Project Type and Run Command

Inspect the repository to determine how to start the application:

### Server / API projects

| Signal | Start command |
|---|---|
| `package.json` with `"start"` or `"dev"` script | `npm run dev` / `yarn dev` / `pnpm dev` |
| `go.mod` | `go run ./cmd/...` or `go run main.go` |
| `pyproject.toml` / `manage.py` | `python manage.py runserver` / `uvicorn main:app --reload` |
| `*.csproj` | `dotnet run` |
| `Cargo.toml` | `cargo run` |
| `Makefile` with `run` target | `make run` |

### Frontend / full-stack projects

| Signal | Start command |
|---|---|
| `next.config.*` | `npm run dev` (default port 3000) |
| `vite.config.*` | `npm run dev` (default port 5173) |
| `angular.json` | `ng serve` (default port 4200) |
| `nuxt.config.*` | `npm run dev` (default port 3000) |

### CLI projects

| Signal | Approach |
|---|---|
| No server, binary output | Run the binary with representative arguments |

Produce a context block before proceeding:
```
PROJECT CONTEXT
- Project type: (API / Frontend / Full-stack / CLI / Library)
- Start command: ...
- Expected port / URL: ...
- Environment file required: (yes / no — .env, .env.local, etc.)
```

If the environment file is required but missing, ask the developer to provide it or the required values before proceeding.

---

## Your Objective

Start the project, wait for it to be ready, and verify that the implemented feature works correctly in the running application — not just in tests.

This is behavioral verification, not code verification. The goal is to confirm the application actually does what was implemented, at the user-facing level.

---

## Hard Constraints

1. DO NOT modify production configuration to make the app start
2. DO NOT commit or push changes made solely to get the app running locally
3. DO NOT claim the feature works without observing actual output from the running app
4. If the app fails to start, diagnose and report — do not claim partial success

---

## Execution Process

### Phase 1: Pre-flight

Before starting:

1. Confirm the environment file exists (`.env`, `.env.local`, `.env.development`, etc.)
2. Confirm dependencies are installed:
   - `node_modules/` exists for Node projects
   - Virtual env is active for Python projects
   - Compiled artifacts exist for compiled languages
3. If dependencies are missing, install them using the detected package manager

---

### Phase 2: Start the Application

1. Launch the application using the detected start command
2. Wait for the ready signal:
   - Node / Vite / Next.js: look for `ready`, `listening on`, `Local:` in stdout
   - Go / .NET: look for `listening` or `started`
   - Django: look for `Starting development server`
3. Note the actual port and URL

If the application does not reach a ready state within a reasonable time:
- Read the last 50 lines of output
- Identify the error
- Report the failure — do not proceed

---

### Phase 3: Verify the Feature

Walk through the implemented feature using the golden path. The verification steps depend on the project type:

#### API / Backend

Use `curl` or the appropriate HTTP client to exercise the endpoint(s):

1. Send a valid request and verify the response status and body
2. Send an invalid request and verify the error response
3. If the feature modifies data, verify the state change (query the resource after mutation)

Document each request and response:
```
Request:  POST /api/v1/resource
Body:     { "field": "value" }
Status:   201
Response: { "id": "...", "field": "value" }
```

#### Frontend / Full-stack

Navigate to the relevant screen and verify:

1. The page loads without console errors
2. The implemented feature is visible and functional
3. The happy path completes successfully
4. At least one error/edge case behaves correctly (e.g., form validation, empty state)

#### CLI

Run the binary with representative arguments:

1. Verify the happy path output
2. Verify at least one error case (missing argument, invalid input)

---

### Phase 4: Edge Cases

After verifying the golden path, verify at least 2 edge cases relevant to the implementation:

| Category | Examples |
|---|---|
| Invalid input | Missing required field, wrong type, out-of-range value |
| Auth / permissions | Unauthenticated request, unauthorized role |
| Empty / boundary state | Empty list, max-length string, zero value |
| Concurrency / duplicates | Duplicate creation attempt |

---

## Required Output

### 1. Start Result

```
START REPORT
────────────
Command:      [exact command run]
Ready signal: [line from stdout that confirmed readiness]
URL:          [actual URL and port]
Status:       Running ✅ / Failed ❌
```

If failed, include the error output and diagnosis.

---

### 2. Feature Verification

For each scenario tested:

| Scenario | Input | Expected | Actual | Result |
|---|---|---|---|---|
| Happy path | | | | ✅ / ❌ |
| Invalid input | | | | ✅ / ❌ |
| Edge case 1 | | | | ✅ / ❌ |
| Edge case 2 | | | | ✅ / ❌ |

Include the raw request/response or console output as evidence for each scenario.

---

### 3. Console / Log Observations

- Unexpected errors or warnings in the server log
- Unhandled exceptions
- Deprecation warnings from new dependencies

---

### 4. Verdict

```
RUN VERDICT
───────────
Feature works in running app: YES / NO
Regressions observed:         YES / NO (list if yes)
Blocking issues:              [description or "none"]
```

---

## When Verification Fails

If a scenario fails:

1. Read the server log output around the time of the failure
2. Identify whether the issue is in the code, the environment, or the test scenario
3. If it is a code issue: report the file and suspected cause — do not silently fix it
4. If it is an environment issue: describe what is missing and how to resolve it
5. Re-run after any fix to confirm the verdict

**Never claim a feature works based on tests alone.** This command exists precisely because passing tests do not guarantee correct behavior in the running application.
