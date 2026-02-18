# Decision Matrix

## Weighted Decision Matrix

Use when comparing multiple options with different criteria.

### Template

| Option | Criterion 1<br>(weight: X) | Criterion 2<br>(weight: Y) | ... | **Total** |
|--------|---------------------------|---------------------------|-----|-----------|
| Option A | score × weight | score × weight | ... | sum |
| Option B | score × weight | score × weight | ... | sum |

**Scoring**: 1-10 (1 = poor, 10 = excellent)
**Weight**: 1-5 (1 = nice-to-have, 5 = critical)

### Example: Choose Database

**Criteria weights**:
- Performance (5) — critical for API latency
- Developer Experience (4) — team productivity
- Cost (3) — budget constrained
- Scalability (4) — will grow
- Maturity (2) — nice but not critical

| Database | Performance<br>(5) | DX<br>(4) | Cost<br>(3) | Scale<br>(4) | Maturity<br>(2) | **Total** |
|----------|----------|-----|------|-------|----------|-------|
| PostgreSQL | 8 × 5 = 40 | 9 × 4 = 36 | 10 × 3 = 30 | 8 × 4 = 32 | 10 × 2 = 20 | **158** ✅ |
| MongoDB | 9 × 5 = 45 | 7 × 4 = 28 | 8 × 3 = 24 | 9 × 4 = 36 | 7 × 2 = 14 | **147** |
| MySQL | 7 × 5 = 35 | 8 × 4 = 32 | 10 × 3 = 30 | 7 × 4 = 28 | 9 × 2 = 18 | **143** |

**Winner**: PostgreSQL (best overall fit)

---

## Pros/Cons Matrix

Simple comparison without weights.

### Example: Microservices vs Monolith

| Aspect | Monolith | Microservices |
|--------|----------|---------------|
| **Pros** | • Simple deployment<br>• Easy debugging<br>• No network overhead<br>• Single codebase | • Independent scaling<br>• Technology flexibility<br>• Team autonomy<br>• Isolated failures |
| **Cons** | • Coupled deployment<br>• Single point of failure<br>• Limited scaling | • Ops complexity<br>• Network latency<br>• Distributed debugging<br>• Data consistency |
| **Best for** | Small team, simple domain | Large team, complex domain |

---

## Decision Tree

For sequential decisions.

```
Choose message queue
├─ Need event replay?
│  ├─ Yes → Kafka
│  └─ No → ↓
├─ Need high throughput (>10K/sec)?
│  ├─ Yes → Kafka
│  └─ No → ↓
├─ Team knows RabbitMQ?
│  ├─ Yes → RabbitMQ ✅
│  └─ No → Consider AWS SQS
```

---

## Trade-off Sliders

Visualize trade-offs between competing goals.

### Example: API Design

```
Flexibility ●---------○ Simplicity
(Many options)         (Few, opinionated)

Performance ○------●-- Developer Experience
(Optimized)            (Convenient)

Consistency ●------○-- Speed
(Perfect data)         (Eventually consistent)
```

**Decision**: Prioritize Simplicity, DX, and Speed for this API.

---

## Must-Have vs Nice-to-Have

### Example: New Feature Requirements

**Must-Have** (MVP):
- ✅ User can create workout
- ✅ User can view workout history
- ✅ Basic calorie tracking

**Nice-to-Have** (v2):
- ⭕ Advanced analytics
- ⭕ Social sharing
- ⭕ Export to PDF

**Won't Have** (out of scope):
- ❌ Meal planning
- ❌ Personal trainer matching

---

## Risk vs Value Matrix

Plot features/options by risk and value.

```
High Value
    ↑
    │  Low Priority  │  High Priority
    │  (do later)    │  (do first!)
    │───────────────────────────────
    │  Avoid         │  Medium Priority
    │  (skip it)     │  (careful)
    │
    └────────────────────────────→ High Risk
```

**Example**:
- **High Priority**: Payment integration (high value, low risk)
- **Medium**: Real-time notifications (high value, high risk)
- **Low**: Export to Excel (low value, low risk)
- **Avoid**: Custom analytics engine (low value, high risk)

---

## Decision Framework Questions

### Reversibility
- How hard to undo this decision?
- Can we change it later?
- What's the exit cost?

**Rule**: Make reversible decisions quickly, irreversible ones carefully.

### Information Availability
- Do we have enough data?
- What's the cost of getting more data?
- Can we do a small experiment?

**Rule**: If decision is reversible and we lack data → experiment.

### Urgency
- When do we need to decide?
- What's the cost of waiting?
- What's the cost of deciding wrong?

**Rule**: Don't make urgent decisions on irreversible choices.

---

## Example: Rewrite vs Refactor

### Decision Matrix

| Criterion | Weight | Rewrite | Refactor |
|-----------|--------|---------|----------|
| Time to market | 5 | 3 (6 months) | 9 (2 months) |
| Code quality | 4 | 10 (clean) | 6 (improved) |
| Risk | 5 | 4 (new bugs) | 8 (safe) |
| Learning curve | 3 | 5 (new patterns) | 9 (familiar) |
| **Total** | | **3×5 + 10×4 + 4×5 + 5×3 = 90** | **9×5 + 6×4 + 8×5 + 9×3 = 136** ✅ |

**Decision**: Refactor (less risk, faster, known patterns)

### Trade-offs
- **Refactor**: Faster, safer, but code not perfect
- **Rewrite**: Perfect code, but risky and slow

**When to reconsider**: If code is truly unmaintainable (>70% needs change).
