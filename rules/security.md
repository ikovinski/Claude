# Security Rules

## Health Data Protection (PII/PHI)

### Mandatory Requirements

1. **Never log sensitive data**
   - No health metrics in logs (weight, calories, heart rate)
   - No personal identifiers (email, phone, user IDs in plain text)
   - Use structured logging with data masking

2. **Encryption requirements**
   - Health data at rest: AES-256
   - Data in transit: TLS 1.3
   - API keys and secrets: environment variables only

3. **Access control**
   - Symfony Voters for authorization
   - No direct SQL without parameterized queries
   - Validate user ownership before data access

### Code Patterns

```php
// GOOD: Masked logging
$this->logger->info('User subscription updated', [
    'user_id' => hash('sha256', $userId),
    'action' => 'renewal'
]);

// BAD: Sensitive data in logs
$this->logger->info('User {email} weight: {weight}', [
    'email' => $user->getEmail(),
    'weight' => $user->getWeight()
]);
```

### Checklist for Code Review

- [ ] No hardcoded credentials or API keys
- [ ] Input validation on all user data
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (output escaping)
- [ ] CSRF protection on state-changing endpoints
- [ ] Rate limiting on authentication endpoints
- [ ] Health data not exposed in error messages
