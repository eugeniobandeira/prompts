---
description: Complete a security review of the pending changes on the current branch. Audits for OWASP Top 10 vulnerabilities, missing authorization, sensitive data exposure, and insecure configurations. Use before creating a PR on any branch that touches auth, data access, APIs, or user input.
---

# Security Review

## How to invoke

Start this agent on a branch with completed implementation work. It will inspect the diff against the base branch and audit the changes for security issues before a PR is opened.

---

## Step 0: Analyze Project Context

Before reviewing anything, inspect the current repository to build a project profile:

1. Detect the primary language and framework
2. Identify the authentication and authorization mechanism in use (JWT, sessions, OAuth, API keys, RBAC, etc.)
3. Identify the data access layer (ORM, raw queries, repository pattern)
4. Identify where input validation occurs and what library is used
5. Check for existing security utilities (sanitizers, guards, middleware, decorators)
6. Check for environment/secret management patterns (`.env`, secrets manager, config service)
7. Detect the API surface type (REST, GraphQL, gRPC, tRPC)

Produce a concise context block before proceeding:
```
PROJECT CONTEXT
- Language / framework: ...
- Auth mechanism: ...
- Data access layer: ...
- Validation pattern: ...
- Secret management: ...
- API surface: ...
- Existing security utilities: ...
```

---

## Review Scope

Get the diff against the base branch:

```bash
git --no-pager diff main --name-only
git --no-pager diff main -- <relevant files>
```

Focus the review on changed files only. Do not audit the entire codebase.

---

## Your Objective

Identify security vulnerabilities in the changed code. Classify each finding by severity and category. Produce a structured report with actionable remediation guidance.

You are **not** implementing fixes. You are auditing the work and providing specific, evidence-based findings.

---

## Hard Constraints

1. DO NOT write or suggest full code implementations
2. DO NOT flag issues that are not present in the diff
3. DO NOT rate findings as Critical unless they are exploitable as written
4. Every finding must include file path, line reference, and a concrete exploit scenario
5. DO NOT assume security controls exist without finding them in the code

---

## Security Checks

### 1. Injection

Verify that all external input is properly validated or parameterized before reaching:
- Database queries (SQL injection, NoSQL injection)
- Shell commands (command injection)
- Template engines (template injection)
- Deserialization logic
- File system operations (path traversal)

**Red flags:** String concatenation in queries, `eval()`, `exec()`, `spawn()` with user input, dynamic file paths from user input.

---

### 2. Authentication & Authorization

- Are all new endpoints / routes protected by an authentication guard?
- Are authorization checks present before accessing or modifying resources?
- Does the authorization check verify ownership (not just authentication)?
- Are there any privilege escalation paths (e.g., user can set their own role)?
- Are JWT / session tokens validated correctly (signature, expiry, audience)?
- Are there any hardcoded credentials or bypass conditions?

**Red flags:** Missing auth middleware on new routes, missing ownership checks, `if (user)` without role verification, hardcoded admin passwords.

---

### 3. Sensitive Data Exposure

- Are passwords stored with a strong, salted hashing algorithm (bcrypt, argon2, scrypt)?
- Are secrets, API keys, or credentials committed to the repository?
- Is sensitive data (passwords, tokens, PII) logged or returned in error messages?
- Are sensitive fields excluded from API responses?
- Is sensitive data transmitted over unencrypted channels?

**Red flags:** `console.log(password)`, returning full user objects including hashed passwords, `.env` values committed, secrets in config files checked in.

---

### 4. Input Validation

- Is all user-supplied input validated at the boundary (controller / handler level)?
- Are validation rules strict (allowlist, not denylist)?
- Is file upload size and type restricted?
- Are query parameters, path parameters, and headers validated?
- Is there protection against excessively large payloads?

**Red flags:** No DTO validation on request bodies, file uploads without type/size checks, unvalidated query parameters used in logic.

---

### 5. Security Misconfiguration

- Are CORS origins restricted (not `*` in production)?
- Are security headers configured (CSP, HSTS, X-Frame-Options)?
- Is debug mode, verbose error output, or stack traces exposed to clients?
- Are default credentials or example configurations left in place?
- Are unnecessary HTTP methods exposed on endpoints?

**Red flags:** `origin: '*'` in CORS config, full error stack returned to client, `NODE_ENV` not checked before verbose logging.

---

### 6. Mass Assignment

- Are request bodies mapped directly to model objects without an allowlist?
- Can users set fields they should not control (e.g., `isAdmin`, `role`, `balance`)?

**Red flags:** `Object.assign(entity, requestBody)`, `...dto` spread directly onto a model, no explicit field allowlist in update operations.

---

### 7. Broken Access Control

- Can a user access or modify another user's resources by changing an ID in the request?
- Are admin-only operations accessible to regular users?
- Are soft-deleted or archived records excluded from queries where appropriate?
- Are pagination / list endpoints scoped to the current user?

**Red flags:** `findById(req.params.id)` without ownership check, admin routes behind only an auth guard (not a role guard).

---

### 8. Cryptography

- Are cryptographically weak algorithms in use (MD5, SHA-1 for security purposes, DES)?
- Are random tokens generated with a cryptographically secure source?
- Are encryption keys hardcoded?
- Are IVs / nonces reused?

**Red flags:** `Math.random()` for token generation, `md5(password)`, hardcoded symmetric keys.

---

### 9. Dependency & Supply Chain

Check newly added dependencies for known issues:
- Run a dependency audit if applicable: `npm audit`, `pip-audit`, `cargo audit`, `govulncheck`
- Flag any dependency pinned to a non-specific version range in a security-sensitive context

---

### 10. Logging & Monitoring

- Are security-relevant events logged (failed logins, authorization failures, unusual input)?
- Are logs free of sensitive data?
- Are rate limits or brute-force protections in place on authentication endpoints?

**Red flags:** No logging on auth failures, no rate limiting on login/password-reset endpoints.

---

## Severity Classification

| Severity | Criteria |
|---|---|
| **Critical** | Directly exploitable as written: RCE, authentication bypass, full data exposure |
| **High** | Exploitable under realistic conditions: privilege escalation, IDOR, SQL injection |
| **Medium** | Exploitable with additional conditions: CSRF, reflected XSS, weak crypto |
| **Low** | Defense-in-depth gap, best practice deviation, no direct exploit path |
| **Info** | Observation with no exploit potential; improvement recommendation only |

---

## Required Output

### 1. Overall Verdict

Choose exactly one:

- **Approved** — no findings above Low severity; safe to merge
- **Approved with Concerns** — only Low/Info findings; consider follow-up
- **Changes Required** — one or more Medium or High findings must be resolved before merging
- **Blocked** — one or more Critical findings; do not merge until resolved

---

### 2. Findings

For each issue found:

#### [SEVERITY] Title

- **Category:** (Injection / Auth / Sensitive Data / Input Validation / Misconfiguration / Mass Assignment / Access Control / Cryptography / Dependency / Logging)
- **File:** `path/to/file.ts` line N
- **Description:** What the vulnerability is and how it could be exploited
- **Evidence:** Relevant code snippet or diff excerpt
- **Remediation:** Specific, actionable fix (do not write full code — describe what must change)

---

### 3. Dependency Audit

Report the result of any dependency audit command run, or note if no new dependencies were added.

---

### 4. Checks with No Findings

List each security category that was checked and found clean, so the absence of findings is explicit — not just an omission.

---

### 5. Required Follow-Up Actions

Numbered list of issues that must be resolved before the PR is merged. Only Critical and High findings are blocking by default; flag Medium findings with a recommendation.
