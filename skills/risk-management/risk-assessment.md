# Risk Assessment

## Risk Matrix

| Likelihood →<br>Impact ↓ | Low | Medium | High |
|---|---|---|---|
| **Critical** | 🟡 Monitor | 🔴 Urgent | 🔴 Blocker |
| **High** | 🟢 Accept | 🟡 Monitor | 🔴 Urgent |
| **Medium** | 🟢 Accept | 🟢 Accept | 🟡 Monitor |
| **Low** | 🟢 Accept | 🟢 Accept | 🟢 Accept |

## Risk Categories

### Technical Risks
- Architecture/design flaws
- Technology choice
- Performance/scalability
- Security vulnerabilities
- Technical debt

### Delivery Risks
- Scope creep
- Dependencies on other teams
- Resource availability
- Timeline pressure

### Operational Risks
- Deployment failures
- Data loss/corruption
- Service downtime
- Monitoring gaps

### Business Risks
- Wrong problem being solved
- User adoption
- Regulatory compliance
- Cost overruns

## Risk Assessment Template

```markdown
### Risk: [Name]

**Category**: [Technical | Delivery | Operational | Business]
**Impact**: [Low | Medium | High | Critical]
**Likelihood**: [Low | Medium | High]
**Priority**: [🟢 Accept | 🟡 Monitor | 🔴 Urgent]

**Description**: What could go wrong?

**Impact if occurs**:
- System impact
- User impact
- Business impact

**Mitigation**:
1. Action to reduce likelihood
2. Action to reduce impact

**Contingency**: What if it happens anyway?

**Owner**: [Person responsible]
```

## Example: Subscription Feature Risks

### Risk 1: Double Charging Users

**Category**: Technical
**Impact**: Critical (money + trust)
**Likelihood**: Medium
**Priority**: 🔴 Urgent

**Description**:
Message handler could process same renewal twice if retry occurs.

**Impact**:
- User charged twice
- Refund process required
- Trust damage
- Support tickets

**Mitigation**:
1. Add idempotency key to renewals
2. Database unique constraint on (user_id, period)
3. Check existing charge before processing

**Contingency**:
- Automated refund script ready
- Support team trained on refund process
- Monitoring alert on duplicate charges

**Owner**: Backend Lead

---

### Risk 2: Payment Gateway Timeout

**Category**: Operational
**Impact**: High (lost revenue)
**Likelihood**: Medium
**Priority**: 🟡 Monitor

**Description**:
Stripe API could timeout during high load.

**Impact**:
- Failed renewals
- Users lose access
- Manual intervention needed

**Mitigation**:
1. Retry with exponential backoff
2. Circuit breaker pattern
3. Fallback queue for failed charges

**Contingency**:
- Manual retry script
- Grace period for payments (3 days)
- Support process for stuck renewals

**Owner**: Platform Team

---

### Risk 3: Email Service Down

**Category**: Operational
**Impact**: Medium (UX issue)
**Likelihood**: Low
**Priority**: 🟢 Accept

**Description**:
SendGrid could be down when sending confirmation.

**Impact**:
- Users don't get confirmation
- Support inquiries increase
- No functional impact (subscription still works)

**Mitigation**:
1. Queue emails (async)
2. Retry failed sends
3. Show confirmation in-app

**Contingency**:
- In-app notification as backup
- Batch send later when service recovers

**Owner**: Backend Team

## Risk Register Format

| ID | Risk | Impact | Likelihood | Priority | Owner | Status |
|----|------|--------|-----------|----------|-------|--------|
| R1 | Double charging | Critical | Medium | 🔴 | John | Mitigated |
| R2 | Payment timeout | High | Medium | 🟡 | Platform | Monitoring |
| R3 | Email service down | Medium | Low | 🟢 | Backend | Accepted |

## When to Assess Risks

- **Project kickoff**: Identify risks upfront
- **Sprint planning**: Review for upcoming work
- **Before deployment**: Check deployment risks
- **After incident**: Assess new risks exposed

## Risk Mitigation Strategies

### Reduce Likelihood
- Better testing
- Code review
- Architecture review
- Feature flags

### Reduce Impact
- Graceful degradation
- Rollback plan
- Monitoring & alerts
- Documentation

### Transfer Risk
- Use managed services
- Insurance
- Third-party validation

### Accept Risk
- Low priority risks
- Cost of mitigation > cost of risk
- Document decision

## Red Flags

🚩 No rollback plan
🚩 No monitoring for critical path
🚩 Touching payment code without tests
🚩 Database migration on production without backup
🚩 New technology team doesn't know
🚩 No feature flag for risky feature
🚩 Deployment during peak hours
