# OWASP Top 10 (2021)

## A01:2021 – Broken Access Control

### Що це
Користувачі можуть отримати доступ до даних/функцій поза їх правами.

### PHP/Symfony Examples
```php
// ❌ Vulnerable
public function getUser($id) {
    return $this->userRepository->find($id); // Anyone can access any user
}

// ✅ Secure
public function getUser($id) {
    $user = $this->userRepository->find($id);
    $this->denyAccessUnlessGranted('view', $user); // Symfony Voter
    return $user;
}
```

### Checklist
- [ ] Symfony Voters для authorization
- [ ] API endpoints перевіряють ownership
- [ ] Admin endpoints захищені ROLE_ADMIN
- [ ] IDOR prevention (insecure direct object references)

---

## A02:2021 – Cryptographic Failures

### Що це
Недостатнє шифрування sensitive data.

### PHP/Symfony Examples
```php
// ❌ Vulnerable
$password = md5($input); // MD5 не підходить для passwords

// ✅ Secure
$password = password_hash($input, PASSWORD_ARGON2ID);
```

### Checklist
- [ ] TLS 1.3 для transit
- [ ] AES-256 для at rest
- [ ] Passwords hashed з bcrypt/argon2
- [ ] API keys в .env, не в коді

---

## A03:2021 – Injection

### Що це
SQL, Command, LDAP injection через unvalidated input.

### PHP/Symfony Examples
```php
// ❌ Vulnerable (SQL Injection)
$query = "SELECT * FROM users WHERE email = '$email'";

// ✅ Secure (Doctrine ORM)
$user = $this->userRepository->findOneBy(['email' => $email]);

// ✅ Secure (DQL with parameters)
$qb = $this->createQueryBuilder('u')
    ->where('u.email = :email')
    ->setParameter('email', $email);
```

### Checklist
- [ ] Doctrine ORM/DBAL з параметрами
- [ ] NO raw SQL з concatenation
- [ ] Command injection prevention (escapeshellarg)
- [ ] LDAP injection prevention

---

## A04:2021 – Insecure Design

### Що це
Архітектурні недоліки (missing security controls).

### Symfony Examples
- Відсутність rate limiting
- No account lockout після failed logins
- Missing CSRF protection
- No audit logging

### Checklist
- [ ] Security by design (threat modeling)
- [ ] Rate limiting (symfony/rate-limiter)
- [ ] CSRF tokens на forms
- [ ] Audit trail для sensitive operations

---

## A05:2021 – Security Misconfiguration

### Що це
Незахищені defaults, verbose errors, відкриті порти.

### PHP/Symfony Examples
```yaml
# ❌ Vulnerable (.env)
APP_ENV=dev  # на production!
APP_DEBUG=true

# ✅ Secure
APP_ENV=prod
APP_DEBUG=false
```

### Checklist
- [ ] APP_DEBUG=false в prod
- [ ] Error pages не показують stack traces
- [ ] Unused endpoints disabled
- [ ] Security headers (HSTS, CSP)

---

## A06:2021 – Vulnerable Components

### Що це
Outdated dependencies з known vulnerabilities.

### PHP/Symfony Commands
```bash
composer audit              # Check vulnerabilities
composer outdated           # Check old packages
composer update symfony/*   # Update Symfony
```

### Checklist
- [ ] composer audit регулярно
- [ ] Dependencies up to date
- [ ] Remove unused dependencies
- [ ] Monitor security advisories

---

## A07:2021 – Identification and Authentication Failures

### Що це
Слабкі passwords, session hijacking, credential stuffing.

### PHP/Symfony Examples
```php
// Symfony Security Configuration
security:
    password_hashers:
        Symfony\Component\Security\Core\User\PasswordAuthenticatedUserInterface:
            algorithm: 'argon2id'
            cost: 16
    firewalls:
        main:
            remember_me:
                secret: '%kernel.secret%'
                lifetime: 604800 # 1 week
```

### Checklist
- [ ] Strong password policy
- [ ] Password hashing (argon2id)
- [ ] Session timeout implemented
- [ ] Secure remember me tokens
- [ ] 2FA для sensitive accounts

---

## A08:2021 – Software and Data Integrity Failures

### Що це
Незахищені CI/CD pipelines, unsigned updates.

### Checklist
- [ ] Code signing для releases
- [ ] CI/CD має security scanning
- [ ] Composer packages verified
- [ ] No unverified deserialization

---

## A09:2021 – Security Logging and Monitoring Failures

### Що це
Відсутність логів security events.

### PHP/Symfony Examples
```php
// Log security events
$this->logger->warning('Failed login attempt', [
    'user_id' => hash('sha256', $userId),
    'ip' => $request->getClientIp(),
]);
```

### Checklist
- [ ] Login attempts logged
- [ ] Failed authorization logged
- [ ] Sensitive operations logged
- [ ] PII NOT in logs
- [ ] Monitoring alerts configured

---

## A10:2021 – Server-Side Request Forgery (SSRF)

### Що це
Attacker змушує сервер робити requests до internal services.

### PHP/Symfony Examples
```php
// ❌ Vulnerable
$url = $_GET['url'];
file_get_contents($url); // Can access internal services

// ✅ Secure
$allowed = ['api.example.com'];
$host = parse_url($url, PHP_URL_HOST);
if (!in_array($host, $allowed)) {
    throw new \Exception('URL not allowed');
}
```

### Checklist
- [ ] URL validation перед fetch
- [ ] Whitelist allowed hosts
- [ ] No access до internal IPs
- [ ] Network segmentation
