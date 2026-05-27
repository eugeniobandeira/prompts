---
description: Stage and commit changes using the Conventional Commits standard. Inspects the current project context, generates a well-formed commit message, and executes the commit after your confirmation.
---

# Semantic Commit

## How to invoke

Start this agent and optionally provide a brief description of what was done. If no description is provided, the agent will inspect the staged/unstaged changes and derive the message from the diff.

---

## Step 0: Analyze Project Context

Before anything else, inspect the current repository to build a project profile:

1. Detect the primary language by looking for project files at the root:
   `*.csproj`, `package.json`, `go.mod`, `pom.xml`, `pyproject.toml`, `Cargo.toml`, `*.gemspec`
2. Map the first and second-level directory structure to identify modules, domains, or features
3. Identify the architectural pattern from folder/project names:
   (`Domain`, `Application`, `Infra`, `Api`, `src/`, `internal/`, `modules/`, `pkg/`, `features/`)
4. Extract valid commit scopes from the modules/domains discovered
5. Detect the ticket system from the current branch name:
   - `PROJ-123` → Jira
   - `#123` or `issue/123` → GitHub Issues
   - `AB#123` → Azure DevOps
   - `ENG-123` → Linear
6. Confirm there are changes to commit:
   ```
   git --no-pager diff --cached --stat
   git --no-pager diff --stat
   ```

Produce a concise context block before proceeding:
```
PROJECT CONTEXT
- Language / framework: ...
- Modules / scopes available: ...
- Ticket system: ...
- Current branch: ...
- Ticket reference (if any): ...
```

If the repository is empty or the context cannot be determined, ask the developer for the missing information before continuing.

---

## Your Objective

Produce a `git commit` command with a well-formed Conventional Commits message based on:
1. The staged or unstaged changes in the working tree
2. Any description provided by the user
3. The project context built in Step 0

---

## Commit Message Format

Follows [Conventional Commits v1.0.0-beta.4](https://www.conventionalcommits.org/en/v1.0.0-beta.4/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Type

| Type | When to use | SemVer impact |
|---|---|---|
| `feat` | New feature | MINOR |
| `fix` | Bug fix | PATCH |
| `feat!` / `fix!` | Breaking change | MAJOR |
| `refactor` | Code change with no behaviour change | — |
| `test` | Adding or updating tests | — |
| `chore` | Build, config, dependency, or tooling changes | — |
| `docs` | Documentation only | — |
| `perf` | Performance improvement | — |
| `ci` | CI/CD configuration | — |
| `style` | Formatting, whitespace (no logic change) | — |
| `build` | Build system or external dependency changes | — |

### Scope

- Use the modules/domains discovered in Step 0
- Lowercase, no spaces
- If the diff spans a module not found in Step 0, ask the developer which scope to use. If the developer does not provide a scope, proceed without one.

### Description

- Imperative mood, lowercase, no trailing period
- Max 72 characters
- Describes *what* the commit does, not *why*

### Body (optional)

- Explain *what* and *why*, not *how*
- Wrap at 72 characters
- Separated from the description by a blank line

### Footers (optional)

- `BREAKING CHANGE: <description>` — required for breaking changes; triggers MAJOR in SemVer
- `Refs: <ticket>` — use the ticket reference detected in Step 0
- `Co-authored-by: <name> <email>` — when applicable

---

## Execution Flow

### Step 1: Project Analysis
1. Run Step 0 and display the project context block

### Step 2: Diff Inspection
2. Inspect the diff:
   ```
   git --no-pager diff --cached --stat
   git --no-pager diff --stat
   ```
3. If nothing is staged, ask whether to stage all changes or specific files before continuing

### Step 3: Commit Scope Validation
4. If the diff spans multiple modules or features that do not share a common purpose, suggest splitting into separate commits before generating a message

### Step 4: Message Generation and Confirmation
5. Generate the commit message using the project context from Step 0
6. Present the full message to the developer for review:
   ```
   Proposed commit:

   <type>(<scope>): <description>

   <body if any>

   <footers if any>
   ```
7. Ask for explicit confirmation: **"Confirm commit? Reply 'yes' to execute, 'cancel' to abort, or describe any changes you want to make first."**
8. On confirmation: execute the commit using `git commit` with multiple `-m` flags:
   - First `-m`: `<type>(<scope>): <description>`
   - Second `-m` (if body exists): `<body text>`
   - Additional `-m` for each footer

   > Each `-m` flag creates a blank-line-separated paragraph in the final message. This separation is required for footer parsing by tools like `conventional-changelog` and `semantic-release`.

---

## Rules

- One logical unit of work per commit — do not bundle unrelated changes
- Never include secrets, connection strings, or environment-specific values in committed files
- Do not execute the commit without explicit developer confirmation
- The confirmation step cannot be skipped

### Monorepo / Multi-Package Handling

When the repository contains multiple packages or projects:

1. Group changes by package/project — each package gets its own commit
2. Use the package name as the scope (e.g., `feat(api): ...`, `fix(web): ...`)
3. Shared/root-level changes get a separate commit with an appropriate scope (e.g., `ci`, `docs`, `chore`)
4. Present all proposed commits as a numbered list for confirmation before executing any of them
