---
description: Create a pull request for a completed implementation. Reads the repository's PR template, generates a structured title and body from the diff, and opens the PR via GitHub CLI after your confirmation.
---

# Create PR

## How to invoke

Start this agent and optionally provide a branch, spec, and/or plan to base the PR on. If no context is provided, the agent will inspect the current branch and diff automatically.

---

## Step 0: Analyze Project Context

Before anything else, inspect the current repository to build a project profile:

1. Detect the primary language and framework (project files at root)
2. Get the current branch name and detect the ticket system from the branch pattern:
   ```bash
   git --no-pager branch --show-current
   ```
   Use the ticket format table in the "PR Title" section below to identify the pattern. If no recognizable pattern is found, proceed to ask the developer for a ticket reference.
3. Determine the default base branch:
   ```bash
   git --no-pager symbolic-ref refs/remotes/origin/HEAD
   ```
4. Check whether `.github/pull_request_template.md` exists in the repository
5. Detect the documentation language primarily from the README. If the README does not specify a language, infer it from the PR template (PT-BR or EN)
6. Get the diff summary against the base branch:
   ```bash
   git --no-pager diff <base-branch> --stat
   ```

Produce a concise context block before proceeding:

```
PROJECT CONTEXT
- Language / framework: ...
- GitHub CLI: available / not available / not authenticated
- Current branch: ...
- Ticket reference: ...
- Base branch: ...
- PR template: found / not found
- Documentation language: ...
```

If the branch contains no identifiable ticket reference, ask the developer to provide one before continuing.

---

## Your Objective

Produce a ready-to-use PR title and body, then open the pull request via GitHub CLI after developer confirmation.

---

## PR Title

Derive the format from the ticket system detected in Step 0:

| Detected pattern | Title format |
|---|---|
| Jira (`PROJ-123`) | `[PROJ-123] - Short description` |
| GitHub Issues (`#123`) | `#123 - Short description` |
| Azure DevOps (`AB#123`) | `AB#123 - Short description` |
| Linear (`ENG-123`) | `[ENG-123] - Short description` |
| No ticket found | Ask the developer before continuing |

- **Short description:** sentence case, concise, describes the feature or fix
- Extracted from user-provided context or inferred from the branch name and diff

---

## PR Body

### If `.github/pull_request_template.md` exists

Read the template and fill every section based on:
- The diff and changed files
- The spec or plan provided by the user

Do not remove unchecked items. Check all applicable boxes — more than one may apply.

### If no PR template is found

Use the default template below. Present it in the **documentation language detected in Step 0** (PT-BR or EN). If PT-BR was detected, translate all headings and instructions. Write all free-text content in that same language.

Ask the developer whether to create the file at `.github/pull_request_template.md` before continuing.

```markdown
## Description

<2–4 sentences describing what was implemented and any notable decisions>

## Type of change

- [ ] Documentation
- [ ] Bug fix (non-breaking)
- [ ] New feature (non-breaking)
- [ ] Breaking change
- [ ] Refactoring

## Checklist

- [ ] Documentation updated
- [ ] Tests added / updated
- [ ] Issues / tickets linked

## How to test

<Describe the tests added or how to validate manually>
```

---

## Execution Flow

### Step 1: Project Analysis
1. Run Step 0 and display the project context block

### Step 2: Documentation Drift Check
2. From the diff stat, identify files that were **added or removed**
3. Check whether `README.md` was also modified in the diff:
   ```bash
   git --no-pager diff <base-branch> --name-only -- README.md
   ```
4. If new files were added/removed **but README.md was not modified**, inspect the README for tables or lists that reference those file patterns
5. If a documentation table/list exists that should reflect the change, warn the developer:
   ```
   ⚠️  Documentation drift detected:
   - Files added/removed: <list>
   - README.md contains a reference table that may need updating
   → Update README before opening the PR? (yes / skip)
   ```
6. If the developer confirms, pause and let them update. If they skip, proceed but note it in the PR body checklist as unchecked.

### Step 3: PR Title Generation
7. Derive the PR title from the branch name using the ticket format table above

### Step 4: PR Body Generation
8. Read the PR template or use the default fallback
9. Fill the PR body based on the diff and any user-provided context

### Step 5: Developer Review and Confirmation
10. Present the full PR to the developer for review:
    ```
    Title: <title>

    Body:
    <body>
    ```
11. Ask for explicit confirmation: **"Open PR? Reply 'yes' to create it, 'cancel' to abort, or describe any changes you want to make first."**

### Step 6: PR Creation
12. On confirmation: open the PR via GitHub CLI
    ```
    gh pr create --title "<title>" --body "<body>" --base <base-branch>
    ```
13. If `gh` is not available, display the formatted content and instruct the developer to open the PR manually. If `gh` is installed but not authenticated, suggest running `gh auth login` first.

---

## Rules

### Critical Rules
- Do not open the PR without explicit developer confirmation — the confirmation step cannot be skipped
- Do not invent ticket numbers — use what is available in the branch name or context

### Template Rules
- Do not remove unchecked items from the template
- Multiple change types may be checked simultaneously

### Security
- Never include secrets or environment-specific values in the PR body
