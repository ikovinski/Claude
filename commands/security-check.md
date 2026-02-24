---
name: security-check
description: Run security review on code. Checks OWASP Top 10, secrets, PII/PHI exposure. Uses Security Reviewer agent.
allowed_tools: ["Read", "Grep", "Glob", "Bash"]
agent: security-reviewer
---

# /security-check - Security Review

Проводить security review коду з фокусом на OWASP Top 10, secrets, та PII/PHI protection.

## Usage

```bash
/security-check                      # Check staged changes
/security-check <file>               # Check specific file
/security-check src/Controller/      # Check directory
/security-check --full               # Full codebase scan
```

## What It Checks

### OWASP Top 10

| # | Vulnerability | What I Look For |
|---|---------------|-----------------|
| 1 | Injection | SQL, command, LDAP injection |
| 2 | Broken Auth | Weak passwords, missing rate limits |
| 3 | Sensitive Data | PII/PHI in logs, unencrypted data |
| 4 | XXE | Unsafe XML parsing |
| 5 | Broken Access | Missing authorization checks |
| 6 | Misconfig | Debug mode, default credentials |
| 7 | XSS | Unescaped output, raw HTML |
| 8 | Insecure Deserialize | Unsafe unserialize() |
| 9 | Vulnerable Deps | Known CVEs in packages |
| 10 | Logging | Missing audit, exposed errors |

### PHP/Symfony Specific

```php
// SQL Injection
❌ $query = "SELECT * FROM users WHERE id = " . $id;
✅ $this->em->getRepository(User::class)->find($id);

// Command Injection
❌ exec("ping " . $userInput);
✅ Use Symfony Process component with arguments

// XSS
❌ {{ user.bio|raw }}
✅ {{ user.bio }} (auto-escaped)

// Secrets
❌ $apiKey = "sk-xxxx";
✅ $apiKey = $_ENV['API_KEY'];

// Auth Bypass
❌ No #[IsGranted] on sensitive endpoint
✅ #[IsGranted('ROLE_USER')] or Voter
```

### Health Data (PII/PHI)

```php
// ❌ CRITICAL: Health data in logs
$this->logger->info('User stats', [
    'weight' => $user->getWeight(),
    'calories' => $workout->getCalories()
]);

// ✅ CORRECT: Only IDs in logs
$this->logger->info('Workout processed', [
    'workout_id' => $workout->getId()
]);
```

## Automated Scans

I'll run these commands:

```bash
# Check for secrets
grep -rn "password\|secret\|api_key\|token" src/ --include="*.php"

# Check for SQL injection patterns
grep -rn "->query\|->exec\|executeQuery" src/ --include="*.php"

# Composer security audit
composer audit

# PHPStan security rules
vendor/bin/phpstan analyse src/ --level=max
```

## Output Format

```markdown
# Security Review Report

**Scope:** [files/directories reviewed]
**Risk Level:** 🔴 HIGH / 🟡 MEDIUM / 🟢 LOW

## Critical Issues 🔴
[Fix immediately]

### 1. [Vulnerability Type]
**Location:** `src/Controller/ApiController.php:45`
**Category:** SQL Injection
**Impact:** Database compromise, data theft

**Vulnerable Code:**
```php
$query = "SELECT * FROM users WHERE email = '$email'";
```

**Secure Fix:**
```php
$user = $this->userRepository->findOneBy(['email' => $email]);
```

**References:**
- OWASP: A03:2021 Injection
- CWE-89

## High Issues 🟠
[Fix before production]

## Medium Issues 🟡
[Fix when possible]

## Security Checklist

- [ ] No hardcoded secrets
- [ ] All inputs validated
- [ ] SQL injection prevention
- [ ] XSS prevention
- [ ] CSRF protection
- [ ] Rate limiting on auth
- [ ] Health data not in logs
- [ ] Composer audit clean
```

## When to Run

**ALWAYS run when:**
- New API endpoint added
- Authentication code changed
- User input handling added
- Database queries modified
- Payment/billing code changed
- Health data processing changed
- Before production deploy

**IMMEDIATELY run when:**
- Production incident occurred
- CVE announced for dependency
- Penetration test scheduled

---

*Uses [Security Reviewer Agent](../agents/security-reviewer.md)*
