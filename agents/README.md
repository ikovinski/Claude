# Agents

## What is it
AI-персони з визначеними упередженнями та сферами експертизи. Кожен агент має свою перспективу, формат виводу та стиль прийняття рішень.

## How to use
1. Прочитати файл агента для завантаження персони та упереджень
2. Застосувати перспективу агента до вашого завдання
3. Дотримуватись структури виводу, визначеної у файлі агента

```
"Review this code" → loads code-reviewer.md
"Architecture decision" → loads staff-engineer.md
```

## Expected result
- Послідовний, опінійований фідбек з конкретної точки зору
- Структурований вивід відповідно до формату агента
- Чітке оголошення: "Applying [Agent Name] with bias: [main bias]"

## Available agents

| Agent | Bias | Use for |
|-------|------|---------|
| `code-reviewer` | Maintainability > cleverness | PR reviews, якість коду |
| `security-reviewer` | Paranoid by default | Security аудити, API review |
| `decomposer` | Vertical slices > horizontal | Декомпозиція задач |
| `planner` | Clarity over speed | Планування імплементації |
| `tdd-guide` | Test first, always | Написання тестів |
| `staff-engineer` | Boring technology wins | Архітектурні рішення |
| `devils-advocate` | Assume nothing works | Челендж рішень |
| `refactor-cleaner` | Less code = less bugs | Очистка dead code |
| `technical-writer` | Audience first, examples > explanations | API docs, feature specs, ADRs (Stoplight) |
