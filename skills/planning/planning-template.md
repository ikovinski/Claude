# Planning Template

## Implementation Plan Structure

### 1. Overview

**Feature**: [Назва фічі]
**Goal**: [Бізнес-ціль]
**Success Criteria**: [Як зрозуміємо що готово]

### 2. Requirements Analysis

**Functional Requirements**:
- [ ] Requirement 1
- [ ] Requirement 2

**Non-Functional Requirements**:
- Performance: [criteria]
- Security: [considerations]
- Scalability: [constraints]

### 3. Current State Analysis

**Existing Components**:
- Component A: [file paths]
- Component B: [file paths]

**Affected Areas**:
- Files to modify: [list]
- New files needed: [list]
- Dependencies: [list]

### 4. Implementation Steps

#### Phase 1: [Name]
**Goal**: [What this phase achieves]
**Duration**: [Estimate]

Steps:
1. **[Step name]** (file.php:line)
   - What: [Description]
   - Why: [Reasoning]
   - Test: [How to verify]

2. **[Step name]** (file.php:line)
   - What: [Description]
   - Why: [Reasoning]
   - Test: [How to verify]

#### Phase 2: [Name]
[Same structure as Phase 1]

### 5. Testing Strategy

**Unit Tests**:
- [ ] Test A (Класс/Метод)
- [ ] Test B (Класс/Метод)

**Integration Tests**:
- [ ] Test C (Сценарій)

**Manual Testing**:
- [ ] Test D (UI/API)

### 6. Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Database migration failure | High | Test on staging, backup plan |
| API breaking change | Medium | Versioning, gradual rollout |

### 7. Rollout Plan

**Pre-deployment**:
- [ ] Code review passed
- [ ] Tests passing (coverage: X%)
- [ ] Staging tested
- [ ] Documentation updated

**Deployment**:
- [ ] Feature flag ready
- [ ] Monitoring configured
- [ ] Rollback plan defined

**Post-deployment**:
- [ ] Metrics tracking
- [ ] User feedback collected
- [ ] Performance monitored

### 8. Dependencies

**External**:
- API changes: [details]
- Third-party services: [details]

**Internal**:
- Other teams: [coordination needed]
- Infrastructure: [resources needed]

### 9. Success Metrics

- Metric 1: [target value]
- Metric 2: [target value]

### 10. Timeline

```
Week 1: Phase 1 (Foundation)
Week 2: Phase 2 (Core functionality)
Week 3: Phase 3 (Testing & polish)
Week 4: Deployment & monitoring
```

## Example: Add Subscription Renewal Feature

### 1. Overview

**Feature**: Automatic Subscription Renewal
**Goal**: Автоматично продовжувати підписки користувачів перед expiration
**Success Criteria**:
- 95% підписок оновлюються автоматично
- 0 failed payments через logic errors

### 2. Requirements Analysis

**Functional**:
- [ ] Check subscriptions 3 days before expiration
- [ ] Charge payment method on file
- [ ] Send confirmation email
- [ ] Handle failed payments (retry logic)

**Non-Functional**:
- Performance: Process 1000 renewals/hour
- Security: PCI compliance для payment data
- Idempotency: Safe to retry

### 3. Current State

**Existing**:
- `SubscriptionRepository` — has findExpiringSoon()
- `PaymentService` — can charge cards
- `EmailService` — can send emails

**Affected**:
- Modify: `src/MessageHandler/RenewalCheckHandler.php`
- New: `src/Service/SubscriptionRenewalService.php`
- New: `tests/Service/SubscriptionRenewalServiceTest.php`

### 4. Implementation Steps

#### Phase 1: Core Service
1. **Create SubscriptionRenewalService** (new file)
   - What: Service з логікою renewal
   - Why: Відокремити business logic
   - Test: Unit test з mocked dependencies

2. **Add renew() method**
   - What: Charge card, update subscription, send email
   - Why: Single responsibility
   - Test: Happy path + failure scenarios

#### Phase 2: Message Handler
1. **Create RenewalCheckHandler**
   - What: Scheduled job (cron)
   - Why: Async processing
   - Test: Integration test з Messenger

2. **Add idempotency check**
   - What: Track processed renewals
   - Why: Prevent double charging
   - Test: Test retries don't duplicate

### 5. Testing Strategy

**Unit Tests**:
- [ ] SubscriptionRenewalService::renew() — happy path
- [ ] SubscriptionRenewalService::renew() — payment fails
- [ ] SubscriptionRenewalService::renew() — idempotency

**Integration Tests**:
- [ ] RenewalCheckHandler processes queue
- [ ] End-to-end renewal flow

### 6. Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Double charging | Critical | Idempotency key |
| Payment gateway timeout | Medium | Retry with backoff |

### 7. Rollout

- Feature flag: `subscription_auto_renewal`
- Gradual: 10% → 50% → 100%
- Monitoring: failed_renewal_count metric

### 8. Timeline

- Week 1: Implementation + Unit tests
- Week 2: Integration tests + Code review
- Week 3: Staging testing
- Week 4: Gradual rollout (10% → 100%)
