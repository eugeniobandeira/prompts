---
description: Analyze an existing codebase and produce structured documentation of its architecture, stack, conventions, and concerns. Use when joining a new project, onboarding, or before planning a large feature in an unfamiliar repo.
---

# Map Codebase

## How to invoke

Start this agent in the root of a repository. It will analyze the codebase and produce a set of structured documents describing the project's architecture, conventions, and health.

---

## Your Objective

Produce a comprehensive but concise analysis of an existing codebase, organized into 7 documents. The output gives any developer (or AI agent) enough context to work safely in this repository without guessing.

---

## Hard Constraints

1. DO NOT modify any files — this is a read-only analysis
2. DO NOT invent or assume — if something is unclear, mark it as "uncertain" or "undetermined"
3. DO NOT produce code — only documentation
4. Base every claim on evidence found in the repository (file paths, code snippets, config values)
5. Keep each section concise — prefer tables and bullet points over prose

---

## Analysis Process

### Phase 1: Discovery

Scan the repository structure:

1. Read root-level config files: `package.json`, `*.csproj`, `go.mod`, `pom.xml`, `pyproject.toml`, `Cargo.toml`, `Gemfile`, `Makefile`, `docker-compose.yml`, etc.
2. Map the first 3 levels of directory structure
3. Identify CI/CD configuration (`.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, etc.)
4. Identify documentation (README, CONTRIBUTING, ADRs, wiki links)
5. Count approximate lines of code per language (from file extensions)

### Phase 2: Deep Inspection

For each major area, inspect 3–5 representative files:

1. **Entry points** — Main files, startup, bootstrap
2. **Business logic** — Services, handlers, use cases
3. **Data access** — Repositories, ORM models, migrations
4. **API surface** — Controllers, routes, resolvers
5. **Tests** — Unit, integration, E2E
6. **Infrastructure** — Docker, CI, deployment configs

---

## Output Documents

Produce the following 7 sections (as a single output, clearly separated by headings):

---

### 1. STACK

Technology stack and dependencies.

| Category | Technology | Version | Notes |
|---|---|---|---|
| Language | | | |
| Framework | | | |
| Database | | | |
| ORM / Data access | | | |
| Testing | | | |
| CI/CD | | | |
| Containerization | | | |
| Key libraries | | | |

---

### 2. ARCHITECTURE

High-level architecture pattern and data flow.

- **Pattern identified:** (Clean Architecture / Hexagonal / MVC / Feature-based / Monolith / Microservices / etc.)
- **Evidence:** (folder structure and naming that supports this conclusion)
- **Layer dependency direction:** (e.g., API → Application → Domain ← Infrastructure)
- **Communication patterns:** (REST, gRPC, events, queues, etc.)
- **Data flow:** (request lifecycle from entry point to response)

Include a simple ASCII diagram if the architecture has clear layers:
```
[API Layer] → [Application/Service Layer] → [Domain Layer]
                                                  ↑
                                        [Infrastructure Layer]
```

---

### 3. CONVENTIONS

Coding conventions derived from the codebase (not assumed).

| Area | Convention | Example |
|---|---|---|
| File naming | | `user-service.ts` / `UserService.cs` |
| Class/type naming | | PascalCase / camelCase |
| Function naming | | camelCase / snake_case |
| Error handling | | Exceptions / Result types / Error codes |
| Validation | | Decorators / Fluent / Manual |
| DI/IoC | | Constructor injection / Module providers |
| Async pattern | | async/await / Promises / Channels |
| Null handling | | Optional / nullable / null checks |
| Import style | | Absolute / Relative / Barrel files |

---

### 4. STRUCTURE

Directory layout with purpose annotations.

```
root/
├── src/               # (purpose)
│   ├── domain/        # (purpose)
│   ├── application/   # (purpose)
│   └── ...
├── tests/             # (purpose)
├── docs/              # (purpose)
└── ...
```

Note any non-obvious organizational choices or deviations from framework defaults.

---

### 5. TESTING

Test infrastructure and patterns.

- **Framework(s):** (Jest, xUnit, pytest, Go testing, etc.)
- **Test types present:** (Unit / Integration / E2E / Contract / Performance)
- **Test location:** (Co-located / Separate folder / Both)
- **Naming convention:** `*.test.ts` / `*_test.go` / `*Tests.cs`
- **Coverage tooling:** (configured? threshold?)
- **Mocking strategy:** (library used, patterns observed)
- **Test data:** (factories, fixtures, builders, inline)
- **CI integration:** (tests run on PR? blocking?)

---

### 6. INTEGRATIONS

External services, APIs, and third-party dependencies.

| Service | Purpose | Config location | Auth method |
|---|---|---|---|
| | | | |

Note: Include databases, message queues, cloud services, third-party APIs, monitoring tools.

---

### 7. CONCERNS

Technical debt, risks, and fragile areas observed.

| Area | Concern | Severity | Evidence |
|---|---|---|---|
| | | Low / Medium / High | (file path or pattern observed) |

Categories to evaluate:
- **Security:** Hardcoded secrets, missing input validation, outdated dependencies
- **Maintainability:** Large files (>500 lines), circular dependencies, dead code
- **Reliability:** Missing error handling, no retry logic, no health checks
- **Performance:** N+1 queries, missing indexes (if visible), unbounded queries
- **Testing gaps:** Untested critical paths, no integration tests
- **Documentation:** Missing README sections, outdated docs

---

## Final Summary

After the 7 documents, produce a brief (5–10 bullet) executive summary:

- What this project is and does
- Current health assessment (Healthy / Needs Attention / Critical)
- Top 3 risks
- Top 3 strengths
- Recommended first actions for a new contributor
