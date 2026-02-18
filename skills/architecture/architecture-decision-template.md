# Architecture Decision Record (ADR) Template

## ADR Format

```markdown
# ADR-###: [Short Title]

Date: YYYY-MM-DD
Status: [Proposed | Accepted | Rejected | Superseded]
Deciders: [Names]

## Context

What is the issue we're facing? What forces are at play?

## Decision

What decision did we make?

## Consequences

What are the positive and negative consequences?

### Positive
- Benefit 1
- Benefit 2

### Negative
- Drawback 1
- Drawback 2

## Alternatives Considered

What other options did we evaluate?

### Option 1: [Name]
- Pros: ...
- Cons: ...
- Why rejected: ...

### Option 2: [Name]
- Pros: ...
- Cons: ...
- Why rejected: ...
```

## Example ADRs

### ADR-001: Use Kafka for Event Streaming

**Date**: 2024-01-15
**Status**: Accepted
**Deciders**: Backend team, Platform team

#### Context

We need to broadcast workout completion events to multiple consumers:
- Analytics service (metrics)
- Achievement service (badges)
- Social feed service (posts)
- Email service (notifications)

Current RabbitMQ setup requires 4 separate queues with message duplication.

**Scale**: 10K workouts/day, growing to 100K/day in 6 months.

#### Decision

Use **Apache Kafka** for workout events instead of RabbitMQ.

#### Consequences

**Positive**:
- Event log retained for 7 days (replay capability)
- Multiple consumers can read independently
- Higher throughput (100K+ messages/sec)
- Better monitoring (Kafka UI)
- Supports future use cases (CDC, analytics)

**Negative**:
- Additional infrastructure (3 Kafka brokers)
- Team learning curve (3-4 weeks)
- More complex deployment
- Higher cost ($200/month vs $50)

#### Alternatives Considered

**Option 1: Keep RabbitMQ**
- Pros: Team knows it, simple
- Cons: Message duplication, no replay, limited throughput
- Rejected: Doesn't scale to 100K/day

**Option 2: AWS EventBridge**
- Pros: Managed service, no ops
- Cons: Vendor lock-in, expensive at scale ($500/month)
- Rejected: Cost too high

**Option 3: Redis Streams**
- Pros: Simple, in-memory speed
- Cons: Data loss risk, no persistence guarantees
- Rejected: Not durable enough for critical events

---

### ADR-002: Migrate from Monolith to Microservices

**Status**: Rejected

#### Context

Current monolith (400K LOC) becoming hard to maintain:
- Deployment takes 30 min
- One team blocks another
- Scaling issues (one service needs more resources)

#### Decision

**Stay with modular monolith**, extract only critical services.

#### Rationale

**Against full microservices migration**:
- Team size (8 devs) too small
- No distributed systems expertise
- Network latency issues (DB queries)
- Operational complexity increase
- 6-12 month migration time

**Instead**:
1. Refactor monolith into modules (Domain-Driven Design)
2. Extract only:
   - Payment service (PCI compliance)
   - Analytics service (resource-heavy)
3. Keep rest in monolith

#### Consequences

**Positive**:
- Faster to implement (2 months vs 12)
- Less operational overhead
- Team can manage it
- Gradual extraction path

**Negative**:
- Still coupled deployment
- Shared database

---

## ADR Quick Guide

### When to Write ADR

Write ADR for decisions that:
- Are hard to reverse (database choice, language)
- Affect multiple teams
- Have significant cost/time impact
- Set architectural direction

### When NOT to Write ADR

Don't write for:
- Trivial choices (library for date formatting)
- Temporary solutions
- Team-internal decisions
- Obvious choices

### ADR Numbering

```
ADR-001: Use PostgreSQL for main database
ADR-002: API versioning strategy
ADR-003: Authentication with JWT
```

Sequential numbering, never reuse numbers.

### ADR Status Lifecycle

```
Proposed → [Accepted | Rejected]
           ↓
        Accepted → [Deprecated | Superseded]
```

**Proposed**: Under discussion
**Accepted**: Implemented
**Rejected**: Not doing this
**Deprecated**: No longer recommended
**Superseded**: Replaced by ADR-XXX

### Storage

```
docs/adr/
├── 001-use-postgresql.md
├── 002-api-versioning.md
├── 003-authentication-jwt.md
└── README.md  (index of all ADRs)
```

### Decision Drivers

Consider these forces:

| Driver | Questions |
|--------|-----------|
| **Cost** | Upfront cost? Ongoing cost? |
| **Time** | How long to implement? |
| **Risk** | What can go wrong? |
| **Team** | Do we have skills? |
| **Scale** | Will it handle growth? |
| **Maintainability** | Easy to change later? |
| **Vendor Lock-in** | Can we switch? |

### Lightweight ADR

For smaller decisions, use this format:

```markdown
## Decision: Use Doctrine ORM

**Why**: Type safety, migrations, no raw SQL
**Trade-off**: Slight performance overhead vs raw SQL
**Alternatives**: Raw PDO (too low-level), Eloquent (Laravel-specific)
```

---

## Example: Choose Message Queue

### Context
Need async job processing for:
- Email sending (100/min)
- Workout sync (50/min)
- Report generation (10/min)

### Options

| Feature | RabbitMQ | Kafka | Redis | SQS |
|---------|----------|-------|-------|-----|
| Throughput | 10K/sec | 100K/sec | 100K/sec | 3K/sec |
| Persistence | Yes | Yes | Optional | Yes |
| Replay | No | Yes | Limited | No |
| Ops complexity | Medium | High | Low | None |
| Cost | $50/mo | $200/mo | $30/mo | Pay-as-go |
| Team knowledge | High | None | High | Medium |

### Decision: RabbitMQ

**Why**:
- Sufficient throughput for our scale
- Team already knows it
- Lower ops complexity than Kafka
- Good enough persistence

**When to reconsider**:
- When we hit 10K jobs/sec
- When we need event replay
- When we add more async consumers (>10)
