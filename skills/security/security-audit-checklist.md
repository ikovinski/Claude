# Security Audit Checklist

## Authentication & Authorization

- [ ] **Authentication required** для всіх sensitive endpoints
- [ ] **JWT tokens** мають expiration
- [ ] **Refresh tokens** rotated після використання
- [ ] **Password hashing** використовує bcrypt/argon2
- [ ] **Rate limiting** на login endpoints
- [ ] **Account lockout** після failed attempts
- [ ] **2FA** доступний для admin accounts
- [ ] **Session invalidation** при logout
- [ ] **Role-based access control** (RBAC) implemented
- [ ] **Symfony Voters** для authorization logic

## Input Validation

- [ ] **All user input** validated перед використанням
- [ ] **Type validation** (string, int, email тощо)
- [ ] **Length limits** на текстових полях
- [ ] **Whitelist validation** для enums/choices
- [ ] **File uploads** перевіряють тип і розмір
- [ ] **SQL injection** prevention (prepared statements)
- [ ] **XSS prevention** (output escaping)
- [ ] **CSRF tokens** на state-changing requests

## Data Protection

- [ ] **PII/PHI encryption** at rest (AES-256)
- [ ] **TLS 1.3** for data in transit
- [ ] **Sensitive data** NOT logged
- [ ] **API keys** в environment variables
- [ ] **Database credentials** secure
- [ ] **No hardcoded secrets** в коді
- [ ] **Data retention** policies implemented
- [ ] **GDPR compliance** для EU users

## API Security

- [ ] **API rate limiting** implemented
- [ ] **Request size limits** configured
- [ ] **CORS** properly configured
- [ ] **API versioning** в headers
- [ ] **Error responses** не показують stack traces
- [ ] **Pagination** на list endpoints
- [ ] **Input sanitization** на search/filter

## Dependencies & Infrastructure

- [ ] **Dependencies** up to date (composer update)
- [ ] **Security advisories** checked (composer audit)
- [ ] **Container security** scan
- [ ] **Environment separation** (prod/staging/dev)
- [ ] **Secrets management** (Vault, AWS Secrets)
- [ ] **Logging** не містить sensitive data
- [ ] **Monitoring** для suspicious activity

## Health Data Specific (HIPAA/GDPR)

- [ ] **Health metrics** encrypted
- [ ] **Access logs** для PII/PHI
- [ ] **Data minimization** — збирається тільки необхідне
- [ ] **User consent** recorded
- [ ] **Right to deletion** implemented
- [ ] **Data export** (портативність)
- [ ] **Breach notification** process

## Code Review Security

- [ ] **No commented credentials** в коді
- [ ] **Debug mode** вимкнено в prod
- [ ] **Error handling** не показує internal details
- [ ] **Validation** на обох сторонах (client + server)
- [ ] **Business logic** не в client code
