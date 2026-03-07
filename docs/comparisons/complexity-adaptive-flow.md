# Complexity-Adaptive Flow: аналіз економії токенів

## Контекст

Feature-development flow складається з 6 фаз: Research → Design → Plan → Implement → Docs → PR. Кожна фаза запускає агентів, створює артефакти, витрачає токени. Питання: чи всі фази потрібні для кожної задачі?

## Що було до змін

### Існуючі механізми економії

| Механізм | Де працює | Що економить |
|----------|-----------|-------------|
| `--type hotfix` | `/feature` | Скіпає Design + Plan → одразу Research → Implement → PR |
| `--skip-docs` | `/feature` | Скіпає `/docs-suite` |
| Complexity Assessment (Small) | `/research` | Lead сканує сам, без team створення (економія ~10 хв, ~50K токенів) |
| `--depth light` | `/design` | Легший дизайн (менше діаграм, ADR) |
| `--skip-adr/api/tests/challenge` | `/design` | Скіп окремих артефактів |
| `--skip-review` | `/implement` | Скіп 3 рев'юверів |

### Проблема: розрив між assessment та рішеннями

Research визначає complexity (Small/Medium/Large), але ця інформація **не пропагувалася** далі. Вона впливала лише на кількість scanners у самому Research.

```
/research → визначає "Small, 1 компонент, 3 файли"
           ↓
           записує в research-report.md
           ↓
/design   → все одно запускає ПОВНИЙ дизайн (Architect + Tester + Devil's Advocate)
           ↓
/plan     → все одно робить повну декомпозицію
           ↓
/implement → все одно 3 рев'юери паралельно
```

Для задачі типу "додати поле в ентіті + міграція + тест" (Small) витрачалося:

| Фаза | Час | Токени | Оптимізовано? |
|------|-----|--------|---------------|
| Research | ~5 хв | ~20K | Так (Lead solo) |
| Design | ~20 хв | ~150K | **Ні** |
| Plan | ~10 хв | ~50K | **Ні** |
| Implement | ~25 хв | ~200K | **Ні** |
| **Разом** | **~60 хв** | **~420K** | Задача на 15 хв ручної роботи |

---

## Рішення: propagate complexity через state.json

### Ключова ідея

Research записує `complexity` в `state.json` → наступні фази автоматично адаптуються.

```json
// state.json
{
  "complexity": "small",
  "complexity_reason": "1 component, 3 files, no external deps",
  "phases": { ... }
}
```

### Матриця адаптації

| Complexity | Research | Design | Plan | Implement | Docs |
|-----------|---------|--------|------|-----------|------|
| **Small** | Lead solo | **skip** | **skip** (мінімальний plan для artifact chain) | 1 reviewer (quality) | skip |
| **Medium** | 2 scanners | `--depth light --skip-challenge` | standard | 2 reviewers (security, quality) | standard |
| **Large** | 3-4 scanners | `--depth standard/detailed` | standard | all 3 reviewers | standard |
| **null** | standard | standard | standard | all 3 reviewers | standard |

### Fast track для Small задач

Після Research, якщо complexity = Small, `/feature --resume` пропонує:

```markdown
### Research Complete — Small Task Detected

Complexity: Small (1 component, 3 files)

Suggested flow:
- ~~Design~~ → skip (too small for architecture decisions)
- ~~Plan~~ → skip (single phase, no decomposition needed)
- Implement directly with lightweight review

Run: /implement {feature-name} --phase 1 --reviewers quality

Override: reply "full flow" to proceed with Design → Plan → Implement as usual.
```

### Критерії для skip

| Критерій | Skip Design | Skip Plan | Lighten Implement |
|----------|-------------|-----------|-------------------|
| <= 5 файлів змін | Yes | Yes | Yes (1 reviewer) |
| Немає нових компонентів | Yes (якщо нема ADR-worthy decisions) | -- | -- |
| 1 фаза імплементації | -- | Yes | -- |
| Немає нових API endpoints | skip api-contracts | -- | skip design-reviewer |
| Bug fix без архітектурних змін | Yes | Yes | -- |

---

## Порівняння: до і після

### Small задача (наприклад: додати поле + міграція + тест)

| Фаза | До (full flow) | Після (auto-skip) | Економія |
|------|---------------|-------------------|----------|
| Research | ~20K | ~20K | 0 |
| Design | ~150K | **0** (skip) | ~150K |
| Plan | ~50K | **0** (skip) | ~50K |
| Implement | ~200K | ~80K (1 reviewer) | ~120K |
| **Разом** | **~420K** | **~100K** | **~320K (76%)** |

### Medium задача (наприклад: новий сервіс + 2-3 ендпоінти)

| Фаза | До (full flow) | Після (auto-adapt) | Економія |
|------|---------------|-------------------|----------|
| Research | ~80K | ~80K | 0 |
| Design | ~150K | ~90K (light, no challenge) | ~60K |
| Plan | ~50K | ~50K | 0 |
| Implement | ~200K | ~150K (2 reviewers) | ~50K |
| **Разом** | **~480K** | **~370K** | **~110K (23%)** |

### Large задача (наприклад: нова підсистема, 4+ компонентів)

| Фаза | До | Після | Економія |
|------|---|-------|----------|
| Все | ~600K+ | ~600K+ | 0 (повний flow правильний) |

---

## Порівняння з hotfix

| Аспект | `--type hotfix` (ручний) | Complexity-adaptive (автоматичний) |
|--------|--------------------------|-----------------------------------|
| Хто вирішує | Людина до початку | Research Lead після аналізу |
| Обґрунтування | "Я думаю це просте" | "1 компонент, 3 файли, без зовнішніх залежностей" |
| Рівні | 2 (hotfix або full) | 3 (small, medium, large) |
| Override | Немає (рішення фіксоване) | "full flow" в будь-який момент |
| Review | `--skip-review` (жодних) | 1 reviewer (quality) — мінімальний контроль |
| Ризик пропустити проблему | Вищий (без review) | Нижчий (quality reviewer залишається) |

---

## Архітектура змін

### Що змінено

| Файл | Зміна |
|------|-------|
| `commands/research.md` | Research записує `complexity` + `complexity_reason` в state.json |
| `commands/feature.md` | Нові поля в state.json, секція Complexity-Adaptive Flow, fast track + override |
| `commands/design.md` | Step 0 читає complexity, auto-defaults для depth/skip flags |
| `commands/plan.md` | Step 0 — Small = мінімальний plan (для artifact chain), skip повного планування |
| `commands/implement.md` | Step 0 — auto-defaults для reviewers за complexity |
| `scenarios/delivery/feature-development.md` | Branching flow diagram, Decision 2, 2 нових anti-patterns |

### Data flow

```
/research
  Phase 3: Complexity Assessment
    → визначає Small/Medium/Large
    → пише в .workflows/{feature}/state.json:
        { "complexity": "small", "complexity_reason": "..." }

/feature --resume
  → читає state.json.complexity
  → Small:  пропонує fast track (skip design + plan)
  → Medium: пропонує lighter design
  → Large:  повний flow

/design (якщо запускається)
  Step 0: читає complexity
  → auto-applies: --depth light --skip-challenge (medium)

/plan (якщо запускається)
  Step 0: читає complexity
  → Small: створює мінімальний plan, не запускає planner agent

/implement
  Step 0: читає complexity
  → auto-selects reviewers: quality (small), security+quality (medium), all (large)
```

### Override protocol

Explicit flags завжди перевизначають auto-defaults:
- `/design --depth detailed` → ігнорує complexity auto-default
- `/implement --reviewers security,quality,design` → ігнорує complexity auto-default
- "full flow" відповідь на fast track → скидає skipped фази назад до pending

---

## Anti-patterns

1. **Full flow для small задач** — запускати Design + Plan + 3 reviewers для зміни в 3 файлах = 76% марних токенів
2. **Ігнорування complexity override** — сліпо слідувати auto-skip коли задача має приховану складність (наприклад, "маленька" зміна торкається auth логіки). Завжди перевіряй fast-track пропозицію перед підтвердженням
3. **Ручне визначення hotfix** замість complexity-adaptive flow — людина гірше оцінює складність ніж Research Lead після Quick Reconnaissance
