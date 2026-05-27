# Claude Code Commands

> A centralized collection of custom slash commands for software development workflows with Claude Code.

Clone this repo, run the install script, and every command becomes available as a `/slash-command` in any project you open with Claude Code.

---

## Installation

**Windows (PowerShell)**
```powershell
git clone <repo-url>
cd prompts
.\install.ps1
```

**Mac / Linux**
```bash
git clone <repo-url>
cd prompts
bash install.sh
```

The scripts copy all `.md` files from `.claude/commands/` into `~/.claude/commands/`, making them globally available across every project.

---

## Commands

| Command | Purpose |
|---|---|
| `/write-spec` | Define what to build: interface contract, validation rules, error cases, data model changes, and testing strategy |
| `/write-plan` | Translate a spec into ordered implementation steps, each scoped to a single file |
| `/write-code` | Execute an implementation plan precisely, enforcing the project's existing conventions |
| `/verify` | Run build, lint, and tests — no completion claims without fresh evidence |
| `/review-code` | Audit the implementation against spec, plan, and architecture rules before merging |
| `/commit` | Stage and commit with a well-formed [Conventional Commits](https://www.conventionalcommits.org/) message |
| `/create-pr` | Generate a structured PR title and body, then open it via GitHub CLI |
| `/map-codebase` | Analyze an existing codebase and produce full architecture documentation |

---

## Recommended Workflow

```
/write-spec → /write-plan → /write-code → /verify → /review-code → /commit → /create-pr
```

Each command hands off cleanly to the next:

1. **`/write-spec`** — Lock in requirements before touching any code.
2. **`/write-plan`** — Break the spec into concrete, file-scoped steps with acceptance criteria.
3. **`/write-code`** — Implement each step, matching the project's patterns at every layer.
4. **`/verify`** — Build, lint, test. Surfaces regressions before they reach review.
5. **`/review-code`** — Final quality gate against spec, plan, and conventions.
6. **`/commit`** — Clean, structured commit message following Conventional Commits.
7. **`/create-pr`** — Structured PR ready for review, opened directly from the terminal.

> Use `/map-codebase` at any point to get an architecture snapshot of an unfamiliar repository.

---

## Adding or Updating Commands

1. Add or edit `.md` files in `.claude/commands/`
2. Re-run the install script to push the update to your global installation
3. Commit and push — teammates get the update on their next `git pull` + install
