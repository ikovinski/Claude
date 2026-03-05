# Phase 2: DESIGN

## Команда запуску

```
/design {feature-name}
```

**Опції:**
- `--skip-adr` — пропустити ADR (для простих фіч)
- `--skip-api` — пропустити API contracts (якщо немає нових endpoints)
- `--skip-tests` — пропустити test strategy (рідко потрібно)

**Prereq:** Phase 1 (Research) завершена — `.workflows/{feature}/research/research-report.md` існує.

---

## Мета

Прийняти архітектурні рішення на основі Research Report. Створити візуальне представлення архітектури. Задокументувати рішення, ризики, тестову стратегію. Після цієї фази — HUMAN CHECKPOINT для ревью інженерами.

---

## Agent Team

```
team_name: "design-{feature-name}"
```

### Учасники

| Name | Agent | Model | Роль |
|------|-------|-------|------|
| architect | `agents/engineering/design-architect.md` | opus | Архітектура + ADR |
| tester | `agents/engineering/test-strategist.md` | sonnet | Тестова стратегія |

### Процес

```
Input: .workflows/{feature}/research/research-report.md
  │
  ▼
Architect читає Research Report
  ├── Створює Architecture Design:
  │   ├── C4 Component Diagram (зміни)
  │   ├── DataFlow Diagram (новий потік даних)
  │   ├── Sequence Diagram (ключові flows)
  │   └── API Contracts (нові/змінені endpoints)
  ├── Створює ADR:
  │   ├── Контекст (з Research Report)
  │   ├── Рішення + альтернативи
  │   ├── Ризики
  │   └── Наслідки
  └── Передає артефакти Test Strategist
  │
  ▼
Test Strategist читає Research + Architecture
  ├── Визначає стратегію тестування
  ├── Описує тестові кейси
  ├── Визначає що тестувати (unit / functional / integration / e2e)
  └── Визначає API контракти для тестування
  │
  ▼
Quality Gate (architect перевіряє consistency)
  │
  ▼
Output: .workflows/{feature}/design/
```

---

## Output Structure

### `.workflows/{feature}/design/architecture.md`

```markdown
# Architecture Design: {Feature Name}

## Overview
{1-2 речення що змінюється в архітектурі}

## Component Diagram (C4 Level 2)

```mermaid
C4Component
  ...
```

## Data Flow

```mermaid
flowchart LR
  ...
```

## Sequence Diagrams

### Main Flow
```mermaid
sequenceDiagram
  ...
```

### Error Flow (якщо релевантно)
```mermaid
sequenceDiagram
  ...
```

## New/Changed Components

| Component | Type | Action | Responsibility |
|-----------|------|--------|---------------|
| PaymentRefundService | Service | NEW | Handle refund logic |
| PaymentController | Controller | MODIFY | Add refund endpoint |
| RefundEvent | Event | NEW | Trigger async processing |

## API Contracts (якщо є нові endpoints)

### POST /api/v2/payments/{id}/refund
- Request: `RefundRequest {amount: int, reason: string}`
- Response 200: `RefundResponse {id: string, status: string}`
- Response 422: `ValidationError`
- Auth: Bearer token, role: admin
```

### `.workflows/{feature}/design/adr.md`

```markdown
# ADR: {Decision Title}

## Status
Proposed

## Context
{З Research Report — що ми знаємо}

## Decision
{Що вирішили робити}

## Alternatives Considered

### Alternative 1: {name}
- Pros: ...
- Cons: ...

### Alternative 2: {name}
- Pros: ...
- Cons: ...

## Risks
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| ... | high/med/low | high/med/low | ... |

## Consequences
- {Що зміниться в системі}
- {Що потрібно враховувати}
```

### `.workflows/{feature}/design/test-strategy.md`

```markdown
# Test Strategy: {Feature Name}

## Testing Approach
{Unit / Functional / Integration / E2E — що і чому}

## Test Cases

### Unit Tests
| Case | Component | What to Verify |
|------|-----------|---------------|
| Refund calculation | RefundService | Correct amount with fees |
| Partial refund | RefundService | Partial amount validation |

### Functional/API Tests
| Case | Endpoint | Scenario | Expected |
|------|----------|----------|----------|
| Happy path | POST /refund | Valid refund | 200, refund created |
| Invalid amount | POST /refund | Amount > original | 422 |

### Integration Tests (якщо потрібно)
| Case | Systems | What to Verify |
|------|---------|---------------|
| Stripe refund | App → Stripe | Refund processed |

## What NOT to Test
- {Явно вказати що виходить за scope}

## Test Data Requirements
- {Fixtures, factories, seeds}

## Coverage Expectations
- New code: 80%+ line coverage
- Critical paths: 100% branch coverage
```

---

## Quality Gate (контроль якості design)

Architect перевіряє перед завершенням:
- [ ] C4 Component Diagram покриває нові компоненти
- [ ] Хоча б 1 Sequence Diagram для основного flow
- [ ] ADR містить alternatives і risks
- [ ] Test Strategy має конкретні test cases
- [ ] API Contracts (якщо є) мають request/response schemas
- [ ] Все консистентно з Research Report (немає протиріч)
- [ ] Mermaid діаграми синтаксично валідні

---

## HUMAN CHECKPOINT

Після завершення Phase 2, флоу **зупиняється**. Інженер:

1. Ревьюїть `architecture.md` — чи правильне архітектурне рішення
2. Ревьюїть `adr.md` — чи всі ризики враховані
3. Ревьюїть `test-strategy.md` — чи достатньо тестів
4. Approved / Request Changes

Тільки після approve — запускає `/plan {feature-name}`.

---

## Anti-Patterns

1. **Design без Research** — архітектурні рішення на основі припущень, а не фактів
2. **ADR без альтернатив** — якщо є тільки 1 варіант, це не рішення
3. **Тестова стратегія "test everything"** — потрібен фокус на критичних paths
4. **Діаграми заради діаграм** — кожна діаграма повинна відповідати на конкретне питання
5. **Ігнорування async flows** — events/messages часто є найскладнішою частиною
