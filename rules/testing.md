# Testing Rules

## Coverage Requirements

### Mandatory Coverage

| Area | Minimum | Target |
|------|---------|--------|
| Billing/Payment logic | 90% | 95% |
| Health data processing | 85% | 90% |
| Message handlers | 80% | 90% |
| API endpoints | 75% | 85% |
| General code | 70% | 80% |

### What MUST Be Tested

1. **Payment flows** - subscription creation, renewal, cancellation
2. **Message handlers** - happy path + failure scenarios + idempotency
3. **Health data calculations** - edge cases (zero, negative, null)
4. **API authentication** - valid/invalid tokens, expired sessions

### Testing Patterns

```php
// GOOD: Test idempotency
public function testHandlerIsIdempotent(): void
{
    $message = new ProcessPaymentMessage($userId, $amount);

    $this->handler->__invoke($message);
    $this->handler->__invoke($message); // Second call

    // Should not create duplicate payment
    $this->assertCount(1, $this->paymentRepository->findByUser($userId));
}

// GOOD: Test failure scenarios
public function testHandlerRetriesOnTransientError(): void
{
    $this->apiClient->willFailTimes(2)->thenSucceed();

    $this->handler->__invoke($message);

    $this->assertEquals(3, $this->apiClient->getCallCount());
}
```

### Test Data Rules

- Use factories (Foundry) for test entities
- Never use production data in tests
- Mock external APIs (payment providers, health APIs)
- Use in-memory SQLite for unit tests where possible

### PHPUnit Configuration

```xml
<coverage>
    <include>
        <directory suffix=".php">src</directory>
    </include>
    <exclude>
        <directory>src/Migrations</directory>
        <directory>src/DataFixtures</directory>
    </exclude>
</coverage>
```
