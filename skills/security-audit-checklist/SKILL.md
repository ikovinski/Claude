---
name: security-audit-checklist
description: Comprehensive security audit checklist with tech-specific items. Used by Security Reviewer during /implement and /design phases. Covers auth, input validation, data protection, API, secrets, dependencies, logging, payments, health data, infrastructure.
version: 1.0.0
---

# Security Audit Checklist Skill

Comprehensive checklist for Security Reviewer agent. Use during code review to verify all security aspects. Select relevant sections based on changed files.

## When This Skill Applies

- Security Reviewer during `/implement` phase (Phase 4 of review workflow)
- Security Reviewer in `/design` phase (optional security review)
- Standalone security audit
- Pre-release security checklist verification

## How to Use

Do NOT check every item on every review. Select sections relevant to the changed files:

| Changed Files | Relevant Sections |
|--------------|-------------------|
| New API endpoints | Authentication, API Security, Input Validation |
| Database/query changes | Input Validation (injection), Data Protection |
| Config/env changes | Secrets & Configuration |
| Payment/billing code | Financial Operations, Data Protection |
| Health/user data | Health Data, Data Protection, Logging |
| Dependency updates | Dependencies & Supply Chain |
| Auth code | Authentication, Logging |
| Infrastructure/deploy | Infrastructure & Deployment |

## Authentication & Authorization

- [ ] Authentication required for all sensitive endpoints
- [ ] JWT tokens have expiration and are validated server-side
- [ ] Refresh tokens rotated after use
- [ ] Password hashing uses bcrypt/argon2id (not MD5/SHA)
- [ ] Rate limiting on login endpoints
- [ ] Account lockout / progressive delay after failed attempts
- [ ] 2FA available for admin/sensitive accounts
- [ ] Session invalidation on logout
- [ ] Role-based access control (RBAC) implemented
- [ ] Authorization checked on every request (not just frontend)
- [ ] Ownership validation for resource access (IDOR prevention)
- [ ] Deny by default — explicitly grant access

### Tech-Specific

#### PHP/Symfony
- [ ] Symfony Voters for authorization logic
- [ ] `#[IsGranted]` or `$this->denyAccessUnlessGranted()` on endpoints
- [ ] Firewall configuration covers all routes
- [ ] Remember-me tokens use `%kernel.secret%`

#### Node/JS
- [ ] Auth middleware applied to protected routes
- [ ] JWT secret stored in environment variable
- [ ] Session cookies have `secure`, `httpOnly`, `sameSite` flags
- [ ] Passport.js / custom auth properly configured

#### Go
- [ ] Auth middleware in router chain
- [ ] Context-based user extraction
- [ ] Token validation on every handler

---

## Input Validation

- [ ] All user input validated before use
- [ ] Type validation (string, int, email, UUID)
- [ ] Length limits on text fields
- [ ] Whitelist validation for enums/choices
- [ ] File uploads check MIME type, extension, and size
- [ ] SQL injection prevention (parameterized queries / ORM)
- [ ] XSS prevention (output escaping / auto-escape templates)
- [ ] CSRF tokens on state-changing requests (non-API)
- [ ] Request body size limits configured
- [ ] Array/object depth limits on JSON parsing

### Tech-Specific

#### PHP/Symfony
- [ ] Symfony Validator constraints on DTOs
- [ ] `ParamConverter` for type-safe route parameters
- [ ] Twig auto-escaping enabled (default)
- [ ] `|raw` filter used only with sanitized content

#### Node/JS
- [ ] Express `express.json({ limit: '100kb' })` configured
- [ ] Validation library (Joi, Zod, class-validator) on all inputs
- [ ] Template engine auto-escaping enabled
- [ ] `innerHTML` never used with user content

---

## Data Protection

- [ ] PII/PHI encrypted at rest (AES-256 or database-level encryption)
- [ ] TLS 1.2+ for all data in transit (prefer 1.3)
- [ ] Sensitive data NOT in logs (emails, passwords, health data, tokens)
- [ ] API keys and secrets in environment variables
- [ ] Database credentials in secure config (not hardcoded)
- [ ] No hardcoded secrets in codebase
- [ ] Data retention policies implemented
- [ ] GDPR/privacy compliance for user data
- [ ] Sensitive data not in URL query parameters
- [ ] Error messages do not expose PII or internal details

---

## API Security

- [ ] API rate limiting implemented (per user/IP)
- [ ] Request size limits configured
- [ ] CORS properly configured (not `Access-Control-Allow-Origin: *` for authenticated APIs)
- [ ] Error responses do not show stack traces
- [ ] Pagination on list endpoints (prevent mass data extraction)
- [ ] Sorting/filtering parameters validated (prevent injection via orderBy)
- [ ] API versioning strategy in place
- [ ] Deprecated endpoints documented and scheduled for removal
- [ ] Webhook signatures validated (HMAC)
- [ ] Third-party API responses validated before use

---

## Secrets & Configuration

- [ ] No hardcoded credentials in code
- [ ] No secrets in git history (check with `git log -S "password"`)
- [ ] `.env` files in `.gitignore`
- [ ] `.env.example` has placeholder values only
- [ ] Debug mode OFF in production
- [ ] Error pages do not show internal paths or stack traces
- [ ] Secrets managed via Vault / AWS Secrets / GCP Secret Manager
- [ ] Cryptographic keys rotated periodically
- [ ] Default credentials changed

---

## Dependencies & Supply Chain

- [ ] Dependency audit clean (`composer audit` / `npm audit` / `govulncheck`)
- [ ] Dependencies regularly updated
- [ ] Unused dependencies removed
- [ ] Lock files committed and reviewed in PRs
- [ ] Private registry configured for internal packages
- [ ] No dependency confusion risk (internal package names don't collide with public)
- [ ] Security advisories monitored (Dependabot/Renovate)

---

## Logging & Monitoring

- [ ] Login attempts (success + failure) logged
- [ ] Authorization failures logged
- [ ] Sensitive operations logged (payments, data export, role changes)
- [ ] PII/PHI NOT in log messages
- [ ] Logs are centralized and tamper-proof
- [ ] Monitoring alerts for anomalies (spike in 401/403, unusual data access)
- [ ] Incident response process documented

---

## Financial / Payment Operations

- [ ] Webhook signature validation (Stripe, etc.)
- [ ] Idempotent payment processing (deduplication key)
- [ ] Atomic transactions for balance changes (`SELECT FOR UPDATE`)
- [ ] No floating-point for money (use integers / cents)
- [ ] Audit trail for all financial operations
- [ ] Reconciliation checks between systems

---

## Health Data Specific (HIPAA/GDPR)

- [ ] Health metrics encrypted at rest
- [ ] Access logs for PII/PHI queries
- [ ] Data minimization — collect only what's necessary
- [ ] User consent recorded before data collection
- [ ] Right to deletion implemented
- [ ] Data export / portability implemented
- [ ] Breach notification process documented
- [ ] Health data not exposed in logs, errors, or debug output

---

## Infrastructure & Deployment

- [ ] Environment separation (prod/staging/dev)
- [ ] Containers run as non-root
- [ ] Container images scanned for vulnerabilities
- [ ] Network segmentation (DB not publicly accessible)
- [ ] Cloud metadata endpoint protected (IMDSv2)
- [ ] IAM follows least privilege
- [ ] CI/CD pipeline has security scanning step
- [ ] Secrets not passed as build args or visible in container env

---

## Quality Checklist

- [ ] Only relevant sections selected for the review (not all checked blindly)
- [ ] Tech-specific items checked for the project's actual stack
- [ ] Each failed item has a corresponding finding in the review report
- [ ] Passed items actually verified in code (not assumed)
- [ ] Domain-specific sections included when applicable (payments, health data)

## Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| Check everything | Reviewing all 80+ items on a 3-file change | Use "How to Use" table to select relevant sections |
| Blind pass | Marking items as checked without reading code | Each checked item should reference the file/line verified |
| Missing tech-specific | Checking generic items but skipping framework-specific | Always include tech-specific subsection for the project's stack |
| Domain blindness | Skipping Financial/Health sections on payment/health code | Match changed files to domain sections |
| Checklist as output | Dumping the entire checklist in the review report | Report only findings (failed items), not the full checklist |
