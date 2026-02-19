# Як Працюють Scenarios

## Огляд

**Scenarios ≠ Slash Commands**. Scenarios — це керовані багатофазні workflows, які комбінують кількох агентів для складних процесів прийняття рішень.

---

## Тригери (Автоматичні)

Scenarios активуються через **природну мову**, не через slash команди:

| Ви кажете... | Активується сценарій |
|--------------|---------------------|
| "Decompose this feature into tasks" | Feature Decomposition |
| "Should we rewrite this module?" | Rewrite Decision |
| "Break down this epic" | Feature Decomposition |
| "Rebuild vs refactor?" | Rewrite Decision |

**Без `/` команди** — просто опишіть потребу.

---

## Структура Scenario

```
Scenario
├── Phase 1: [Lead: Agent A]
│   ├── Steps 1-5
│   └── Output: Document A
├── Phase 2: [Lead: Agent B]  ← Перемикання контексту!
│   ├── Steps 1-3
│   └── Output: Document B
├── Decision Point
│   └── [User input required]
└── Phase 3: [Lead: Agent A]
    └── Final Output
```

Кожен scenario складається з:
1. **Кількох фаз** з чіткими цілями
2. **Перемикання агентів** між фазами (різні перспективи)
3. **Точок рішень** що потребують вашого input
4. **Структурованих deliverables** на кожному кроці

---

## Наявні Scenarios

### 1. Feature Decomposition

**Мета**: Розбити epic/feature на deliverable tasks (1-3 дні кожна)

**Ланцюжок виконання**:
```
Phase 1: Decomposer
  ↓ Scope Understanding
  ↓ Clarifying questions

Phase 2: Decomposer
  ↓ Initial decomposition
  ↓ Vertical slices

Phase 3: Staff Engineer
  ↓ Technical validation
  ↓ Reality check estimates

Phase 4: Decomposer
  ↓ Incorporate feedback
  ↓ Final decomposition
```

**Skills використовує**:
- `planning/epic-breakdown`
- `planning/vertical-slicing`
- `planning/planning-template`
- Auto: `{project}-patterns`

**Deliverables**:
- Scope document
- Decomposed slices (кожен: scope, DoD, estimate, dependencies)
- Dependencies map
- Execution strategy
- MVP definition

**Тривалість**: 30-90 хвилин

---

### 2. Rewrite Decision

**Мета**: Прийняти обґрунтоване рішення: rewrite vs refactor vs fix

**Ланцюжок виконання**:
```
Phase 1: Staff Engineer
  ↓ Problem validation
  ↓ Data collection

Phase 2: Staff Engineer
  ↓ Alternative analysis
  ↓ Options comparison

Phase 3: Devil's Advocate
  ↓ Challenge assumptions
  ↓ Risk assessment
  ↓ Pre-mortem

Phase 4: Staff Engineer
  ↓ Synthesize findings
  ↓ Make recommendation
  ↓ ADR (Architecture Decision Record)
```

**Skills використовує**:
- `architecture/architecture-decision-template`
- `architecture/decision-matrix`
- `risk-management/risk-assessment`
- Auto: `{project}-patterns`

**Deliverables**:
- Problem statement
- Options comparison table
- Risk assessment
- ADR document
- Phased plan (якщо схвалено)

**Тривалість**: 1-2 години

---

## Як Використовувати Scenarios

### Приклад 1: Feature Decomposition

```
Ви: "Need to decompose 'Add workout sharing to social feed' feature"

Система:
1. Завантажує Decomposer agent
2. Перевіряє project skill (wellness-backend-patterns/)
3. Оголошує: "Starting Feature Decomposition scenario"
4. Проходить 4 фази
5. Видає final decomposition
```

### Приклад 2: Rewrite Decision

```
Ви: "Should we rewrite the sync engine? It's slow and hard to maintain"

Система:
1. Завантажує Staff Engineer + Devil's Advocate
2. Оголошує: "Starting Rewrite Decision scenario"
3. Аналізує проблему
4. Challenge assumptions
5. Видає ADR з рекомендацією
```

---

## Ключові Особливості

### 1. Перемикання Агентів

Кожна фаза використовує **різних агентів** з їхніми біасами:
- **Decomposer**: "Vertical slices > horizontal layers"
- **Staff Engineer**: "Boring technology wins"
- **Devil's Advocate**: "Assume nothing works"

Це забезпечує множинні перспективи на складні рішення.

### 2. Decision Points

Складні scenarios включають **checkpoints** для вашого input:
```
Phase 2 completed.

Decision: Should we proceed with rewrite or fix existing code?
[Waiting for your input...]
```

### 3. Deliverables на Кожному Кроці

Кожна фаза видає **конкретний документ**:
- Scope document
- Decomposition table
- Risk assessment
- Architecture Decision Record (ADR)

### 4. Автоматичне Завантаження Skills

Scenarios **автоматично** підтягують потрібні skills:
- Загальні skills (epic-breakdown, decision-matrix)
- Проєктні skills ({project}-patterns/)

---

## Scenarios vs Slash Commands

| | Slash Commands | Scenarios |
|---|----------------|-----------|
| **Виклик** | `/plan`, `/review` | Природна мова |
| **Агенти** | 1 агент | Кілька агентів |
| **Фази** | 1 фаза | 3-4 фази |
| **Тривалість** | 5-15 хв | 30-90 хв |
| **Output** | Один документ | Кілька deliverables |
| **Decision points** | Ні | Так (потрібен user input) |
| **Перемикання контексту** | Ні | Так (між агентами) |

---

## Коли Використовувати Scenarios

| Ситуація | Використай |
|----------|------------|
| Новий epic без breakdown | Feature Decomposition scenario |
| "Легше переписати" discussion | Rewrite Decision scenario |
| Простий code review | `/code-review` command |
| Простий implementation plan | `/plan` command |
| Потрібна швидка відповідь | Один агент |
| Складне рішення з ризиками | Scenario |

**Правило**: Scenarios для **складних багатокрокових рішень**. Commands для **одноразових дій**.

---

## Що Робить Scenarios Потужними

### 1. Структурований Процес
Ніяких ad-hoc рішень — слідуєте перевіреному workflow.

### 2. Множинні Перспективи
Різні агенти challenge припущення один одного.

### 3. Forced Checkpoints
Неможливо пропустити критичні кроки мислення.

### 4. Задокументоване Reasoning
Кожна фаза створює artifacts для майбутнього reference.

### 5. Проєктний Контекст
Автоматично завантажує проєктні паттерни та конвенції.

---

## Внутрішня Механіка

### Як Система Розпізнає Scenario

```yaml
# В кожному scenario є metadata
trigger: "Should we rewrite this?" question from team
participants:
  - Staff Engineer (lead)
  - Devil's Advocate (challenger)
```

Коли ви говорите щось схоже на trigger phrase, система:
1. Розпізнає pattern у вашому запиті
2. Завантажує відповідний scenario file
3. Перевіряє metadata для списку агентів
4. Ініціює Phase 1

### Що Відбувається Між Фазами

```
Phase 1: Decomposer active
  → Generates: scope_document.md
  → Loads: skills/planning/*

[Context Switch]

Phase 2: Staff Engineer active
  → Receives: scope_document.md
  → Applies bias: "Boring technology wins"
  → Generates: validation_report.md
```

Кожна фаза:
- **Отримує output** попередньої фази
- **Застосовує свої biases**
- **Використовує свої skills**
- **Генерує власний deliverable**

---

## Приклад Реального Виконання

### Input
```
"Decompose feature: Add Apple Health integration"
```

### Execution Flow

**Phase 1: Scope Understanding (Decomposer)**
```
Loading: agents/technical/feature-decomposer.md
Loading: skills/wellness-backend-patterns/SKILL.md
Applying bias: "Vertical slices > horizontal layers"

Questions:
- Which metrics to sync? (steps, workouts, heart rate?)
- Offline support needed?
- Historical data import?

Output: scope_document.md
```

**Phase 2: Initial Decomposition (Decomposer)**
```
Input: scope_document.md
Applying skill: planning/vertical-slicing

Slices identified:
1. Basic auth + permission request (2d)
2. Steps sync (1d)
3. Workouts sync (2d)
4. Heart rate sync (2d)
5. Historical import (3d) — can defer

Output: decomposition_draft.md
```

**Phase 3: Technical Validation (Staff Engineer)**
```
Switching to: agents/technical/architecture-advisor.md
Input: decomposition_draft.md
Applying bias: "Boring technology wins"

Hidden complexity found:
- Apple Health API rate limits
- Background sync iOS restrictions
- Health data PII compliance

Estimate adjustment: +2d for compliance review

Output: validation_report.md
```

**Phase 4: Finalization (Decomposer)**
```
Switching back to: agents/technical/feature-decomposer.md
Input: decomposition_draft.md + validation_report.md

Final slices:
1. Auth + permissions (2d)
2. Compliance review (2d) ← new from validation
3. Steps sync (1d)
4. Workouts sync (2d)
5. Heart rate sync (2d)
Total: 9d (2 engineers, parallel tracks)

Deferred to v2:
- Historical import (3d)

Output: final_decomposition.md
```

---

## Відмінності від Звичайного Agent Call

| Аспект | Звичайний Agent Call | Scenario |
|--------|---------------------|----------|
| Тривалість | Одна сесія | Кілька фаз |
| Зміна perspective | Немає | Так, між фазами |
| Deliverables | 1 документ | N документів (по 1 на фазу) |
| User checkpoints | Опціонально | Обов'язково в decision points |
| Skills loading | Один раз | Може змінюватись між фазами |
| Context retention | Linear | Cumulative (наступна фаза бачить все попереднє) |

---

## Best Practices

### 1. Чіткий Тригер
```
✅ GOOD: "Need to decide: rewrite workout sync or refactor?"
❌ BAD: "Workout sync has issues"
```

Чіткий тригер → правильний scenario → краща відповідь.

### 2. Довіряйте Процесу
Не намагайтеся пропустити фази. Кожна фаза додає value:
- Decomposer бачить "що"
- Staff Engineer бачить "як"
- Devil's Advocate бачить "що може зламатись"

### 3. Відповідайте на Decision Points
Коли scenario питає — дайте конкретну відповідь. Це критичні точки.

### 4. Зберігайте Deliverables
Кожна фаза генерує документ. Зберігайте їх:
```
docs/decisions/
  ├── 2026-02-17-rewrite-sync-engine/
  │   ├── problem-statement.md
  │   ├── alternatives.md
  │   ├── risk-assessment.md
  │   └── adr.md
```

---

## Коли НЕ Використовувати Scenario

❌ **Не використовуйте scenario якщо:**

1. **Питання просте**
   - "How does this function work?" → просто запитайте

2. **Часу мало**
   - Scenario = 30-90 хв
   - Якщо потрібна швидка відповідь → slash command

3. **Рішення вже прийняте**
   - "We will rewrite, help plan" → `/plan` command
   - Scenario для "should we rewrite?" (ще не вирішили)

4. **Немає складності**
   - "Add a button" → не потребує scenario

✅ **Використовуйте scenario коли:**

- Рішення **має наслідки** (architecture, timelines, resources)
- Потрібно **challenge assumptions**
- Є **невизначеність** у scope чи approach
- Stakeholders **не aligned**

---

## Розширення Scenarios

Ви можете додати власні scenarios:

```yaml
# scenarios/your-domain/your-scenario.md
name: api-versioning-decision
category: technical-decisions
trigger: "How to version this API?"
participants:
  - Staff Engineer (options analysis)
  - Code Reviewer (breaking changes check)
  - Devil's Advocate (migration risks)
skills:
  - architecture/api-design
  - architecture/versioning-strategies
```

Система автоматично підхопить новий scenario при правильному trigger phrase.

---

## Пов'язана Документація

- [Agents Overview](../../agents/README.md) - Розуміння agent biases
- [Skills System](../../skills/README.md) - Як завантажуються skills
- [Feature Decomposition Scenario](../../scenarios/delivery/feature-decomposition.md)
- [Rewrite Decision Scenario](../../scenarios/technical-decisions/rewrite-decision.md)
- [Commands Overview](../../commands/README.md) - Відмінність від slash commands
