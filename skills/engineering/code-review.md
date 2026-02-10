# Code Review Skill

## Metadata
```yaml
name: code-review
category: engineering
complexity: medium
time_estimate: 10-30 minutes
requires_context:
  - Code diff or PR link
  - What the code does (context)
  - Review scope (full/security/performance/quick)
```

## Purpose
Провести структурований code review з фокусом на maintainability, production-readiness та тестове покриття для Symfony/PHP backend codebase.

## When to Use
- PR готовий до review
- Self-review перед тим як просити колег
- Code audit існуючого коду
- Mentoring: показати junior як робити review

## When NOT to Use
- Архітектурні рішення (use Staff Engineer agent)
- Дуже великий PR (>500 lines) — спочатку decompose
- Code style тільки — use PHP CS Fixer замість

---

## Prompt

```
[SYSTEM CONTEXT]
Ти — Senior PHP Code Reviewer для wellness/fitness tech продукту.
Tech stack:
- PHP 8.3, Symfony 6.4
- Doctrine ORM + MySQL
- RabbitMQ (AMQP Messenger) + Kafka
- Redis, Memcached (cache)
- Elasticsearch
- Docker, Kubernetes

Architecture:
- DDD-style: Domain/, Entity/, Service/, Repository/
- Message-driven: Message/, Messaging/, EventListener/
- API layer: API/, Controller/
- Infrastructure layer: Infrastructure/, Integration/

Quality tools: PHPStan, Psalm, PHP CS Fixer, PHPUnit

Domain: health data (workouts, nutrition, subscriptions) — PII/PHI sensitive.

[BIASES TO APPLY]
1. Maintainability > cleverness — код читають 10x частіше ніж пишуть
2. Production-first — що станеться о 3 ночі на prod під навантаженням?
3. Test coverage = insurance — особливо для health data та billing
4. Explicit > implicit — Symfony magic = debug hell
5. Security by default — health data + payments = критично
6. Type safety — використовуй PHP 8.3 features: typed properties, union types, readonly
7. Message reliability — RabbitMQ/Kafka messages мають бути idempotent

[TASK]
Review the following PHP/Symfony code. Provide structured feedback.

[INPUT]
Code/Diff:
{{paste_code_or_diff}}

Context: {{what_this_code_does}}
Review scope: {{full | security | performance | quick}}

[OUTPUT FORMAT]
## Summary
[1-2 sentences overall impression]

## Blocking Issues 🚫
[Must fix before merge. Include file:line, why matters, suggested fix]

## Suggestions 💡
[Should consider. Include context why better]

## Nitpicks 📝
[Minor, prefix with "nit:"]

## What's Good ✅
[Positive observations for team learning]

## Questions ❓
[Clarifying questions if unclear]

[CONSTRAINTS]
- Don't block for pure style preferences — PHP CS Fixer handles that
- Consider PHPStan/Psalm baseline — don't require fixing pre-existing issues
- Focus on issues that matter for production
- Be constructive: explain "why", suggest fixes
```

---

## Quality Bar

### Must Have (Блокери)
- [ ] Визначені всі security issues (SQL injection, auth bypass, data exposure)
- [ ] Перевірено error handling для external calls (APIs, DB, RabbitMQ, Kafka)
- [ ] Перевірено handling edge cases для health data (null, zero, negative)
- [ ] Doctrine: N+1 queries, missing indexes, transaction boundaries
- [ ] Messages: idempotency, retry logic, dead letter handling
- [ ] Кожен blocking issue має explanation "чому важливо"
- [ ] Кожен blocking issue має suggested fix

### Should Have (Важливо)
- [ ] Summary дає quick overview якості PR
- [ ] Suggestions мають context чому краще
- [ ] Виділено що зроблено добре (team learning)
- [ ] Перевірено test coverage для критичних paths
- [ ] PHP 8.3 features використані правильно (types, readonly, enums)
- [ ] Symfony best practices (DI, events, voters для auth)

### Nice to Have (Бонус)
- [ ] References до Symfony/Doctrine документації
- [ ] Порівняння з існуючим кодом в codebase
- [ ] Performance implications (DB queries, memory, queue throughput)
- [ ] PHPStan/Psalm level compliance

---

## Examples

### Example Input
```php
// Context: Message handler для sync workout data з external provider

#[AsMessageHandler]
class SyncWorkoutHandler
{
    public function __construct(
        private EntityManagerInterface $em,
        private WorkoutApiClient $apiClient,
    ) {}

    public function __invoke(SyncWorkoutMessage $message): void
    {
        $user = $this->em->find(User::class, $message->userId);
        $workouts = $this->apiClient->getWorkouts($user->getExternalToken());

        foreach ($workouts as $workout) {
            $entity = new Workout();
            $entity->setUser($user);
            $entity->setData($workout);
            $this->em->persist($entity);
        }

        $this->em->flush();
    }
}
```

### Example Output
```
## Summary
Функціональний handler, але missing critical error handling та idempotency для production message processing.

## Blocking Issues 🚫

1. **No null check for User** [line 12]
   - Why: `$message->userId` може бути deleted user. `$user->getExternalToken()` викличе error on null.
   - Fix:
     ```php
     $user = $this->em->find(User::class, $message->userId);
     if (!$user) {
         throw new UserNotFoundException($message->userId);
     }
     ```

2. **No error handling for API call** [line 13]
   - Why: External API може timeout, return 401/500. Message буде requeued нескінченно.
   - Fix: Wrap у try-catch, throw `RecoverableMessageHandlingException` для retry або `UnrecoverableMessageHandlingException` для dead letter.

3. **N+1 та no batch insert** [line 15-20]
   - Why: 100 workouts = 100 persist calls + 1 flush. Slow та ризик partial failure mid-transaction.
   - Fix: Collect entities, use batch processing з chunk size ~50.

4. **No idempotency** [line 15-20]
   - Why: Якщо message retry після partial success — дублікати workouts.
   - Fix: Check existing by `externalId` before insert, або use upsert.

## Suggestions 💡

1. **Add readonly class** — PHP 8.3 дозволяє `readonly class SyncWorkoutHandler` якщо всі properties readonly.

2. **Consider async dispatch** — якщо workouts багато, dispatch окремий message на кожен workout для parallel processing.

3. **Add logging** — для production debugging важливо логувати sync start/end/count.

## Nitpicks 📝

- nit: `$workout` variable shadows the entity type name. Consider `$workoutData`.

## What's Good ✅
- Proper use of `#[AsMessageHandler]` attribute
- Constructor property promotion
- Single responsibility — handler робить одну річ
```

---

## Integration Notes
- **Combines well with**: task-decomposition (якщо PR великий)
- **Often followed by**: виправлення issues, повторний review
- **Related agents**: Code Reviewer, Staff Engineer (для architectural concerns)

---

## Stack-Specific Checklist

### Symfony / PHP 8.3
- [ ] Typed properties та return types скрізь
- [ ] Constructor property promotion
- [ ] Readonly classes/properties де можливо
- [ ] Enums замість magic strings/constants
- [ ] Attributes замість annotations (`#[Route]`, `#[AsMessageHandler]`)
- [ ] No `@var` коментарі якщо type вже в signature

### Doctrine / MySQL
- [ ] Eager/lazy loading правильно налаштований (уникати N+1)
- [ ] Indexes на часто queried columns
- [ ] Transaction boundaries явні для multi-entity operations
- [ ] `QueryBuilder` замість raw DQL де можливо
- [ ] `flush()` викликається один раз в кінці, не в циклі

### RabbitMQ / Symfony Messenger
- [ ] Message handlers idempotent (retry-safe)
- [ ] Proper exception handling: `RecoverableMessageHandlingException` vs `UnrecoverableMessageHandlingException`
- [ ] Dead letter queue налаштований для failed messages
- [ ] Message serialization/deserialization tested
- [ ] Retry policy з exponential backoff

### Kafka
- [ ] Schema validation через Avro/JSON Schema
- [ ] Consumer group правильно налаштований
- [ ] Offset commit strategy (auto vs manual)
- [ ] Partition key для ordering guarantees
- [ ] Idempotent producer якщо exactly-once required

### Docker / Kubernetes
- [ ] Health checks endpoints працюють
- [ ] Graceful shutdown handlers для message consumers
- [ ] Resource limits (memory, CPU) враховані в коді
- [ ] No hardcoded hosts/ports — все через env vars
- [ ] Stateless design (no local file storage)
