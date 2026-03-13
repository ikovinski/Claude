---
name: owasp-top-10
description: OWASP Top 10 (2021) vulnerability reference with code patterns per tech profile. Used by Security Reviewer during /implement and /design phases. Supplemented with API Security Top 10 (2023) and modern threats.
version: 1.0.0
---

# OWASP Top 10 Skill

Vulnerability reference for Security Reviewer agent. Each category: what it is, VULNERABLE/SECURE code patterns (per tech profile), and a checklist.

> OWASP Top 10 2021 — latest official release. Supplemented with API Security Top 10 (2023) and emerging threats (2024-2025).

## When This Skill Applies

- Security Reviewer checking code during `/implement` phase
- Security Reviewer in `/design` phase (optional security review)
- Any code review involving user input, auth, API endpoints, or sensitive data
- Standalone security audit outside the feature flow

## A01:2021 — Broken Access Control

### What
Users access data/functions beyond their permissions. IDOR, missing ownership checks, privilege escalation.

### Code Patterns

#### PHP/Symfony
```php
// VULNERABLE
public function getUser(int $id): Response {
    return $this->json($this->userRepository->find($id)); // Anyone can access any user
}

// SECURE — Symfony Voter
#[IsGranted('VIEW', subject: 'user')]
public function getUser(User $user): Response {
    return $this->json($user);
}

// SECURE — manual ownership check
public function getWorkout(int $id): Response {
    $workout = $this->workoutRepository->find($id);
    $this->denyAccessUnlessGranted('view', $workout);
    return $this->json($workout);
}
```

#### Node/JS
```javascript
// VULNERABLE
app.get('/api/users/:id', async (req, res) => {
    const user = await User.findById(req.params.id); // No auth check
    res.json(user);
});

// SECURE — ownership middleware
app.get('/api/users/:id', authenticate, authorizeOwner('user'), async (req, res) => {
    res.json(req.resource);
});
```

#### Go
```go
// VULNERABLE
func GetUser(w http.ResponseWriter, r *http.Request) {
    id := chi.URLParam(r, "id")
    user, _ := repo.FindByID(id) // No auth check
    json.NewEncoder(w).Encode(user)
}

// SECURE
func GetUser(w http.ResponseWriter, r *http.Request) {
    currentUser := auth.FromContext(r.Context())
    id := chi.URLParam(r, "id")
    if currentUser.ID != id && !currentUser.IsAdmin() {
        http.Error(w, "Forbidden", http.StatusForbidden)
        return
    }
    user, _ := repo.FindByID(id)
    json.NewEncoder(w).Encode(user)
}
```

### Checklist
- [ ] Authorization checked on EVERY endpoint (not just frontend)
- [ ] Ownership validation for resource access (IDOR prevention)
- [ ] Admin endpoints require admin role
- [ ] CORS properly configured (not `*` for authenticated APIs)
- [ ] JWT/session validated server-side on each request
- [ ] Deny by default — explicitly grant, not explicitly deny

---

## A02:2021 — Cryptographic Failures

### What
Weak or missing encryption for sensitive data. Plaintext passwords, weak hashing, missing TLS.

### Code Patterns

#### PHP/Symfony
```php
// VULNERABLE
$hash = md5($password);       // MD5 not for passwords
$hash = sha1($password);      // SHA1 not for passwords

// SECURE
$hash = password_hash($password, PASSWORD_ARGON2ID);
// or via Symfony PasswordHasher
$hash = $this->passwordHasher->hashPassword($user, $plainPassword);
```

#### Node/JS
```javascript
// VULNERABLE
const hash = crypto.createHash('md5').update(password).digest('hex');

// SECURE
const hash = await bcrypt.hash(password, 12);
// or argon2
const hash = await argon2.hash(password, { type: argon2.argon2id });
```

### Checklist
- [ ] Passwords hashed with bcrypt/argon2id (not MD5/SHA)
- [ ] TLS 1.2+ for all data in transit (prefer 1.3)
- [ ] Sensitive data encrypted at rest (AES-256)
- [ ] API keys/secrets in environment variables, not code
- [ ] No sensitive data in URLs (query params logged by proxies)
- [ ] Cryptographic keys rotated periodically

---

## A03:2021 — Injection

### What
SQL, command, LDAP, ORM injection through unvalidated input.

### Code Patterns

#### PHP/Symfony
```php
// VULNERABLE — SQL injection
$query = "SELECT * FROM users WHERE email = '$email'";
$this->em->getConnection()->executeQuery($query);

// VULNERABLE — DQL injection
$dql = "SELECT u FROM User u WHERE u.name = '" . $name . "'";

// SECURE — Doctrine ORM
$user = $this->userRepository->findOneBy(['email' => $email]);

// SECURE — QueryBuilder with parameters
$qb = $this->createQueryBuilder('u')
    ->where('u.email = :email')
    ->setParameter('email', $email);

// VULNERABLE — Command injection
exec("convert " . $filename . " output.pdf");

// SECURE
$process = new Process(['convert', $filename, 'output.pdf']);
$process->run();
```

#### Node/JS
```javascript
// VULNERABLE — SQL injection
db.query(`SELECT * FROM users WHERE email = '${email}'`);

// SECURE — parameterized
db.query('SELECT * FROM users WHERE email = $1', [email]);

// VULNERABLE — NoSQL injection
User.find({ email: req.body.email }); // Can pass { $gt: "" }

// SECURE
User.find({ email: String(req.body.email) });

// VULNERABLE — command injection
exec(`convert ${filename} output.pdf`);

// SECURE
execFile('convert', [filename, 'output.pdf']);
```

### Checklist
- [ ] All SQL via ORM or parameterized queries (no string concatenation)
- [ ] Command execution via safe APIs (Process, execFile)
- [ ] User input never directly in shell commands
- [ ] LDAP queries use parameterized filters
- [ ] Template engines auto-escape by default

---

## A04:2021 — Insecure Design

### What
Missing security controls at architecture level. Not a code bug — a design flaw.

### Examples
- No rate limiting on login/API
- No account lockout after failed attempts
- No CSRF protection on state-changing operations
- Missing audit logging for sensitive operations
- Business logic allows unlimited retries (payment, OTP)

### Checklist
- [ ] Threat modeling done for sensitive flows
- [ ] Rate limiting on authentication endpoints
- [ ] Account lockout / progressive delays after failed attempts
- [ ] CSRF protection on state-changing requests
- [ ] Audit trail for sensitive operations (payments, data access, role changes)
- [ ] Business logic limits (max retries, cooldowns, amount limits)

---

## A05:2021 — Security Misconfiguration

### What
Insecure defaults, verbose errors, unnecessary features enabled in production.

### Code Patterns

#### PHP/Symfony
```yaml
# VULNERABLE — production
framework:
    profiler: true
# .env
APP_ENV=dev
APP_DEBUG=true

# SECURE
framework:
    profiler: false
# .env
APP_ENV=prod
APP_DEBUG=false
```

#### Node/JS
```javascript
// VULNERABLE
app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));

// SECURE
if (process.env.NODE_ENV === 'production') {
    app.use((err, req, res, next) => {
        res.status(500).json({ error: 'Internal Server Error' });
    });
}
```

### Checklist
- [ ] Debug mode OFF in production
- [ ] Error pages do not show stack traces
- [ ] Unused endpoints/features disabled
- [ ] Security headers set (HSTS, CSP, X-Content-Type-Options, X-Frame-Options)
- [ ] Default credentials changed
- [ ] Directory listing disabled
- [ ] CORS not overly permissive

---

## A06:2021 — Vulnerable and Outdated Components

### What
Using dependencies with known vulnerabilities.

### Commands

```bash
# PHP
composer audit
composer outdated

# Node/JS
npm audit --audit-level=high
npm outdated

# Go
govulncheck ./...
```

### Checklist
- [ ] Dependency audit clean (no known CVEs)
- [ ] Dependencies regularly updated
- [ ] Unused dependencies removed
- [ ] Lock files committed (composer.lock, package-lock.json)
- [ ] Security advisories monitored

---

## A07:2021 — Identification and Authentication Failures

### What
Weak passwords, session hijacking, credential stuffing, broken session management.

### Code Patterns

#### PHP/Symfony
```yaml
# SECURE — Symfony security config
security:
    password_hashers:
        Symfony\Component\Security\Core\User\PasswordAuthenticatedUserInterface:
            algorithm: 'argon2id'
    firewalls:
        main:
            remember_me:
                secret: '%kernel.secret%'
                lifetime: 604800
                secure: true
                httponly: true
```

#### Node/JS
```javascript
// SECURE — session config
app.use(session({
    secret: process.env.SESSION_SECRET,
    cookie: { secure: true, httpOnly: true, sameSite: 'strict', maxAge: 3600000 },
    resave: false,
    saveUninitialized: false,
}));
```

### Checklist
- [ ] Strong password policy enforced
- [ ] Password hashing with argon2id/bcrypt
- [ ] Session timeout implemented
- [ ] Secure cookie flags (httpOnly, secure, sameSite)
- [ ] JWT expiration set and validated
- [ ] Refresh token rotation
- [ ] Rate limiting on auth endpoints
- [ ] 2FA available for sensitive accounts

---

## A08:2021 — Software and Data Integrity Failures

### What
Insecure CI/CD, unsigned updates, unverified deserialization.

### Code Patterns

#### PHP/Symfony
```php
// VULNERABLE — unserialize user input
$data = unserialize($_POST['data']);

// SECURE — JSON with validation
$data = json_decode($request->getContent(), true, 512, JSON_THROW_ON_ERROR);

// SECURE — Symfony Serializer with type enforcement
$dto = $this->serializer->deserialize($content, CreateUserDTO::class, 'json');
```

#### Node/JS
```javascript
// VULNERABLE — eval user input
eval(req.body.expression);

// SECURE — JSON parse with schema validation
const data = JSON.parse(req.body.data);
const validated = schema.validate(data);
```

### Checklist
- [ ] No unserialize/eval on user input
- [ ] JSON deserialization with type enforcement
- [ ] CI/CD pipeline has security scanning
- [ ] Package integrity verified (lock files, checksums)
- [ ] Webhook signatures validated

---

## A09:2021 — Security Logging and Monitoring Failures

### What
Missing logs for security events. No alerting. PII in logs.

### Code Patterns

#### PHP/Symfony
```php
// VULNERABLE — PII in logs
$this->logger->info('Login', ['email' => $user->getEmail(), 'password' => $password]);

// SECURE — sanitized logging
$this->logger->warning('Failed login attempt', [
    'user_id' => $user->getId(),
    'ip' => $request->getClientIp(),
    'timestamp' => new \DateTimeImmutable(),
]);
```

### Checklist
- [ ] Login attempts (success + failure) logged
- [ ] Authorization failures logged
- [ ] Sensitive operations logged (payments, data access, role changes)
- [ ] PII/PHI NOT in logs (no emails, passwords, health data)
- [ ] Logs are tamper-proof (append-only, centralized)
- [ ] Monitoring alerts configured for anomalies

---

## A10:2021 — Server-Side Request Forgery (SSRF)

### What
Attacker forces server to make requests to internal services or cloud metadata.

### Code Patterns

#### PHP/Symfony
```php
// VULNERABLE
$url = $request->query->get('url');
$content = file_get_contents($url); // Can access internal services, cloud metadata

// SECURE — whitelist
$allowedHosts = ['api.example.com', 'cdn.example.com'];
$host = parse_url($url, PHP_URL_HOST);
if (!in_array($host, $allowedHosts, true)) {
    throw new BadRequestException('URL not allowed');
}
// Also block internal IPs
$ip = gethostbyname($host);
if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE) === false) {
    throw new BadRequestException('Internal URLs not allowed');
}
```

#### Node/JS
```javascript
// VULNERABLE
const response = await fetch(req.body.url);

// SECURE
const url = new URL(req.body.url);
if (!ALLOWED_HOSTS.includes(url.hostname)) {
    throw new ForbiddenError('Host not allowed');
}
```

### Checklist
- [ ] URL validation before any server-side fetch
- [ ] Whitelist of allowed hosts/domains
- [ ] Block access to internal/private IP ranges (169.254.x.x, 10.x.x.x, 172.16-31.x.x, 192.168.x.x)
- [ ] Block cloud metadata endpoints (169.254.169.254)
- [ ] Network segmentation for internal services

---

## Modern Supplements (2023-2025)

### API Security (OWASP API Security Top 10, 2023)

| # | Threat | Description |
|---|--------|-------------|
| API1 | BOLA | Broken Object Level Authorization — same as IDOR but API-specific |
| API2 | Broken Authentication | Weak API auth mechanisms |
| API3 | BOPLA | Broken Object Property Level Authorization — mass assignment |
| API4 | Unrestricted Resource Consumption | No rate limiting, no pagination limits |
| API5 | BFLA | Broken Function Level Authorization — admin endpoints exposed |
| API6 | Unrestricted Access to Sensitive Business Flows | Bot abuse, scraping, mass creation |
| API7 | SSRF | Server-Side Request Forgery via API parameters |
| API8 | Security Misconfiguration | Same as A05 but API context |
| API9 | Improper Inventory Management | Undocumented/deprecated API versions still live |
| API10 | Unsafe Consumption of APIs | Trusting third-party API responses without validation |

### Supply Chain Attacks (extends A06, A08)

- **Dependency confusion** — private package name squatted on public registry
- **Typosquatting** — `lodash` vs `1odash`
- **Compromised maintainer** — legitimate package with malicious update
- **Lock file manipulation** — modified lock file points to different version

### Checklist
- [ ] Private registry configured for internal packages
- [ ] Lock file changes reviewed in PRs
- [ ] `npm audit` / `composer audit` in CI pipeline
- [ ] Dependabot/Renovate enabled

### Cloud-Native Threats (extends A10)

- **Cloud metadata SSRF** — `http://169.254.169.254/latest/meta-data/` gives AWS keys
- **Container escape** — privileged containers, mounted Docker socket
- **Misconfigured IAM** — overly permissive roles

### Checklist
- [ ] IMDSv2 enforced (AWS) or equivalent
- [ ] Containers run as non-root
- [ ] IAM follows least privilege
- [ ] No secrets in environment variables visible to all containers

---

## Quality Checklist

- [ ] Every OWASP category reviewed for applicable files
- [ ] Code patterns use VULNERABLE/SECURE format with real examples
- [ ] Checklists are concrete (not vague "ensure security")
- [ ] Tech profiles cover the project's actual stack
- [ ] Modern supplements checked (API Security, Supply Chain, Cloud)
- [ ] Findings reference specific OWASP/CWE category

## Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| Checklist-only review | Checking boxes without reading code | Read actual code, verify patterns match |
| Single-category focus | Only checking injection, missing access control | Work through ALL 10 categories systematically |
| Framework trust | "Symfony handles it" without verification | Verify framework protections are actually configured |
| Copy-paste findings | Generic "SQL injection possible" without proof | Show the actual vulnerable line with VULNERABLE/SECURE examples |
| Ignoring supplements | Only checking classic Top 10, missing API/supply chain | Always include Modern Supplements section for API-heavy code |
