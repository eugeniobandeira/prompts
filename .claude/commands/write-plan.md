---
description: Translate a feature spec into a detailed, executable implementation plan for this codebase. Reads the current project context to derive layer order, naming conventions, and existing patterns. Use when you have a spec or clear requirements and need a step-by-step implementation plan.
---

# Write Plan

## How to invoke

Start this agent and provide a spec or feature description. You can paste the output from the `write-spec` agent directly.

---

## Step 0: Analyze Project Context

Before anything else, inspect the current repository to build a project profile:

1. Detect the primary language and framework (project files at root)
2. Map the first and second-level directory structure
3. Identify the architectural pattern and derive the correct implementation order:
   - **Clean Architecture** → Domain → Infrastructure → Application → IoC → API → Tests
   - **Feature-based** → Model → Repository → Service → Controller/Handler → Tests
   - **Hexagonal** → Domain/Ports → Adapters → Application Service → Tests
   - **MVC** → Model → Migration → Controller → View/Serializer → Tests
   - If the repository does not clearly match any listed pattern, identify the most similar pattern and document the deviation in the PROJECT CONTEXT block.
4. List existing modules / domains / aggregates to identify where the new feature belongs
5. Inspect 2–3 existing files at each layer to capture:
   - Naming conventions (files, classes, interfaces, methods)
   - Base classes or interfaces that new files must extend
   - DI/IoC registration patterns
   - Error handling and return type patterns
   - Validation patterns and where constants/messages are stored
6. Identify test projects/folders, testing frameworks, and test naming conventions
7. Check whether a database migration is needed and what tool manages it
8. Detect the package manager in use:
   `package.json` → check for yarn.lock / pnpm-lock.yaml / package-lock.json; `*.csproj` → NuGet; `go.mod` → Go modules; `pyproject.toml` / `requirements.txt` → pip/poetry/uv; `Cargo.toml` → cargo

Produce a concise context block before proceeding:
```
PROJECT CONTEXT
- Language / framework: ...
- Package manager: ...
- Architectural pattern: ...
- Implementation order: ...
- Modules / domains: ...
- Naming conventions: ...
- DI / IoC pattern: ...
- Error handling pattern: ...
- Validation pattern: ...
- Test framework and structure: ...
- Migration tool (if applicable): ...
```

If something in the spec conflicts with what the repository shows, flag it explicitly — do not silently work around it.

---

## Your Objective

Produce a comprehensive implementation plan based on:
1. The spec or feature description provided by the user
2. The project context built in Step 0

The plan must be detailed enough that a mid-level developer can execute it without re-reading the spec.

---

## Hard Constraints

1. DO NOT write code — no code snippets beyond trivial pseudocode if absolutely necessary
2. DO NOT invent requirements not present in the spec
3. DO NOT assume missing requirements — flag them in **Risks & Unknowns**
4. Every decision must be grounded in the spec and the existing codebase patterns from Step 0

---

## Plan Sections

### 1. Feature Summary

- What is being built and which domain(s) / module(s) it touches
- Key operation(s): Create / Read / Update / Delete / Other
- Clear mapping to spec requirements

---

### 2. Impacted Areas

List every file or module that will be created or changed:

| File / Module | Layer | Change | Reason |
|---|---|---|---|
| | | New / Modify | |

Use real file names and paths based on the conventions discovered in Step 0.

---

### 3. Data Model Changes

- New entities / models: fields, types (using the language's real types), constraints
- Changes to existing entities
- Database migration: required or not, which files are affected
- Backward compatibility: nullable columns, default values, rollback considerations

---

### 4. API / Interface Contract

Describe the interface — do not implement it:
- Method, route, or function signature
- Request shape (field names and types)
- Response shape
- Success status
- Error mapping: each failure scenario → error type → status code (if applicable)

---

### 5. Step-by-Step Implementation Plan

Follow the implementation order derived from Step 0. Each step must be:
- Scoped to a single file or concern
- Assigned to a layer
- Referencing an existing file in the repository as a pattern to follow

For each step, use this structured task format:

```markdown
---
status: pending
title: [Short descriptive title]
type: [backend | frontend | infra | test | docs | refactor | chore]
complexity: [low | medium | high]
dependencies: [list of step numbers this depends on, e.g. [1, 2]]
---

**Layer:** [Domain / Application / Infrastructure / API / Test]
**File:** [exact file path to create or modify]
**Reference:** [existing file in the repo that serves as pattern]
**What:** [What to create or change — one sentence]
**Done when:** [Verifiable acceptance criterion]
**Commit:** [Conventional commit message for this step]
```

Also produce a summary table for quick reference:

| # | Layer | What to create / change | Reference file | Depends on |
|---|---|---|---|---|
| | | | | |

---

### 6. Validation Plan

For each input field, specify the rule and where constants or messages come from:

| Field | Rule | Source / Constant |
|---|---|---|
| | | |

---

### 7. Error Cases & Handler Logic

Map each failure scenario to the handler/service decision tree:

| Step | Condition | Action |
|---|---|---|
| 1 | Validation fails | Return validation errors |
| 2 | Duplicate detected | Return conflict error |
| 3 | Record not found | Return not found error |
| 4 | Success | Persist and return result |

Flag if a multi-step write requires a transaction.

---

### 8. Testing Strategy

Use the test framework and folder structure from Step 0.

#### Unit Tests
- Valid input → passes
- Each required field absent → fails
- Each boundary / format rule fails correctly
- Each error scenario returns the correct error type
- Side effects are not triggered on failure

#### Integration Tests (if applicable)
- Entity is persisted with correct field values
- Queries return correct results (filters, ordering, pagination if applicable)

#### End-to-End Tests (if applicable)
- Happy path returns expected response and status
- Error scenarios return correct status and body

---

### 9. Risks & Unknowns

- `[blocking]` — must be resolved before implementation can start
- `[non-blocking]` — can be resolved during implementation

Include: ambiguities in the spec, missing business rules, schema risks, breaking changes to shared interfaces, migration risks on live data.

---

## Plan Validation

Before delivering the plan, verify:

1. **File references** — every file path in the "Impacted Areas" table and step-by-step plan exists in the repository (for modifications) or its parent directory exists (for new files)
2. **Pattern references** — every "Reference file" in the implementation steps is a real file that can be found via search
3. **Dependency order** — no step references a file or type that is created in a later step (unless marked as a dependency)
4. **Scope alignment** — every step maps back to a spec requirement; no orphan steps

If any validation fails, flag it in **Risks & Unknowns** before delivering.

---

## Planning Principles

- Prefer modifying existing components over creating new ones unless the spec requires it.
- Minimize the surface area of change — one operation, one handler/controller, one endpoint/route.
- Every step must reference an existing file or pattern in the repository as its implementation guide.
- If the spec conflicts with or requires something the current architecture does not support, flag it explicitly.
- The plan must be detailed enough that a mid-level developer can execute it without re-reading the spec.
