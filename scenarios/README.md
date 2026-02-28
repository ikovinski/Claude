# Scenarios

## What is it
Багатокрокові workflows, які комбінують кількох агентів та точки прийняття рішень. Scenarios проводять через складні процеси з чіткими фазами та checkpoints.

## How to use
Scenarios активуються складними запитами:

```
"Decompose this feature into tasks" → Feature Decomposition scenario
"Should we rewrite this module?" → Rewrite Decision scenario
```

Кожен scenario має:
1. Кілька фаз
2. Перемикання агентів між фазами
3. Точки рішень, що потребують input користувача
4. Чіткі deliverables на кожному кроці

## Expected result
- Керований багатокроковий процес
- Оголошення фаз та відстеження прогресу
- Структуровані deliverables (списки задач, decision matrices тощо)
- Затвердження користувача в ключових точках рішень

## Available scenarios

| Scenario | Phases | Use for |
|----------|--------|---------|
| `feature-decomposition` | Analysis → Breakdown → Validation | Декомпозиція epics на tasks |
| `rewrite-decision` | Assessment → Options → Recommendation | Рішення rebuild vs refactor |
| `documentation-suite` | Scan → Analyze → Compile → Cross-Review → Index | Повна документація з codebase (3 агенти, team-based) |
| `dev-workflow/1-research` | Decompose → Scan (parallel) → Aggregate | AS-IS аналіз кодової бази (3 агенти, team-based) |
| `dev-workflow/2-design` | Analyze → Contracts (parallel) → Compile → Quality Gate | Технічний дизайн + ADR + API contracts (2 агенти, team-based) |
| `dev-workflow/3-plan` | Validate → Synthesize → Plan | Розбиття дизайну на фази реалізації (1 агент) |
| `dev-workflow/4-implement` | Per-phase: TDD → Review → Fix loop | Реалізація коду з TDD + internal review (2 агенти, team-based) |
| `dev-workflow/5-review` | Review (parallel) → Compile | Повний code review + security audit (2 агенти, team-based) |
| `dev-workflow/6-pr` | Prepare → Branch → Commit → PR Draft | Створення гілки, комітів, PR description (bash/gh) |
