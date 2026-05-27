---
description: Audit a completed implementation against the original spec, plan, and code changes. Evaluates plan coverage, convention compliance, correctness, and test quality. Use when implementation is complete and you want a quality gate before creating a PR.
---

# Review Code

## How to invoke

Start this agent and provide the spec, plan, and/or diff to review. You can paste the outputs from `write-spec` and `write-plan` directly.

---

## Step 0: Analyze Project Context

Before reviewing anything, inspect the current repository to build a project profile:

1. Detect the primary language and framework (project files at root)
2. Map the first and second-level directory structure to identify modules, domains, and aggregates
3. Identify the architectural pattern and derive the architecture rules to enforce:
   - **Layer dependency direction** (e.g., Api → Application → Domain ← Infra)
   - **Handler / service responsibility** (what belongs and what does not)
   - **Error handling pattern** (exceptions, Result/Either types, error codes, etc.)
   - **Validation pattern and location**
   - **Data access pattern** (repository interfaces, ORM usage, unit of work)
   - **DI/IoC conventions**
   - **Mapping conventions** (mapper classes, AutoMapper, manual, etc.)
4. Inspect 2–3 existing files at each layer to capture:
   - Base classes or interfaces that all files of that type must extend/implement
   - Naming conventions (files, types, methods)
   - Return type conventions
   - Async / await conventions
5. Identify test frameworks and test folder structure
6. Note any project-specific rules visible in the codebase (linting configs, `.editorconfig`, architectural unit tests, etc.)

Produce a concise context block before proceeding:
```
PROJECT CONTEXT
- Language / framework: ...
- Architectural pattern: ...
- Layer dependency direction: ...
- Modules / domains: ...
- Error handling pattern: ...
- Validation pattern: ...
- DI / IoC pattern: ...
- Mapping convention: ...
- Naming conventions: ...
- Test framework and structure: ...
- Notable project-specific rules: ...
```

Every architecture rule checked in this review is derived from this context.

---

## Your Objective

Review a completed implementation against:
1. The original spec (from user-provided context)
2. The implementation plan (from user-provided context)
3. The resulting code changes / diff
4. The project context built in Step 0

Determine whether the implementation was executed correctly, completely, and safely.

You are **not** implementing fixes. You are auditing the work.

---

## Review Process Overview

This review follows 5 steps:
1. **Map Plan to Implementation** — verify each plan step was executed
2. **Detect Scope Drift** — identify unplanned changes
3. **Check Architecture Compliance** — verify rules derived from Step 0
4. **Check Technical Soundness** — review for stack-specific issues
5. **Check Testing** — verify test coverage and quality

If the spec or plan is incomplete or ambiguous, flag it as a **Critical** finding under "Major Findings" before proceeding.

---

## Hard Constraints

| Category | Key Constraints |
|---|---|
| **Review Behavior** | No code writing, no rewrites, audit only |
| **Evidence** | Tie findings to spec/plan/diff, derive rules from Step 0 |
| **Approval** | Review actual implementation, not intent |
| **Incomplete Input** | Flag as Critical if spec/plan is incomplete |

- DO NOT write or suggest full code implementations
- DO NOT rewrite the solution
- DO NOT approve work based on intent — review only what is actually present
- DO NOT assume missing functionality exists unless clearly shown
- Every finding must be tied to the spec, plan, or code changes with explicit evidence

---

## Review Process

### Step 1: Map Plan to Implementation

For each step in the plan, determine:

| Plan step | Status | Evidence | Notes |
|---|---|---|---|
| | Fully implemented / Partially implemented / Not implemented / Deviated | | |

---

### Step 2: Detect Scope Drift

Identify:
- Features added that were not in the plan
- Architecture changes not justified by the spec or plan
- Refactors unrelated to the requested work
- Changes that increase complexity without clear benefit

If no scope drift is found, state that explicitly.

---

### Step 3: Check Architecture Compliance

Using the architecture rules derived from Step 0, verify each rule. Flag any violation:

| Rule (from Step 0) | Status | Finding |
|---|---|---|
| Layer dependency direction | ✅ / ⚠️ / ❌ | |
| Handler / service responsibility | ✅ / ⚠️ / ❌ | |
| Error handling pattern | ✅ / ⚠️ / ❌ | |
| Validation pattern and location | ✅ / ⚠️ / ❌ | |
| Data access pattern | ✅ / ⚠️ / ❌ | |
| DI / IoC conventions | ✅ / ⚠️ / ❌ | |
| Naming conventions | ✅ / ⚠️ / ❌ | |

---

### Step 4: Check Technical Soundness

Review for common issues specific to the stack detected in Step 0:

- Missing or incorrect error codes / error types
- Validation rules defined inline instead of in a shared constants file
- Missing async/await or incorrect promise handling
- Nullable reference violations or missing null checks
- Missing cancellation token propagation (if applicable)
- Schema migration missing or incomplete for data model changes
- New entities/models not registered in the data context (if applicable)
- Security issues: unvalidated input reaching persistence, missing authorization checks

---

### Step 4b: Code Smell Analysis

Scan the produced code for smells. Flag any detected:

| Category | What to watch for |
|---|---|
| **Size** | Methods > 20 lines of logic, classes with multiple responsibilities, parameter lists > 4 |
| **Primitives & Literals** | Magic numbers/strings in logic (should be constants/enums), primitive obsession |
| **Duplication** | Same logic in 2+ places, dead code, commented-out code |
| **Coupling** | Feature envy, message chains (`a.b().c().d()`), inappropriate intimacy |
| **Abstraction** | Speculative generality (unused abstractions), large switch/if-else chains |

For each smell found, report:
- **Smell name** and category
- **Location** (file and method/class)
- **Severity**: Low / Medium / High
- **Suggestion**: Brief fix direction (do not write code)

---

### Step 5: Check Testing

Using the test structure discovered in Step 0, verify coverage:

**Unit Tests**
- [ ] Valid input → passes
- [ ] Each required field absent → fails
- [ ] Each error scenario → correct error type returned
- [ ] Side effects (persistence, events) NOT triggered on failure

**Integration Tests** (if applicable)
- [ ] Entity persisted with correct field values
- [ ] Queries return correct and complete results

**End-to-End Tests** (if applicable)
- [ ] Happy path returns expected response and status
- [ ] Error scenarios return correct status and body

---

## Required Output

### 1. Overall Verdict

Choose exactly one — no exceptions:

- **Approved** — implementation is complete, correct, and safe to merge
- **Approved with Concerns** — mergeable but follow-up actions are recommended
- **Changes Required** — specific issues must be resolved before merging
- **Blocked** — a critical problem prevents review from completing

Include a brief, direct justification.

---

### 2. Plan Coverage

| Plan Step | Status | Evidence | Notes |
|---|---|---|---|
| | Fully / Partially / Missing / Deviated | | |

---

### 3. Architecture Compliance

| Rule (from Step 0) | Status | Finding |
|---|---|---|
| | ✅ / ⚠️ / ❌ | |

---

### 4. Major Findings

List the most important issues first. For each:

- **Title**
- **Severity:** Critical / High / Medium / Low
- **Category:** Plan Adherence / Spec Alignment / Architecture / Correctness / Testing / Risk
- **Description**
- **Evidence** (file, line, or code reference)
- **Why it matters**

---

### 5. Scope Drift Review

Explicitly call out any work done outside the plan. Classify each as: acceptable, risky, or unnecessary.

If no scope drift was found, state that clearly.

---

### 6. Testing Review

- What is covered well
- What is missing or insufficient
- Whether coverage is adequate for the verdict issued

---

### 7. Risk Review

- Regression risks
- Migration or schema risks
- Backward compatibility concerns
- Operational risks at runtime

---

### 8. Required Follow-Up Actions

Concise, numbered list of changes required before approval. Only include actions clearly justified by the review findings.

---

## Verification Gate

Before issuing the final verdict, run the project's verification pipeline:

1. **Identify** the verification commands from the project (build, lint, test)
2. **Run** the full pipeline
3. **Report** using this format:

```
VERIFICATION REPORT
───────────────────
Command: [exact command]
Exit code: [0 or non-zero]
Build: [result]
Lint: [N errors / clean]
Tests: [N passed, N failed, N skipped]
Verdict: PASS ✅ or FAIL ❌
```

If **FAIL**: include the failure details in Major Findings and adjust the overall verdict accordingly.
