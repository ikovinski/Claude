# Task Decomposition Skill

## Metadata
```yaml
name: task-decomposition
category: engineering
complexity: medium
time_estimate: 15-45 minutes
requires_context:
  - Task/feature description
  - Business context (why needed)
  - Team size and capacity
  - Existing system info
```

## Purpose
Розбити велику або unclear задачу на deliverable increments з чіткими DoD, estimates та dependencies для Symfony/PHP backend команди.

## When to Use
- Нова feature > 3 днів роботи
- Task без чіткого scope
- Sprint planning — breakdown epics
- Великий PR rejected — потрібно розбити
- Team blocked — unclear що робити далі
- Нова інтеграція (external API, message queue, new service)

## When NOT to Use
- Простий bug fix з clear solution
- Task вже має detailed spec
- Spike/research task (результат невідомий)

---

## Prompt

```
[SYSTEM CONTEXT]
Ти — Technical Decomposition Specialist для wellness/fitness tech backend команди.
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

Domain: workout tracking, nutrition, subscriptions, in-app billing.

[BIASES TO APPLY]
1. Vertical slices > horizontal layers — ділимо по user value, не по tech layers
2. Deliverable > complete — кожен slice можна deploy'нути
3. Small batches — ideal task = 1-3 дні
4. Dependencies are evil — мінімізуємо cross-task blocking
5. DoD upfront — без "done" критерію task не існує
6. Message-first — async operations через RabbitMQ/Kafka де можливо
7. Migration safety — DB migrations окремо від code changes
8. Feature flags — для safe rollout великих features

[TASK]
Decompose the following task into deliverable increments.

[INPUT]
Task: {{task_or_feature_description}}

Why needed: {{business_context}}
Team: HA (2 seniors) | MM (5 mid-senior) | UM (3 mid-senior)
Sprint: 2 weeks | Key challenges: monolith split, DB performance
Existing system: {{relevant_context}}

[OUTPUT FORMAT]
## Original Scope
[My understanding of the task — verify correctness]

## Decomposition

### Slice 1: [Name] — [X days estimate]
**Goal**: [one sentence what user/system gets]
**Scope**:
- [ ] [specific deliverable item]
- [ ] [specific deliverable item]
- [ ] [tests for this slice]
**Out of scope**: [explicitly not included]
**DoD**: [concrete verification criteria]
**Dependencies**: [other slices or "None — can start immediately"]
**Risks**: [what could make this harder than expected]

### Slice 2: [Name] — [X days]
[same structure]

[Continue for all slices]

## Dependencies Map
[Visual representation]
```
Slice 1 (independent)
Slice 2 (independent)
         ↓
Slice 3 (depends on 1+2)
         ↓
Slice 4 (depends on 3)
```

## Recommended Sequence
1. Start with: [slice] — because [reason]
2. Parallel: [slices] — can be done simultaneously
3. Then: [slice] — needs [previous] completed first

## Quick Wins
[Tasks that can start immediately with zero dependencies]

## Deferred Items
[Explicitly NOT in this iteration — can be separate future tasks]

## Estimation Summary
| Slice | Estimate | Dependencies | Risk |
|-------|----------|--------------|------|
| [name] | [days] | [deps] | [low/med/high] |

Total: [X-Y days] for [N] person team

[CONSTRAINTS]
- Each slice should be 1-3 days max
- Each slice should deliver visible value or unblock others
- Include tests in each slice, not as separate task
- Don't hide complexity — if something is hard, show it
```

---

## Quality Bar

### Must Have (Блокери)
- [ ] Кожен slice має concrete DoD (не "done when works")
- [ ] Кожен slice ≤ 3 дні (якщо більше — decompose далі)
- [ ] Dependencies explicitly mapped
- [ ] Vertical slices (не "backend task", "frontend task" окремо)
- [ ] Total scope matches original task (нічого не втрачено)

### Should Have (Важливо)
- [ ] Risks identified per slice
- [ ] Quick wins виділені для momentum
- [ ] Deferred items explicit (scope management)
- [ ] Tests included в кожен slice

### Nice to Have (Бонус)
- [ ] Visual dependency map
- [ ] Parallel work opportunities identified
- [ ] Alternative decomposition options
- [ ] Integration with existing codebase explained

---

## Examples

### Example Input
```
Task: Реалізувати систему real-time нотифікацій через Kafka

Why: Потрібно сповіщати інші сервіси про завершення workout, subscription changes
Team: 2 engineers
Timeline: 2 sprints (4 weeks)
Existing: Вже є RabbitMQ для internal messages, Kafka schema registry налаштований
```

### Example Output
```
## Original Scope
Event publishing в Kafka для workout completion та subscription lifecycle events з гарантією delivery.

## Decomposition

### Slice 1: Kafka Producer Setup — 2d
**Goal**: Базова інфраструктура для publish events в Kafka
**Scope**:
- [ ] Kafka producer service class
- [ ] Config в `config/packages/kafka.yaml`
- [ ] Connection health check endpoint
- [ ] Avro schema для base event envelope
- [ ] Unit tests для serialization
**Out of scope**: Actual domain events
**DoD**: Can publish test message to Kafka topic, visible in Kafka UI
**Dependencies**: None — can start immediately
**Risks**: Kafka cluster access, schema registry config

### Slice 2: Workout Event Schema — 1d
**Goal**: Avro schema для workout events готова і зареєстрована
**Scope**:
- [ ] Design `WorkoutCompletedEvent` schema
- [ ] Register в schema registry
- [ ] DTO class `App\Message\Kafka\WorkoutCompletedEvent`
- [ ] Serializer/Deserializer tests
**Out of scope**: Publishing logic
**DoD**: Schema visible в registry, DTO serializes correctly
**Dependencies**: Slice 1
**Risks**: Low — schema design straightforward

### Slice 3: Workout Event Publishing — 2d
**Goal**: Workout completion автоматично публікується в Kafka
**Scope**:
- [ ] `WorkoutCompletedEventPublisher` service
- [ ] Doctrine Event Listener на `Workout::STATUS_COMPLETED`
- [ ] Transactional outbox pattern (optional but recommended)
- [ ] Retry logic з exponential backoff
- [ ] Integration tests
**Out of scope**: Subscription events
**DoD**: Complete workout → event appears in Kafka topic within 5s
**Dependencies**: Slice 1 + Slice 2
**Risks**: Exactly-once delivery, transaction boundaries

### Slice 4: Subscription Event Schema — 1d
**Goal**: Avro schemas для subscription lifecycle
**Scope**:
- [ ] `SubscriptionCreatedEvent` schema
- [ ] `SubscriptionCancelledEvent` schema
- [ ] `SubscriptionRenewedEvent` schema
- [ ] DTOs та tests
**Out of scope**: Publishing logic
**DoD**: All schemas registered, DTOs working
**Dependencies**: Slice 1
**Risks**: Low

### Slice 5: Subscription Event Publishing — 2d
**Goal**: Subscription changes автоматично публікуються
**Scope**:
- [ ] Event listeners для subscription state changes
- [ ] Integration з existing billing flow
- [ ] Idempotency keys для duplicate prevention
- [ ] Integration tests
**Out of scope**: Consumer side
**DoD**: Subscription create/cancel/renew → events in Kafka
**Dependencies**: Slice 4
**Risks**: Integration з billing webhooks complexity

### Slice 6: Monitoring & Alerts — 1d
**Goal**: Можемо бачити і реагувати на проблеми
**Scope**:
- [ ] Prometheus metrics для publish success/failure
- [ ] Grafana dashboard
- [ ] PagerDuty alert для publish failures > threshold
- [ ] Dead letter topic setup
**Out of scope**: Consumer monitoring
**DoD**: Dashboard shows publish rate, alert fires on test failure
**Dependencies**: Slice 3 або Slice 5
**Risks**: Low

## Dependencies Map
```
Slice 1 (Producer) ──► Slice 2 (Workout Schema) ──► Slice 3 (Workout Publish)
         │                                                    │
         │                                                    ▼
         └──────────► Slice 4 (Sub Schema) ──► Slice 5 ──► Slice 6 (Monitoring)
```

## Recommended Sequence
1. Start with: Slice 1 (both engineers, critical path)
2. Parallel: Slice 2 + Slice 4 (one engineer each)
3. Then: Slice 3 (priority) + Slice 5 (parallel)
4. Finally: Slice 6 (one engineer while other starts QA)

## Quick Wins
- Slice 1 can be demoed immediately (message in Kafka UI)
- Slice 2 completion unblocks integration testing

## Deferred Items
- Consumer service (окремий мікросервіс)
- Retry/replay UI для failed events
- Event versioning strategy (v2 schemas)
- Kafka Streams processing

## Estimation Summary
| Slice | Estimate | Dependencies | Risk |
|-------|----------|--------------|------|
| Producer Setup | 2d | None | Medium |
| Workout Schema | 1d | 1 | Low |
| Workout Publish | 2d | 1+2 | Medium |
| Sub Schema | 1d | 1 | Low |
| Sub Publish | 2d | 4 | Medium |
| Monitoring | 1d | 3 or 5 | Low |

Total: ~9 days for 2 engineers ≈ 1.5 sprints with buffer
```

---

## Integration Notes
- **Combines well with**: code-review (для review кожного slice)
- **Often followed by**: sprint planning, task assignment
- **Related agents**: Decomposer, Staff Engineer (для validation)
- **Use before**: starting any task > 3 days

---

## Stack-Specific Decomposition Guidelines

### Symfony / PHP
- **Окремі slices для**:
  - Doctrine migrations (завжди окремо від code!)
  - Service classes та їх interfaces
  - Console commands
  - API endpoints
- **Не розділяй**: Entity + Repository (йдуть разом)

### Doctrine / MySQL
- **Migration-first**: DB schema changes — окремий slice, deploy перед code
- **Backward compatible migrations**: додавай nullable columns, не видаляй одразу
- **Index changes**: окремий slice (можуть бути slow на production)

### RabbitMQ / Symfony Messenger
- **Producer окремо від Consumer**: різні deploy cycles
- **Message schema first**: DTO + serialization тести перед logic
- **Handler slice включає**:
  - Handler class
  - Retry/failure handling
  - Integration test з real queue

### Kafka
- **Schema registration**: окремий slice перед publishing
- **Producer і Consumer**: різні tasks (можуть бути різні сервіси)
- **Idempotency**: виділи як explicit subtask в кожному consumer slice

### Docker / Kubernetes
- **Config changes**: окремий slice (Helm values, ConfigMaps)
- **New service**: container + deployment + service + ingress = один slice
- **Resource changes**: окремий slice з load testing

### Feature Flags
- **Для великих features**: перший slice = feature flag setup
- **Cleanup**: останній slice = remove feature flag (після full rollout)
