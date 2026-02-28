# Dev Workflow: Review Scenario

## Metadata
```yaml
name: dev-review
category: dev-workflow
trigger: Review implemented code
participants:
  - Team Lead (orchestrator)
  - code-reviewer (quality + design compliance)
  - security-reviewer (OWASP + PII/PHI)
duration: 15-30 minutes
skills:
  - auto:{project}-patterns
  - code-quality/refactoring-patterns
  - security/owasp-top-10
  - security/security-audit-checklist
team_execution: true
```

## Skills Usage in This Scenario

1. **{project}-patterns**: Both reviewers apply project-specific conventions and patterns
2. **code-quality/refactoring-patterns**: Quality reviewer uses for structural and maintainability analysis
3. **security/owasp-top-10**: Security reviewer uses for vulnerability scanning against OWASP categories
4. **security/security-audit-checklist**: Security reviewer uses for comprehensive security audit
5. **coding-style**: Quality reviewer applies PHP 8.3 / Symfony 6.4 standards (loaded from rules)
6. **testing**: Quality reviewer checks coverage requirements per area (loaded from rules)
7. **database**: Quality reviewer checks N+1, pagination, transactions (loaded from rules)
8. **messaging**: Quality reviewer checks handler idempotency, error types (loaded from rules)

## Situation

### Description
Fifth step of the `/dev` workflow. This is a FULL-SCOPE review of all implemented code, distinct from the per-phase review that happens during the Implement step. The per-phase review in step 4 catches issues within each phase; this review examines the complete implementation holistically -- looking for cross-phase inconsistencies, overall design compliance, and systemic security concerns. Two reviewers work in parallel: quality + security. The Team Lead orchestrates, merges findings, and produces the final REVIEW.md. This step can also run standalone via `/dev --step review`.

### Common Triggers
- Automatic progression from Implement step (all phases complete)
- `/dev --step review` (standalone full-scope review on any code)
- "Review all implemented code"
- "Final review before PR"
- "Full review of [feature]"

### Wellness/Fitness Tech Context
- **PII/PHI full audit**: Security reviewer scans ALL new code for health data exposure -- logs, error messages, API responses, test fixtures
- **Integration security**: New external API integrations require credential management review, token storage audit, webhook signature verification
- **Billing compliance**: Payment-related code requires idempotency and failure handling review across all phases
- **Cross-phase consistency**: Naming conventions, error handling patterns, and logging patterns must be consistent across all implementation phases
- **Data flow security**: End-to-end data flow from API input to database storage reviewed for injection, validation, and encryption
- **Coverage thresholds**: Health data processing >= 85%, billing >= 90%, message handlers >= 80%, API endpoints >= 75%

---

## Participants

### Required
| Role/Agent | Model | Purpose in Scenario |
|------------|-------|---------------------|
| Team Lead (orchestrator) | opus | Spawns reviewers in parallel, merges findings, produces REVIEW.md, determines verdict |
| quality (code-reviewer) | sonnet | Full-scope code quality review: cross-phase consistency, design compliance, test coverage, coding standards |
| security (security-reviewer) | sonnet | Full-scope security review: OWASP Top 10, PII/PHI protection, auth/authz, credential management |

### Optional
| Role/Agent | When to Include |
|------------|-----------------|
| decision-challenger | When implementation involved significant architectural choices -- challenges whether they hold up under scrutiny |

---

## Process Flow

### Phase 1: REVIEW (Parallel)
**Duration**: 10-20 minutes
**Lead**: quality + security (parallel execution)

**Track A -- Quality Reviewer (code-reviewer)**:
1. Read `.workflows/design/DESIGN.md` for design intent
2. Read `.workflows/implement/PROGRESS.md` for implementation history and file list
3. Read ALL new/modified code files (from PROGRESS.md)
4. Review for:
   - **Design compliance**: Does implementation match DESIGN.md and ADRs?
   - **Cross-phase consistency**: Naming, error handling, logging patterns consistent across all phases
   - **Code quality**: PHP 8.3 standards, readonly, enums, attributes, type safety
   - **Architecture**: No N+1 queries, proper pagination, explicit transactions, single flush
   - **Patterns**: Consistent use of Repository, Service, Handler patterns
   - **Tests**: Coverage adequate per area, edge cases covered, mocks used correctly
   - **Messaging**: Handler idempotency, proper exception types (Recoverable/Unrecoverable)
5. Categorize findings:
   - **BLOCKING**: Must fix before PR (security issues, broken functionality, missing tests)
   - **SUGGESTION**: Improve but not blocking (naming, minor refactoring, style)

**Track B -- Security Reviewer (security-reviewer)**:
1. Read `.workflows/design/DESIGN.md` for security-relevant decisions
2. Read ALL new/modified code files
3. Apply OWASP Top 10 checklist:
   - A01: Broken Access Control (missing auth checks, IDOR, privilege escalation)
   - A02: Cryptographic Failures (health data not encrypted, weak hashing)
   - A03: Injection (SQL injection, command injection, XSS)
   - A04: Insecure Design (missing rate limiting, no input validation)
   - A05: Security Misconfiguration (debug mode, default credentials, verbose errors)
   - A06: Vulnerable Components (outdated dependencies with known CVEs)
   - A07: Authentication Failures (weak tokens, no expiry, missing validation)
   - A08: Data Integrity Failures (unsigned webhooks, missing CSRF, no signature verification)
   - A09: Logging Failures (PII in logs, missing audit trail)
   - A10: SSRF (unvalidated URLs, internal resource access)
4. PII/PHI specific checks:
   - Health data (weight, calories, heart rate) NOT in logs or error messages
   - User IDs hashed in log entries (not plain text)
   - Health metrics NOT in API error responses
   - Test fixtures do NOT contain real health data
   - Proper data masking in structured logging
5. Categorize findings:
   - **BLOCKING**: Security vulnerabilities that must be fixed
   - **WARNING**: Potential issues that need investigation
   - **INFO**: Security observations for awareness

**Output (Track A)**: Quality review findings
**Output (Track B)**: Security review findings
**Gate**: Team Lead waits for both reviews to complete

### Phase 2: COMPILE
**Duration**: 5-10 minutes
**Lead**: Team Lead (orchestrator)

Steps:
1. Read both reviewer outputs
2. Merge findings into unified REVIEW.md:
   - **Blocking Issues** section (from both reviewers -- must fix)
   - **Suggestions** section (quality improvements -- optional)
   - **Security** section (all security findings with OWASP category and severity)
3. De-duplicate: if both reviewers flagged the same issue, merge into single entry
4. Prioritize blocking issues by severity (Critical > High > Medium)
5. Add Design Compliance section (from quality reviewer)
6. Add Test Coverage Assessment section (from quality reviewer)
7. Determine verdict:
   - **APPROVED**: Zero blocking issues -- proceed to PR step
   - **BLOCKED**: Blocking issues exist -- redirect to Implement step for fixes
8. Shutdown reviewer teammates

**Output**: `.workflows/review/{feature-slug}/REVIEW.md`

---

## REVIEW.md Format

```markdown
# Code Review: {Feature Name}

## Summary
- **Verdict**: APPROVED | BLOCKED
- **Quality Score**: {1-10}
- **Security Score**: {1-10}
- **Files Reviewed**: {count}
- **Blocking Issues**: {count}
- **Suggestions**: {count}
- **Security Findings**: {count}

---

## Blocking Issues
Issues that MUST be fixed before creating a PR.

### BLK-1: {Title}
**Source**: Quality | Security
**Severity**: Critical | High
**File**: `{file_path}:{line}`
**Rule**: {which rule violated -- security.md, coding-style.md, etc.}
**Description**: {what is wrong}
**Fix**: {how to fix}

### BLK-2: {Title}
...

---

## Suggestions
Improvements that would benefit the codebase but are not blocking.

### SUG-1: {Title}
**Source**: Quality
**File**: `{file_path}:{line}`
**Description**: {what could be improved}
**Reason**: {why it matters}

### SUG-2: {Title}
...

---

## Security

### OWASP Check Results
| Check | Status | Notes |
|-------|--------|-------|
| A01: Broken Access Control | PASS/FAIL | {details} |
| A02: Cryptographic Failures | PASS/FAIL | {details} |
| A03: Injection | PASS/FAIL | {details} |
| A04: Insecure Design | PASS/FAIL | {details} |
| A05: Security Misconfiguration | PASS/FAIL | {details} |
| A06: Vulnerable Components | PASS/FAIL | {details} |
| A07: Authentication Failures | PASS/FAIL | {details} |
| A08: Data Integrity Failures | PASS/FAIL | {details} |
| A09: Logging Failures | PASS/FAIL | {details} |
| A10: SSRF | PASS/FAIL | {details} |

### PII/PHI Audit
| Check | Status | Notes |
|-------|--------|-------|
| Health data not in logs | PASS/FAIL | {details} |
| Personal identifiers masked | PASS/FAIL | {details} |
| Encryption at rest | PASS/FAIL | {details} |
| User ownership checked | PASS/FAIL | {details} |

### Secrets Scan
- {result}

---

## Design Compliance
How well the implementation matches the approved design.

| Design Element | Status | Notes |
|----------------|--------|-------|
| {ADR-001 decision} | Compliant / Deviation | {details} |
| {Component X} | Compliant / Deviation | {details} |
| {API contract Y} | Compliant / Deviation | {details} |

---

## Test Coverage Assessment
| Area | Required | Actual | Status |
|------|----------|--------|--------|
| Health data processing | 85% | {X}% | PASS/FAIL |
| Billing/Payment | 90% | {X}% | PASS/FAIL |
| Message handlers | 80% | {X}% | PASS/FAIL |
| API endpoints | 75% | {X}% | PASS/FAIL |
| General code | 70% | {X}% | PASS/FAIL |

### Coverage Gaps (if any)
- {class/method} missing {type} test

---

## Cross-Phase Consistency
| Aspect | Status | Notes |
|--------|--------|-------|
| Naming conventions | Consistent / Inconsistent | {details} |
| Error handling patterns | Consistent / Inconsistent | {details} |
| Logging patterns | Consistent / Inconsistent | {details} |
| No unnecessary duplication | Yes / No | {details} |
```

---

## Team-Based Execution

### Team Setup

```
Team Lead creates team:
  team_name: "dev-review-{feature-slug}"
  description: "Full-scope review for {task description}"
```

### Teammates

| Name | Agent File | subagent_type | Model | Focus |
|------|-----------|---------------|-------|-------|
| quality | code-reviewer | code-reviewer | sonnet | Quality + Design compliance |
| security | security-reviewer | security-reviewer | sonnet | OWASP + PII/PHI |

### Phase Execution

```
Phase 1 (REVIEW):
  Team Lead spawns "quality" and "security" IN PARALLEL
  quality reads design + progress + code, produces quality findings
  security reads design + code, produces security findings
  Both write to shared context (no file conflicts -- different focus areas)
  Team Lead waits for BOTH to complete

Phase 2 (COMPILE):
  Team Lead reads both reviewer outputs
  Team Lead de-duplicates and merges findings
  Team Lead creates .workflows/review/{feature-slug}/REVIEW.md
  Team Lead sends shutdown_request to both reviewers
  Calls TeamDelete to clean up

If BLOCKED:
  Team Lead lists blocking issues with fix instructions
  Control redirects to Implement step
  After fixes, Review step re-runs with fresh reviewers
```

### Task List Structure

```
1. [quality] Full quality + design compliance + test coverage review
2. [security] Full OWASP + PII/PHI security review
3. [lead] Compile REVIEW.md from both findings
4. [lead] Verdict: approve for PR or redirect to implement
```

### Communication Pattern

- **Team Lead -> reviewers**: Code files + design artifacts for context
- **quality -> Team Lead**: Quality findings (blocking, suggestions) with file:line references
- **security -> Team Lead**: Security findings (blocking, warning, info) with OWASP categories
- **Team Lead -> Implement step**: Blocking issues list (if BLOCKED verdict)
- **Team Lead -> PR step**: REVIEW.md with APPROVED verdict (if no blocking issues)

---

## Standalone Mode

This step can run independently via `/dev --step review`:

```
/dev --step review

Behavior in standalone mode:
- File discovery: uses git diff instead of PROGRESS.md
- Design compliance: only if .workflows/design/ exists (skips otherwise)
- Plan compliance: only if .workflows/plan/ exists (skips otherwise)
- Full quality + security review still performed
- Output: .workflows/review/{slug}/REVIEW.md
- Does NOT trigger redirect to Implement (report only)
```

| Aspect | Pipeline Mode | Standalone Mode |
|--------|---------------|-----------------|
| File discovery | PROGRESS.md | git diff |
| Design compliance | Yes (required) | Only if artifacts exist |
| Plan compliance | Yes (required) | Only if artifacts exist |
| Blocking -> Implement redirect | Yes | No (report only) |
| Output location | .workflows/review/{slug}/ | .workflows/review/{slug}/ |

---

## Decision Points

### Decision 1: Blocking Threshold
**Question**: What severity level blocks the PR?
**Options**:
- A: Only Critical security issues -- permissive
- B: All security issues + critical quality issues -- balanced (default)
- C: All issues including suggestions -- strict

**Recommended approach**: B for most features. C for billing/payment features.

### Decision 2: Coverage Enforcement
**Question**: How strictly to enforce coverage thresholds?
**Options**:
- A: Advisory -- report but do not block
- B: Blocking for critical areas (health data, billing) only (default)
- C: Blocking for all areas

**Recommended approach**: B -- block only when coverage is below threshold for sensitive areas.

### Decision 3: Fix Cycle
**Question**: What happens when blocking issues are found?
**Options**:
- A: Return to full Implement step -- developer fixes, full re-review of everything
- B: Targeted fix -- developer fixes specific issues, re-review only fixes (default)
- C: Fix and proceed -- developer fixes, skip re-review

**Recommended approach**: B for most cases. A for fundamental design issues. Never C.

---

## Prompts Sequence

### Quality Review Prompt
**Use Agent**: code-reviewer
**Prompt**:
```
[IDENTITY]
You are the Quality Reviewer performing a FULL-SCOPE review for the /dev workflow.
This is NOT a per-phase review -- this is a holistic review of ALL implemented code.

[CONTEXT]
Task: {{task_description}}
Design: .workflows/design/DESIGN.md
ADRs: .workflows/design/adr/*.md
Contracts: .workflows/design/api-contracts.md
Progress: .workflows/implement/PROGRESS.md

[RULES TO APPLY]
- rules/coding-style.md: PHP 8.3 / Symfony 6.4 standards
- rules/testing.md: Coverage thresholds per area
- rules/database.md: Query performance, N+1, pagination, transactions
- rules/messaging.md: Handler idempotency, error types

[TASK]
1. Read ALL files listed in PROGRESS.md
2. Review CROSS-PHASE CONSISTENCY:
   - Naming conventions consistent across all new files
   - Error handling patterns consistent (same exception approach)
   - Logging format consistent
   - No unnecessary duplication across phases
3. Review DESIGN COMPLIANCE:
   - Architecture matches DESIGN.md
   - API matches api-contracts.md
   - ADR decisions followed in code
   - No unauthorized scope creep
4. Review TEST COVERAGE:
   - Coverage meets thresholds per area (health 85%, billing 90%, handlers 80%, API 75%)
   - Edge cases covered (null, zero, negative, boundary)
   - Integration tests with mocked external APIs
   - Functional tests for API endpoints
   - Idempotency tests for message handlers
5. Review CODE QUALITY:
   - PHP 8.3 standards (type declarations, readonly, enums, attributes)
   - No N+1 queries, list endpoints paginated
   - Explicit transactions for multi-entity operations
   - Single flush per request/handler

[OUTPUT]
## Quality Review Findings

### Blocking Issues
| ID | Severity | File:Line | Issue | Fix |
|----|----------|-----------|-------|-----|

### Suggestions
| ID | File:Line | Issue | Suggestion |
|----|-----------|-------|------------|

### Design Compliance
| Element | Status | Notes |
|---------|--------|-------|

### Test Coverage
| Component | Tests | Coverage | Assessment |
|-----------|-------|----------|------------|

### Cross-Phase Consistency
| Aspect | Status | Notes |
|--------|--------|-------|
```

### Security Review Prompt
**Use Agent**: security-reviewer
**Prompt**:
```
[IDENTITY]
You are the Security Reviewer performing a FULL-SCOPE security audit for the /dev workflow.
You are paranoid by default. Health data = high stakes.

[CONTEXT]
Task: {{task_description}}
Design: .workflows/design/DESIGN.md (security-relevant sections)
Files: all files from .workflows/implement/PROGRESS.md

[RULES TO APPLY]
- rules/security.md: PII/PHI protection, auth, encryption

[TASK]
Security audit ALL new/modified code.

1. OWASP Top 10 on every file:
   - A01: Broken Access Control -- auth on every endpoint, no IDOR
   - A02: Cryptographic Failures -- health data encrypted (AES-256)
   - A03: Injection -- parameterized queries, no raw SQL, no command injection
   - A04: Insecure Design -- rate limiting, input validation
   - A05: Security Misconfiguration -- no debug, no defaults
   - A06: Vulnerable Components -- outdated deps
   - A07: Auth Failures -- token validation, expiry
   - A08: Data Integrity -- webhook signatures, CSRF
   - A09: Logging Failures -- no PII/PHI in logs
   - A10: SSRF -- URL validation

2. PII/PHI AUDIT:
   - Health metrics (weight, calories, heart rate) NOT in logs
   - Personal identifiers (email, phone) NOT in logs
   - User IDs hashed in log entries
   - Health data encrypted at rest
   - User ownership validated before data access
   - Test fixtures contain no real health data

3. SECRETS SCAN:
   - No hardcoded credentials or API keys
   - Environment variables for all secrets

[OUTPUT]
## Security Review Findings

### Blocking (Must Fix)
| ID | OWASP | Severity | File:Line | Vulnerability | Remediation |
|----|-------|----------|-----------|---------------|-------------|

### Warnings (Investigate)
| ID | OWASP | Severity | File:Line | Concern | Action |
|----|-------|----------|-----------|---------|--------|

### Info (Awareness)
| ID | Category | File:Line | Observation |
|----|----------|-----------|-------------|

### PII/PHI Audit
| Check | Status | Details |
|-------|--------|---------|
```

### Compile Prompt (Team Lead)
**Prompt**:
```
[TASK]
Merge quality and security review findings into REVIEW.md.

1. Read quality reviewer output
2. Read security reviewer output
3. De-duplicate: if both flagged the same issue, merge into single entry
4. Create .workflows/review/{feature-slug}/REVIEW.md using the format above
5. Score quality (1-10) and security (1-10)
6. Determine verdict:
   - APPROVED if zero blocking issues
   - BLOCKED if any blocking issues exist

If BLOCKED: list specific fixes needed and redirect to Implement step.
If APPROVED: confirm readiness for PR step.
```

---

## Success Criteria

### Minimum Viable Outcome
- [ ] Both quality and security reviews completed
- [ ] REVIEW.md exists with clear verdict (APPROVED or BLOCKED)
- [ ] All blocking issues have file:line references and fix suggestions
- [ ] Security findings categorized by OWASP category

### Good Outcome
- [ ] Design compliance checked against all ADRs and api-contracts
- [ ] Test coverage assessed against thresholds per area
- [ ] Cross-phase consistency verified (naming, patterns, error handling)
- [ ] PII/PHI audit completed with specific findings per check
- [ ] De-duplication applied (no repeated findings)

### Excellent Outcome
- [ ] APPROVED verdict on first review (no blocking issues)
- [ ] Zero security vulnerabilities found
- [ ] Quality and security scores above 8/10
- [ ] Suggestions section provides actionable improvements for future work
- [ ] Review catches cross-phase issues that per-phase reviews missed

---

## Anti-Patterns

### What to Avoid

1. **Duplicating Per-Phase Review**: This review is NOT a repeat of the Implement step reviews. Focus on cross-phase concerns, holistic patterns, and systemic issues that per-phase reviews cannot catch.

2. **Sequential Reviews**: Running quality review then security review sequentially. They examine different aspects of the same code -- always run in parallel.

3. **Blocking on Style**: Marking minor style preferences as BLOCKING. Only security vulnerabilities, broken functionality, and missing critical tests should block.

4. **Security Theater**: Running OWASP checks superficially without tracing actual data flow from input to storage. Security review must read the code paths, not just check for keyword patterns.

5. **Review Without Design Context**: Reviewing code without reading DESIGN.md and ADRs. The review must check design compliance -- this requires knowing the design.

6. **No Actionable Feedback**: Writing "this is bad" without "fix by doing X." Every blocking issue must include a specific fix suggestion with file and line reference.

7. **Approving With Open Security Issues**: Marking APPROVED when there are unresolved security warnings. Every security finding must have a disposition (fixed, accepted risk with justification, or false positive).

### Warning Signs
- Review took less than 5 minutes -- not thorough enough
- Zero findings of any kind -- not looking hard enough (every implementation has at least suggestions)
- Security review only found "no hardcoded passwords" -- OWASP checklist not fully applied
- Quality review does not mention design compliance -- DESIGN.md not read
- REVIEW.md has no file:line references -- findings are abstract, not actionable
- Same issues found here that were already caught in per-phase review -- per-phase review was ineffective

---

## Example Walkthrough

### Context
Task: "Add Apple Health integration to the wellness-backend"
All 4 implementation phases complete. PROGRESS.md shows 15 tests, 10 new files, 2 modified files.

### How It Played Out

**Phase 1 (REVIEW -- parallel)**:
```
Track A (Quality Reviewer):
  Design compliance:
    - ADR-001 (device-token auth): Compliant
    - ADR-002 (push-based sync): Compliant
    - ADR-003 (existing entity mapping): Compliant
    - API contracts: all 3 endpoints match

  Cross-phase consistency:
    - Naming: all Apple Health classes in src/Service/Integration/AppleHealth/ (consistent)
    - Error handling: INCONSISTENT -- Client uses AppleHealthException,
      Handler uses generic \RuntimeException
    - Logging: structured format used consistently

  Test coverage:
    - Health data processing: 87% (target 85%) -- adequate
    - Message handlers: 92% (target 80%) -- adequate
    - API endpoints: 85% (target 75%) -- adequate
    - Gap: missing test for concurrent sync attempts in SyncHandler

  Quality findings:
    - BLK-1: AppleHealthSyncHandler catches generic Exception instead of
      specific exceptions (should use Recoverable/Unrecoverable)
      File: src/MessageHandler/AppleHealthSyncHandler.php:45
    - SUG-1: Client and Handler use different exception types --
      standardize to AppleHealthException hierarchy
    - SUG-2: AppleHealthMapper could use match() instead of switch()

Track B (Security Reviewer):
  OWASP findings:
    - SEC-1 [BLOCKING] A08 Data Integrity:
      Webhook controller validates signature but does not check timestamp
      -> replay attacks possible
      File: src/Controller/Api/V1/Integration/AppleHealthWebhookController.php:32
      Remediation: Add timestamp validation (reject if > 5 min old)

    - SEC-2 [WARNING] A09 Logging:
      AppleHealthMapper logs workout data at DEBUG level
      -> health metrics (calories, duration) visible in debug logs
      File: src/Service/Integration/AppleHealth/AppleHealthMapper.php:67
      Action: Mask health data in log entries or remove DEBUG log

    - SEC-3 [INFO] Auth:
      Device token stored in IntegrationToken entity with symmetric encryption
      -> adequate for current threat model

  PII/PHI audit:
    - Health data not in logs: FAIL (SEC-2)
    - Personal identifiers masked: PASS
    - Encryption at rest: PASS
    - User ownership checked: PASS
    - Test fixtures: no real health data found -- PASS
```

**Phase 2 (COMPILE)**:
```
Team Lead merges findings:

REVIEW.md:
  Verdict: BLOCKED (2 blocking issues)
  Quality Score: 7/10
  Security Score: 6/10
  Blocking Issues: 2
  Suggestions: 2
  Security Findings: 3

  Blocking Issues:
    BLK-1: Generic Exception in SyncHandler (Quality)
      File: src/MessageHandler/AppleHealthSyncHandler.php:45
      Fix: Replace catch(\Exception) with specific Recoverable/Unrecoverable types
    BLK-2: Missing webhook timestamp validation -- replay attack (Security, SEC-1)
      File: src/Controller/Api/V1/Integration/AppleHealthWebhookController.php:32
      Fix: Add timestamp check, reject payloads older than 5 minutes

  Suggestions:
    SUG-1: Standardize exception hierarchy across Client and Handler
    SUG-2: Use match() in AppleHealthMapper

  Security:
    SEC-1: [BLOCKING] Webhook replay attack (A08)
    SEC-2: [WARNING] Health data in debug logs (A09)
    SEC-3: [INFO] Token encryption adequate

  -> Redirect to Implement: fix BLK-1, BLK-2, SEC-2 (elevated to blocking)
```

**After fixes and re-review**:
```
Developer fixes:
  - BLK-1: Replaced generic Exception with RecoverableMessageHandlingException
    and UnrecoverableMessageHandlingException
  - BLK-2: Added timestamp validation in webhook controller
  - SEC-2: Masked health data in AppleHealthMapper debug logs

Re-review (targeted):
  BLK-1: Fixed -- specific exception types used
  BLK-2: Fixed -- timestamp validation added, 5-min window
  SEC-2: Fixed -- health data masked in logs

Updated REVIEW.md:
  Verdict: APPROVED
  Quality Score: 9/10
  Security Score: 9/10
  Blocking Issues: 0
```

### Outcome
- Full-scope review caught 2 blocking issues missed by per-phase review:
  - Generic exception handling (cross-phase pattern inconsistency)
  - Webhook replay attack (requires holistic view of auth flow)
- Security warning about debug logging caught early (PII/PHI audit value)
- Design compliance verified against all 3 ADRs
- Total time: ~25 minutes (first review + fixes + re-review)

---

## Related

- **Previous step**: [4-implement.md](./4-implement.md) -- Phase-by-phase implementation
- **Next step**: [6-document.md](./6-document.md) -- Documentation generation
- **Redirect to**: [4-implement.md](./4-implement.md) -- When blocking issues found
- **Agent files**: [code-reviewer](../../agents/code-reviewer.md), [security-reviewer](../../agents/security-reviewer.md)
- **Skills**: [refactoring-patterns](../../skills/code-quality/refactoring-patterns.md), [owasp-top-10](../../skills/security/owasp-top-10.md), [security-audit-checklist](../../skills/security/security-audit-checklist.md)
- **Input**: `.workflows/design/`, `.workflows/implement/PROGRESS.md`, code files
- **Output**: `.workflows/review/{feature-slug}/REVIEW.md`
- **Feedback loop**: If BLOCKED verdict -> redirect to Implement step for fixes, then re-review
