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
