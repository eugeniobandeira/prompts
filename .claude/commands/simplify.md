---
description: Review changed code for reuse, quality, and efficiency, then fix any issues found. Use after write-code and before verify to catch smells, duplication, and unnecessary complexity introduced by the implementation.
---

# Simplify

## How to invoke

Start this agent after completing an implementation step. It will inspect the recent changes, identify code smells and quality issues, and fix them in place — staying strictly within the scope of the changes made.

---

## Step 0: Analyze Project Context

Before reviewing anything, inspect the current repository to build a project profile:

1. Detect the primary language and framework (project files at root)
2. Map the first and second-level directory structure
3. Identify the architectural pattern and the layer boundaries relevant to the changed files
4. Inspect 2–3 existing files at each affected layer to capture:
   - Established naming and structural conventions
   - Existing utilities, helpers, and shared abstractions
   - Error handling and return type patterns
5. Identify the package manager and any available linting / formatting commands

Produce a concise context block before proceeding:
```
PROJECT CONTEXT
- Language / framework: ...
- Architectural pattern: ...
- Affected layers: ...
- Existing utilities relevant to the changes: ...
- Lint / format command: ...
```

---

## Your Objective

Review the code changed in the current implementation, fix issues in place, and report what was changed and why. You are not expanding scope, redesigning the solution, or introducing new features — you are making the existing implementation cleaner and easier to maintain.

---

## Hard Constraints

1. DO NOT introduce new behavior or change existing behavior
2. DO NOT expand scope beyond the files touched in the current implementation
3. DO NOT apply speculative refactors ("this might be useful later")
4. If a fix would require changing files outside the current scope, flag it as a suggestion — do not implement it
5. Every change must be traceable to a smell identified below

---

## Review Scope

Identify the files to review:

```bash
git --no-pager diff --name-only HEAD
```

If the working tree has unstaged changes, review those as well. Do not review files that were not part of the current implementation.

---

## Smell Detection

For each changed file, scan for the following categories. Flag every instance with its location (file + line).

### Size

| Smell | Threshold | Action |
|---|---|---|
| Long method | > 20 lines of logic | Extract to named helper |
| Large class | > 1 responsibility | Extract secondary responsibility |
| Long parameter list | > 4 parameters | Introduce parameter object |
| Deep nesting | > 3 levels | Extract early returns or helper |

### Primitives & Literals

| Smell | Example | Action |
|---|---|---|
| Magic number | `if (status === 3)` | Extract to named constant or enum |
| Magic string | `throw new Error("not_found")` | Extract to constants file |
| Primitive obsession | Raw strings for IDs, emails, currencies | Introduce value object if the project uses them |

### Duplication

| Smell | Signal | Action |
|---|---|---|
| Identical logic in 2+ places | Same block copy-pasted | Extract to shared utility |
| Near-duplicate with minor variation | Same structure, different variable | Parameterize and extract |
| Dead code | Unreachable block, unused variable | Remove |
| Commented-out code | `// old implementation` | Remove |

### Coupling

| Smell | Signal | Action |
|---|---|---|
| Feature envy | Method uses more from another class than its own | Move the method |
| Message chain | `a.b().c().d()` | Introduce intermediate variable or delegate |
| Inappropriate intimacy | Class reaches into another's internals | Expose behavior through the interface |
| Hardcoded dependency | `new ConcreteService()` inside a class | Use injection if the project's DI pattern supports it |

### Abstraction

| Smell | Signal | Action |
|---|---|---|
| Speculative generality | Interface with one implementation and no planned extension | Flatten if not required by architecture |
| Unnecessary indirection | Wrapper that adds no behavior | Remove |
| Overcomplicated conditionals | Long if/else chain that could be a map or strategy | Simplify if clear and safe |

---

## Reuse Check

After smell detection, verify whether the implementation duplicates something already in the codebase:

1. Search for existing utilities that perform the same operation
2. Check whether an existing base class or mixin could replace new code
3. Check whether a constant or enum already exists for the values introduced

If a reuse opportunity is found, apply it. If applying it would require changes outside the current scope, flag it as a suggestion.

---

## Fix Protocol

For each smell or reuse issue found:

1. **Assess impact** — Is the fix self-contained within the current scope?
   - Yes → fix in place
   - No → flag as suggestion, do not implement
2. **Apply the fix** — minimal change, no unrelated edits
3. **Verify behavior is unchanged** — re-read the method before and after; if behavior could differ, do not apply the fix

**Never:**
- Rename things that are not smells
- Rewrite logic that is correct but "could be cleaner"
- Apply stylistic preferences not grounded in the project's conventions

---

## Required Output

### 1. Files Reviewed

List every file inspected and whether issues were found.

---

### 2. Smell Report

For each smell found:

| File | Location | Category | Smell | Severity | Action taken |
|---|---|---|---|---|---|
| | | Size / Primitives / Duplication / Coupling / Abstraction | | Low / Medium / High | Fixed / Flagged as suggestion |

If no smells were found, state that explicitly.

---

### 3. Changes Made

For each fix applied:

| File | What changed | Why |
|---|---|---|
| | | |

If no changes were made, state that explicitly.

---

### 4. Suggestions (out of scope)

List improvements that were identified but not applied because they would require changes outside the current scope. For each:

- **What:** brief description of the improvement
- **Where:** file and location
- **Why:** the benefit it would provide

---

### 5. Reuse Opportunities Applied

List any cases where new code was replaced with an existing utility, constant, or abstraction.

---

## Completion Condition

Simplify is complete when:
- All in-scope smells are resolved or explicitly flagged
- No new behavior has been introduced
- The diff is smaller or equal to before (fixes should reduce code, not add it)
- Out-of-scope suggestions are documented for follow-up
