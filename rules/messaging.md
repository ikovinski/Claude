# Messaging Rules (RabbitMQ / Kafka)

## Message Handler Requirements

### Idempotency (CRITICAL)

Every message handler MUST be idempotent - safe to process multiple times.

```php
// GOOD: Idempotent handler with deduplication
#[AsMessageHandler]
class ProcessPaymentHandler
{
    public function __invoke(ProcessPaymentMessage $message): void
    {
        // Check if already processed
        if ($this->paymentRepository->existsByExternalId($message->externalId)) {
            $this->logger->info('Payment already processed, skipping');
            return;
        }

        // Process payment...
    }
}

// BAD: Not idempotent - creates duplicates on retry
public function __invoke(ProcessPaymentMessage $message): void
{
    $payment = new Payment($message->amount);
    $this->em->persist($payment);
    $this->em->flush();
}
```

### Error Handling

```php
use Symfony\Component\Messenger\Exception\RecoverableMessageHandlingException;
use Symfony\Component\Messenger\Exception\UnrecoverableMessageHandlingException;

public function __invoke(SyncWorkoutMessage $message): void
{
    try {
        $this->apiClient->sync($message->userId);
    } catch (RateLimitException $e) {
        // Retry later - temporary issue
        throw new RecoverableMessageHandlingException(
            'Rate limited, retry later',
            previous: $e
        );
    } catch (InvalidTokenException $e) {
        // Don't retry - permanent issue
        throw new UnrecoverableMessageHandlingException(
            'Invalid token, requires user re-auth',
            previous: $e
        );
    }
}
```

### Exception Types

| Exception | When to Use | Retry? |
|-----------|-------------|--------|
| `RecoverableMessageHandlingException` | Temporary failures (timeout, rate limit) | Yes |
| `UnrecoverableMessageHandlingException` | Permanent failures (invalid data) | No → Dead Letter |
| Regular exception | Unknown errors | Yes (with backoff) |

## RabbitMQ vs Kafka Usage

| Use Case | Choose | Reason |
|----------|--------|--------|
| Internal async jobs | RabbitMQ | Symfony Messenger integration |
| Request-reply pattern | RabbitMQ | Built-in support |
| Cross-service events | Kafka | Event log, multiple consumers |
| Audit trail | Kafka | Immutable log |
| High throughput | Kafka | Better scalability |

## Kafka-Specific Rules

### Schema Management

```php
// GOOD: Versioned schema with backward compatibility
#[AvroSchema(
    name: 'subscription.created',
    version: 2,
    compatibility: 'BACKWARD'
)]
class SubscriptionCreatedEvent
{
    public function __construct(
        public readonly string $subscriptionId,
        public readonly string $userId,
        public readonly string $plan,
        public readonly ?string $promoCode = null, // New field, nullable for backward compat
    ) {}
}
```

### Consumer Groups

- One consumer group per service
- Use meaningful names: `{service}-{purpose}`
- Example: `billing-subscription-processor`

## Checklist for Message Handlers

- [ ] Handler is idempotent (safe for retry)
- [ ] Proper exception types (Recoverable vs Unrecoverable)
- [ ] Logging with correlation ID
- [ ] Metrics/monitoring for processing time
- [ ] Dead letter queue configured
- [ ] Graceful shutdown handling (K8s)
